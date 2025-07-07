

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TB_adder is
end entity;

architecture behavior of TB_adder is

    component adder
        generic (
            NBIT : integer := 32;
            NBIT_PER_BLOCK : integer := 4);
        port (
            A    : in  std_logic_vector(NBIT-1 downto 0);
            B    : in  std_logic_vector(NBIT-1 downto 0);
            Cin  : in  std_logic;
            S    : out std_logic_vector(NBIT-1 downto 0);
            Cout : out std_logic);
    end component;

    constant NBIT : integer := 32;
    constant NBIT_PER_BLOCK : integer := 4;

    signal A, B, S : std_logic_vector(NBIT-1 downto 0);
    signal Cin, Cout : std_logic;

begin

    uut: adder
        generic map (
            NBIT => NBIT,
            NBIT_PER_BLOCK => NBIT_PER_BLOCK)
        port map (
            A => A,
            B => B,
            Cin => Cin,
            S => S,
            Cout => Cout
        );

    stim_proc: process

        function to_slv(x: integer; bits: integer) return std_logic_vector is
        begin
            return std_logic_vector(to_unsigned(x, bits));
        end;

        function to_int(slv: std_logic_vector) return integer is
        begin
            return to_integer(unsigned(slv));
        end;

        procedure run_test(
            A_in : integer;
            B_in : integer;
            Cin_in : integer;
            expected : integer;
            msg : string) is
        begin
            A <= to_slv(A_in, NBIT);
            B <= to_slv(B_in, NBIT);
            Cin <= std_logic'val(Cin_in);
            wait for 10 ns;
            assert to_int(S) = expected
                report "FAILED (" & msg & "): A=" & integer'image(A_in) &
                       ", B=" & integer'image(B_in) &
                       ", Cin=" & integer'image(Cin_in) &
                       ", Expected=" & integer'image(expected) &
                       ", Got=" & integer'image(to_int(S))
                severity error;
            report "PASSED (" & msg & "): A=" & integer'image(A_in) &
                   ", B=" & integer'image(B_in) &
                   ", Cin=" & integer'image(Cin_in) &
                   ", Result=" & integer'image(to_int(S));
        end;

        -- Returns 2's complement of value within NBIT
        function negate(x: integer) return integer is
        begin
            return (2 ** NBIT) - x;
        end;

    begin
        wait for 20 ns;

        -- Additions
        run_test(0, 0, 0, 0, "ADD 0+0");
        run_test(1, 2, 0, 3, "ADD 1+2");
        run_test(100, 200, 0, 300, "ADD 100+200");

        -- Subtractions via 2's complement: A + (NOT B + 1) => B_neg = negate(B)
        run_test(5, negate(3), 1, 2, "SUB 5-3");
        run_test(10, negate(7), 1, 3, "SUB 10-7");
        run_test(1234, negate(1234), 1, 0, "SUB 1234-1234");
        run_test(500, negate(499), 1, 1, "SUB 500-499");

        report "All tests completed.";
        wait;
    end process;

end architecture;

