# Makefile for compilation of C programs for RISC-V platform

# C Compiler definitions
CROSS := riscv32-unknown-elf-
CC := $(CROSS)gcc
DUMP := $(CROSS)objdump

# Dir definitions
BUILD_DIR := build

# Source and object file names
CSRCS := $(shell find -name '*.c')
ASRCS := $(shell find -name '*.S')
OBJS := $(CSRCS:%.c=$(BUILD_DIR)/%.o) $(ASRCS:%.S=$(BUILD_DIR)/%.o)

# Compiler flags
OLEVEL ?= 0
CFLAGS := \
	-fdata-sections -ffunction-sections -Wl,--gc-sections,-S\
	$(WFLAGS)\
	-O$(OLEVEL)\
	-march=rv32g -mabi=ilp32 -mno-div\
	-fopt-info-optimized=comp_report.txt\
	-I . -I libs\
	-ffreestanding -nostartfiles -T linker.lds\
	$(C_EXTRA_FLAGS)

# Memory size parameter for linker script


.PHONY: c_all c_libs c_info c_clean c_dump c_libs

c_all: c_clean c_info c_dump

c_libs: c_clean c_info $(OBJS) 

c_info:
	@echo "--- C Info ---"
	@echo "CFLAGS -> $(CFLAGS)"
	@echo "BSP CONFIG -> $(BSP_CONFIG)"
	@echo "--------------"

c_clean:
	@rm -rf $(BUILD_DIR)
	@rm -rf main.dump
	@rm -rf comp_report.txt

c_dump: $(BUILD_DIR)/main.elf
	@echo "DUMP $<"
	@$(DUMP) -D $< > main.dump

$(BUILD_DIR)/main.elf : $(OBJS)
	@echo "LD $@"
	@$(CC) -E -P -x c $(BSP_CONFIG) linker.lds.in > linker.lds
	@$(CC) $(CFLAGS) $(BSP_CONFIG) $^ -o $@

$(BUILD_DIR)/%.o: %.c
	@echo "CC $<"
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) $(BSP_CONFIG) -c $< -o $@

$(BUILD_DIR)/%.o: %.S
	@echo "CASM $<"
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) $(BSP_CONFIG) -c $< -o $@
