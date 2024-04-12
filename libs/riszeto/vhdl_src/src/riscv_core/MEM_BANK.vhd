-- DECODE data bank

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity MEM_BANK_RISC is 
port (
	clk 	        : in std_logic;
	reset	        : in std_logic;
	we 		        : in std_logic;

	res_in	    : in std_logic_vector(31 downto 0);
	rd_in       : in std_logic_vector(4 downto 0);
	rd_mux_in	: in std_logic;
	rd_we_in    : in std_logic;

	res_out		: out std_logic_vector(31 downto 0);
	rd_out      : out std_logic_vector(4 downto 0);
	rd_mux_out	: out std_logic;
	rd_we_out   : out std_logic
	);
end MEM_BANK_RISC;

architecture behavioral of MEM_BANK_RISC is

	signal res : std_logic_vector(31 downto 0);
	signal rd : std_logic_vector(4 downto 0);
	signal rd_we, rd_mux : std_logic;

begin

	process(clk)
	begin
		if (rising_edge(clk)) then

			if (reset = '1') then
				res <= (others => '0');
				rd <= (others => '0');
				rd_we <= '0';
				rd_mux <= '0';
			elsif (we = '1') then
				res <= res_in;
				rd <= rd_in;
				rd_we <= rd_we_in;
				rd_mux <= rd_mux_in;
			end if;

		end if;

	end process;

	res_out <= res;
	rd_out <= rd;
	rd_we_out <= rd_we;
	rd_mux_out <= rd_mux;

end behavioral ; -- arch