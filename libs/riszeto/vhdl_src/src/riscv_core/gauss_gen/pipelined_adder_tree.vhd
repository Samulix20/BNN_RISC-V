-- Tree of adders (12 x 12 b -> 16 b)
-- Pipelined in 3 stages

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

use work.adder_tree_pkg.all;
use work.of_u_adder_pkg.all;

entity PIPELINED_ADDER_TREE is
    port(
        clk : in std_logic;
        advance : in std_logic;
        data_in : in tree_input_t;
        data_out : out unsigned(15 downto 0)
    );
end PIPELINED_ADDER_TREE;

architecture behavioral of PIPELINED_ADDER_TREE is    

    type l1_t is array (5 downto 0) of unsigned(12 downto 0);
    type l2_t is array (2 downto 0) of unsigned(13 downto 0);
    type l3_t is array (1 downto 0) of unsigned(14 downto 0);

    signal s1, l1_reg : l1_t;
    signal s2, l2_reg : l2_t;
    signal s3, l3_reg : l3_t;
    signal result : unsigned(15 downto 0);

begin

    -- Pipeline register
    process(clk)
    begin
        if rising_edge(clk) then
            if advance = '1' then
                l1_reg <= s1;
                l2_reg <= s2;
                l3_reg <= s3; 
            end if;
        end if;
    end process;

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
            A => l1_reg(2 * I),
            B => l1_reg((2 * I) + 1),
            R => s2(I)
        );
    end generate;
    
    -- 3 rd level of adders (14 b -> 15 b)
    adder_l3 : OF_U_ADDER generic map (
        size => 14
    ) port map (
        A => l2_reg(0),
        B => l2_reg(1),
        R => s3(0)
    );
    s3(1) <= unsigned('0' & std_logic_vector(l2_reg(2)));

    -- 4 th level of adders (15 b -> 16 b)
    adder_l4 : OF_U_ADDER generic map (
        size => 15
    ) port map (
        A => l3_reg(0),
        B => l3_reg(1),
        R => result
    );

    data_out <= result;

end behavioral;
