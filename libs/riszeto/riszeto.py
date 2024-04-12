import os
import tempfile
import subprocess
import re
import io
import copy

from math import log2, ceil

from elftools.elf.elffile import ELFFile

default_vhdl_cpu_config_template = """
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

package test_config_pkg is

    -- Default/Example Generic constants
	constant ram_addr_bits : integer := {ram_addr_bits};
	constant print_peripheral_register_addr : std_logic_vector := {print_addr};
	constant addr_mtime : std_logic_vector := {mtimer_addr};
	constant addr_mtimecmp : std_logic_vector := std_logic_vector(unsigned(addr_mtime) + 8);

end package test_config_pkg;
"""

def write_vhdl_memory(ram, data, path):
    """
        Creates a txt file with the ram banks contents

            Parameters:
                ram (int): Ram bank Id [0-3]
                data (list): List of bank contents as integers
                path (Directory Path): Path to save ram{ram}_content.txt
    """
    with open(f'{path}/ram{ram}_content.txt', "w", encoding="utf8") as ram_file:
        ram_code = ""
        addr = 0
        for j in data:
            ram_code += f'{j:02x}\n'
            addr += 1
        ram_file.writelines(ram_code)

def bank_divide(efile):
    """
        Divides the words of the load segments of efile into 4 list of bytes

            Parameters:
                efile (Path to .elf file): Ram bank Id [0-3]
            
            Returns:
                _rams (list): List of list of bytes
                    Shape 2D (4, number of bytes)
                program_size (int): The number of bytes of the load segments
    """
    with open(efile, 'rb') as fil:
        program_size = 0
        elf_file = ELFFile(fil)
        seg_data = elf_file.get_segment(1).data()
        _rams = [[], [], [], []]
        j = 0
        print_out_ram = ""
        for byt in seg_data:
            _rams[j].append(byt)
            print_out_ram = f'{byt:02x}' + print_out_ram
            j += 1
            program_size += 1
            if j == 4:
                j = 0
                #print(f'0x{print_out_ram},')
                print_out_ram = ""
        return _rams, program_size

class RiscvCpu():

    def __init__(self, gsrc_path=None, bsp_path=None):

        lib_dir = os.path.dirname(os.path.abspath(__file__))

        if bsp_path is None:
            self.bsp_path = f'{lib_dir}/riscv_bsp'
        else:
            self.bsp_path = bsp_path

        if gsrc_path is None:
            gsrc_path = f'{lib_dir}/vhdl_src'

        self.bsp_config = {
            "MTIMER_BASE_ADDR": "0x10500000",
            "PRINT_REG_ADDR": "0x10400000",
            "STACK_SIZE": f'{1024 * 10}'
        }

        self.vhdl_cpu_config_template = default_vhdl_cpu_config_template
        self.vhdl_config = {
            "MEM SIZE KB": 1024 * 1,
            "print_addr": 'x"10400000"',
            "mtimer_addr": 'x"10500000"'
        }

        # Default stack size in kB, if simulation fails increase
        self.ghdl_stack_size = 500

        # Create tmp dir
        self.tmp_dir = tempfile.TemporaryDirectory(prefix="riszeto_cpu_")
        os.system(f"""
            cp -r {gsrc_path} {self.tmp_dir.name}/gsrc
        """)

    def _check_bash_error(self, r, err_path):
        """
            Params: 
                r: error code from bash execution
                err_path: path to stderr dump file
        """
        if r != 0:
            txt_error = ""
            with open(err_path, "r", encoding="utf-8") as f:
                for l in f:
                    txt_error += l
            raise(Exception(f"Found error executing bash, code {r} error:\n{txt_error}"))

    def _terminal(self, sim_proc, quiet):
        """
            Params: 
                sim_proc: Popen ghdl simulation process
                quiet: if true silences realtime output
            Returns:
                simulation output stringIO object
        """

        # Regular expresion for printchars
        print_re = re.compile("^\./peripherals/VHDL_PRINT\.vhd.*: ([0-9]+)$")

        output_str = ""
        raw_output = ""

        if not quiet:
            print("--- Output TERM ---")

        # Main read from process stdout loop
        while True:
            # Check if process died
            errc = sim_proc.poll()
            if errc is not None:
                raise Exception(f"Error ocurred during simulation, code {errc} error:\n{raw_output}")

            # Get line
            line = sim_proc.stdout.readline().decode()
            raw_output += line

            # Filter for terminal printchars
            re_result = print_re.match(line)
            if re_result:
                v = int(re_result.group(1))

                # If termchar found kill the simulation
                if v == 4:
                    sim_proc.kill()
                    break
                v = chr(v)
                output_str += v

                if not quiet:
                    print(v, end='')

        if not quiet:
            print("-------------------")

        return io.StringIO(output_str)

    def build_cpu(self, quiet=False):
        """
            Params:
                cpu_config: dictionary with values to use in template (default_cpu_config)
                cpu_config_template: template for vhdl test_config (default_config_template)
                quiet: if true silences config info prints
        """

        aux_vhdl_config = copy.deepcopy(self.vhdl_config)

        self.cpu_ram_size_kb = aux_vhdl_config.pop("MEM SIZE KB")
        cpu_ram_addr_bits = int(ceil(log2(self.cpu_ram_size_kb * 1024)))

        if not quiet:
            print('--- MEMORY CONFIG ---')
            print(f'{"SIZE": >20} {self.cpu_ram_size_kb} kB')
            print(f'{"TOP ADDR": >20} 0x{self.cpu_ram_size_kb * 1024 :08X}')
            print(f'{"BITS ADDR": >20} {cpu_ram_addr_bits}')
            print('---------------------')

            print()

            print('--- EXTRA CONFIG ---')
            for param in aux_vhdl_config:
                print(f'{param: >20} {aux_vhdl_config[param]}')
            print('--------------------')

        aux_vhdl_config["ram_addr_bits"] = cpu_ram_addr_bits

        # Set config
        with open(f'{self.tmp_dir.name}/gsrc/src/pkg/test_config_pkg.vhd', 'w') as f:
            f.writelines(self.vhdl_cpu_config_template.format(**aux_vhdl_config))

        # Build cpu using ghdl
        err = os.system(f"""
            cd {self.tmp_dir.name} &&\
            make -s -C {self.tmp_dir.name}/gsrc RV_ID=riszeto 2>&1 > errors.log
        """)
        self._check_bash_error(err, f'{self.tmp_dir.name}/errors.log')

        return self

    def set_program(self, csrc_path):
        """
            Params: 
                csrc_path: path to C/C++ source of program
        """
        os.system(f"""
            rm -rf {self.tmp_dir.name}/csrc &&\
            mkdir {self.tmp_dir.name}/csrc &&\
            cp -r {self.bsp_path} {self.tmp_dir.name}/csrc/riscv &&\
            mv {self.tmp_dir.name}/csrc/riscv/make/* {self.tmp_dir.name}/csrc &&\
            cp -r {csrc_path}/* {self.tmp_dir.name}/csrc
        """)
        return self

    def compile_program(self, is_cpp=False, olevel=3, quiet=False):
        """
            Params: 
                is_cpp: if true uses C++ makefiles instead of C
                olevel: gcc omptimization level -O{olevel}
                bsp_config: dict with defines for bsp config.h (default_bsp_config)
                quiet: if true silences compilation info
            Returns:
                a file object with the compiled assembly
        """

        _quiet = "> /dev/null" if quiet else ""

        if is_cpp:
            c_target = "c_libs"
            cpp_target = "cpp_all"
        else:
            c_target = "c_all"
            cpp_target = "cpp_skip"

        tmp_bsp_config = copy.deepcopy(self.bsp_config)
        tmp_bsp_config["MEM_SIZE"] = f'{self.cpu_ram_size_kb}k'

        bsp_str = ""
        for key in tmp_bsp_config:
            bsp_str += f"-D {key}={tmp_bsp_config[key]} "

        err = os.system(f"""
            cd {self.tmp_dir.name}/csrc &&\
            make -s -f c.mk {c_target} BSP_CONFIG="{bsp_str}" BUILD_DIR=build OLEVEL={olevel} {_quiet} 2> errors.log &&\
            make -s -f cpp.mk {cpp_target} BSP_CONFIG="{bsp_str}" BUILD_DIR=build OLEVEL={olevel} {_quiet} 2> errors.log
        """)
        self._check_bash_error(err, f'{self.tmp_dir.name}/csrc/errors.log')

        return open(f"{self.tmp_dir.name}/csrc/main.dump", "r")

    def generate_ram_files(self, elf_path=None):
        """
            Params: 
                elf_path: if present generate rams from its contents if not
                    use tmpdir build file
            Returns:
                program size in bytes
        """
        if elf_path is None:
            elf_path = f'{self.tmp_dir.name}/csrc/build/main.elf'

        rams, total_ram_size = bank_divide(elf_path)
        for i in range(4):
            write_vhdl_memory(i, rams[i], f'{self.tmp_dir.name}/gsrc/build')

        return total_ram_size

    def run(self, quiet=False):
        """
            Params: 
                quiet: if true silences realtime output of simulation
            Returns:
                simulation output stringIO object
        """

        # Run simulation
        sim_proc = subprocess.Popen(
            [
                "./riscv_riszeto",
                f"--max-stack-alloc={self.ghdl_stack_size}",
                "--unbuffered"
            ],
            cwd=f'{self.tmp_dir.name}/gsrc/build',
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )

        # Format output as terminal and kill process
        output = self._terminal(sim_proc=sim_proc, quiet=quiet)

        return output
