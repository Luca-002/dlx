library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity logic_unit is    --TODO: test
    generic(NBIT: integer:=32);
    port(
		A :		in	std_logic_vector(NBIT-1 downto 0);
		B :		in	std_logic_vector(NBIT-1 downto 0);
        op:     in aluOp;
        result: out STD_LOGIC_VECTOR(NBIT-1 downto 0)
    );
end logic_unit;
architecture behavioral of logic_unit is
    signal decoded_op: STD_LOGIC_VECTOR(3 downto 0);
    signal tmp1,tmp2,tmp3,tmp4,notA,notB: STD_LOGIC_VECTOR(NBIT-1 downto 0);
    begin
        notA<=not(A);
        notB<=not(B);
        process(op)
            begin
            case op is
                when  ALU_AND   =>decoded_op<="0001";  
                when  ALU_NAND  =>decoded_op<="1110";  
                when  ALU_OR    =>decoded_op<="0111";  
                when  ALU_NOR   =>decoded_op<="1000";  
                when  ALU_XOR   =>decoded_op<="0110";  
                when  ALU_XNOR  =>decoded_op<="1001";  
            end case;
            for i in 0 to NBIT-1 loop
                tmp1(i)<=decoded_op(0) nand (notA(i) nand notB(i));
            end loop;
            for i in 0 to NBIT-1 loop
                tmp2(i)<=decoded_op(0) nand (notA(i) nand B(i));
            end loop;
            for i in 0 to NBIT-1 loop
                tmp3(i)<=decoded_op(0) nand (A(i) nand notB(i));
            end loop;
            for i in 0 to NBIT-1 loop
                tmp4(i)<=decoded_op(0) nand (A(i) nand B(i));
            end loop;
            result<=tmp1 nand (tmp2 nand (tmp3 nand tmp4));
        end process;

end behavioral;
