-- RISC CSR MSTATUS

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity MSTATUS_RISC is 
	port (
		clk 		: in std_logic;
		reset		: in std_logic;
		we			: in std_logic;
		data_in		: in std_logic_vector(31 downto 0);
		data_out	: out std_logic_vector(31 downto 0));
end MSTATUS_RISC;

architecture behavioral of MSTATUS_RISC is

	-- MIE -> Machine interrupt enable
	-- 		1 enable interrupts
	-- 		0 disable interrupts
	-- MPIE -> Machine prior interrupt enable
	-- MPP -> Machine prior privilege 
	-- MPRV -> Modify privilege (does nothing but its required by the spec)
	-- TW -> '1', always trap WFI in lower privilege levels
	signal MIE, MPIE, MPP, MPRV : std_logic;

begin

	process(clk)
	begin
		if (rising_edge(clk)) then

			if (reset = '1') then

				MIE <= '0';
				MPP <= '1';
				MPIE <= '0';
				MPRV <= '0';

			elsif (we = '1') then
				
				MIE <= data_in(3);
				MPIE <= data_in(7);
				MPP <= data_in(11);
				MPRV <= data_in(17);

			end if;

		end if;

	end process;

	data_out <= (
		3 => MIE,
		7 => MPIE,
		11 => MPP,
		12 => MPP,
		17 => MPRV,
		21 => '1',
		others => '0'
	);

end behavioral ; -- arch