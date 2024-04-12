-- RISC RAM
-- Little Endian

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

use work.mem_ram_pkg.all;

-- Mode
-- "000" signed byte
-- "100" unsigned byte
-- "001" signed half (16 bits)
-- "101" unsigned half (16 bits)
-- "010" word (32 bits)

entity MEM_RAM is 
	generic (
		addr_bits_used : integer
	);
	port (
		reset		: in std_logic;
		clk 		: in std_logic;
		we 			: in std_logic;
		fetch		: in std_logic;
		mode		: in std_logic_vector (2 downto 0);
		addr_inst 	: in std_logic_vector (29 downto 0);
		addr_data	: in std_logic_vector (31 downto 0);

		data_in 	: in std_logic_vector (31 downto 0);

		inst_out 	: out std_logic_vector (31 downto 0);
		data_out 	: out std_logic_vector (31 downto 0)); 
end MEM_RAM;

architecture behavioral of MEM_RAM is

	signal we_0, we_1, we_2, we_3, bg_in : std_logic; 
	signal data_in_0, data_in_1, data_in_2, data_in_3 : std_logic_vector(7 downto 0);
	signal data_out_0, data_out_1, data_out_2, data_out_3 : std_logic_vector(7 downto 0);
	signal unsg_byte, sign_byte, unsg_half, sign_half, word : std_logic_vector(31 downto 0);

	signal saved_byte : std_logic_vector(1 downto 0);
	signal saved_mode : std_logic_vector(2 downto 0);
	signal bg : std_logic;

	constant total_ram_size : integer := 2 ** addr_bits_used;
	constant bank_addr_bits : integer := addr_bits_used - 2;

begin

	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				saved_byte <= "00";
				saved_mode <= "000";
				bg <= '0';
			else
				saved_byte <= addr_data(1 downto 0);
				saved_mode <= mode;
				bg <= bg_in;
			end if;
		end if;
	end process;

	bg_in <= '1' when unsigned(addr_data) < to_unsigned(total_ram_size,32) else '0';

	we_0 <= '1' when we = '1' and (	(mode(1 downto 0) = "00" and addr_data(1 downto 0) = "00") or
									(mode(1 downto 0) = "01" and addr_data(1 downto 0) = "00") or
									(mode(1 downto 0) = "10") ) and bg_in = '1'
	else '0';

	data_in_0 <= data_in(7 downto 0);

	bank_0 : B_RAM_F
	GENERIC MAP (
		file_path => "ram0_content.txt",
		addr_bits_used => bank_addr_bits
	)
	PORT MAP (
		clk => clk,
		we => we_0,
		fetch => fetch,
		addr_inst => addr_inst,
		addr_data => addr_data(31 downto 2),
		data_in => data_in_0,
		inst_out => inst_out(7 downto 0),
		data_out => data_out_0 
	);

	we_1 <= '1' when we = '1' and (	(mode(1 downto 0) = "00" and addr_data(1 downto 0) = "01") or
									(mode(1 downto 0) = "01" and addr_data(1 downto 0) = "00") or
									(mode(1 downto 0) = "10")) and bg_in = '1'
	else '0';

	data_in_1 <= 	data_in(7 downto 0) when mode(1 downto 0) = "00" 
	else 			data_in(15 downto 8);

	bank_1 : B_RAM_F
	GENERIC MAP (
		file_path => "ram1_content.txt",
		addr_bits_used => bank_addr_bits
	)
	PORT MAP (
		clk => clk,
		we => we_1,
		fetch => fetch,
		addr_inst => addr_inst,
		addr_data => addr_data(31 downto 2),
		data_in => data_in_1,
		inst_out => inst_out(15 downto 8),
		data_out => data_out_1
	);

	we_2 <= '1' when we = '1' and (	(mode(1 downto 0) = "00" and addr_data(1 downto 0) = "10") or
									(mode(1 downto 0) = "01" and addr_data(1 downto 0) = "10") or
									(mode(1 downto 0) = "10")) and bg_in = '1'
	else '0';

	data_in_2 <= 	data_in(7 downto 0) when mode(1 downto 0) = "01" or mode(1 downto 0) = "00"
	else			data_in(23 downto 16);

	bank_2 : B_RAM_F
	GENERIC MAP (
		file_path => "ram2_content.txt",
		addr_bits_used => bank_addr_bits
	)
	PORT MAP (
		clk => clk,
		we => we_2,
		fetch => fetch,
		addr_inst => addr_inst,
		addr_data => addr_data(31 downto 2),
		data_in => data_in_2,
		inst_out => inst_out(23 downto 16),
		data_out => data_out_2
	);

	we_3 <= '1' when we = '1' and (	(mode(1 downto 0) = "00" and addr_data(1 downto 0) = "11") or
									(mode(1 downto 0) = "01" and addr_data(1 downto 0) = "10") or
									(mode(1 downto 0) = "10")) and bg_in = '1'
	else '0';

	data_in_3 <= 	data_in(7 downto 0) when mode(1 downto 0) = "00"
	else 			data_in(15 downto 8) when mode(1 downto 0) = "01"
	else			data_in(31 downto 24);

	bank_3 : B_RAM_F
	GENERIC MAP (
		file_path => "ram3_content.txt",
		addr_bits_used => bank_addr_bits
	)
	PORT MAP (
		clk => clk,
		we => we_3,
		fetch => fetch,
		addr_inst => addr_inst,
		addr_data => addr_data(31 downto 2),
		data_in => data_in_3,
		inst_out => inst_out(31 downto 24),
		data_out => data_out_3
	);

	-- Generate output signed/unsigned byte/half/word
	-- With values of data registers of mem banks
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

end behavioral ; -- arch

