
library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.riscv_peripherals_pkg.all;
use work.mem_ram_pkg.all;
use work.riscv_core_pkg.all;

entity RISCV_BUS is 
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
end RISCV_BUS;

architecture behavioral of RISCV_BUS is

	-- General signals
	signal IRQ : std_logic;
	
	-- Fetch Bus
	signal pc_bus : std_logic_vector(29 downto 0);
	signal instr_bus : std_logic_vector(31 downto 0);
	signal fetch_bus : std_logic;

	-- Mem Bus
	signal write_bus : std_logic_vector(31 downto 0);
	signal read_bus : std_logic_vector(31 downto 0);
	signal addr_bus : std_logic_vector(31 downto 0);
	signal mode_bus : std_logic_vector(2 downto 0);
	signal we_bus : std_logic;
	
	-- Dump signal
	signal dump_signal : std_logic_vector(31 downto 0);
	
	-- Core bus interface signals
	signal core_clk : std_logic;
	signal core_write_bus : std_logic_vector(31 downto 0);
	signal core_addr_bus : std_logic_vector(31 downto 0);
	signal core_mode_bus : std_logic_vector(2 downto 0);
	signal core_we_bus : std_logic;

begin

    read_bus <= read_bus_ext; 
    write_bus_ext <= write_bus;
    addr_bus_ext <= addr_bus;
    mode_bus_ext <= mode_bus;
    we_bus_ext <= we_bus;
    
    core_clk <= clk and core_enable;

	-- Component Instantiation
	core : RISCV_CORE 
	PORT MAP (
		clk => core_clk, 
		reset => reset,
		
		tim_irq => irq,
		ext_irq => '0',

		fetch => fetch_bus,
		pc_fetch => pc_bus,
		fetch_bus => instr_bus,

		write_data => core_write_bus,
		addr_data => core_addr_bus,
		bus_mode => core_mode_bus,
		bus_we => core_we_bus,
		data_bus => read_bus
	);
	
	write_bus <= core_write_bus when core_enable = '1' else data_in;
    addr_bus <= core_addr_bus when core_enable = '1' else addr_in;
    mode_bus <= core_mode_bus when core_enable = '1' else "010";
    we_bus <= core_we_bus when core_enable = '1' else we_in;

	mem : MEM_RAM 
	GENERIC MAP (addr_bits_used => ram_addr_bits)
	PORT MAP (
		clk => clk,
		reset => reset,

		fetch => fetch_bus,
		addr_inst => pc_bus,
		inst_out => instr_bus,

		data_in => write_bus,
		addr_data => addr_bus,
		we => we_bus,
		mode => mode_bus,
		data_out => read_bus
	);

	mtimer : MTIMER_RISCV
	GENERIC MAP (addr_mtime => addr_mtime, addr_mtimecmp => addr_mtimecmp)
	PORT MAP (
		reset => reset,
		clk => clk,
		irq => irq,

		-- Bus Interface
		data_in => write_bus,
		addr_data => addr_bus,
		we => we_bus,
		mode => mode_bus,
		data_out => read_bus
	);

end behavioral;
