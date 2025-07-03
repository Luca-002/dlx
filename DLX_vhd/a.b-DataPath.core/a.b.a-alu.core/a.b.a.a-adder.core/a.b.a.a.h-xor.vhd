library IEEE;
use IEEE.std_logic_1164.all; 
entity xor_gate is
	Port (	A,B:	In	std_logic;
		Y:	Out	std_logic);
end xor_gate;


architecture BEHAVIORAL of xor_gate is

begin
	Y <= A XOR B;

end BEHAVIORAL;