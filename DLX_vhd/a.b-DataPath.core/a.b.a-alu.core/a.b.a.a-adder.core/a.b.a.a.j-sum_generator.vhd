library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity SUM_GENERATOR is
	generic (NBIT_PER_BLOCK: integer := 4;
			NBLOCKS:	integer := 8);
	port(A,B: in std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
		Ci: in std_logic_vector(NBLOCKS-1 downto 0);
		S: out std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0));
end SUM_GENERATOR;

architecture STRUCTURAL of SUM_GENERATOR is
	component CSB is
		generic(N: integer:=4);
		port(A, B: IN std_logic_vector(N-1 downto 0);
		cin: IN std_logic;
		Y: OUT std_logic_vector(N-1 downto 0));
	end component;
	signal B_sub: STD_LOGIC_VECTOR(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
	begin
		process(B,Ci)    --B xor Cin for the subtraction
			begin
				for i in 0 to NBIT_PER_BLOCK*NBLOCKS-1 loop
					B_sub(i)<=B(i) xor Ci(0);
				end loop;
		end process;
		gen:for i in 0 to NBLOCKS-1 generate
			carry_select: CSB
				generic map(NBIT_PER_BLOCK)
				port map(A(((i+1)*NBIT_PER_BLOCK)-1 downto i*NBIT_PER_BLOCK),B_sub(((i+1)*NBIT_PER_BLOCK)-1 downto i*NBIT_PER_BLOCK), Ci(i), S(((i+1)*NBIT_PER_BLOCK)-1 downto i*NBIT_PER_BLOCK) );
		end generate;
end STRUCTURAL;
