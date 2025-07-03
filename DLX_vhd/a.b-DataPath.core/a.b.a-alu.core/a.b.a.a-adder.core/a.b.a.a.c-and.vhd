library IEEE;
use IEEE.std_logic_1164.all; 

entity and_gate is
	Port (	A,B:	In	std_logic;
		Y:	Out	std_logic);
end and_gate;


architecture BEHAVIORAL of and_gate is

begin
	Y <= A AND B;

end BEHAVIORAL;