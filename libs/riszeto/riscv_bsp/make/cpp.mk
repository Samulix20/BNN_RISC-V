# Makefile for compilation of C++ programs for RISC-V platform

# CPP Compiler definitions
CROSS := riscv32-unknown-elf-
CC := $(CROSS)g++
DUMP := $(CROSS)objdump

# Dir definitions
BUILD_DIR := build

SRCS := $(shell find -name '*.cpp')
OBJS := $(shell find -name '*.o' | grep -v main.o) $(SRCS:%.cpp=$(BUILD_DIR)/%.o)

# Compiler flags
OLEVEL ?= 3
CPPFLAGS := \
	-fdata-sections -ffunction-sections -Wl,--gc-sections,-S\
	$(WFLAGS)\
	-O$(OLEVEL)\
	-march=rv32g -mabi=ilp32 -mno-div\
	-fopt-info-optimized=comp_report.txt\
	-I . -I libs\
	-ffreestanding -nostartfiles -T linker.lds\
	$(CPP_EXTRA_FLAGS)

.PHONY: cpp_all cpp_info cpp_dump cpp_skip

cpp_skip: ;

cpp_all: cpp_info cpp_dump

cpp_info:
	@echo "--- CPP Info ---"
	@echo "CPPFLAGS -> $(CPPFLAGS)"
	@echo "BSP CONFIG -> $(BSP_CONFIG)"
	@echo "----------------"

cpp_dump: $(BUILD_DIR)/main.elf
	@echo "DUMP $<"
	@$(DUMP) -D $< > main.dump

$(BUILD_DIR)/main.elf: $(OBJS)
	@echo "LD $@"
	@$(CC) -E -P -x c $(BSP_CONFIG) linker.lds.in > linker.lds
	@$(CC) $(CPPFLAGS) $^ -o $@

$(BUILD_DIR)/%.o: %.cpp
	@echo "C++ $<"
	@mkdir -p $(@D)
	@$(CC) $(CPPFLAGS) -c $< -o $@
