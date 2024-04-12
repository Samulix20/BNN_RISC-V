-- Gaussian number generator, 12 LFSR -> 12 b ==> 32 b out

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

use work.adder_tree_pkg.all;
use work.lfsr_31_pkg.all;

entity GAUSS_GEN_12_12 is
port(
	clk     : in std_logic;
    set     : in std_logic_vector(3 downto 0);
    seed    : in std_logic_vector(30 downto 0);
    gen     : in std_logic;
	value   : out std_logic_vector(31 downto 0)
);
end GAUSS_GEN_12_12;

architecture behavioral of GAUSS_GEN_12_12 is

    type raw_vals_t is array (11 downto 0) of std_logic_vector(30 downto 0);
    signal raw_vals : raw_vals_t;
    signal tree_input : tree_input_t;

    type default_seeds_t is array (11 downto 0) of integer;
    signal default_seeds : default_seeds_t := (
        1082159512,
        76811588,
        1439998451,
        73697298,
        1239472396,
        1612362739,
        581446409,
        676345546,
        1310124748,
        806001601,
        942653533,
        1716423834
    );

    -- Decoded signal
    signal set_en : std_logic_vector(15 downto 0);

    -- Number generated
    signal final_sum : unsigned(15 downto 0);
    signal centered : std_logic_vector(15 downto 0);

begin

    -- Decoder
    d0 : for I in 0 to 15 generate 
        set_en(I) <= '1' when I + 1 = unsigned(set) else '0';
    end generate;

    --  Generator level
    f0 : for I in 0 to 11 generate
        lsfr : LFSR_31 generic map (
            reset_seed => std_logic_vector(to_unsigned(default_seeds(I), 31))
        ) port map (
            clk => clk,
            set => set_en(I),
            seed => seed,
            shift => gen, 
            state => raw_vals(I)
        );
        tree_input(I) <= unsigned(raw_vals(I)(11 downto 0));
    end generate;

    -- Tree of adders
    adder : ADDER_TREE port map (
        data_in => tree_input,
        data_out => final_sum
    );

    -- Center result subtracting mean -- 24570
    centered <= std_logic_vector(final_sum - 24570);
    value(31 downto 16) <= (others => centered(15));
    value(15 downto 0) <= centered;

end behavioral;