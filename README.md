# C Integer only BNN inference for RISC-V

This repository contains code for training different bayesian neural networks, perform optimized integer only inference on a simulated RISC-V CPU and analyze the obtained results.

This is the code of the paper *Accelerating Bayesian Neural Networks on low-power edge RISC-V processors*.

# Requirements

- The `requirements.txt` file contains the Python packages required. Using a virtual python environment is recommended.
- GHDL 4.0.0 with LLVM backend.
- RISC-V GNU Compiler Toolchain with support for the following flags `-march=rv32g -mabi=ilp32 -mno-div`. A special patched version of the compiler is required for running some experiments.

## Custom RISC-V instructions

The RISC-V cpu code of this repository has support for 2 new instructions for sampling a standard gaussian distribution. A patched version of the GNU Compiler Toolchain is required to run the last [RISC-V Simulation](#risc-v-simulation) tests, those are commented out on the test script and can be uncommented if the modified toolchain is present.

The `custom_riscv_gcc` directory contains the patched files of binutils. Those files must substitute `binutils/opcodes/riscv-opc.c` and `binutils/include/opcodes/riscv-opc.h`.

# Components

The directory `ext` contains external linked github repositories. The directory `libs` contains the code of the libraries of this work

- [BNN_for_hyperspectral_datasets_analysis](https://github.com/universidad-zaragoza/BNN_for_hyperspectral_datasets_analysis). Python code to train bayesian neural networks for some of the most widely used open hyperspectral imaging datasets.

- `bnnc`. Python code to port Keras Tensorflow Probability models to C integer only inference code.

- `riszeto`. Python code that helps running simulations and compile C code for a RISC-V CPU written in VHDL. The simulations are run using GHDL.

# Tests

The `test` directory contains the python scripts to run the paper experiments. The results are stored in a directory `tmp` that will be created in this repository base directory.

### Hyperspectral

To evaluate and create the figures for the hyperspectral models run

```
python test/hyperspectral.py
```

### Train Models

To train the LENET-5 and the B2N2 models for the CIFAR10 and MNIST dataset run

```
python test/train_models.py
```

### Test Models

To test the trained models with different optimizations run

```
python test/test_models.py
```

### RISC-V Simulation

To simulate the execution of a bayesian forward pass of the hyperspectral models inside the RISC-V CPU run

```
python test/test_rv.py
```
