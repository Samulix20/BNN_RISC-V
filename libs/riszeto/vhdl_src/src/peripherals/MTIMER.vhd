-- RISCV MTIMER module
-- Only supports word access

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

-- Addr layout
-- mtime
-- hmtime
-- mtimecmp
-- hmtimecmp

entity MTIMER_RISCV is 
	generic (
		addr_mtime 	    : std_logic_vector(31 downto 0);
		addr_mtimecmp 	: std_logic_vector(31 downto 0));
	port (
		reset		: in std_logic;
		clk 		: in std_logic;
		irq         : out std_logic;

		-- Bus Interface
		data_in 	: in std_logic_vector (31 downto 0);
		addr_data	: in std_logic_vector (31 downto 0);
		we 			: in std_logic;
		mode		: in std_logic_vector (2 downto 0);
		data_out 	: out std_logic_vector (31 downto 0));
end MTIMER_RISCV;

architecture behavioral of MTIMER_RISCV is

	-- Regs
	signal mtime, mtimecmp : std_logic_vector(63 downto 0);
	signal saved_ra : std_logic_vector(2 downto 0);

	-- Signals
	signal we_time, we_htime, we_cmp, we_hcmp : std_logic;
	signal ra : std_logic_vector(2 downto 0);

begin

	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				saved_ra <= "000";
				mtime <= (others => '0');
				mtimecmp <= (others => '1'); -- Highest value to avoid interrupts
			else
				saved_ra <= ra;
				
				if (we_time = '1' or we_htime = '1') then
					if (we_time = '1') then
						mtime(31 downto 0) <= data_in;
					else
						mtime(63 downto 32) <= data_in;
					end if;
				else
					mtime <= std_logic_vector(unsigned(mtime) + 1); 
				end if;

				if (we_cmp = '1') then
					mtimecmp(31 downto 0) <= data_in;
				elsif (we_hcmp = '1') then
					mtimecmp(63 downto 32) <= data_in;
				end if;

			end if;
		end if;
	end process;

	-- In logic
	ra <= 	"100" when addr_data = addr_mtime
	else	"101" when unsigned(addr_data) = unsigned(addr_mtime) + 4
	else	"110" when addr_data = addr_mtimecmp
	else	"111" when unsigned(addr_data) = unsigned(addr_mtimecmp) + 4
	else	"000";

	we_time <= '1' when ra = "100" and we = '1' else '0';
	we_htime <= '1' when ra = "101" and we = '1' else '0';
	we_cmp <= '1' when ra = "110" and we = '1' else '0';
	we_hcmp <= '1' when ra = "111" and we = '1' else '0';

	-- Out logic
	data_out <=	mtime(31 downto 0) when saved_ra = "100"
	else		mtime(63 downto 32) when saved_ra = "101"
	else		mtimecmp(31 downto 0) when saved_ra = "110"
	else		mtimecmp(63 downto 32) when saved_ra = "111"
	else 		(others => 'Z');
	

	-- Timer logic
	irq <= '1' when unsigned(mtime) >= unsigned(mtimecmp) else '0';

end behavioral;