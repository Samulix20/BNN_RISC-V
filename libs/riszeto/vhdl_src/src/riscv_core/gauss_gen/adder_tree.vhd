-- Tree of adders (12 x 12 b -> 16 b)

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

use work.adder_tree_pkg.all;
use work.of_u_adder_pkg.all;

entity ADDER_TREE is
    port(
        data_in : in tree_input_t;
        data_out : out unsigned(15 downto 0)
    );
end ADDER_TREE;

architecture behavioral of ADDER_TREE is    

    type l1_t is array (5 downto 0) of unsigned(12 downto 0);
    type l2_t is array (2 downto 0) of unsigned(13 downto 0);
    type l3_t is array (1 downto 0) of unsigned(14 downto 0);

    signal s1 : l1_t;
    signal s2 : l2_t;
    signal s3 : l3_t;
    signal result : unsigned(15 downto 0);

begin

	-- 1 st level of adders (12 b -> 13 b)
    l1_for : for I in 0 to 5 generate
        adder : OF_U_ADDER generic map (
            size => 12
        ) port map (
            A => data_in(2 * I),
            B => data_in((2 * I) + 1),
            R => s1(I)
        );
    end generate;

    -- 2 nd level of adders (13 b -> 14 b)
    l2_for : for I in 0 to 2 generate
        adder : OF_U_ADDER generic map (
            size => 13
        ) port map (
            A => s1(2 * I),
            B => s1((2 * I) + 1),
            R => s2(I)
        );
    end generate;
    
    -- 3 rd level of adders (14 b -> 15 b)
    adder_l3 : OF_U_ADDER generic map (
        size => 14
    ) port map (
        A => s2(0),
        B => s2(1),
        R => s3(0)
    );
    s3(1) <= unsigned('0' & std_logic_vector(s2(2)));

    -- 4 th level of adders (15 b -> 16 b)
    adder_l4 : OF_U_ADDER generic map (
        size => 15
    ) port map (
        A => s3(0),
        B => s3(1),
        R => result
    );

    data_out <= result;

end behavioral;
