
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.myTypes.all;   -- This imports aluOp type


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
	port map(A, B, op, result );

	A <= x"AAAAAAAA", x"AAAAAAAA" after 1 ns, x"AAAAAAAA" after 2 ns, 
         x"AAAAAAAA" after 3 ns, x"AAAAAAAA" after 4 ns, x"AAAAAAAA" after 5 ns; 


	B <= x"DB6DB6DB", x"DB6DB6DB" after 1 ns, x"DB6DB6DB" after 2 ns, 
         x"DB6DB6DB" after 3 ns, x"DB6DB6DB" after 4 ns, x"DB6DB6DB" after 5 ns;


	op <= ALU_AND , ALU_NAND after 1 ns, ALU_OR after 2 ns, 
         ALU_NOR after 3 ns, ALU_XOR after 4 ns, ALU_XNOR after 5 ns;

	process
	begin
		

    wait for 0.5 ns;
    assert result = x"8A28A28A"
        report "AND Test failed: Expected result = 8A28A28A" severity error;

    wait for 1 ns;
    assert result = x"75D75D75"
        report "NAND Test failed: Expected result = 75D75D75" severity error;

    wait for 1 ns;
    assert result = x"FBEFBEFB"
        report "OR Test failed: Expected result = FBEFBEFB" severity error;

    wait for 1 ns;
    assert result = x"04104104"
        report "NOR Test failed: Expected result = 04104104" severity error;

    wait for 1 ns;
    assert result = x"71C71C71"
        report "XOR Test failed: Expected result = 71C71C71" severity error;

    wait for 1 ns;
    assert result = x"8E38E38E"
        report "NXOR Test failed: Expected result = 8E38E38E" severity error;
		wait;
	end process;

end TEST;

configuration LOGICTEST of TB_logic is
  for TEST
    for all: logic_unit
      use entity WORK.logic_unit;
    end for;
  end for;
end LOGICTEST;

