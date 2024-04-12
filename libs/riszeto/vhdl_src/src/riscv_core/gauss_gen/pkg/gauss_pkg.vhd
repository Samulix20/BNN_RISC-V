library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package of_u_adder_pkg is

    component OF_U_ADDER is
        generic(
            size : natural
        );
        port(
            A   : in unsigned(size - 1 downto 0);
            B   : in unsigned(size - 1 downto 0);
            R   : out unsigned(size downto 0)
        );
    end component;

end package of_u_adder_pkg;

---------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package adder_tree_pkg is

    type tree_input_t is array (11 downto 0) of unsigned(11 downto 0);

    component ADDER_TREE is
        port(
            data_in : in tree_input_t;
            data_out : out unsigned(15 downto 0)
        );
    end component;

    component PIPELINED_ADDER_TREE is
        port(
            clk : in std_logic;
            advance : in std_logic;
            data_in : in tree_input_t;
            data_out : out unsigned(15 downto 0)
        );
    end component;

end package adder_tree_pkg;

-----------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package lfsr_31_pkg is

    component LFSR_31 is
        generic(
		    reset_seed : std_logic_vector(30 downto 0)
	    );
        port(
            clk     : in std_logic;
            set     : in std_logic;
            shift	: in std_logic;
            seed    : in std_logic_vector(30 downto 0);
            state   : out std_logic_vector(30 downto 0)
        );
    end component;

end package lfsr_31_pkg;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package lfsr_151_144_pkg is

    component LFSR_151_144 is
        generic(
            reset_seed : std_logic_vector(150 downto 0)
        );
        port(
            clk     : in std_logic;
            set     : in std_logic;
            shift	: in std_logic;
            seed    : in std_logic_vector(150 downto 0);
            state   : out std_logic_vector(150 downto 0)
        );
    end component;

end package lfsr_151_144_pkg;


-----------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package gaus_gen_pkg is

    component GAUSS_GEN_12_12 is
        port(
            clk     : in std_logic;
            set     : in std_logic_vector(3 downto 0);
            seed    : in std_logic_vector(30 downto 0);
            gen     : in std_logic;
            value   : out std_logic_vector(31 downto 0)
        );
    end component;

    component PIPELINED_GAUSS_GEN_12_12 is
        port(
            reset   : in std_logic;
            clk     : in std_logic;
            set     : in std_logic_vector(3 downto 0);
            seed    : in std_logic_vector(30 downto 0);
            gen     : in std_logic;
            value   : out std_logic_vector(31 downto 0)
        );
    end component;

end package gaus_gen_pkg;
