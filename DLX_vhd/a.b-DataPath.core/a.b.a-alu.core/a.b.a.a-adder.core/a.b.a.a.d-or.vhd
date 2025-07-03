library IEEE;
use IEEE.std_logic_1164.all; 

entity or_gate is
	Port (	A,B:	In	std_logic;
		Y:	Out	std_logic);
end or_gate;


architecture BEHAVIORAL of or_gate is

begin
	Y <= A OR B;

end BEHAVIORAL;