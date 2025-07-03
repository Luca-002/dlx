library IEEE;
use IEEE.std_logic_1164.all; 

entity single_register is
    Generic(N: integer:= 32);
	Port (	D:	In	std_logic_vector(N-1 downto 0);
		CK:	In	std_logic;
		RESET:	In	std_logic;
		Q:	Out	std_logic_vector(N-1 downto 0));
end single_register;

architecture async of single_register is 

begin
	
	PASYNCH: process(CK,RESET)
	begin
	  if RESET='1' then
	    Q <= (others => '0');
	  elsif CK'event and CK='1' then 
	    Q <= D; 
	  end if;
	end process;

end async;