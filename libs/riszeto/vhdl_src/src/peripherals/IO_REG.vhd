-- IO_REG to be used in MMIO

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity IO_REG is 
	generic ( addr : std_logic_vector (31 downto 0));
	port (
		reset		: in std_logic;
		clk 		: in std_logic;

		-- Bus Interface
		data_in 	: in std_logic_vector (31 downto 0);
		addr_data	: in std_logic_vector (31 downto 0);
		we 			: in std_logic;
		mode		: in std_logic_vector (2 downto 0);
		data_out 	: out std_logic_vector (31 downto 0));
end IO_REG;

architecture behavioral of IO_REG is

	-- Regs
	signal bg : std_logic;
	signal saved_byte : std_logic_vector(1 downto 0);
	signal saved_mode : std_logic_vector(2 downto 0);
	signal data : std_logic_vector(31 downto 0);

	-- Signals
	signal we_0, we_1, we_2, we_3, bg_in : std_logic; 
	signal data_in_0, data_in_1, data_in_2, data_in_3 : std_logic_vector(7 downto 0);
	signal data_out_0, data_out_1, data_out_2, data_out_3 : std_logic_vector(7 downto 0);
	signal unsg_byte, sign_byte, unsg_half, sign_half, word : std_logic_vector(31 downto 0);

begin

	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				saved_byte <= "00";
				saved_mode <= "000";
				bg <= '0';
				data <= (others => '0');
			else
				saved_byte <= addr_data(1 downto 0);
				saved_mode <= mode;
				bg <= bg_in;

				if (we_0 = '1') then
					data(7 downto 0) <= data_in_0;
				end if;
				if (we_1 = '1') then
					data(15 downto 8) <= data_in_1;
				end if;
				if (we_2 = '1') then
					data(23 downto 16) <= data_in_2;
				end if;
				if (we_3 = '1') then
					data(31 downto 24) <= data_in_3;
				end if;
			end if;
		end if;
	end process;

	-- In logic
	bg_in <= '1' when addr_data(31 downto 2) = addr(31 downto 2) else '0';

	we_0 <= '1' when we = '1' and (	(mode(1 downto 0) = "00" and addr_data(1 downto 0) = "00") or
									(mode(1 downto 0) = "01" and addr_data(1 downto 0) = "00") or
									(mode(1 downto 0) = "10") ) and bg_in = '1'
	else '0';
	data_in_0 <= data_in(7 downto 0);

	we_1 <= '1' when we = '1' and (	(mode(1 downto 0) = "00" and addr_data(1 downto 0) = "01") or
									(mode(1 downto 0) = "01" and addr_data(1 downto 0) = "00") or
									(mode(1 downto 0) = "10")) and bg_in = '1'
	else '0';
	data_in_1 <= 	data_in(7 downto 0) when mode(1 downto 0) = "00" 
	else 			data_in(15 downto 8);

	we_2 <= '1' when we = '1' and (	(mode(1 downto 0) = "00" and addr_data(1 downto 0) = "10") or
									(mode(1 downto 0) = "01" and addr_data(1 downto 0) = "10") or
									(mode(1 downto 0) = "10")) and bg_in = '1'
	else '0';
	data_in_2 <= 	data_in(7 downto 0) when mode(1 downto 0) = "01" or mode(1 downto 0) = "00"
	else			data_in(23 downto 16);

	we_3 <= '1' when we = '1' and (	(mode(1 downto 0) = "00" and addr_data(1 downto 0) = "11") or
									(mode(1 downto 0) = "01" and addr_data(1 downto 0) = "10") or
									(mode(1 downto 0) = "10")) and bg_in = '1'
	else '0';
	data_in_3 <= 	data_in(7 downto 0) when mode(1 downto 0) = "00"
	else 			data_in(15 downto 8) when mode(1 downto 0) = "01"
	else			data_in(31 downto 24);

	-- Out logic
	data_out_0 <= data(7 downto 0);
	data_out_1 <= data(15 downto 8);
	data_out_2 <= data(23 downto 16);
	data_out_3 <= data(31 downto 24);

	unsg_byte(7 downto 0) <= 	data_out_0 when saved_byte(1 downto 0) = "00"
	else						data_out_1 when saved_byte(1 downto 0) = "01"
	else						data_out_2 when saved_byte(1 downto 0) = "10"
	else						data_out_3;
	unsg_byte(31 downto 8) <= (others => '0');
	sign_byte(7 downto 0) <= unsg_byte(7 downto 0);
	sign_byte(31 downto 8) <= (others => unsg_byte(7));

	unsg_half(15 downto 0) <= 	data_out_1 & data_out_0 when saved_byte(1) = '0'
	else						data_out_3 & data_out_2;
	unsg_half(31 downto 16) <= (others => '0');
	sign_half(15 downto 0) <= unsg_half(15 downto 0);
	sign_half(31 downto 16) <= (others => unsg_half(15));

	word <= data_out_3 & data_out_2 & data_out_1 & data_out_0;

	data_out <= (others => 'Z') when bg = '0'
	else 		sign_byte when saved_mode = "000"
	else		unsg_byte when saved_mode = "100"
	else		sign_half when saved_mode = "001"
	else		unsg_half when saved_mode = "101"
	else		word;

end behavioral;