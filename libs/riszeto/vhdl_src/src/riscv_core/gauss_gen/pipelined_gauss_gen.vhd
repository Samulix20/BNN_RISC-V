-- Gaussian number generator, 12 LFSR -> 12 b ==> 32 b out

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

use work.adder_tree_pkg.all;
use work.lfsr_31_pkg.all;
use work.lfsr_151_144_pkg.all;

entity PIPELINED_GAUSS_GEN_12_12 is
port(
    reset   : in std_logic;
	clk     : in std_logic;
    set     : in std_logic_vector(3 downto 0);
    seed    : in std_logic_vector(30 downto 0);
    gen     : in std_logic;
	value   : out std_logic_vector(31 downto 0)
);
end PIPELINED_GAUSS_GEN_12_12;

architecture behavioral of PIPELINED_GAUSS_GEN_12_12 is

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
    signal final_sum, final_reg : unsigned(15 downto 0);
    signal centered : std_logic_vector(15 downto 0);

    type state_t is (rst, adv4, adv3, adv2, adv1, rdy);
    signal state : state_t;
    signal internal_gen, new_seed : std_logic;
    signal raw_vec : std_logic_vector(150 downto 0);

begin

    -- Decoder
    d0 : for I in 0 to 15 generate 
        set_en(I) <= '1' when I + 1 = unsigned(set) else '0';
    end generate;

    -- Control unit
    new_seed <= '0' when unsigned(set) = 0 or reset = '1' else '1';
    internal_gen <= '0' when reset = '1' or new_seed = '1'
    else            '0' when state = rdy and gen = '0'
    else            '1';

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= rst;
            else
                case state is
                    when rst =>
                        state <= adv4;
					when adv4 =>
						if new_seed = '1' then
							state <= adv4;
						else
							state <= adv3;
						end if;
					when adv3 =>
						if new_seed = '1' then
							state <= adv4;
						else
							state <= adv2;
						end if;
					when adv2 =>
						if new_seed = '1' then
							state <= adv4;
						else
							state <= adv1;
						end if;
					when adv1 =>
						if new_seed = '1' then
							state <= adv4;
						else
							state <= rdy;
						end if;
					when rdy =>
						if new_seed = '1' then
							state <= adv4;
						else
							state <= rdy;
						end if;
                end case;
            end if;
        end if;
    end process;

    --  Generator level
    --f0 : for I in 0 to 11 generate
    --    lsfr : LFSR_31 generic map (
    --        reset_seed => std_logic_vector(to_unsigned(default_seeds(I), 31))
    --    ) port map (
    --        clk => clk,
    --       set => set_en(I),
    --        seed => seed,
    --        shift => internal_gen, 
    --        state => raw_vals(I)
    --    );
    --    tree_input(I) <= unsigned(raw_vals(I)(11 downto 0));
    --end generate;

    lfsr : LFSR_151_144 generic map (
        reset_seed => "0111001100100100110011101101000111101000001000100001000111001100011000101110010111111111011101101110110110110000100001000010010110001101000011111001000"
    ) port map (
        clk => clk,
        set => set_en(0),
        seed => "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" & seed,
        shift => internal_gen,
        state => raw_vec
    );

    f0 : for I in 0 to 11 generate
        tree_input(I) <= unsigned(raw_vec(11 + (I * 12)  downto I * 12));
    end generate;

    -- Tree of adders
    adder : PIPELINED_ADDER_TREE port map (
        clk => clk,
        advance => internal_gen,
        data_in => tree_input,
        data_out => final_sum
    );

    -- Register
    process(clk)
    begin
        if rising_edge(clk) then
            if internal_gen = '1' then
                final_reg <= final_sum;
            end if;
        end if;
    end process;

    -- Center result subtracting mean -- 6 * 2**12 -> 24574
    centered <= std_logic_vector(final_reg - 24574);
    value(31 downto 16) <= (others => centered(15));
    value(15 downto 0) <= centered;

end behavioral;