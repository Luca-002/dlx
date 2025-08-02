

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TB_divider is
end TB_divider;

architecture TEST of TB_divider is

    -- Component declaration
    component divider is
        generic(NBIT: integer := 32);
        port (
            clk      : in  std_logic;
            start    : in  std_logic;
            dividend : in  std_logic_vector(NBIT-1 downto 0);
            divisor  : in  std_logic_vector(NBIT-1 downto 0);
            quotient : out std_logic_vector(NBIT-1 downto 0);
            remainder: out std_logic_vector(NBIT-1 downto 0);
            done     : out std_logic
        );
    end component;

    signal clk        : std_logic := '0';
    signal start      : std_logic := '0';
    signal dividend   : std_logic_vector(31 downto 0);
    signal divisor    : std_logic_vector(31 downto 0);
    signal quotient   : std_logic_vector(31 downto 0);
    signal remainder  : std_logic_vector(31 downto 0);
    signal done       : std_logic;

    constant clk_period : time := 10 ns;

begin

    -- Clock process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Instantiate divider
    uut: divider
        port map (
            clk       => clk,
            start     => start,
            dividend  => dividend,
            divisor   => divisor,
            quotient  => quotient,
            remainder => remainder,
            done      => done
        );

    -- Stimulus process
    stim_proc: process
    begin
        wait for 15 ns;
        
        -- Test 1: 100 / 10 = 10 R 0
        dividend <= x"00000064"; -- 100
        divisor  <= x"0000000A"; -- 10
        start    <= '1';
        wait for clk_period;
        start <= '0';
        wait until done = '1';
        assert quotient = x"0000000A" and remainder = x"00000000"
            report "Test 1 failed: Expected Q=10, R=0" severity error;

        -- Test 2: 255 / 16 = 15 R 15
        wait for clk_period * 2;
        dividend <= x"000000FF"; -- 255
        divisor  <= x"00000010"; -- 16
        start    <= '1';
        wait for clk_period;
        start <= '0';
        wait until done = '1';
        assert quotient = x"0000000F" and remainder = x"0000000F"
            report "Test 2 failed: Expected Q=15, R=15" severity error;

        -- Test 3: 1234 / 1 = 1234 R 0
        wait for clk_period * 2;
        dividend <= x"000004D2"; -- 1234
        divisor  <= x"00000001"; -- 1
        start    <= '1';
        wait for clk_period;
        start <= '0';
        wait until done = '1';
        assert quotient = x"000004D2" and remainder = x"00000000"
            report "Test 3 failed: Expected Q=1234, R=0" severity error;

        -- Test 4: 7 / 3 = 2 R 1
        wait for clk_period * 2;
        dividend <= x"00000007";
        divisor  <= x"00000003";
        start    <= '1';
        wait for clk_period;
        start <= '0';
        wait until done = '1';
        assert quotient = x"00000002" and remainder = x"00000001"
            report "Test 4 failed: Expected Q=2, R=1" severity error;

        wait;
    end process;

end TEST;

configuration DIVIDERTEST of TB_divider is
    for TEST
        for all: divider
            use entity WORK.divider;
        end for;
    end for;
end DIVIDERTEST;

