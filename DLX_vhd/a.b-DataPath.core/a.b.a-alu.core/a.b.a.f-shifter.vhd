
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shifter is
    generic(N: integer);
    port(
        A: in std_logic_vector(N-1 downto 0);
        B: in std_logic_vector(4 downto 0);
        LOGIC_ARITH: in std_logic;   -- 1 = logic, 0 = arith
        LEFT_RIGHT: in std_logic;    -- 1 = left, 0 = right
        SHIFT_ROTATE: in std_logic;  -- 1 = shift, 0 = rotate
        OUTPUT: out std_logic_vector(N-1 downto 0)
    );
end entity shifter;

architecture BEHAVIORAL of shifter is
    function rotate_left(val: std_logic_vector; shamt: integer) return std_logic_vector is
        variable temp: std_logic_vector(N-1 downto 0);
    begin
        temp := val(N-1-shamt downto 0) & val(N-1 downto N-shamt);
        return temp;
    end function;

    function rotate_right(val: std_logic_vector; shamt: integer) return std_logic_vector is
        variable temp: std_logic_vector(N-1 downto 0);
    begin
        temp := val(shamt-1 downto 0) & val(N-1 downto shamt);
        return temp;
    end function;
begin

    SHIFT: process (A, B, LOGIC_ARITH, LEFT_RIGHT, SHIFT_ROTATE)
        variable shift_amt: integer := 0;
        variable temp: std_logic_vector(N-1 downto 0);
    begin
        shift_amt := to_integer(unsigned(B));
        temp := A;

        if SHIFT_ROTATE = '0' then
            -- Rotate
            if LEFT_RIGHT = '0' then
                temp := rotate_right(A, shift_amt);
            else
                temp := rotate_left(A, shift_amt);
            end if;
        else
            -- Shift
            if LEFT_RIGHT = '0' then
                -- Right shift
                if LOGIC_ARITH = '0' then
                    -- Arithmetic
                    temp := std_logic_vector(shift_right(signed(A), shift_amt));
                else
                    -- Logical
                    temp := std_logic_vector(shift_right(unsigned(A), shift_amt));
                end if;
            else
                -- Left shift (same for both)
                if LOGIC_ARITH = '0' then
                    temp := std_logic_vector(shift_left(signed(A), shift_amt));
                else
                    temp := std_logic_vector(shift_left(unsigned(A), shift_amt));
                end if;
            end if;
        end if;

        OUTPUT <= temp;
    end process;

end architecture BEHAVIORAL;

