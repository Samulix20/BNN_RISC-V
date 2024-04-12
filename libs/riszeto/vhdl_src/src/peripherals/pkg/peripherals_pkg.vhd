library IEEE;
use IEEE.STD_LOGIC_1164.all;

package riscv_peripherals_pkg is

	component VHDL_PRINT is 
		generic (
			addr 	: std_logic_vector
		);
		port (
			reset		: in std_logic;
			clk 		: in std_logic;

			-- Bus Interface
			data_in 	: in std_logic_vector (31 downto 0);
			addr_data	: in std_logic_vector (31 downto 0);
			we 			: in std_logic;
			mode		: in std_logic_vector (2 downto 0);
			data_out 	: out std_logic_vector (31 downto 0)
		);
	end component;

	component AXI_BRIDGE is
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
	end component;

	component IO_REG is 
		generic ( 
			addr : std_logic_vector (31 downto 0)
		);
		port (
			reset		: in std_logic;
			clk 		: in std_logic;

			-- Bus Interface
			data_in 	: in std_logic_vector (31 downto 0);
			addr_data	: in std_logic_vector (31 downto 0);
			we 			: in std_logic;
			mode		: in std_logic_vector (2 downto 0);
			data_out 	: out std_logic_vector (31 downto 0));
	end component;

	component MTIMER_RISCV is 
		generic (
			addr_mtime 	    : std_logic_vector(31 downto 0);
			addr_mtimecmp 	: std_logic_vector(31 downto 0)
		);
		port (
			reset		: in std_logic;
			clk 		: in std_logic;
			irq         : out std_logic;

			-- Bus Interface
			data_in 	: in std_logic_vector (31 downto 0);
			addr_data	: in std_logic_vector (31 downto 0);
			we 			: in std_logic;
			mode		: in std_logic_vector (2 downto 0);
			data_out 	: out std_logic_vector (31 downto 0));
	end component;

end package riscv_peripherals_pkg;