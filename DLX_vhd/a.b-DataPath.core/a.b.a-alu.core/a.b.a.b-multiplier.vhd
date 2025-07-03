library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity multiplier is
	generic (
		NBIT :		integer := 8);
	port (
		A :		in	std_logic_vector((NBIT/2)-1 downto 0);
		B :		in	std_logic_vector((NBIT/2)-1 downto 0);
		P :		out	std_logic_vector(NBIT-1 downto 0));
end multiplier;

architecture struct of multiplier is
	component P4_ADDER is
		generic (
			NBIT :		integer := 32);
		port (
			A :		in	std_logic_vector(NBIT-1 downto 0);
			B :		in	std_logic_vector(NBIT-1 downto 0);
			Cin :	in	std_logic;
			S :		out	std_logic_vector(NBIT-1 downto 0);
			Cout :	out	std_logic);
	end component;
	component SIGNCHANGER is 
	generic (N: INTEGER :=16);
	Port (	A:	In	std_logic_vector(N-1 downto 0);
		Y:	Out	std_logic_vector(N-1 downto 0));
	end component; 
	component encoder is 
	port(A,B,C: in std_logic;
		Y: out std_logic_vector(2 downto 0));
	end component;
	component mux is 
  	generic(
  	n : integer:=8);
  	port(
  	A,B,C,D,E: in std_logic_vector(n-1 downto 0);
  	sel: in std_logic_vector(2 downto 0);
  	Y: out std_logic_vector(n-1 downto 0)
      ); 
    end component;
	type encodedMatrix is array ((NBIT/4)-1 downto 0) of std_logic_vector(2 downto 0);
	type matrix is array ((NBIT/2)-1 downto 0) of std_logic_vector(NBIT-1 downto 0);
	signal intermediateResults: matrix;
	signal encodedInput: encodedMatrix;
	signal tmp,inputNegated: std_logic_vector(NBIT/2 downto 0);
	signal positiveShifts, negativeShifts: matrix;
	
	begin
		tmp<=A((NBIT/2)-1)&A; --we need to extend the number in order to be able to get every possible positive integer (for example if i want to negate -8 in 4 bits, it is not possible, i need 5 bits)
		inverter: SIGNCHANGER
			generic map ((NBIT/2)+1)
			port map (tmp, inputNegated);
		first_encoder: encoder
		 port map(B(1),B(0),'0',encodedInput(0));
		encoders: for i in 1 to (NBIT/4)-1 generate
			other_encoders: encoder
				port map (
					 B((2*i)+1), B(2*i),B((2*i)-1), encodedInput(i)
				);
		end generate;
		positiveShifts(0)<= ((NBIT/2)-1 downto 0 => A((NBIT/2)-1)) & A;
		negativeShifts(0)<=((NBIT/2)-2 downto 0 =>inputNegated(NBIT/2)) & inputNegated;
		generate_shifts: for i in 1 to  (NBIT/2)-1 generate
			positiveShifts(i)<=positiveShifts(i-1)((NBIT)-2 downto 0) & '0';
			negativeShifts(i)<=negativeShifts(i-1)((NBIT)-2 downto 0) & '0';
		end generate;
		first_mux: mux 
		generic map (NBIT)
		port map((others => '0'), positiveShifts(0),positiveShifts(1),negativeShifts(1),negativeShifts(0),encodedInput(0), intermediateResults(0) ); 
		generate_muxes: for i in 1 to (NBIT/4)-1 generate
			muxes: mux
				generic map (NBIT)
				port map((others => '0'), positiveShifts(i*2),positiveShifts((i*2)+1),negativeShifts((i*2)+1),negativeShifts(i*2),encodedInput(i), intermediateResults((i*2)-1) );
		end generate;
		generate_adders: for i in 1 to (NBIT/4)-1 generate
			adders:P4_ADDER
				generic map (NBIT)
				port map (intermediateResults((i*2)-2),intermediateResults((i*2)-1), '0',intermediateResults(i*2));
		end generate;
		P<=intermediateResults((NBIT/2)-2);
end architecture;