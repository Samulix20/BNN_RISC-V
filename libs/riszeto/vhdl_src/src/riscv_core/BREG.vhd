-- 32 reg 32 bit integer register bank

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity BREG_RISC is 
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
end BREG_RISC;

architecture behavioral of BREG_RISC is

	type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
	signal reg_file : reg_array;

begin

	process(clk)
	begin

		if falling_edge(clk) then
			
			if reset = '1' then
				reg_file <= (others => (others => '0'));
			elsif we = '1' then
				reg_file(to_integer(unsigned(reg_W))) <= data_in;	
			end if;
			
		end if;

		-- Reg x0 value is always 0
		reg_file(0) <= (others => '0');

	end process;

	data_A <= reg_file(to_integer(unsigned(reg_A)));
	data_B <= reg_file(to_integer(unsigned(reg_B)));

end behavioral;