library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity CARRY_GENERATOR is    --NEEDS TESTING
		generic (
			NBIT :		integer := 32;
			NBIT_PER_BLOCK: integer := 4);
		port (
			A :		in	std_logic_vector(NBIT-1 downto 0);
			B :		in	std_logic_vector(NBIT-1 downto 0);
			Cin :	in	std_logic;
			Co :	out	std_logic_vector((NBIT/NBIT_PER_BLOCK)-1 downto 0));
end CARRY_GENERATOR;
architecture struct of CARRY_GENERATOR is
	function log(N: integer) return integer is
		variable result: integer := 0;
		variable tmp: integer := N;
	begin
		while tmp > 1 loop
			tmp := tmp / 2;
			result := result + 1;
		end loop;
		return result;
	end function;
	function get_pos(i, k: integer) return integer is     --function to know the position of the previous block during the generation of the additional blocks
		type vector is array (natural range <>) of integer;
		variable tmp: integer:=1;
		variable vec: vector(0 to NBIT-1);
		variable index: integer :=0;
		variable value: integer:=1;
		variable row_index: integer;
		begin
			while(2**(tmp-1))<NBIT_PER_BLOCK+1 loop --first we need to find in what layer the additional blocks begin to be created, this is layer 0, so the length of the generated sequence will be i(current layer)-tmp(first layer)
				tmp:=tmp+1;
			end loop;
			row_index:=i-tmp;
			for j in  row_index downto 0 loop --starting from layer 0, we consider the sequences (in the following sequences, the tuple (x)(y) indicates that y is repeated x times (e.g. (2)(1) indicates 1,1)) 0: (2**0)(1), (2**0)(2); 1: (2**1)(1), (2**0)(2), (2**0)(3);...;n: (2**n)(1), (2**(n-1))(2)...(2**0)(n+1),(2**0)(n+2). We create the sequence with index row_index: (2**row_index)(1), (2**(row_index-1))(2)...(2**0)(row_index+1),(2**0)(row_index+2)
				for l in 0 to (2**j)-1 loop
					vec(index):=value;
					index:=index+1;
				end loop;
				value:=value+1;
			end loop;
			vec(index):=row_index+2;
			return vec(k);
		end function;
	component xor_gate is
		Port (	A,B:	In	std_logic;
			Y:	Out	std_logic);
	end component;
	component and_gate is
		Port (	A,B:	In	std_logic;
			Y:	Out	std_logic);
	end component;
	component or_gate is
		Port (	A,B:	In	std_logic;
			Y:	Out	std_logic);
	end component;
	type matrix is array (log(NBIT) downto 0) of std_logic_vector(NBIT-1 downto 0);
	signal g_aux: matrix;
	signal g_array: matrix;
	signal p_array: matrix;
	signal B_sub: STD_LOGIC_VECTOR(NBIT-1 downto 0);
	begin
		process(B)    --B xor Cin for the subtraction
			begin
				for i in 0 to NBIT-1 loop
					B_sub(i)<=B(i) xor Cin;
				end loop;
		end process;
		first_layer:for i in 1 to NBIT-1 generate  --generation of the first layer of p and g
			first_gs: and_gate
			port map(A(i), B_sub(i), g_array(0)(i));
			first_ps: xor_gate
			port map(A(i), B_sub(i), p_array(0)(i));
		end generate first_layer;
		g_array(0)(0)<=(A(0) and B_sub(0)) or ((A(0) xor B_sub(0)) and Cin);
		rows: for i in 1 to log(NBIT)  generate
			columns:for j in 0 to NBIT-1 generate
				check_g:if j mod (2**i)=(2**i)-1 generate 	--every 2**i starting from 2**i -1 we want to generate a G block
					g_and:and_gate
					port map(g_array(i-1)(j-2**(i-1)), p_array(i-1)(j),g_aux(i)(j));
					g_or: or_gate
					port map(g_aux(i)(j), g_array(i-1)(j), g_array(i)(j));

					check_p:if j>(2**i) generate  --if the G block we generated is not the first block, we also generate a P block
						p_and: and_gate
						port map(p_array(i-1)(j-2**(i-1)), p_array(i-1)(j), p_array(i)(j));
					end generate check_p;

					output:if j<(2**i)+1 and (j+2)>NBIT_PER_BLOCK generate --we connect the G block to the output if the P block hasn't been generated (first G block) and we have checked enough bits to generate the output (we need at least NBIT_PER_BLOCK bits)
						Co(((j+1)/NBIT_PER_BLOCK)-1)<=g_array(i)(j);
					end generate output;

					additional_blocks:if (2**(i-1))>NBIT_PER_BLOCK generate  --if the "distance" from one block and the other is too big, we need to add additional blocks

						blocks: for k in 1 to (((2**(i-1))/NBIT_PER_BLOCK)-1) generate --the additional blocks will be the same as the block genertaed before, so if we generated a G block, we keep generating G blocks, if we generated a PG block, we keep generating PG blocks
							additional_g_and:and_gate
							port map(g_array(i-1)(j-2**(i-1)), p_array(i-get_pos(i,k))(j-(k*NBIT_PER_BLOCK)),g_aux(i)(j-(k*NBIT_PER_BLOCK)) ); --the function get_pos is needed to know where to find the previous block in order to get the G and P signals
							additional_g_or: or_gate
							port map(g_aux(i)(j-(k*NBIT_PER_BLOCK)), g_array(i-get_pos(i,k))(j-(k*NBIT_PER_BLOCK)), g_array(i)(j-(k*NBIT_PER_BLOCK)));
              				check_additional_p: if j>(2**i) generate
                			additional_p_and: and_gate
                			port map(p_array(i-1)(j-2**(i-1)), p_array(i-get_pos(i,k))(j-(k*NBIT_PER_BLOCK)), p_array(i)(j-(k*NBIT_PER_BLOCK)));
					    end generate check_additional_p;
              			additional_output: if j<(2**i)+1 generate 
                			Co(((j+1)/NBIT_PER_BLOCK)-1-k)<=g_array(i)(j-(k*NBIT_PER_BLOCK));
              			end generate additional_output;

						end generate blocks;

					end generate additional_blocks;

				end generate check_g;

			end generate columns;

		end generate rows;
	end struct;

