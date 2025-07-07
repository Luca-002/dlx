
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity TB_adder is
end TB_adder;

architecture TEST of TB_adder is
	
	-- Component declaration
	component adder is
		generic (
			NBIT : integer := 32);
		port (
			A     : in  std_logic_vector(NBIT-1 downto 0);
			B     : in  std_logic_vector(NBIT-1 downto 0);
			Cin   : in  std_logic;
			S     : out std_logic_vector(NBIT-1 downto 0);
			Cout  : out std_logic);
	end component;
	
	signal A, B     : std_logic_vector(31 downto 0);
	signal SUM      : std_logic_vector(31 downto 0);
	signal Cout     : std_logic; 
	signal Cin      : std_logic;

begin
	-- Instantiate adder
	add: adder
	port map(A, B, Cin, SUM, Cout);

	-- Stimulus signals
	A <= x"00000000", x"12345678" after 1 ns, x"FFFFFFFF" after 2 ns, 
         x"80000000" after 3 ns, x"AAAAAAAA" after 4 ns, x"0F0F0F0F" after 5 ns, 
         x"CAFEBABE" after 6 ns, x"00000000" after 7 ns, x"00000024" after 8 ns, 
         x"0000BEEF" after 9 ns, x"0000CAFE" after 10 ns;

	B <= x"00000000", x"87654321" after 1 ns, x"00000001" after 2 ns, 
         x"80000000" after 3 ns, x"55555555" after 4 ns, x"F0F0F0F0" after 5 ns, 
         x"DEADBEEF" after 6 ns, x"FFFFFFFF" after 7 ns, x"00000032" after 8 ns,
         x"0000DEAD" after 9 ns, x"0000BABE" after 10 ns;

	Cin <= '0', '1' after 8 ns;	

	-- Assertion process
	process
	begin
		wait for 1.5 ns;
		assert SUM = x"99999999" and Cout = '0'
			report "Test 1 failed: Expected SUM=99999999, Cout=0" severity error;

		wait for 1 ns;
		assert SUM = x"00000000" and Cout = '1'
			report "Test 2 failed: Expected SUM=00000000, Cout=1" severity error;

		wait for 1 ns;
		assert SUM = x"00000000" and Cout = '1'
			report "Test 3 failed: Expected SUM=00000000, Cout=1" severity error;

		wait for 1 ns;
		assert SUM = x"FFFFFFFF" and Cout = '0'
			report "Test 4 failed: Expected SUM=FFFFFFFF, Cout=0" severity error;

		wait for 1 ns;
		assert SUM = x"FFFFFFFF" and Cout = '0'
			report "Test 5 failed: Expected SUM=FFFFFFFF, Cout=0" severity error;

		wait for 1 ns;
		assert SUM = x"FFFFFFFF" and Cout = '0'
			report "Test 6 failed: Expected SUM=FFFFFFFF, Cout=0" severity error;

		wait for 1 ns;
		assert SUM = x"A9AC79AD" and Cout = '1'
			report "Test 7 failed: Expected SUM=A9AC79AD, Cout=1" severity error;

		wait for 1 ns;
		assert SUM = x"FFFFFFFF" and Cout = '0'
			report "Test 8 failed: Expected SUM=FFFFFFFF, Cout=0" severity error;

		wait for 1 ns;
		assert SUM = x"0000000E" and Cout = '0'
			report "Test 9 failed: Expected SUM=0000000E, Cout=0" severity error;

		wait for 1 ns;
		assert SUM = x"00001FBE" and Cout = '0'
			report "Test 10 failed: Expected SUM=00001FBE, Cout=0" severity error;

		wait for 1 ns;
		assert SUM = x"FFFFEFC0" and Cout = '0'
			report "Test 11 failed: Expected SUM=FFFFEFC0, Cout=0" severity error;
		wait;
	end process;

end TEST;

configuration ADDERTEST of TB_adder is
  for TEST
    for all: adder
      use entity WORK.adder;
    end for;
  end for;
end ADDERTEST;

