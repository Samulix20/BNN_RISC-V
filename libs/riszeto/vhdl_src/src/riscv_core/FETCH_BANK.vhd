-- FETCH data bank

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity FETCH_BANK_RISC is 
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
end FETCH_BANK_RISC;

architecture behavioral of FETCH_BANK_RISC is

	signal noped : std_logic;
	signal instr_pc, pc4 : std_logic_vector(31 downto 0);

begin

	process(clk)
	begin
		if (rising_edge(clk)) then

			if (reset = '1') then
				noped <= '0';
                instr_pc <= instr_pc_in;
				pc4 <= (others => '0');
			elsif (nop = '1') then
				noped <= '1';
				instr_pc <= instr_pc_in;
				pc4 <= (others => '0');
			elsif (we = '1') then
				noped <= '0';
                instr_pc <= instr_pc_in;
				pc4 <= pc4_in;
			end if;

		end if;

	end process;

	instr_pc_out <= instr_pc;
	pc4_out <= pc4;
	nop_out <= noped;

end behavioral ; -- arch