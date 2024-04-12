-- RISCV_BUS - 1 AXI REGISTER BRIDGE
-- ONLY SUPPORTS WORD ACCESS

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity AXI_BRIDGE is
	generic(addr : std_logic_vector);
	port (
		reset	: in std_logic;
		clk		: in std_logic;

		-- Bus Interface
		bus_data_in 	: in std_logic_vector (31 downto 0);
		bus_data_out 	: out std_logic_vector (31 downto 0);
		bus_addr		: in std_logic_vector (31 downto 0);
		bus_we 			: in std_logic;

		-- AXI Interface
		axi_data_in		: in std_logic_vector (31 downto 0);
		axi_data_out	: out std_logic_vector (31 downto 0);
		axi_we			: out std_logic
	);
end AXI_BRIDGE;

architecture behavioral of AXI_BRIDGE is

	-- Signals
	signal we_in, bg_in, bg : std_logic; 

begin

	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				bg <= '0';
			else
				bg <= bg_in;
			end if;
		end if;
	end process;

	-- Check bus grant
	bg_in <= '1' when bus_addr = addr else '0';

	-- AXI out logic
	axi_data_out <= bus_data_in;
	axi_we <= bus_we and bg_in;

	-- Write AXI data to bus if granted
	bus_data_out <= axi_data_in when bg = '1' else (others => 'Z');

end behavioral;