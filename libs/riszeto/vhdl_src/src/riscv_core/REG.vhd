
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity REG is 
	generic (size : natural);
	port (
		clk 		: in std_logic;
		reset		: in std_logic;
		we			: in std_logic;
		data_in		: in std_logic_vector(size-1 downto 0);
		data_out	: out std_logic_vector(size-1 downto 0));
end REG;

architecture behavioral of REG is

	signal data : std_logic_vector(size-1 downto 0);

begin

	process(clk)
	begin
		if (rising_edge(clk)) then

			if (reset = '1') then
				data <= (others => '0');
			elsif (we = '1') then
				data <= data_in;
			end if;

		end if;

	end process;

	data_out <= data;

end behavioral ; -- arch
