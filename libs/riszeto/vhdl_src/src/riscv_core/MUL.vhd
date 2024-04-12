--32 bit interger RISCV multiplier unit

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

-- mul      : "00"
-- mulh     : "01"
-- mulhsu   : "10"
-- mulhu    : "11"

entity MUL_RISCV is 
port (
	op1     : in std_logic_vector(31 downto 0);
	op2     : in std_logic_vector(31 downto 0);
	mode    : in std_logic_vector(1 downto 0);
	res     : out std_logic_vector(31 downto 0));
end MUL_RISCV;

architecture behavioral of MUL_RISCV is

    signal smul, umul : std_logic_vector(63 downto 0);
    signal sumul_op1, sumul_op2 : std_logic_vector(32 downto 0);
    signal sumul : std_logic_vector(65 downto 0);

begin

    smul <= std_logic_vector(signed(op1) * signed(op2));
    umul <= std_logic_vector(unsigned(op1) * unsigned(op2));

    -- Signed x Unsigned multiplication
    -- Signed extension to 33 bits
    sumul_op1(31 downto 0) <= op1;
    sumul_op1(32) <= op1(31);
    -- Unsigned extension to 33 bits
    sumul_op2(31 downto 0) <= op2;
    sumul_op2(32) <= '0';
    -- 33 bits multiplication, ignore 66-65 bits of the result
    sumul <= std_logic_vector(signed(sumul_op1) * signed(sumul_op2));

    res <=  smul(31 downto 0) when mode = "00"
    else    smul(63 downto 32) when mode = "01"
    else    sumul(63 downto 32) when mode = "10"
    else    umul(63 downto 32);

end behavioral;

