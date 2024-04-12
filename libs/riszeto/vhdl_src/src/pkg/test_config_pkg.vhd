library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

package test_config_pkg is

    -- Default/Example Generic constants
	constant ram_addr_bits : integer := 17;
	constant print_peripheral_register_addr : std_logic_vector := x"00400000";
	constant addr_mtime : std_logic_vector := x"00500000";
	constant addr_mtimecmp : std_logic_vector := std_logic_vector(unsigned(addr_mtime) + 8);

end package test_config_pkg;
