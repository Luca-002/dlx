
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity TB_logic is
end TB_logic;

architecture TEST of TB_logic is
	

  component logic_unit
      generic(NBIT: integer:=32);
      port(
      A :		in	std_logic_vector(NBIT-1 downto 0);
      B :		in	std_logic_vector(NBIT-1 downto 0);
          op:     in aluOp;
          result: out STD_LOGIC_VECTOR(NBIT-1 downto 0)
      );
  end component;

	signal A, B     : std_logic_vector(31 downto 0);
	signal result      : std_logic_vector(31 downto 0);
	signal op     : aluOp; 

begin
	add: logic_unit
	port map(A, B, op);

	A <= x"00000000", x"12345678" after 1 ns, x"FFFFFFFF" after 2 ns, 
         x"80000000" after 3 ns, x"AAAAAAAA" after 4 ns, x"0F0F0F0F" after 5 ns; 


	B <= x"00000000", x"87654321" after 1 ns, x"00000001" after 2 ns, 
         x"80000000" after 3 ns, x"55555555" after 4 ns, x"F0F0F0F0" after 5 ns;


	op <= ALU_AND , ALU_NAND after 1 ns, ALU_OR after 2 ns, 
         ALU_NOR after 3 ns, ALU_XOR after 4 ns, ALU_XNOR after 5 ns;

	process
	begin
		wait for 1.5 ns;
		assert result = x"99999999" 
			report "Test 1 failed: Expected result=99999999" severity error;

		wait for 1 ns;
		assert result = x"00000000" 
			report "Test 2 failed: Expected result=00000000" severity error;

		wait for 1 ns;
		assert result = x"00000000" 
			report "Test 3 failed: Expected result=00000000" severity error;

		wait for 1 ns;
		assert result = x"FFFFFFFF" 
			report "Test 4 failed: Expected result=FFFFFFFF" severity error;

		wait for 1 ns;
		assert result = x"FFFFFFFF" 
			report "Test 5 failed: Expected result=FFFFFFFF" severity error;

		wait for 1 ns;
		assert result = x"FFFFFFFF" 
			report "Test 6 failed: Expected result=FFFFFFFF" severity error;

		wait for 1 ns;
		assert result = x"A9AC79AD" 
			report "Test 7 failed: Expected result=A9AC79AD" severity error;

		wait for 1 ns;
		assert result = x"FFFFFFFF"
			report "Test 8 failed: Expected result=FFFFFFFF" severity error;

		wait for 1 ns;
		assert result = x"0000000E" 
			report "Test 9 failed: Expected result=0000000E" severity error;

		wait for 1 ns;
		assert result = x"00001FBE" 
			report "Test 10 failed: Expected result=00001FBE" severity error;

		wait for 1 ns;
		assert result = x"FFFFEFC0" 
			report "Test 11 failed: Expected result=FFFFEFC0" severity error;
		wait;
	end process;

end TEST;

configuration LOGICTEST of TB_logic is
  for TEST
    for all: logic
      use entity WORK.logic;
    end for;
  end for;
end LOGICTEST;

