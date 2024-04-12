# Compiler definitions
CC := gcc
DUMP := objdump

# Dir definitions
BUILD_DIR := build

# Source and object file names, remove riscv platform code
CSRCS := $(shell find -name '*.c')
ASRCS := $(shell find -name '*.S')
OBJS := $(CSRCS:%.c=$(BUILD_DIR)/%.o) $(ASRCS:%.S=$(BUILD_DIR)/%.o)

# Compiler flags
OLEVEL ?= 3

CFLAGS = \
	-fdata-sections -ffunction-sections -Wl,--gc-sections\
	-fopt-info-optimized=comp_report.txt\
	$(WFLAGS)\
	-O$(OLEVEL)\
	-I libs\
	-lm\
	$(EXTRA_FLAGS)

# Run logfile
LOGFILE := run.log

run: clean info $(BUILD_DIR)/main.elf
	@echo "RUN $(BUILD_DIR)/main.elf $(RUNARGS)"
	@echo "---"
	./$(BUILD_DIR)/main.elf $(RUNARGS) | tee $(LOGFILE)

$(BUILD_DIR)/main.elf : $(OBJS)
	@echo "LD $@"
	@$(CC) $(CFLAGS) $^ -o $@ /dev/null

$(BUILD_DIR)/%.o: %.c
	@echo "CC $<"
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.S
	@echo "CASM $<"
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c $< -o $@

info:
	@echo "--- INFO ---"
	@echo "CFLAGS -> $(CFLAGS)"
	@echo "LDFLAGS -> $(LDFLAGS)"
	@echo "------------"

clean:
	@rm -rf $(BUILD_DIR) $(LOGFILE)
