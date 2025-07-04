library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity adder is  --TODO: test
	generic (
		NBIT :		integer := 32;
		NBIT_PER_BLOCK: integer := 4);
	port (
		A :		in	std_logic_vector(NBIT-1 downto 0);
		B :		in	std_logic_vector(NBIT-1 downto 0);
		Cin :	in	std_logic;
		S :		out	std_logic_vector(NBIT-1 downto 0);
		Cout :	out	std_logic);
end adder;

architecture struct of adder is 
component CARRY_GENERATOR is
	generic (
		NBIT :		integer := 32;
		NBIT_PER_BLOCK: integer := 4);
	port (
		A :		in	std_logic_vector(NBIT-1 downto 0);
		B :		in	std_logic_vector(NBIT-1 downto 0);
		Cin :	in	std_logic;
		Co :	out	std_logic_vector((NBIT/NBIT_PER_BLOCK)-1 downto 0));
end component;

component SUM_GENERATOR is
	generic (
		NBIT_PER_BLOCK: integer := 4;
		NBLOCKS:	integer := 8);
	port (
		A:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
		B:	in	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
		Ci:	in	std_logic_vector(NBLOCKS-1 downto 0);
		S:	out	std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0));
end component;
signal C_generated: std_logic_vector(NBIT/NBIT_PER_BLOCK downto 0);

Begin
	C_generated(0)<=Cin;
CARRY: CARRY_GENERATOR
	generic map(NBIT, NBIT_PER_BLOCK)
	port map(A,B, C_generated(0), C_generated(NBIT/NBIT_PER_BLOCK downto 1));
ADDER: SUM_GENERATOR 
	generic map (NBIT_PER_BLOCK, NBIT/NBIT_PER_BLOCK)
	port map (A, B, C_generated((NBIT/NBIT_PER_BLOCK)-1 downto 0), S);
	Cout<=C_generated(NBIT/4);
end struct;