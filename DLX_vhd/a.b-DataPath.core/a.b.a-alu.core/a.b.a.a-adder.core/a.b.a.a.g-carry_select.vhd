library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity CSB is
	generic(N: integer:=4);
	port(A, B: IN std_logic_vector(N-1 downto 0);
	cin: IN std_logic;
	Y: OUT std_logic_vector(N-1 downto 0));
end CSB;
architecture structural of CSB is
	component RCA is 
	generic (N: INTEGER);
	Port (	A:	In	std_logic_vector(N-1 downto 0);
		B:	In	std_logic_vector(N-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(N-1 downto 0);
		Co:	Out	std_logic);
	end component; 
	component MUX21_GENERIC is
		generic (NBIT: integer:= 4);
			Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
				B:	In	std_logic_vector(NBIT-1 downto 0);
				SEL:	In	std_logic;
				Y:	Out	std_logic_vector(NBIT-1 downto 0));
		end component;
	signal add0, add1: std_logic_vector(N-1 downto 0);
	begin
		adder0: RCA
		generic map(N)
		port map(A,B,'0',add0);
		adder1: RCA
		generic map (N)
		port map (A,B,'1',add1);
		mux: MUX21_GENERIC
		generic map(N)
		port map(add1, add0, cin, y);
	end structural;