RV_ID ?= ""

RV_TARGET := build/riscv$(RV_ID)

$(RV_TARGET):
	@echo "COMPILING VHDL..."
	@bash ./scripts/vhdl_comp.sh $(RV_ID)

fullsim:
	@echo "SIMULATION"
	@bash ./scripts/vhdl_sim.sh $(RV_ID)

sim: build/riscv
	bash ./scripts/vhdl_sim.sh -t 8000us

clean:
	rm -rf build
