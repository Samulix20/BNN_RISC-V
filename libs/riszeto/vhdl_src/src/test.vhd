
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.riscv_peripherals_pkg.all;
use work.test_config_pkg.all;

entity test is end test;

architecture behavioral of test is

	-- Clock period definitions
	-- 1 MHz
	constant CLK_period : time := 1000 ns;

	component RISCV_BUS is 
	generic (
		ram_addr_bits : integer;
		addr_mtime : std_logic_vector;
		addr_mtimecmp : std_logic_vector
	);
	port (
		clk : in std_logic;
		reset : in std_logic;
		
		-- Bus signals
		read_bus_ext : in std_logic_vector(31 downto 0);
		write_bus_ext : out std_logic_vector(31 downto 0);
		addr_bus_ext : out std_logic_vector(31 downto 0);
		mode_bus_ext : out std_logic_vector(2 downto 0);
		we_bus_ext : out std_logic;
			
		-- External master
		core_enable : in std_logic;
		addr_in : in std_logic_vector(31 downto 0);
		data_in : in std_logic_vector(31 downto 0);
		we_in : in std_logic
	);
	end component;

	-- General signals
	signal CLK, RESET : std_logic;

	-- Out side bus
	signal read_bus, write_bus, addr_bus : std_logic_vector(31 downto 0);
	signal mode_bus : std_logic_vector(2 downto 0);
	signal we_bus : std_logic;

	-- AXI Registers
	signal slv_axi0_we : std_logic;
	signal slv_axi0_write : std_logic_vector(31 downto 0);
	signal slv_axi0 : std_logic_vector(31 downto 0);

begin

	-- Component Instantiation
	proc : RISCV_BUS 
	GENERIC MAP (
		ram_addr_bits => ram_addr_bits,
		addr_mtime => addr_mtime,
		addr_mtimecmp => addr_mtimecmp
	)
	PORT MAP (
		-- General signals
		clk => clk, 
		reset => reset,
		
		-- Bus I/O signals
		read_bus_ext => read_bus,
		write_bus_ext => write_bus,
		addr_bus_ext => addr_bus,
		mode_bus_ext => mode_bus,
		we_bus_ext => we_bus,
		
		-- RAM slave signals
		core_enable => '1',
		addr_in => (others => 'Z'),
		data_in => (others => 'Z'),
		we_in => '0'
	);

	-- Print register
	print_peripheral_register : VHDL_PRINT
	GENERIC MAP (addr => print_peripheral_register_addr)
	PORT MAP (
		reset => reset,
		clk => clk,
		data_in => write_bus,
		addr_data => addr_bus,
		we => we_bus,
		mode => mode_bus,
		data_out => read_bus
	);

	-- Axi bridge tests
	axi1 : AXI_BRIDGE
	GENERIC MAP (addr => x"000A0000")
	PORT MAP (
		reset => reset,
		clk => clk,

		bus_data_in => write_bus,
		bus_data_out => read_bus,
		bus_addr => addr_bus,
		bus_we => we_bus,

		axi_data_in => slv_axi0,
		axi_data_out => slv_axi0_write,
		axi_we => slv_axi0_we
	);

	-- Clock process definitions
	CLK_process : process
	begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
	end process;

	test_proc: process
	begin
		RESET <= '1';
		wait for CLK_period * 3/2;
		RESET <= '0';
		wait;
	end process;

	-- AXI register process
	AXI_process : process(CLK)
	begin
		if (rising_edge(CLK)) then
			if(RESET = '1') then
				slv_axi0 <= (others => '0');
			else
				if(slv_axi0_we = '1') then
					slv_axi0 <= slv_axi0_write;
				end if;
			end if;
		end if;	
	end process;

end behavioral;
