library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity multiplier is
	generic (
		NBIT :		integer := 8);
	port (
		CLK:	in std_logic;
		rst: 	in std_logic;
		A :		in	std_logic_vector((NBIT/2)-1 downto 0);
		B :		in	std_logic_vector((NBIT/2)-1 downto 0);
		P :		out	std_logic_vector(NBIT-1 downto 0));
end multiplier;

architecture struct of multiplier is
	component adder is
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
	type skew_matrix is array ((NBIT/2)-1 downto 0) of std_logic_vector(NBIT/2-1 downto 0);
	type comb_shifts is array( 3 downto 0) of STD_LOGIC_VECTOR(NBIT-1 downto 0);
	signal intermediateResults,intermediateResultsRegisters: matrix;
	signal encodedInput: encodedMatrix;
	signal tmp,inputNegated: std_logic_vector(NBIT/2 downto 0);
	signal positiveShifts, negativeShifts: matrix;
	signal imm_shifts, imm_shifts_negated: comb_shifts;
	signal B_skew:	skew_matrix;
	begin
		tmp<=A((NBIT/2)-1)&A; --we need to extend the number in order to be able to get every possible positive integer (for example if i want to negate -8 in 4 bits, it is not possible, i need 5 bits)
		inverter: SIGNCHANGER
			generic map ((NBIT/2)+1)
			port map (tmp, inputNegated);
		first_encoder: encoder
		 port map(B(1),B(0),'0',encodedInput(0));
		second_encoder: encoder
		 port map(B(3),B(2),B(1),encodedInput(1));
		encoders: for i in 2 to (NBIT/4)-1 generate
			other_encoders: encoder
				port map (
					 B_skew(i-2)((2*i)+1), B_skew(i-2)(2*i),B_skew(i-2)((2*i)-1), encodedInput(i)
				);
				
		end generate;
		imm_shifts(0)<=((NBIT/2)-1 downto 0 => A((NBIT/2)-1)) & A;
		imm_shifts_negated(0)<=((NBIT/2)-2 downto 0 =>inputNegated(NBIT/2)) & inputNegated;
		imm_shifts(1)<=((NBIT/2)-2 downto 0 => A((NBIT/2)-1)) & A(NBIT/2 - 1 downto 0) & '0';
		imm_shifts_negated(1)<=((NBIT/2)-3 downto 0 =>inputNegated(NBIT/2)) & inputNegated(NBIT/2 downto 0) & '0';
		imm_shifts(2)<=((NBIT/2)-3 downto 0 => A((NBIT/2)-1)) & A(NBIT/2 -1 downto 0) & "00" ;
		imm_shifts_negated(2)<=((NBIT/2)-4 downto 0 =>inputNegated(NBIT/2)) & inputNegated(NBIT/2 downto 0) & "00" ;
		imm_shifts(3)<=((NBIT/2)-4 downto 0 => A((NBIT/2)-1)) & A(NBIT/2 - 1 downto 0) & "000";
		imm_shifts_negated(3)<=((NBIT/2)-5 downto 0 =>inputNegated(NBIT/2)) & inputNegated(NBIT/2 downto 0) & "000";
		first_mux: mux 
		generic map (NBIT)
		port map((others => '0'), imm_shifts(0),imm_shifts(1),imm_shifts_negated(1),imm_shifts_negated(0),encodedInput(0), intermediateResults(0) ); 
		second_mux: mux 
		generic map (NBIT)
		port map((others => '0'), imm_shifts(2),imm_shifts(3),imm_shifts_negated(3),imm_shifts_negated(2),encodedInput(1), intermediateResults(1) ); 
		generate_muxes: for i in 2 to (NBIT/4)-1 generate
			muxes: mux
				generic map (NBIT)
				port map((others => '0'), positiveShifts(i*2),positiveShifts((i*2)+1),negativeShifts((i*2)+1),negativeShifts(i*2),encodedInput(i), intermediateResults((i*2)-1) );
		end generate;
		first_adder: adder
		generic map (NBIT)
				port map (intermediateResults(0),intermediateResults(1), '0',intermediateResults(2));
		generate_adders: for i in 2 to (NBIT/4)-1 generate
			adders:adder
				generic map (NBIT)
				port map (intermediateResultsRegisters((i*2)-2),intermediateResults((i*2)-1), '0',intermediateResults(i*2));
		end generate;
		P<=intermediateResultsRegisters((NBIT/2)-2);
		process(clk, rst)
		begin
			if rising_edge(clk) then
				positiveShifts(4)<=((NBIT/2)-5 downto 0 => A((NBIT/2)-1)) & A(NBIT/2 - 1 downto 0) & "0000";
				negativeShifts(4)<=((NBIT/2)-6 downto 0 =>inputNegated(NBIT/2)) & inputNegated(NBIT/2 downto 0) & "0000";
				positiveShifts(5)<=((NBIT/2)-6 downto 0 => A((NBIT/2)-1)) & A(NBIT/2 - 1 downto 0) & "00000";
				negativeShifts(5)<=((NBIT/2)-7 downto 0 =>inputNegated(NBIT/2)) & inputNegated(NBIT/2 downto 0) & "00000";
				for i in 3 to (NBIT/4)-1 loop
					positiveShifts(2*i)<=positiveShifts(2*i-1)(NBIT-2 downto 0) & '0';
					negativeShifts(2*i)<=negativeShifts(2*i-1)(NBIT-2 downto 0) & '0';
					positiveShifts(2*i+1)<=positiveShifts(2*i-1)(NBIT-3 downto 0) & "00";
					negativeShifts(2*i+1)<=negativeShifts(2*i-1)(NBIT-3 downto 0) & "00";
				end loop ;	
				B_skew(0)<=B;
				for i in 1 to (NBIT/4)-1 loop 
					B_skew(i)<=B_skew(i-1);
				end loop;
				for i in 1 to (NBIT/4)-1 loop
					intermediateResultsRegisters(i*2)<=intermediateResults(i*2);
				end loop;
			end if;
		end process;
end architecture;
