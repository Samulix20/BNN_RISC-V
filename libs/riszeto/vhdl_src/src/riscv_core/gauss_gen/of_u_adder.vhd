-- Unsinged adder that overflows

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity OF_U_ADDER is
	generic(
		size : natural
	);
	port(
		A   : in unsigned(size - 1 downto 0);
		B   : in unsigned(size - 1 downto 0);
		R   : out unsigned(size downto 0)
	);
end OF_U_ADDER;

architecture behavioral of OF_U_ADDER is

begin

	R <= unsigned('0' & std_logic_vector(A)) + unsigned('0' & std_logic_vector(B));

end behavioral;
