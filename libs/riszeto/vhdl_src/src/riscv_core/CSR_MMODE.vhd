-- RISC CSR MMODE

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity MMODE_RISC is 
	port (
		clk 		: in std_logic;
		reset		: in std_logic;
		we			: in std_logic;
		data_in		: in std_logic;
		data_out	: out std_logic);
end MMODE_RISC;

architecture behavioral of MMODE_RISC is

	-- Modes
	-- U -> 0
	-- M -> 1
	signal mode : std_logic;

begin

	process(clk)
	begin
		if (rising_edge(clk)) then

			if (reset = '1') then
				mode <= '1';
			elsif (we = '1') then
				mode <= data_in;
			end if;

		end if;

	end process;

	data_out <= mode;

end behavioral ; -- arch
