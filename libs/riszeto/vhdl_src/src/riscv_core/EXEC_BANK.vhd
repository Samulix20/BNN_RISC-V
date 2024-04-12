-- DECODE data bank

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity EXEC_BANK_RISC is 
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
end EXEC_BANK_RISC;

architecture behavioral of EXEC_BANK_RISC is

	signal pc, res, rs2, csr_result : std_logic_vector(31 downto 0);
	signal csr_dest : std_logic_vector(11 downto 0);
	signal rd : std_logic_vector(4 downto 0);
	signal funct3 : std_logic_vector(2 downto 0);
	signal mem_use : std_logic_vector(1 downto 0);
	signal rd_we, mret, zicsr, bad_jump, ecall, ebreak, bad_instr : std_logic;
	signal invalid : std_logic;

begin

	process(clk)
	begin
		if (rising_edge(clk)) then

			if (reset = '1' or nop = '1') then
				
				if (nop = '1' and reset = '0') then
					pc <= pc_in;
				else
					pc <= (others => '0');
				end if;
				
				res <= (others => '0');
				rs2 <= (others => '0');
				rd <= (others => '0');
				funct3 <= (others => '0');
				rd_we <= '0';
				mem_use <= (others => '0');
				mret <= '0';
				csr_result <= (others => '0');
				csr_dest <= (others => '0');
				zicsr <= '0';
				bad_jump <= '0';
				ecall <= '0';
				ebreak <= '0';
				bad_instr <= '0';
				invalid <= '1';

			elsif (we = '1') then
				pc <= pc_in;
				res <= res_in;
				rs2 <= rs2_in;
				rd <= rd_in;
				funct3 <= funct3_in;
				rd_we <= rd_we_in;
				mem_use <= mem_use_in;
				mret <= mret_in;
				csr_result <= csr_result_in;
				csr_dest <= csr_dest_in;
				zicsr <= zicsr_in;
				bad_jump <= bad_jump_in;
				ecall <= ecall_in;
				ebreak <= ebreak_in;
				bad_instr <= bad_instr_in;
				invalid <= invalid_in;

			end if;

		end if;

	end process;

	pc_out <= pc;
	res_out <= res;
	rs2_out <= rs2;
	rd_out <= rd;
	funct3_out <= funct3;
	rd_we_out <= rd_we;
	mem_use_out <= mem_use;
	mret_out <= mret;
	csr_result_out <= csr_result;
	csr_dest_out <= csr_dest;
	zicsr_out <= zicsr;
	bad_jump_out <= bad_jump;
	ecall_out <= ecall;
	ebreak_out <= ebreak;
	bad_instr_out <= bad_instr;
	invalid_out <= invalid;

end behavioral ; -- arch