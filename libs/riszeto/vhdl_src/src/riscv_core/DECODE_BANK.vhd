-- DECODE data bank

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity DECODE_BANK_RISC is 
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
end DECODE_BANK_RISC;

architecture behavioral of DECODE_BANK_RISC is

	signal instr_pc, pc4, rs1, rs2, imm, csr_val : std_logic_vector(31 downto 0);
	signal csr_dest : std_logic_vector(11 downto 0);
	signal rd : std_logic_vector(4 downto 0);
	signal alu : std_logic_vector(3 downto 0);
	signal comp : std_logic_vector(2 downto 0);
	signal rs1_risk, rs2_risk, branch_mode, op1_sel, mem_use : std_logic_vector(1 downto 0);
	signal rd_we, op2_sel, mret, zicsr, ecall, ebreak, bad_instr, muldiv, setseed, genum : std_logic;
	signal invalid : std_logic;

begin

	process(clk)
	begin
		if (rising_edge(clk)) then

			if (reset = '1' or nop = '1') then
				
				if (nop = '1' and reset = '0') then
					instr_pc <= instr_pc_in;
				else
					instr_pc <= (others => '0');
				end if;

				pc4 <= (others => '0');
				rs1 <= (others => '0');
				rs2 <= (others => '0');
				imm <= (others => '0');
				rd <= (others => '0');
				alu <= (others => '0');
				comp <= (others => '0');
				rs1_risk <= (others => '0');
				rs2_risk <= (others => '0');
				branch_mode <= (others => '0');
				rd_we <= '0';
				mem_use <= (others => '0');
				op1_sel <= (others => '0');
				op2_sel <= '0';
				mret <= '0';
				csr_val <= (others => '0');
				csr_dest <= (others => '0');
				zicsr <= '0';
				ecall <= '0';
				ebreak <= '0';
				bad_instr <= '0';
				muldiv <= '0';
				setseed <= '0';
				genum <= '0';
				invalid <= '1';

			elsif (we = '1') then
				instr_pc <= instr_pc_in;
				pc4 <= pc4_in;
				rs1 <= rs1_in;
				rs2 <= rs2_in;
				imm <= imm_in;
				rd <= rd_in;
				alu <= alu_in;
				comp <= comp_in;
				rs1_risk <= rs1_risk_in;
				rs2_risk <= rs2_risk_in;
				branch_mode <= branch_mode_in;
				rd_we <= rd_we_in;
				mem_use <= mem_use_in;
				op1_sel <= op1_sel_in;
				op2_sel <= op2_sel_in;
				mret <= mret_in;
				csr_val <= csr_val_in;
				csr_dest <= csr_dest_in;
				zicsr <= zicsr_in;
				ecall <= ecall_in;
				ebreak <= ebreak_in;
				bad_instr <= bad_instr_in;
				muldiv <= muldiv_in;
				setseed <= setseed_in;
				genum <= genum_in;
				invalid <= invalid_in;
			end if;

		end if;

	end process;

	instr_pc_out <= instr_pc;
	pc4_out <= pc4;
	rs1_out <= rs1;
	rs2_out <= rs2;
	imm_out <= imm;
	rd_out <= rd;
	alu_out <= alu;
	comp_out <= comp;
	rs1_risk_out <= rs1_risk;
	rs2_risk_out <= rs2_risk;
	branch_mode_out <= branch_mode;
	rd_we_out <= rd_we;
	mem_use_out <= mem_use;
	op1_sel_out <= op1_sel;
	op2_sel_out <= op2_sel;
	mret_out <= mret;
	csr_val_out <= csr_val;
	csr_dest_out <= csr_dest;
	zicsr_out <= zicsr;
	ecall_out <= ecall;
	ebreak_out <= ebreak;
	bad_instr_out <= bad_instr;
	muldiv_out <= muldiv;
	setseed_out <= setseed;
	genum_out <= genum;
	invalid_out <= invalid;

end behavioral ; -- arch