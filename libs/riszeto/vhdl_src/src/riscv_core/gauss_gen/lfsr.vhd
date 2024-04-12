-- 31 bit Max linear-feedback shift register 

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity LFSR_31 is
	generic(
		reset_seed : std_logic_vector(30 downto 0)
	);
	port(
		clk     : in std_logic;
		set     : in std_logic;
		shift	: in std_logic;
		seed    : in std_logic_vector(30 downto 0);
		state   : out std_logic_vector(30 downto 0)
	);
end LFSR_31;

architecture behavioral of LFSR_31 is

	signal internal_state : std_logic_vector(30 downto 0) := reset_seed;
	signal feedback : std_logic;

begin

	process(clk)
	begin
		if rising_edge(clk) then
			
			if set = '1' then
				internal_state <= seed;
			elsif shift = '1' then
				internal_state <= feedback & internal_state(30 downto 1);
			end if;

		end if;
	end process;

	feedback <= internal_state(3) xor internal_state(0);
	state <= internal_state;

end behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity LFSR_151_144 is
	generic(
		reset_seed : std_logic_vector(150 downto 0)
	);
	port(
		clk     : in std_logic;
		set     : in std_logic;
		shift	: in std_logic;
		seed    : in std_logic_vector(150 downto 0);
		state   : out std_logic_vector(150 downto 0)
	);
end LFSR_151_144;

architecture behavioral of LFSR_151_144 is

	signal internal_state : std_logic_vector(150 downto 0) := reset_seed;
	signal next_state : std_logic_vector(150 downto 0);

begin

	process(clk)
	begin
		if rising_edge(clk) then
			
			if set = '1' then
				internal_state <= seed;
			elsif shift = '1' then
				internal_state <= next_state;
			end if;

		end if;
	end process;

	state <= internal_state;

	next_state(150) <= internal_state(146) xor internal_state(143);
	next_state(149) <= internal_state(145) xor internal_state(142);
	next_state(148) <= internal_state(144) xor internal_state(141);
	next_state(147) <= internal_state(143) xor internal_state(140);
	next_state(146) <= internal_state(142) xor internal_state(139);
	next_state(145) <= internal_state(141) xor internal_state(138);
	next_state(144) <= internal_state(140) xor internal_state(137);
	next_state(143) <= internal_state(139) xor internal_state(136);
	next_state(142) <= internal_state(138) xor internal_state(135);
	next_state(141) <= internal_state(137) xor internal_state(134);
	next_state(140) <= internal_state(136) xor internal_state(133);
	next_state(139) <= internal_state(135) xor internal_state(132);
	next_state(138) <= internal_state(134) xor internal_state(131);
	next_state(137) <= internal_state(133) xor internal_state(130);
	next_state(136) <= internal_state(132) xor internal_state(129);
	next_state(135) <= internal_state(131) xor internal_state(128);
	next_state(134) <= internal_state(130) xor internal_state(127);
	next_state(133) <= internal_state(129) xor internal_state(126);
	next_state(132) <= internal_state(128) xor internal_state(125);
	next_state(131) <= internal_state(127) xor internal_state(124);
	next_state(130) <= internal_state(126) xor internal_state(123);
	next_state(129) <= internal_state(125) xor internal_state(122);
	next_state(128) <= internal_state(124) xor internal_state(121);
	next_state(127) <= internal_state(123) xor internal_state(120);
	next_state(126) <= internal_state(122) xor internal_state(119);
	next_state(125) <= internal_state(121) xor internal_state(118);
	next_state(124) <= internal_state(120) xor internal_state(117);
	next_state(123) <= internal_state(119) xor internal_state(116);
	next_state(122) <= internal_state(118) xor internal_state(115);
	next_state(121) <= internal_state(117) xor internal_state(114);
	next_state(120) <= internal_state(116) xor internal_state(113);
	next_state(119) <= internal_state(115) xor internal_state(112);
	next_state(118) <= internal_state(114) xor internal_state(111);
	next_state(117) <= internal_state(113) xor internal_state(110);
	next_state(116) <= internal_state(112) xor internal_state(109);
	next_state(115) <= internal_state(111) xor internal_state(108);
	next_state(114) <= internal_state(110) xor internal_state(107);
	next_state(113) <= internal_state(109) xor internal_state(106);
	next_state(112) <= internal_state(108) xor internal_state(105);
	next_state(111) <= internal_state(107) xor internal_state(104);
	next_state(110) <= internal_state(106) xor internal_state(103);
	next_state(109) <= internal_state(105) xor internal_state(102);
	next_state(108) <= internal_state(104) xor internal_state(101);
	next_state(107) <= internal_state(103) xor internal_state(100);
	next_state(106) <= internal_state(102) xor internal_state(99);
	next_state(105) <= internal_state(101) xor internal_state(98);
	next_state(104) <= internal_state(100) xor internal_state(97);
	next_state(103) <= internal_state(99) xor internal_state(96);
	next_state(102) <= internal_state(98) xor internal_state(95);
	next_state(101) <= internal_state(97) xor internal_state(94);
	next_state(100) <= internal_state(96) xor internal_state(93);
	next_state(99) <= internal_state(95) xor internal_state(92);
	next_state(98) <= internal_state(94) xor internal_state(91);
	next_state(97) <= internal_state(93) xor internal_state(90);
	next_state(96) <= internal_state(92) xor internal_state(89);
	next_state(95) <= internal_state(91) xor internal_state(88);
	next_state(94) <= internal_state(90) xor internal_state(87);
	next_state(93) <= internal_state(89) xor internal_state(86);
	next_state(92) <= internal_state(88) xor internal_state(85);
	next_state(91) <= internal_state(87) xor internal_state(84);
	next_state(90) <= internal_state(86) xor internal_state(83);
	next_state(89) <= internal_state(85) xor internal_state(82);
	next_state(88) <= internal_state(84) xor internal_state(81);
	next_state(87) <= internal_state(83) xor internal_state(80);
	next_state(86) <= internal_state(82) xor internal_state(79);
	next_state(85) <= internal_state(81) xor internal_state(78);
	next_state(84) <= internal_state(80) xor internal_state(77);
	next_state(83) <= internal_state(79) xor internal_state(76);
	next_state(82) <= internal_state(78) xor internal_state(75);
	next_state(81) <= internal_state(77) xor internal_state(74);
	next_state(80) <= internal_state(76) xor internal_state(73);
	next_state(79) <= internal_state(75) xor internal_state(72);
	next_state(78) <= internal_state(74) xor internal_state(71);
	next_state(77) <= internal_state(73) xor internal_state(70);
	next_state(76) <= internal_state(72) xor internal_state(69);
	next_state(75) <= internal_state(71) xor internal_state(68);
	next_state(74) <= internal_state(70) xor internal_state(67);
	next_state(73) <= internal_state(69) xor internal_state(66);
	next_state(72) <= internal_state(68) xor internal_state(65);
	next_state(71) <= internal_state(67) xor internal_state(64);
	next_state(70) <= internal_state(66) xor internal_state(63);
	next_state(69) <= internal_state(65) xor internal_state(62);
	next_state(68) <= internal_state(64) xor internal_state(61);
	next_state(67) <= internal_state(63) xor internal_state(60);
	next_state(66) <= internal_state(62) xor internal_state(59);
	next_state(65) <= internal_state(61) xor internal_state(58);
	next_state(64) <= internal_state(60) xor internal_state(57);
	next_state(63) <= internal_state(59) xor internal_state(56);
	next_state(62) <= internal_state(58) xor internal_state(55);
	next_state(61) <= internal_state(57) xor internal_state(54);
	next_state(60) <= internal_state(56) xor internal_state(53);
	next_state(59) <= internal_state(55) xor internal_state(52);
	next_state(58) <= internal_state(54) xor internal_state(51);
	next_state(57) <= internal_state(53) xor internal_state(50);
	next_state(56) <= internal_state(52) xor internal_state(49);
	next_state(55) <= internal_state(51) xor internal_state(48);
	next_state(54) <= internal_state(50) xor internal_state(47);
	next_state(53) <= internal_state(49) xor internal_state(46);
	next_state(52) <= internal_state(48) xor internal_state(45);
	next_state(51) <= internal_state(47) xor internal_state(44);
	next_state(50) <= internal_state(46) xor internal_state(43);
	next_state(49) <= internal_state(45) xor internal_state(42);
	next_state(48) <= internal_state(44) xor internal_state(41);
	next_state(47) <= internal_state(43) xor internal_state(40);
	next_state(46) <= internal_state(42) xor internal_state(39);
	next_state(45) <= internal_state(41) xor internal_state(38);
	next_state(44) <= internal_state(40) xor internal_state(37);
	next_state(43) <= internal_state(39) xor internal_state(36);
	next_state(42) <= internal_state(38) xor internal_state(35);
	next_state(41) <= internal_state(37) xor internal_state(34);
	next_state(40) <= internal_state(36) xor internal_state(33);
	next_state(39) <= internal_state(35) xor internal_state(32);
	next_state(38) <= internal_state(34) xor internal_state(31);
	next_state(37) <= internal_state(33) xor internal_state(30);
	next_state(36) <= internal_state(32) xor internal_state(29);
	next_state(35) <= internal_state(31) xor internal_state(28);
	next_state(34) <= internal_state(30) xor internal_state(27);
	next_state(33) <= internal_state(29) xor internal_state(26);
	next_state(32) <= internal_state(28) xor internal_state(25);
	next_state(31) <= internal_state(27) xor internal_state(24);
	next_state(30) <= internal_state(26) xor internal_state(23);
	next_state(29) <= internal_state(25) xor internal_state(22);
	next_state(28) <= internal_state(24) xor internal_state(21);
	next_state(27) <= internal_state(23) xor internal_state(20);
	next_state(26) <= internal_state(22) xor internal_state(19);
	next_state(25) <= internal_state(21) xor internal_state(18);
	next_state(24) <= internal_state(20) xor internal_state(17);
	next_state(23) <= internal_state(19) xor internal_state(16);
	next_state(22) <= internal_state(18) xor internal_state(15);
	next_state(21) <= internal_state(17) xor internal_state(14);
	next_state(20) <= internal_state(16) xor internal_state(13);
	next_state(19) <= internal_state(15) xor internal_state(12);
	next_state(18) <= internal_state(14) xor internal_state(11);
	next_state(17) <= internal_state(13) xor internal_state(10);
	next_state(16) <= internal_state(12) xor internal_state(9);
	next_state(15) <= internal_state(11) xor internal_state(8);
	next_state(14) <= internal_state(10) xor internal_state(7);
	next_state(13) <= internal_state(9) xor internal_state(6);
	next_state(12) <= internal_state(8) xor internal_state(5);
	next_state(11) <= internal_state(7) xor internal_state(4);
	next_state(10) <= internal_state(6) xor internal_state(3);
	next_state(9) <= internal_state(5) xor internal_state(2);
	next_state(8) <= internal_state(4) xor internal_state(1);
	next_state(7) <= internal_state(3) xor internal_state(0);
	next_state(6) <= internal_state(150);
	next_state(5) <= internal_state(149);
	next_state(4) <= internal_state(148);
	next_state(3) <= internal_state(147);
	next_state(2) <= internal_state(146);
	next_state(1) <= internal_state(145);
	next_state(0) <= internal_state(144);

end behavioral;
