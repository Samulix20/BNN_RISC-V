
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.gaus_gen_pkg.all;

entity RISCV_CORE is 
port (
	clk 	: in std_logic;
	reset	: in std_logic;
	
	-- External interrupts
	ext_irq	: in std_logic;
	tim_irq : in std_logic;

	-- Fetch interface
	fetch 		: out std_logic;
	pc_fetch	: out std_logic_vector (29 downto 0);
	fetch_bus	: in std_logic_vector (31 downto 0);

	-- Mem Bus interface
	write_data	: out std_logic_vector (31 downto 0);
	addr_data	: out std_logic_vector (31 downto 0);
	bus_mode	: out std_logic_vector (2 downto 0);
	bus_we		: out std_logic;
	data_bus	: in std_logic_vector (31 downto 0)
); 
end RISCV_CORE;

architecture behavioral of RISCV_CORE is

	component REG is 
	generic (size : integer);
	port (
		clk 		: in std_logic;
		reset		: in std_logic;
		we			: in std_logic;
		data_in     : in std_logic_vector(size-1 downto 0);
		data_out    : out std_logic_vector(size-1 downto 0)
	);
	end component;

	component FETCH_BANK_RISC is 
	port (
		clk				: in std_logic;
		reset			: in std_logic;
		we				: in std_logic;
		nop				: in std_logic;
	
		instr_pc_in	    : in std_logic_vector(31 downto 0);
		pc4_in			: in std_logic_vector(31 downto 0);
	
		instr_pc_out	: out std_logic_vector(31 downto 0);
		pc4_out			: out std_logic_vector(31 downto 0);
		nop_out			: out std_logic);
	end component;

	component BREG_RISC is 
	port (
		clk 	: in std_logic;
		reset	: in std_logic;
		reg_A	: in std_logic_vector(4 downto 0);
		reg_B	: in std_logic_vector(4 downto 0);
		reg_W	: in std_logic_vector(4 downto 0);
		data_in	: in std_logic_vector(31 downto 0);
		we 		: in std_logic;
		data_A	: out std_logic_vector(31 downto 0);
		data_B	: out std_logic_vector(31 downto 0));
	end component;

	component DECODE_BANK_RISC is 
	port (
		clk				: in std_logic;
		reset			: in std_logic;
		we				: in std_logic;
		nop				: in std_logic;
	
		instr_pc_in		: in std_logic_vector(31 downto 0);
		pc4_in			: in std_logic_vector(31 downto 0);
		rs1_in			: in std_logic_vector(31 downto 0);
		rs2_in			: in std_logic_vector(31 downto 0);
		imm_in			: in std_logic_vector(31 downto 0);
		rd_in			: in std_logic_vector(4 downto 0);
		rd_we_in		: in std_logic;
		alu_in			: in std_logic_vector(3 downto 0);
		branch_mode_in	: in std_logic_vector(1 downto 0);
		comp_in			: in std_logic_vector(2 downto 0);
		rs1_risk_in		: in std_logic_vector(1 downto 0);
		rs2_risk_in		: in std_logic_vector(1 downto 0);
		mem_use_in		: in std_logic_vector(1 downto 0);
		op1_sel_in		: in std_logic_vector(1 downto 0);
		op2_sel_in		: in std_logic;
		mret_in			: in std_logic;
		csr_val_in		: in std_logic_vector(31 downto 0);
		csr_dest_in		: in std_logic_vector(11 downto 0);
		zicsr_in		: in std_logic;
		ecall_in 		: in std_logic;
		ebreak_in 		: in std_logic;
		bad_instr_in	: in std_logic;
		muldiv_in		: in std_logic;
		setseed_in		: in std_logic;
		genum_in		: in std_logic;
		invalid_in		: in std_logic;
	
		instr_pc_out	: out std_logic_vector(31 downto 0);
		pc4_out			: out std_logic_vector(31 downto 0);
		rs1_out			: out std_logic_vector(31 downto 0);
		rs2_out			: out std_logic_vector(31 downto 0);
		imm_out			: out std_logic_vector(31 downto 0);
		rd_out			: out std_logic_vector(4 downto 0);
		rd_we_out		: out std_logic;
		alu_out			: out std_logic_vector(3 downto 0);
		branch_mode_out	: out std_logic_vector(1 downto 0);
		comp_out		: out std_logic_vector(2 downto 0);
		rs1_risk_out	: out std_logic_vector(1 downto 0);
		rs2_risk_out	: out std_logic_vector(1 downto 0);
		mem_use_out		: out std_logic_vector(1 downto 0);
		op1_sel_out		: out std_logic_vector(1 downto 0);
		op2_sel_out		: out std_logic;
		mret_out		: out std_logic;
		csr_val_out		: out std_logic_vector(31 downto 0);
		csr_dest_out	: out std_logic_vector(11 downto 0);
		zicsr_out		: out std_logic;
		ecall_out		: out std_logic;
		ebreak_out		: out std_logic;
		bad_instr_out	: out std_logic;
		muldiv_out 		: out std_logic;
		setseed_out		: out std_logic;
		genum_out		: out std_logic;
		invalid_out 	: out std_logic
	);
	end component;

	component ALU_RISC is 
	port (
		op1     : in std_logic_vector(31 downto 0);
		op2     : in std_logic_vector(31 downto 0);
		mode    : in std_logic_vector(3 downto 0);
		res     : out std_logic_vector(31 downto 0));
	end component;

	component MUL_RISCV is 
	port (
		op1     : in std_logic_vector(31 downto 0);
		op2     : in std_logic_vector(31 downto 0);
		mode    : in std_logic_vector(1 downto 0);
		res     : out std_logic_vector(31 downto 0));
	end component;

	component COMPARATOR_RISC is 
	port (
		op1     : in std_logic_vector(31 downto 0);
		op2     : in std_logic_vector(31 downto 0);
		mode    : in std_logic_vector(2 downto 0);
		res     : out std_logic);
	end component;

	component EXEC_BANK_RISC is 
	port (
		clk				: in std_logic;
		reset			: in std_logic;
		we				: in std_logic;
		nop				: in std_logic;
	
		pc_in			: in std_logic_vector(31 downto 0);
		res_in			: in std_logic_vector(31 downto 0);
		rs2_in			: in std_logic_vector(31 downto 0);
		rd_in			: in std_logic_vector(4 downto 0);
		funct3_in		: in std_logic_vector(2 downto 0);
		mem_use_in		: in std_logic_vector(1 downto 0);
		rd_we_in		: in std_logic;
		mret_in			: in std_logic;
		csr_result_in	: in std_logic_vector(31 downto 0);
		csr_dest_in		: in std_logic_vector(11 downto 0);
		zicsr_in		: in std_logic;
		bad_jump_in		: in std_logic;
		ecall_in 		: in std_logic;
		ebreak_in 		: in std_logic;
		bad_instr_in	: in std_logic;
		invalid_in		: in std_logic;
	
		pc_out			: out std_logic_vector(31 downto 0); 
		res_out			: out std_logic_vector(31 downto 0);
		rs2_out			: out std_logic_vector(31 downto 0);
		rd_out			: out std_logic_vector(4 downto 0);
		funct3_out		: out std_logic_vector(2 downto 0);
		mem_use_out		: out std_logic_vector(1 downto 0);
		rd_we_out		: out std_logic;
		mret_out 		: out std_logic;
		csr_result_out	: out std_logic_vector(31 downto 0);
		csr_dest_out	: out std_logic_vector(11 downto 0);
		zicsr_out		: out std_logic;
		bad_jump_out	: out std_logic;
		ecall_out		: out std_logic;
		ebreak_out		: out std_logic;
		bad_instr_out 	: out std_logic;
		invalid_out		: out std_logic
	);
	end component;

	component MEM_BANK_RISC is 
	port (
		clk 	    : in std_logic;
		reset	    : in std_logic;
		we 		    : in std_logic;
	
		res_in	    : in std_logic_vector(31 downto 0);
		rd_in       : in std_logic_vector(4 downto 0);
		rd_mux_in	: in std_logic;
		rd_we_in    : in std_logic;
	
		res_out		: out std_logic_vector(31 downto 0);
		rd_out      : out std_logic_vector(4 downto 0);
		rd_mux_out	: out std_logic;
		rd_we_out   : out std_logic
	);
	end component;

	component MMODE_RISC is
	port (
		clk 		: in std_logic;
		reset		: in std_logic;
		we			: in std_logic;
		data_in		: in std_logic;
		data_out	: out std_logic
	);
	end component;

	component MSTATUS_RISC is 
	port (
		clk 		: in std_logic;
		reset		: in std_logic;
		we			: in std_logic;
		data_in		: in std_logic_vector(31 downto 0);
		data_out	: out std_logic_vector(31 downto 0)
	);
	end component;

	component MIE_RISC is 
	port (
		clk 		: in std_logic;
		reset		: in std_logic;
		we			: in std_logic;
		data_in		: in std_logic_vector(31 downto 0);
		data_out	: out std_logic_vector(31 downto 0));
	end component;

	-- Status control signals
	signal mode_input, mode_we, mode, mstatus_we, mtvec_we, mepc_we, mcause_we, mscratch_we, mie_we, mcycle_we, mcountinhibit_we, minstret_we : std_logic;
	signal mstatus_sw, mtvec_sw, mepc_sw, mcause_sw, mscratch_sw, mcycle_sw, mcycleh_sw, mie_sw, mcountinhibit_sw, minstret_sw, minstreth_sw : std_logic;
	signal mstatus_in, mstatus_out, mepc_in, mepc_out, mcause_in, mcause_out, mie_out : std_logic_vector(31 downto 0);
	signal mscratch_in, mscratch_out, mie_in : std_logic_vector(31 downto 0);
	signal mcycle_in, mcycle_out, minstret_in, minstret_out : std_logic_vector(63 downto 0);
	signal mtvec_in, mtvec_out : std_logic_vector(29 downto 0);
	signal mcountinhibit_out, mcountinhibit_in : std_logic_vector(2 downto 0);
	signal csr_sw : std_logic;

	-- Trap signals
	signal take_trap, except : std_logic;
	signal mem_cause : std_logic_vector(31 downto 0);

	-- Memory signals declarations
	signal data_out, data_in, addr_inst : std_logic_vector(31 downto 0);
	signal mem_we : std_logic;

	-- Fetch stage signals declarations
	signal pc_we, fetch_bank_we, fetch_nop : std_logic;
	signal pc_in, pc4, bank_pc_in : std_logic_vector(31 downto 0);

	-- Decode stage signals declarations
	signal instr_dec, pc_dec, pc_dec_bank, rs1_data, rs2_data, pc4_dec, csr_read : std_logic_vector(31 downto 0);
	signal csr_sd : std_logic_vector(11 downto 0);
	signal opcode, funct7 : std_logic_vector(6 downto 0);
	signal rd, rs1, rs2 : std_logic_vector(4 downto 0);
	signal alu_op : std_logic_vector(3 downto 0);
	signal funct3 : std_logic_vector(2 downto 0);
	signal op1_sel, rs1_risk_sel, rs2_risk_sel, branch_mode, mem_use_dec : std_logic_vector(1 downto 0);
	signal decode_bank_we, rd_we_dec, op2_sel, mret_dec, zicsr_dec, bad_instr_dec, muldiv_dec, setseed_dec, genum_dec : std_logic;
	signal invalid_dec : std_logic;
	-- Immediate signals
	signal imm, i_imm, s_imm, b_imm, u_imm, j_imm, shamt, csr_imm : std_logic_vector(31 downto 0);
	-- Risk detection signals
	signal risk_rs1_exe, risk_rs2_exe, risk_rs1_mem, risk_rs2_mem, use_rs1, use_rs2, load_use, nop_dec, noped_fetch : std_logic;
	signal csr_stop, ecall_dec, ebreak_dec : std_logic;

	-- Execution stage signal declarations
	signal pc_exe, pc4_exe, imm_exe, rs1_bank, rs2_bank, rs1_exe, rs2_exe, op1_exe, op2_exe, alu_res, result, pc_exe_out, csr_val_exe, csr_result, muldiv_res, gen_res : std_logic_vector(31 downto 0);
	signal set_seed_in_exe : std_logic_vector(3 downto 0);
	signal csr_dest_exe : std_logic_vector(11 downto 0);
	signal rd_exe : std_logic_vector(4 downto 0);
	signal alu_exe : std_logic_vector(3 downto 0);
	signal comp_exe : std_logic_vector(2 downto 0);
	signal rs1_risk, rs2_risk, branch_exe, op1_sel_exe, mem_use_exe : std_logic_vector(1 downto 0);
	signal rd_we_exe, exec_bank_we, comp_res, branch, op2_sel_exe, mret_exe, nop_exe, zicsr_exe, bad_jump_exe, muldiv_exe, genum_exe, setseed_exe : std_logic;
	signal ecall_exe, ebreak_exe, bad_instr_exe, invalid_exe : std_logic;

	-- Memory stage signal declarations
	signal res_mem, pc_mem, mret_values, csr_result_mem : std_logic_vector(31 downto 0);
	signal csr_dest_mem : std_logic_vector(11 downto 0);
	signal rd_mem : std_logic_vector(4 downto 0);
	signal funct3_mem : std_logic_vector(2 downto 0);
	signal mem_use : std_logic_vector(1 downto 0);
	signal rd_we_mem, rd_we_mem_out, mret_mem, zicsr_mem, bad_jump_mem : std_logic;
	signal ecall_mem, ebreak_mem, ma_half, ma_word, bad_instr_mem, invalid_mem, invalid_mem_out : std_logic;

	-- Writeback stage signal declarations
	signal rd_wb : std_logic_vector(4 downto 0);
	signal we_wb, mem_bank_we, rd_mux : std_logic;
	signal data_wb, res_wb : std_logic_vector(31 downto 0);

begin

	-- CSRs
	mmode : MMODE_RISC
	PORT MAP (
		clk => clk,
		reset => reset,
		we => mode_we,
		data_in => mode_input,
		data_out => mode
	);

	mode_we <= 	take_trap or mret_mem;
	mode_input <= 	'1' when take_trap = '1'
	else			mstatus_out(11) when mret_mem = '1'
	else			'0'; -- This is undefined behaviour, should never write

	-- 0x300 MSTATUS
	-- 3 	MIE
	-- 7 	MPIE
	-- 11 	MPP
	-- 17 	MPRV
	mstatus : MSTATUS_RISC
	PORT MAP (
		clk => clk,
		reset => reset,
		we => mstatus_we,
		data_in => mstatus_in,
		data_out => mstatus_out
	);

	mstatus_we <= take_trap or mret_mem or mstatus_sw;
	mstatus_in <= 	(7 => '1', 11 => mode, 17 => mstatus_out(17), others => '0') when take_trap = '1'
	else			(3 => mstatus_out(7), 7 => '1', 11 => '0', 17 => mstatus_out(11) and mstatus_out(17), others => '0') when mret_mem = '1'
	else			csr_result_mem when csr_sw = '1'
	else			(others => '0'); -- This is undefined behaviour, should never write 

	-- 0x305 MTVEC implemented as REG, MODE -> "00", always direct mode
	mtvec : REG
	GENERIC MAP (size => 30) 
	PORT MAP (
		clk => clk,
		reset => reset,
		we => mtvec_we,
		data_in => mtvec_in,
		data_out => mtvec_out
	);

	mtvec_we <= mtvec_sw;
	mtvec_in <= csr_result_mem(31 downto 2);
	
	-- 0x340 MSCRATCH implemented as REG, may be written by sw
	mscratch : REG
	GENERIC MAP (size => 32)
	PORT MAP (
		clk => clk,
		reset => reset,
		we => mscratch_we,
		data_in => mscratch_in,
		data_out => mscratch_out
	);

	mscratch_we <= take_trap or mscratch_sw;
	mscratch_in <= 	res_mem when take_trap = '1' 
	else 			csr_result_mem;

	-- 0x341 MEPC implemented as REG, may be written by sw
	mepc : REG
	GENERIC MAP (size => 32) 
	PORT MAP (
		clk => clk,
		reset => reset,
		we => mepc_we,
		data_in => mepc_in,
		data_out => mepc_out
	);

	mepc_we <= take_trap or mepc_sw;
	mepc_in <= 	csr_result_mem when csr_sw = '1'
	else		pc_mem;

	-- 0x342 MCAUSE implemented as REG, may be written by sw
	mcause : REG
	GENERIC MAP (size => 32) 
	PORT MAP (
		clk => clk,
		reset => reset,
		we => mcause_we,
		data_in => mcause_in,
		data_out => mcause_out
	);

	mcause_we <= take_trap or mcause_sw;
	mcause_in <= 	csr_result_mem when csr_sw = '1'
	else			mem_cause;


	mcycle : REG
	GENERIC MAP (size => 64) 
	PORT MAP (
		clk => clk,
		reset => reset,
		we => mcycle_we,
		data_in => mcycle_in,
		data_out => mcycle_out
	);

	mcycle_we <=	(not mcountinhibit_out(0)) or mcycle_sw or mcycleh_sw;
	mcycle_in <= 	mcycle_out(63 downto 32) & csr_result_mem when mcycle_sw = '1'
	else			csr_result_mem & mcycle_out(31 downto 0) when mcycleh_sw = '1'
	else			std_logic_vector(unsigned(mcycle_out) + 1);

	mcountinhibit : REG
	GENERIC MAP (size => 3)
	PORT MAP (
		clk => clk,
		reset => reset,
		we => mcountinhibit_we,
		data_in => mcountinhibit_in,
		data_out => mcountinhibit_out
	);

	mcountinhibit_we <= mcountinhibit_sw;
	mcountinhibit_in(2 downto 0) <= csr_result_mem(2 downto 0);

	minstret : REG
	GENERIC MAP (size => 64)
	PORT MAP (
		clk => clk,
		reset => reset,
		we => minstret_we,
		data_in => minstret_in,
		data_out => minstret_out
	);

	minstret_we <=	((not invalid_mem_out) and (not mcountinhibit_out(2))) or minstret_sw or minstreth_sw;
	minstret_in <=	minstret_out(63 downto 32) & csr_result_mem when minstret_sw = '1'
	else			csr_result_mem & minstret_out(31 downto 0) when minstreth_sw = '1'
	else			std_logic_vector(unsigned(minstret_out) + 1);

	mie : MIE_RISC
	PORT MAP (
		clk => clk,
		reset => reset,
		we => mie_we,
		data_in => mie_in,
		data_out => mie_out
	);

	mie_we <= mie_sw;
	mie_in <= csr_result_mem;

	-- Fetch stage
	pc : REG
	GENERIC MAP (size => 32) 
	PORT MAP (
		clk => clk,
		reset => reset,
		we => pc_we,
		data_in => pc_in,
		data_out => addr_inst
	);

	-- Pc advance control
	pc_we <= not (load_use or csr_stop) or take_trap or mret_mem;	-- irqs and mret must always write pc 
	pc_in <= 	mtvec_out & "00" when take_trap = '1'
	else		mepc_out when mret_mem = '1'
	else		alu_res(31 downto 2) & "00" when branch = '1'
	else		pc4;
	
	-- Fetch bank control
	fetch_bank_we <= not (load_use or csr_stop);
	fetch_nop <= take_trap or branch or mret_mem;	-- clear whats in bank

	-- Fetch bus control
	fetch <= fetch_bank_we;
	pc_fetch <= addr_inst(31 downto 2);
	
	-- Load pc
	pc4 <= std_logic_vector(unsigned(addr_inst) + 4);
	
	-- When an instruction is deleted from pipeline must get
	-- a valid pc
	bank_pc_in <= 	mepc_out when mret_mem = '1'
	else			alu_res(31 downto 1)&"0" when branch = '1'
	else			(others => '0') when reset = '1'
	else			addr_inst;

	-- Bank FETCH-DECODE
	fetch_bank : FETCH_BANK_RISC
	PORT MAP (
		clk => clk,
		reset => reset,
		we => fetch_bank_we,
		nop => fetch_nop,

		instr_pc_in => bank_pc_in,
		pc4_in => pc4,

		instr_pc_out => pc_dec,
		pc4_out => pc4_dec,
		nop_out => noped_fetch
	);

	-- Decode stage

	-- Trick to delete fetched instr
	instr_dec <= 	fetch_bus when noped_fetch = '0' and reset = '0'
	else			x"00000013";

	invalid_dec <= noped_fetch;

	opcode <= instr_dec(6 downto 0);
	rd <= instr_dec(11 downto 7);
	rs1 <= instr_dec(19 downto 15);
	rs2 <= instr_dec(24 downto 20);
	funct3 <= instr_dec(14 downto 12);
	funct7 <= instr_dec(31 downto 25);
	csr_sd <= instr_dec(31 downto 20);

	-- All type of inmediates
	i_imm(31 downto 11) <= (others => instr_dec(31));
	i_imm(10 downto 0) <= instr_dec(30 downto 20);
	
	s_imm(31 downto 11) <= (others => instr_dec(31)); 
	s_imm(10 downto 5) <= instr_dec(30 downto 25);
	s_imm(4 downto 0) <= instr_dec(11 downto 7);
	
	b_imm(31 downto 12) <= (others => instr_dec(31));
	b_imm(11) <= instr_dec(7);
	b_imm(10 downto 5) <= instr_dec(30 downto 25);
	b_imm(4 downto 1) <= instr_dec(11 downto 8);
	b_imm(0) <= '0';

	u_imm(31 downto 12) <= instr_dec(31 downto 12);
	u_imm(11 downto 0) <= (others => '0');

	j_imm(31 downto 20) <= (others => instr_dec(31));
	j_imm(19 downto 12) <= instr_dec(19 downto 12);
	j_imm(11) <= instr_dec(20);
	j_imm(10 downto 1) <= instr_dec(30 downto 21);
	j_imm(0) <= '0';

	shamt(4 downto 0) <= instr_dec(24 downto 20);
	shamt(5) <= instr_dec(25); -- For detecting illegal instructions
	shamt(31 downto 6) <= (others => '0');

	csr_imm(4 downto 0) <= rs1;
	csr_imm(31 downto 5) <= (others => '0');

	-- Control signal decoding

	-- Check if instr is valid
	bad_instr_dec <= '1' when opcode /= "0110111" -- LUI
						and opcode /= "0010111" -- AUIPC
						and opcode /= "1101111" -- JAL
						and opcode /= "1100111" -- JALR
						and opcode /= "1100011" -- Branches
						and opcode /= "0000011" -- Loads
						and opcode /= "0100011" -- Stores
						and opcode /= "0010011" -- Integer Immediate base arithmetic
						and opcode /= "0110011" -- Integer Integer base arithmetic
						and opcode /= "0001111" -- TODO implement Fence transform into nop
						and opcode /= "1110011" -- Zicsr extension and SWI
						and opcode /= "0001011" -- Custom instructions
	else '1' when opcode = "0010011" and (funct3 = "001" or funct3 = "101") and shamt(5) = '1' -- Instructions with shamt[5] are illegal
	else '1' when muldiv_dec = '1' and funct3(2) = '1' -- Division operations are not supported
	else '0';

	-- Type of immediate
	imm <= 	shamt when opcode = "0010011" and (funct3 = "001" or funct3 = "101")
	else 	csr_imm when opcode = "1110011" and (funct3(2) = '1')
	else 	i_imm when opcode = "0010011" or opcode = "1100111" or opcode = "0000011"
	else 	u_imm when opcode = "0110111" or opcode = "0010111"
	else	j_imm when opcode = "1101111"
	else	s_imm when opcode = "0100011"
	else	b_imm when opcode = "1100011"
	else 	(others => '0');

	-- Type of alu op
	alu_op <=	"1000" when funct3 = "101" and funct7 = "0100000" and opcode = "0010011"
	else		"1000" when funct3 = "101" and funct7 = "0100000" and opcode = "0110011"
	else		"1001" when funct3 = "000" and funct7 = "0100000" and opcode = "0110011"
	else		"0000" when opcode = "0110111" or opcode = "0010111" or opcode = "0000011" 
	else		"0000" when opcode = "0100011" or opcode = "1100011" or opcode = "1101111"
	else 		"0000" when opcode = "1100111"
	else 		"0"&funct3;

	-- MULDIV op?
	muldiv_dec <= '1' when opcode = "0110011" and funct7 = "0000001" else '0';

	-- Set seed op?
	setseed_dec <= '1' when opcode = "0001011" and funct3 = "000" else '0';
	-- Gen num op?
	genum_dec <= '1' when opcode = "0001011" and funct3 = "001" else '0';

	-- Mret?
	mret_dec <= '1' when instr_dec = "00110000001000000000000001110011" else '0';
	-- Ecall?
	ecall_dec <= '1' when instr_dec = "00000000000000000000000001110011" else '0';
	-- Ebreak?
	ebreak_dec <= '1' when instr_dec = "00000000000100000000000001110011" else '0';
	
	-- Zicsr instr?
	zicsr_dec <= '1' when opcode = "1110011" 
							and mret_dec = '0' 
							and ecall_dec = '0' 
							and ebreak_dec = '0' else '0';	-- check its not other sysop cause they share opcode

	-- Register write?
	rd_we_dec <=	'0' when opcode = "1100011" or opcode = "0100011" or rd = "00000" or setseed_dec = '1'
	else			'0' when opcode = "0000000" or mret_dec = '1' or reset = '1'	-- Only for reset
	else			'1';

	-- Branching?
	-- "00" no jump
	-- "01" inconditional jump
	-- "10" conditional jump
	-- "11" undf
	branch_mode <=	"01" when opcode = "1101111" or opcode = "1100111"
	else			"10" when opcode = "1100011"
	else			"00";

	-- Memory write/load?
	-- "00" no use
	-- "10" load
	-- "11" store
	mem_use_dec <=	"10" when opcode = "0000011"
	else			"11" when opcode = "0100011"
	else			"00";

	-- Operators control

	-- operator 1
	-- "00" register
	-- "01" pc
	-- "10" 0
	op1_sel <=	"00" when opcode = "0010011" or opcode = "0110011" or opcode = "0000011"
	else		"00" when opcode = "0100011" or opcode = "1100111" or opcode = "0001011"
	else		"01" when opcode = "0010111" or opcode = "1101111" or opcode = "1100011"
	else		"10"; 

	-- operator 2
	-- '0' register
	-- '1' immediate
	op2_sel <=	'0' when opcode = "0110011" or opcode = "0001011"
	else		'1';

	-- Risk detection
	use_rs1 <= 	'1' when op1_sel = "00" or opcode = "1100011" or (zicsr_dec = '1' and funct3(2) = '0')
	else		'0';
	use_rs2 <=	'1' when op2_sel = '0' or opcode = "0100011" or opcode = "1100011"
	else		'0';
	risk_rs1_exe <=	'1' when rd_exe = rs1 and rs1 /= "00000" and rd_we_exe = '1' and use_rs1 = '1'
	else			'0';
	risk_rs2_exe <=	'1' when rd_exe = rs2 and rs2 /= "00000" and rd_we_exe = '1' and use_rs2 = '1'
	else			'0';
	risk_rs1_mem <= '1' when rd_mem = rs1 and rs1 /= "00000" and rd_we_mem = '1' and use_rs1 = '1'
	else			'0';
	risk_rs2_mem <= '1' when rd_mem = rs2 and rs2 /= "00000" and rd_we_mem = '1' and use_rs2 = '1'
	else			'0';

	-- Load-Use?
	load_use <= '1' when mem_use_exe = "10" and (risk_rs1_exe = '1' or risk_rs2_exe = '1')
	else		'0';
	-- Zicsr instr in pipe?
	csr_stop <= zicsr_dec and (zicsr_exe or zicsr_mem);

	-- Risk MUX CTRL
	-- "00" no short
	-- "01" mem short
	-- "10" wb short
	-- "11" undf
	rs1_risk_sel <=	"00" when risk_rs1_exe = '0' and risk_rs1_mem = '0'
	else			"01" when risk_rs1_exe = '1'
	else			"10" when risk_rs1_exe = '0' and risk_rs1_mem = '1'
	else			"00";

	rs2_risk_sel <=	"00" when risk_rs2_exe = '0' and risk_rs2_mem = '0'
	else			"01" when risk_rs2_exe = '1'
	else			"10" when risk_rs2_exe = '0' and risk_rs2_mem = '1'
	else			"00";

	-- Register bank
	register_bank : BREG_RISC
	PORT MAP (
		clk => clk,
		reset => reset,
		reg_A => rs1,
		reg_B => rs2,
		reg_W => rd_wb,
		data_in	=> data_wb,
		we => we_wb,
		data_A => rs1_data,
		data_B => rs2_data
	);

	-- CSR read values
	csr_read <= mstatus_out when csr_sd = x"300"
	else		x"40100100" when csr_sd = x"301"
	else		mtvec_out & "00" when csr_sd = x"305"
	else		std_logic_vector(to_unsigned(0, 29)) & mcountinhibit_out when csr_sd = x"320"
	else		mscratch_out when csr_sd = x"340"
	else		mepc_out when csr_sd = x"341"
	else		mcause_out when csr_sd = x"342"
	else		mcycle_out(31 downto 0) when csr_sd = x"B00"
	else 		mcycle_out(63 downto 32) when csr_sd = x"B80"
	else		minstret_out(31 downto 0) when csr_sd = x"B02"
	else		minstret_out(63 downto 32) when csr_sd = x"B82"
	else		(others => '0');

	-- Bank control
	nop_dec <= load_use or csr_stop or branch or take_trap or mret_mem;
	pc_dec_bank <= 	mepc_out when mret_mem = '1'
	else			alu_res(31 downto 1)&"0" when branch = '1'
	else			pc_dec;

	-- Constant decode stage signals
	decode_bank_we <= '1';

	-- Bank DECODE-EXEC
	decode_bank : DECODE_BANK_RISC
	PORT MAP (
		clk => clk,
		reset => reset,
		we => decode_bank_we,
		nop => nop_dec,

		instr_pc_in => pc_dec_bank,
		pc4_in => pc4_dec,
		rs1_in => rs1_data,
		rs2_in => rs2_data,
		imm_in => imm,
		rd_in => rd,
		rd_we_in => rd_we_dec,
		alu_in => alu_op,
		branch_mode_in => branch_mode,
		comp_in => funct3,
		rs1_risk_in => rs1_risk_sel,
		rs2_risk_in => rs2_risk_sel,
		mem_use_in => mem_use_dec,
		op1_sel_in => op1_sel,
		op2_sel_in => op2_sel,
		mret_in => mret_dec,
		csr_val_in => csr_read,
		csr_dest_in => csr_sd,
		zicsr_in => zicsr_dec,
		ecall_in => ecall_dec,
		ebreak_in => ebreak_dec,
		bad_instr_in => bad_instr_dec,
		muldiv_in => muldiv_dec,
		setseed_in => setseed_dec,
		genum_in => genum_dec,
		invalid_in => invalid_dec,

		instr_pc_out => pc_exe,
		pc4_out => pc4_exe,
		rs1_out => rs1_bank,
		rs2_out => rs2_bank,
		imm_out => imm_exe,
		rd_out => rd_exe,
		rd_we_out => rd_we_exe,
		alu_out => alu_exe,
		branch_mode_out => branch_exe,
		comp_out => comp_exe,
		rs1_risk_out => rs1_risk,
		rs2_risk_out => rs2_risk,
		mem_use_out => mem_use_exe,
		op1_sel_out => op1_sel_exe,
		op2_sel_out => op2_sel_exe,
		mret_out => mret_exe,
		csr_val_out => csr_val_exe,
		csr_dest_out => csr_dest_exe,
		zicsr_out => zicsr_exe,
		ecall_out => ecall_exe,
		ebreak_out => ebreak_exe,
		bad_instr_out => bad_instr_exe,
		muldiv_out => muldiv_exe,
		setseed_out => setseed_exe,
		genum_out => genum_exe,
		invalid_out => invalid_exe
	);

	-- Execution stage

	-- MUX rs1_exe
	-- "00" no short
	-- "01" mem short
	-- "10" wb short
	-- "11" undf
	rs1_exe <=	rs1_bank when rs1_risk = "00"
	else		res_mem when rs1_risk = "01"
	else		data_wb; --to prevent latches

	-- MUX op1_exe
	-- "00" register
	-- "01" pc
	-- "10" 0
	op1_exe <=	rs1_exe when op1_sel_exe = "00"
	else		pc_exe when op1_sel_exe = "01"
	else		(others => '0');

	-- MUX rs2_exe
	-- "00" no short
	-- "01" mem short
	-- "10" wb short
	-- "11" undf
	rs2_exe <=	rs2_bank when rs2_risk = "00"
	else		res_mem when rs2_risk = "01"
	else		data_wb; --to prevent latches

	-- MUX op2_exe
	-- '0' register
	-- '1' immediate
	op2_exe <=	rs2_exe when op2_sel_exe = '0'
	else		imm_exe;

	alu : ALU_RISC
	PORT MAP (
		op1 => op1_exe,
		op2 => op2_exe,
		mode => alu_exe,
		res => alu_res
	);

	mul_unit : MUL_RISCV
	PORT MAP (
		op1 => op1_exe,
		op2 => op2_exe,
		mode => comp_exe(1 downto 0),
		res => muldiv_res
	);

	comparator : COMPARATOR_RISC
	PORT MAP (
		op1 => rs1_exe,
		op2 => rs2_exe,
		mode => comp_exe,
		res => comp_res
	);

	-- Custom extension 
	set_seed_in_exe <= 	op1_exe(3 downto 0) when setseed_exe = '1' 
	else 				(others => '0');

	--gauss_gen : GAUSS_GEN_12_12
	--PORT MAP (
	--	clk => clk,
	--	set => set_seed_in_exe,
	--	seed => op2_exe(30 downto 0),
	--	gen => genum_exe,
	--	value => gen_res
	--);

	gauss_gen : PIPELINED_GAUSS_GEN_12_12
	PORT MAP (
		reset => reset,
		clk => clk,
		set => set_seed_in_exe,
		seed => op2_exe(30 downto 0),
		gen => genum_exe,
		value => gen_res
	);

	-- CSR operations
	-- comp_exe is funct3 so its used here
	csr_result <= 	rs1_exe when comp_exe = "001"
	else			rs1_exe or csr_val_exe when comp_exe = "010"
	else			(not rs1_exe) and csr_val_exe when comp_exe = "011"
	else			imm_exe when comp_exe = "101"
	else			imm_exe or csr_val_exe when comp_exe = "110"
	else			(not imm_exe) and csr_val_exe when comp_exe = "111"
	else			(others => '0');

	-- Branch
	-- "00" no jump
	-- "01" inconditional jump
	-- "10" conditional jump
	-- "11" undf
	branch <=	'1' when branch_exe = "01"
	else		'1' when branch_exe = "10" and comp_res = '1'
	else		'0';

	-- Missaligned jump detection
	bad_jump_exe <= '1' when alu_res(1) /= '0' and branch = '1'
	else			'0';

	-- MUX result
	result <= 	gen_res when genum_exe = '1'
	else 		muldiv_res when muldiv_exe = '1'
	else		csr_val_exe when zicsr_exe = '1'
	else		alu_res when branch_exe = "00"
	else 		pc4_exe;

	pc_exe_out <= 	mepc_out when mret_mem = '1'
	else			pc_exe;

	-- Clear exe bank
	nop_exe <= take_trap or mret_mem;

	-- Execution stage constants
	exec_bank_we <= '1';

	-- Bank EXEC-MEM
	exec_bank : EXEC_BANK_RISC
	PORT MAP (
		clk => clk,
		reset => reset,
		we => exec_bank_we,
		nop => nop_exe,
		
		pc_in => pc_exe_out,
		res_in => result,
		rs2_in => rs2_exe,
		rd_in => rd_exe,
		funct3_in => comp_exe,
		rd_we_in => rd_we_exe,
		mem_use_in => mem_use_exe,
		mret_in => mret_exe,
		csr_result_in => csr_result,
		csr_dest_in => csr_dest_exe,
		zicsr_in => zicsr_exe,
		bad_jump_in => bad_jump_exe,
		ecall_in => ecall_exe,
		ebreak_in => ebreak_exe,
		bad_instr_in => bad_instr_exe,
		invalid_in => invalid_exe,

		pc_out => pc_mem,
		res_out	=> res_mem,
		rs2_out => data_in,
		rd_out => rd_mem,
		funct3_out => funct3_mem,
		rd_we_out => rd_we_mem,
		mem_use_out => mem_use,
		mret_out => mret_mem,
		csr_result_out => csr_result_mem,
		csr_dest_out => csr_dest_mem,
		zicsr_out => zicsr_mem,
		bad_jump_out => bad_jump_mem,
		ecall_out => ecall_mem,
		ebreak_out => ebreak_mem,
		bad_instr_out => bad_instr_mem,
		invalid_out => invalid_mem
	);

	-- Memory stage

	-- Exceptions
	ma_half <= '1' when funct3_mem(1 downto 0) = "01" and res_mem(0) /= '0' else '0';
	ma_word <= '1' when funct3_mem(1 downto 0) = "10" and res_mem(1 downto 0) /= "00" else '0';

	except <= 	'1' when (zicsr_mem = '1' and mode = '0') or bad_instr_mem = '1'	-- csr instr are privileged or instruction is illegal
	else		'1' when bad_jump_mem = '1' 										-- missaligned instruction
	else		'1' when ecall_mem = '1' or ebreak_mem = '1'						-- software trap isntructions
	else		'1' when mem_use = "10" and (ma_half = '1' or ma_word = '1')		-- missaligned load
	else		'1' when mem_use = "11" and (ma_half = '1' or ma_word = '1')		-- missaligned store
	else		'0';

	-- Trap causes
	mem_cause <= 	x"80000007" when (tim_irq and mie_out(7)) = '1' and mstatus_out(3) = '1'	
	else			x"8000000b" when (ext_irq and mie_out(11)) = '1' and mstatus_out(3) = '1'	
	else 			x"00000003" when ebreak_mem = '1'
	else			x"00000002" when (zicsr_mem = '1' and mode = '0') or bad_instr_mem = '1'
	else			x"00000000" when bad_jump_mem = '1'
	else			x"00000008" when ecall_mem = '1' and mode = '0'
	else			x"0000000b" when ecall_mem = '1' and mode = '1'
	else			x"00000004" when mem_use = "10" and (ma_half = '1' or ma_word = '1')
	else			x"00000006" when mem_use = "11" and (ma_half = '1' or ma_word = '1')
	else 			(others => '0');

	-- Trap handling
	take_trap <= (((tim_irq and mie_out(7)) or (ext_irq and mie_out(11))) and mstatus_out(3)) or except;

	-- Write enables
	mem_we <= '1' when mem_use = "11" and take_trap = '0' else '0';
	rd_we_mem_out <= rd_we_mem when take_trap = '0' else '0';

	-- Memory constant values
	mem_bank_we <= '1';

	-- CSR sw writing
	csr_sw <= zicsr_mem and not(take_trap);
	mstatus_sw <= '1' when csr_dest_mem = x"300" and csr_sw = '1' else '0';
	mie_sw <= '1' when csr_dest_mem = x"304" and csr_sw = '1' else '0';
	mtvec_sw <= '1' when csr_dest_mem = x"305" and csr_sw = '1' else '0';
	mcountinhibit_sw <= '1' when csr_dest_mem = x"320" and csr_sw = '1' else '0';
	mscratch_sw <= '1' when csr_dest_mem = x"340" and csr_sw = '1' else '0';
	mepc_sw <= '1' when csr_dest_mem = x"341" and csr_sw = '1' else '0';
	mcause_sw <= '1' when csr_dest_mem = x"342" and csr_sw = '1' else '0'; 
	mcycle_sw <= '1' when csr_dest_mem = x"B00" and csr_sw = '1' else '0';
	mcycleh_sw <= '1' when csr_dest_mem = x"B80" and csr_sw = '1' else '0';
	minstret_sw <= '1' when csr_dest_mem = x"B02" and csr_sw = '1' else '0';
	minstreth_sw <= '1' when csr_dest_mem = x"B82" and csr_sw = '1' else '0';

	-- Mem bus control
	write_data <= data_in;
	addr_data <= res_mem;
	bus_mode <= funct3_mem;
	bus_we <= mem_we;

	-- Valid counter
	invalid_mem_out <= invalid_mem or take_trap;

	-- Benk MEM-WB
	mem_bank : MEM_BANK_RISC
	PORT MAP (
		clk => clk,
		reset => reset,
		we => mem_bank_we,

		res_in => res_mem,
		rd_in => rd_mem,
		rd_we_in => rd_we_mem_out,
		rd_mux_in => mem_use(1),
		
		res_out => res_wb,
		rd_mux_out => rd_mux,
		rd_out => rd_wb,
		rd_we_out => we_wb
	);

	data_wb <= 	res_wb when rd_mux = '0'
	else		data_bus;

end behavioral ; -- arch