library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all; 

entity mux is 
  generic(
  n : integer:=8);
  port(
  A,B,C,D,E: in std_logic_vector(n-1 downto 0);
  sel: in std_logic_vector(2 downto 0);
  Y: out std_logic_vector(n-1 downto 0)
      ); 
    end mux;

architecture beh of mux is 
  begin
    process(sel)
      begin
        case sel is 
          when "000" => Y<=A;
          when "001" => Y<=B;
          when "010" => Y<=C;
          when "011" => Y<=D;
		  when "100" => Y<=E;
          when others=> Y<=(others => '0');
        end case;
      end process;

end architecture;