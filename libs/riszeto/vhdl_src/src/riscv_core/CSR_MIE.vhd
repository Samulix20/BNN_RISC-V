-- RISC CSR MIE

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity MIE_RISC is 
	port (
		clk 		: in std_logic;
		reset		: in std_logic;
		we			: in std_logic;
		data_in		: in std_logic_vector(31 downto 0);
		data_out	: out std_logic_vector(31 downto 0));
end MIE_RISC;

architecture behavioral of MIE_RISC is

	-- MEIP External interrupt enable (bit 11)
    -- MTIP Timer interrupt enable (bit 7)
	signal MEIP, MTIP : std_logic;

begin

	process(clk)
	begin
		if (rising_edge(clk)) then

			if (reset = '1') then

				MEIP <= '0';
                MTIP <= '0';

			elsif (we = '1') then

                MEIP <= data_in(11);
                MTIP <= data_in(7);

			end if;

		end if;

	end process;

	data_out <= (
		7 => MTIP,
		11 => MEIP,
		others => '0'
	);

end behavioral ; -- arch