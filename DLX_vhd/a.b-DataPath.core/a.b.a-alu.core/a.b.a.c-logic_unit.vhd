library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
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
            tmp1(i) := decoded_op(0) nand (v_notA(i) nand v_notB(i));
            tmp2(i) := decoded_op(1) nand (v_notA(i) nand B(i));
            tmp3(i) := decoded_op(2) nand (A(i) nand v_notB(i));
            tmp4(i) := decoded_op(3) nand (A(i) nand B(i));
        end loop;

        for i in 0 to NBIT-1 loop
            v_result(i) := tmp1(i) nand (tmp2(i) nand (tmp3(i) nand tmp4(i)));
        end loop;

        result <= v_result;
    end process;

end behavioral;
