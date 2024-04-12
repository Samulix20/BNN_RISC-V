import os
import sys

# Reduce TF logs
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

# set base dir to repository root
repo_base_dir = os.path.dirname(os.path.dirname(
    os.path.abspath(__file__)
))

results_base_dir = f'{repo_base_dir}/tmp/'

# add paths
sys.path.append(f'{repo_base_dir}/ext/')
sys.path.append(f'{repo_base_dir}/libs/')
sys.path.append(f'{repo_base_dir}/test/lib/')
sys.path.append(f'{repo_base_dir}/test/')

from riszeto.riszeto import RiscvCpu
from bnnc.bnnc_env import BnncEnviroment
from hyperspectral import hyperspectral_bnn_models

# Set path to BNN ext module to use same config
os.chdir(f'{repo_base_dir}/ext/BNN_for_hyperspectral_datasets_analysis')

# Simulate using diferent gen_types
def riscv_hyper_sim(gen_type):
    bnnc_env = BnncEnviroment()
    # Only one forward pass to count cycles
    bnnc_env.mc_passes = 1

    rv_cpu = RiscvCpu()
    # Increase stack size for simulation
    rv_cpu.ghdl_stack_size = 3000
    rv_cpu.build_cpu(quiet=True)

    for name in hyperspectral_bnn_models.model_list:
        # Create dir for rv model
        rv_model_dir = f'{repo_base_dir}/tmp/RISC-V/{name}'
        os.makedirs(rv_model_dir, exist_ok=True)

        # Load model and dataset
        model = hyperspectral_bnn_models().get_model(name)
        data, _ = hyperspectral_bnn_models().get_test_data(name)
        # Get only first image
        data = data[:1]

        # Generate model sources
        bnnc_env.gen_type = gen_type
        bnnc_env.gen_model_src(model, rv_model_dir)
        bnnc_env.gen_dataset_src(data, rv_model_dir)

        # Set RISCV main in C src folder
        os.system(f"""
            cp {repo_base_dir}/test/lib/main_rv.c {rv_model_dir}/main.c
        """)

        # Run simulation
        asm = rv_cpu.set_program(rv_model_dir).compile_program(quiet=True)
        with open(f'{rv_model_dir}/code.dump', 'w', encoding="utf-8") as f:
            for line in asm:
                f.write(line)

        rv_cpu.generate_ram_files()
        result = rv_cpu.run(quiet=True).readlines()
        print(f'{name} Instruction', result[-1])


def main():
    print("CLT")
    riscv_hyper_sim(0)
    print("UNIFORM")
    riscv_hyper_sim(1)
    # Uncomment only if custom gcc available
    #print("CUSTOM INSTRUCTION")
    #riscv_hyper_sim(2)


# MAIN
if __name__ == '__main__':
    main()
