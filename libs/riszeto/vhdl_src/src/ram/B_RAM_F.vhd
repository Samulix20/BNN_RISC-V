library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity B_RAM_F is
	generic (
		file_path : string;
		addr_bits_used : integer
	);
	port (
		clk 		: in std_logic;
		we 			: in std_logic;
		fetch		: in std_logic;
		addr_inst 	: in std_logic_vector (29 downto 0);
		addr_data	: in std_logic_vector (29 downto 0);
		data_in 	: in std_logic_vector (7 downto 0);

		inst_out 	: out std_logic_vector (7 downto 0);
		data_out 	: out std_logic_vector (7 downto 0)
	);
end B_RAM_F;

architecture behavioral of B_RAM_F is

	constant bram_size : integer := 2**addr_bits_used;

	type ram_type is array (0 to bram_size - 1) of std_logic_vector(7 downto 0);
    
	-- Init ram from files
    impure function init_ram_hex return ram_type is
		file text_file : text open read_mode is file_path;
		variable text_line : line;
		variable ram_content : ram_type;
	begin
		for i in 0 to (bram_size - 1) loop
            if (not endfile(text_file)) then
                readline(text_file, text_line);
                hread(text_line, ram_content(i));
            else
                ram_content(i) := (others => '0');
            end if;
		end loop;
	
		return ram_content;
	end function;
    
    signal ram : ram_type := init_ram_hex;

begin

	process(clk)
	begin
		if (rising_edge(clk)) then
			if (fetch = '1') then
				inst_out <= ram(to_integer(unsigned(addr_inst(addr_bits_used - 1 downto 0))));
			end if;

			if (we = '1') then
				ram(to_integer(unsigned(addr_data(addr_bits_used - 1 downto 0)))) <= data_in;
			end if;
			
			data_out <= ram(to_integer(unsigned(addr_data(addr_bits_used - 1 downto 0))));
		end if;
	end process;

end behavioral ; -- arch
