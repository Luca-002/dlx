
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity TB_shifter is
end TB_shifter;

architecture TEST of TB_shifter is

  -- Component declaration
  component SHIFTER_GENERIC is
    generic (N: integer);
    port (
      A           : in std_logic_vector(N-1 downto 0);
      B           : in std_logic_vector(4 downto 0);
      LOGIC_ARITH : in std_logic;
      LEFT_RIGHT  : in std_logic;
      SHIFT_ROTATE: in std_logic;
      OUTPUT      : out std_logic_vector(N-1 downto 0)
    );
  end component;

  -- Signals
  signal A           : std_logic_vector(31 downto 0);
  signal B           : std_logic_vector(4 downto 0);
  signal LOGIC_ARITH : std_logic;
  signal LEFT_RIGHT  : std_logic;
  signal SHIFT_ROTATE: std_logic;
  signal OUTP        : std_logic_vector(31 downto 0);

begin

  -- Instantiate SHIFTER_GENERIC
  DUT: SHIFTER_GENERIC
    generic map (N => 32)
    port map (
      A           => A,
      B           => B,
      LOGIC_ARITH => LOGIC_ARITH,
      LEFT_RIGHT  => LEFT_RIGHT,
      SHIFT_ROTATE=> SHIFT_ROTATE,
      OUTPUT      => OUTP
    );

  -- Stimuli
  A <= x"12345678", x"FFFFFFFF" after 1 ns, x"80000000" after 2 ns, 
       x"00000001" after 3 ns, x"CAFEBABE" after 4 ns, x"00000010" after 5 ns;

  B <= "00001", "00100" after 1 ns, "00010" after 2 ns, 
       "00001" after 3 ns, "01000" after 4 ns, "00001" after 5 ns;

  SHIFT_ROTATE <= '1', '0' after 3 ns;  -- Shift for first 3, rotate for last 3
  LEFT_RIGHT   <= '1', '0' after 2 ns, '1' after 4 ns;  -- L/R toggling
  LOGIC_ARITH  <= '1', '0' after 1 ns, '1' after 3 ns, '0' after 5 ns;

  -- Assertions
  process
  begin
    wait for 0.5 ns;
    assert OUTP = x"2468ACF0"
      report "Test 1 failed: Expected OUTP=2468ACF0" severity error;

    wait for 1 ns;
    assert OUTP = x"FFFFFFF0"
      report "Test 2 failed: Expected OUTP=FFFFFFF0" severity error;

    wait for 1 ns;
    assert OUTP = x"E0000000"
      report "Test 3 failed: Expected OUTP=E0000000" severity error;

    wait for 1 ns;
    assert OUTP = x"80000000"
      report "Test 4 failed: Expected OUTP=00000002" severity error;

    wait for 1 ns;
    assert OUTP = x"FEBABECA"
      report "Test 5 failed: Expected OUTP=EBABEFCA" severity error;

    wait for 1 ns;
    assert OUTP = x"00000020"
      report "Test 6 failed: Expected OUTP=00000020" severity error;

    wait;
  end process;

end TEST;

configuration SHIFTERTEST of TB_shifter is
  for TEST
    for all: SHIFTER_GENERIC
      use entity WORK.SHIFTER_GENERIC(BEHAVIORAL);
    end for;
  end for;
end SHIFTERTEST;
