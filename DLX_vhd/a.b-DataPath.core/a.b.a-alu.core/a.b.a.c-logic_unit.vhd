library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.myTypes.all;   -- This imports aluOp type

entity logic_unit is
    generic(NBIT: integer := 32);
    port(
        A      : in  std_logic_vector(NBIT-1 downto 0);
        B      : in  std_logic_vector(NBIT-1 downto 0);
        op     : in  aluOp;
        result : out std_logic_vector(NBIT-1 downto 0)
    );
end logic_unit;

architecture behavioral of logic_unit is
begin

    process(A, B, op)
        variable v_notA, v_notB   : std_logic_vector(NBIT-1 downto 0);
        variable v_result         : std_logic_vector(NBIT-1 downto 0);
        variable decoded_op       : std_logic_vector(3 downto 0);
        variable tmp1, tmp2, tmp3, tmp4 : std_logic_vector(NBIT-1 downto 0);
    begin
        v_notA := not A;
        v_notB := not B;

        case op is
            when ALU_AND   => decoded_op := "0001";
            when ALU_NAND  => decoded_op := "1110";
            when ALU_OR    => decoded_op := "0111";
            when ALU_NOR   => decoded_op := "1000";
            when ALU_XOR   => decoded_op := "0110";
            when ALU_XNOR  => decoded_op := "1001";
            when others    => decoded_op := "0000";
        end case;

        for i in 0 to NBIT-1 loop
            tmp1(i) := not(decoded_op(3) and (v_notA(i) and v_notB(i)));
            tmp2(i) := not(decoded_op(2) and (v_notA(i) and B(i)));
            tmp3(i) := not(decoded_op(1) and (A(i) and v_notB(i)));
            tmp4(i) := not(decoded_op(0) and (A(i) and B(i)));
        end loop;

        for i in 0 to NBIT-1 loop
            v_result(i) :=not(tmp1(i) and (tmp2(i) and (tmp3(i) and tmp4(i))));
        end loop;

        result <= v_result;
    end process;

end behavioral;