--32 bit interger ALU

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

-- add    : "0000"
-- sll    : "0001"
-- slt    : "0010"
-- sltu   : "0011"
-- xor    : "0100"
-- srl    : "0101"
-- or     : "0110"
-- and    : "0111"
-- sra    : "1000"
-- sub    : "1001"

entity ALU_RISC is 
port (
	op1     : in std_logic_vector(31 downto 0);
	op2     : in std_logic_vector(31 downto 0);
	mode    : in std_logic_vector(3 downto 0);
	res     : out std_logic_vector(31 downto 0));
end ALU_RISC;

architecture behavioral of ALU_RISC is

	signal slt, sltu : std_logic_vector(31 downto 0);

begin

	slt <= 	(0 => '1', others => '0') when signed(op1) < signed(op2)
			else (others => '0');
	
	sltu <= (0 => '1', others => '0') when unsigned(op1) < unsigned(op2)
			else (others => '0');
	
	res <= 	std_logic_vector(signed(op1) + signed(op2)) when mode = "0000"
	else 	std_logic_vector(shift_left(unsigned(op1), to_integer(unsigned(op2(4 downto 0))))) when mode = "0001"
	else	slt when mode = "0010"
	else	sltu when mode = "0011"
	else	op1 xor op2 when mode = "0100"
	else 	std_logic_vector(shift_right(unsigned(op1), to_integer(unsigned(op2(4 downto 0))))) when mode = "0101"
	else 	op1 or op2 when mode = "0110"
	else 	op1 and op2 when mode = "0111"
	else	std_logic_vector(shift_right(signed(op1), to_integer(unsigned(op2(4 downto 0))))) when mode = "1000"
	else	std_logic_vector(signed(op1) - signed(op2)) when mode = "1001"
	else	(others => '0');

end behavioral ; -- arch