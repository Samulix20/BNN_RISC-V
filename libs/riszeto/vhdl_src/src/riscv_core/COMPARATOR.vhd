--32 bit integer comparator

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

-- eq   : "000"
-- ne   : "001"
-- lt   : "100"
-- ge   : "101"
-- ltu  : "110"
-- geu  : "111"

entity COMPARATOR_RISC is 
port (
	op1     : in std_logic_vector(31 downto 0);
	op2     : in std_logic_vector(31 downto 0);
	mode    : in std_logic_vector(2 downto 0);
	res     : out std_logic);
end COMPARATOR_RISC;

architecture behavioral of COMPARATOR_RISC is

	signal eq, lt, ge, ltu, geu : std_logic;

begin

	eq <= '1' when op1 = op2 else '0';
	lt <= '1' when signed(op1) < signed(op2) else '0';
	ge <= '1' when signed(op1) >= signed(op2) else '0';
	ltu <= '1' when unsigned(op1) < unsigned(op2) else '0';
	geu <= '1' when unsigned(op1) >= unsigned(op2) else '0';

	res <=	eq when mode = "000"
	else	not eq when mode = "001"
	else	lt when mode = "100"
	else	ge when mode = "101"
	else	ltu when mode = "110"
	else	geu; --to prevent latches
	--else	geu when mode = "111";

end behavioral ; -- arch