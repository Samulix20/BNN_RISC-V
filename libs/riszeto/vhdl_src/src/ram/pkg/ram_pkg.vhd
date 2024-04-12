library IEEE;
use IEEE.STD_LOGIC_1164.all;

package mem_ram_pkg is

    component MEM_RAM is 
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
            data_out 	: out std_logic_vector (31 downto 0)
        ); 
    end component;

	component B_RAM_F is
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
	end component;

    component B_RAM_0 is 
	port (
		clk 		: in std_logic;
		we 			: in std_logic;
		fetch      	: in std_logic;
		addr_inst 	: in std_logic_vector (29 downto 0);
		addr_data	: in std_logic_vector (29 downto 0);
		data_in 	: in std_logic_vector (7 downto 0);

		inst_out 	: out std_logic_vector (7 downto 0);
		data_out 	: out std_logic_vector (7 downto 0)); 
	end component;

	component B_RAM_1 is 
	port (
		clk 		: in std_logic;
		we 			: in std_logic;
		fetch      	: in std_logic;
		addr_inst 	: in std_logic_vector (29 downto 0);
		addr_data	: in std_logic_vector (29 downto 0);
		data_in 	: in std_logic_vector (7 downto 0);

		inst_out 	: out std_logic_vector (7 downto 0);
		data_out 	: out std_logic_vector (7 downto 0)); 
	end component;

	component B_RAM_2 is 
	port (
		clk 		: in std_logic;
		we 			: in std_logic;
		fetch      	: in std_logic;
		addr_inst 	: in std_logic_vector (29 downto 0);
		addr_data	: in std_logic_vector (29 downto 0);
		data_in 	: in std_logic_vector (7 downto 0);

		inst_out 	: out std_logic_vector (7 downto 0);
		data_out 	: out std_logic_vector (7 downto 0)); 
	end component;

	component B_RAM_3 is 
	port (
		clk 		: in std_logic;
		we 			: in std_logic;
		fetch 		: in std_logic;
		addr_inst 	: in std_logic_vector (29 downto 0);
		addr_data	: in std_logic_vector (29 downto 0);
		data_in 	: in std_logic_vector (7 downto 0);

		inst_out 	: out std_logic_vector (7 downto 0);
		data_out 	: out std_logic_vector (7 downto 0)); 
	end component;

end package mem_ram_pkg;


