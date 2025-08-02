
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity TB_comparator is
end TB_comparator;

architecture TEST of TB_comparator is

    -- Component declaration
    component comparator is
        generic (
            DATA_WIDTH: integer := 32
        );
        port (
            cout           : in  std_logic;
            sum            : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            A_gt_or_eq_B   : out std_logic;
            A_gt_B         : out std_logic;
            A_lt_or_eq_B   : out std_logic;
            A_lt_B         : out std_logic;
            A_eq_B         : out std_logic
        );
    end component;

    signal cout           : std_logic;
    signal sum            : std_logic_vector(31 downto 0);
    signal A_gt_or_eq_B   : std_logic;
    signal A_gt_B         : std_logic;
    signal A_lt_or_eq_B   : std_logic;
    signal A_lt_B         : std_logic;
    signal A_eq_B         : std_logic;

begin

    -- Instantiate comparator
    uut: comparator
        port map (
            cout         => cout,
            sum          => sum,
            A_gt_or_eq_B => A_gt_or_eq_B,
            A_gt_B       => A_gt_B,
            A_lt_or_eq_B => A_lt_or_eq_B,
            A_lt_B       => A_lt_B,
            A_eq_B       => A_eq_B
        );

    -- Stimulus and assertions
    process
    begin
        -- Test 1: A > B (cout = '1', sum ≠ 0)
        cout <= '1';
        sum  <= x"00000001";
        wait for 1 ns;
        assert A_gt_or_eq_B = '1' and
               A_gt_B       = '1' and
               A_lt_or_eq_B = '0' and
               A_lt_B       = '0' and
               A_eq_B       = '0'
            report "Test 1 failed: Expected A > B" severity error;

        -- Test 2: A = B (cout = '1', sum = 0)
        cout <= '1';
        sum  <= x"00000000";
        wait for 1 ns;
        assert A_gt_or_eq_B = '1' and
               A_gt_B       = '0' and
               A_lt_or_eq_B = '1' and
               A_lt_B       = '0' and
               A_eq_B       = '1'
            report "Test 2 failed: Expected A = B" severity error;

        -- Test 3: A < B (cout = '0', sum ≠ 0)
        cout <= '0';
        sum  <= x"00000001";
        wait for 1 ns;
        assert A_gt_or_eq_B = '0' and
               A_gt_B       = '0' and
               A_lt_or_eq_B = '1' and
               A_lt_B       = '1' and
               A_eq_B       = '0'
            report "Test 3 failed: Expected A < B" severity error;

        -- Test 4: A < B and A = B (corner case: cout = '0', sum = 0)
        cout <= '0';
        sum  <= x"00000000";
        wait for 1 ns;
        assert A_gt_or_eq_B = '0' and
               A_gt_B       = '0' and
               A_lt_or_eq_B = '1' and
               A_lt_B       = '1' and
               A_eq_B       = '1'
            report "Test 4 failed: Expected A <= B and A = B" severity error;

        wait;
    end process;

end TEST;

configuration COMPARATORTB of TB_comparator is
    for TEST
        for all: comparator
            use entity WORK.comparator;
        end for;
    end for;
end COMPARATORTB;
