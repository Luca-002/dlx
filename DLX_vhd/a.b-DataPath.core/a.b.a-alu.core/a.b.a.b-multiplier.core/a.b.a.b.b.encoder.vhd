library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity encoder is 
	port(A,B,C: in std_logic;
		Y: out std_logic_vector(2 downto 0));
end encoder;

architecture behavioral of encoder is 
signal tmp: std_logic_vector(2 downto 0);
begin
tmp <= A & B & C;

with tmp select
  Y <= "000" when "000"|"111",
       "001" when "001" | "010",
       "010" when "011",
       "011" when "100",
       "100" when "101" | "110",
       (others => '1') when others;
end architecture;