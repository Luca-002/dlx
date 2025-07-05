
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity comparator_tb is
end comparator_tb;

architecture behavior of comparator_tb is
    constant DATA_WIDTH : integer := 32;

    signal cout             : std_logic;
    signal sum              : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal A_gt_or_eq_B     : std_logic;
    signal A_gt_B           : std_logic;
    signal A_lt_or_eq_B     : std_logic;
    signal A_lt_B           : std_logic;
    signal A_eq_B           : std_logic;

begin

    uut: entity work.comparator
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            cout            => cout,
            sum             => sum,
            A_gt_or_eq_B    => A_gt_or_eq_B,
            A_gt_B          => A_gt_B,
            A_lt_or_eq_B    => A_lt_or_eq_B,
            A_lt_B          => A_lt_B,
            A_eq_B          => A_eq_B
        );

    stim_proc: process
    begin
        -- Test case 1: A == B (cout = '1', sum = 0)
        cout <= '1';
        sum <= (others => '0');
        wait for 10 ns;

        assert (A_gt_or_eq_B = '1') report "Test 1 failed: A_gt_or_eq_B" severity error;
        assert (A_gt_B = '0') report "Test 1 failed: A_gt_B" severity error;
        assert (A_lt_or_eq_B = '1') report "Test 1 failed: A_lt_or_eq_B" severity error;
        assert (A_lt_B = '0') report "Test 1 failed: A_lt_B" severity error;
        assert (A_eq_B = '1') report "Test 1 failed: A_eq_B" severity error;

        -- Test case 2: A > B (cout = '1', sum ≠ 0)
        cout <= '1';
        sum <= x"00000001"; -- any non-zero value
        wait for 10 ns;

        assert (A_gt_or_eq_B = '1') report "Test 2 failed: A_gt_or_eq_B" severity error;
        assert (A_gt_B = '1') report "Test 2 failed: A_gt_B" severity error;
        assert (A_lt_or_eq_B = '0') report "Test 2 failed: A_lt_or_eq_B" severity error;
        assert (A_lt_B = '0') report "Test 2 failed: A_lt_B" severity error;
        assert (A_eq_B = '0') report "Test 2 failed: A_eq_B" severity error;

        -- Test case 3: A < B (cout = '0', sum = non-zero)
        cout <= '0';
        sum <= x"00000001";
        wait for 10 ns;

        assert (A_gt_or_eq_B = '0') report "Test 3 failed: A_gt_or_eq_B" severity error;
        assert (A_gt_B = '0') report "Test 3 failed: A_gt_B" severity error;
        assert (A_lt_or_eq_B = '1') report "Test 3 failed: A_lt_or_eq_B" severity error;
        assert (A_lt_B = '1') report "Test 3 failed: A_lt_B" severity error;
        assert (A_eq_B = '0') report "Test 3 failed: A_eq_B" severity error;

        -- Test case 4: A < B, but sum = 0 (invalid corner case)
        cout <= '0';
        sum <= (others => '0');
        wait for 10 ns;

        assert (A_gt_or_eq_B = '0') report "Test 4 failed: A_gt_or_eq_B" severity error;
        assert (A_gt_B = '0') report "Test 4 failed: A_gt_B" severity error;
        assert (A_lt_or_eq_B = '1') report "Test 4 failed: A_lt_or_eq_B" severity error;
        assert (A_lt_B = '1') report "Test 4 failed: A_lt_B" severity error;
        assert (A_eq_B = '1') report "Test 4 failed: A_eq_B" severity error;

        report "All test cases completed.";

        wait;
    end process;
end behavior;

