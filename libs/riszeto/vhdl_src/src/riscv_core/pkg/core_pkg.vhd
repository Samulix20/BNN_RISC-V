library IEEE;
use IEEE.STD_LOGIC_1164.all;

package riscv_core_pkg is

    component RISCV_CORE is 
        port (
            clk 	: in std_logic;
            reset	: in std_logic;
            
            -- External interrupts
            ext_irq	: in std_logic;
            tim_irq : in std_logic;

            -- Fetch interface
            fetch 		: out std_logic;
            pc_fetch	: out std_logic_vector (29 downto 0);
            fetch_bus	: in std_logic_vector (31 downto 0);

            -- Mem Bus interface
            write_data	: out std_logic_vector (31 downto 0);
            addr_data	: out std_logic_vector (31 downto 0);
            bus_mode	: out std_logic_vector (2 downto 0);
            bus_we		: out std_logic;
            data_bus	: in std_logic_vector (31 downto 0)
        ); 
    end component;

end package riscv_core_pkg;
