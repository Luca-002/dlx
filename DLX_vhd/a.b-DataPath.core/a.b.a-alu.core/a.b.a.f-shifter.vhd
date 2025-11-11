
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shifter is
    generic(N: integer);
    port(
        A: in std_logic_vector(N-1 downto 0);
        B: in std_logic_vector(4 downto 0);
        LOGIC_ARITH: in std_logic;   -- 1 = logic, 0 = arith
        LEFT_RIGHT: in std_logic;    -- 1 = left, 0 = right
        SHIFT_ROTATE: in std_logic;  -- 1 = shift, 0 = rotate
        OUTPUT: out std_logic_vector(N-1 downto 0)
    );
end entity shifter;

architecture BEHAVIORAL of shifter is
    component MUX21_GENERIC is
        generic (NBIT: integer:= N);
			Port (	A:	In	std_logic_vector(N-1 downto 0);
				B:	In	std_logic_vector(N-1 downto 0);
				SEL:	In	std_logic;
				Y:	Out	std_logic_vector(N-1 downto 0));
		end component;
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
    type matrix is array (log(N)-1 downto 0) of std_logic_vector(N-1 downto 0);
    signal intermediatelsl: matrix;
	signal tmplsl: matrix; 
	signal intermediatelsr: matrix;
	signal tmplsr: matrix; 
    signal intermediateasr: matrix;
	signal tmpasr: matrix;
	signal intermediaterl: matrix;
	signal tmprl: matrix; 
	signal intermediaterr: matrix;
	signal tmprr: matrix; 

begin

    L_rotate: for i in 0 to log(N)-1 generate
    
    	begin
    	first: if i=0  generate
    		begin
    			intermediaterl(i)<=A(N-2 downto 0)&A(N-1 downto N-1);
    		first_mux: MUX21_GENERIC
                      generic map (NBIT=>N)
                      port map ( intermediaterl(i),A,B(i),tmprl(0));
    	end  generate first;
    	not_first: if i>0 generate
    		begin
    			intermediaterl(i)<=tmprl(i-1)(N-(2**i)-1 downto 0)&tmprl(i-1)(N-1 downto N-(2**i));
    		other_muxes: MUX21_GENERIC
    		generic map (NBIT=>N)	
    		port map(intermediaterl(i),tmprl(i-1) , B(i),tmprl(i));
    	end generate not_first;
    end generate L_rotate;
            
            
    R_rotate: for i in 0 to log(N)-1 generate
            
    	begin
    	first: if i=0  generate
    		begin
    			intermediaterr(i)<=A(0 downto 0)&A(N-1 downto 1);
    		first_mux: MUX21_GENERIC
                      generic map (NBIT=>N)
                      port map ( intermediaterr(i),A,B(i),tmprr(0));
    	end  generate first;
    	not_first: if i>0 generate
    		begin
    			intermediaterr(i)<=tmprr(i-1)((2**i)-1 downto 0 )&tmprr(i-1)(N-1 downto (2**i));
    		other_muxes: MUX21_GENERIC
    		generic map (NBIT=>N)	
    		port map(intermediaterr(i),tmprr(i-1) , B(i),tmprr(i));
    	end generate not_first;
    end generate R_rotate;
    
L_shifter: for i in 0 to log(N)-1 generate
	
	begin
	first: if i=0  generate
		begin
		intermediatelsl(i)<=A(N-2 downto 0)&'0';
		first_mux: MUX21_GENERIC
                  generic map (NBIT=>N)
                  port map ( intermediatelsl(i),A,B(i),tmplsl(0));
	end  generate first;
	not_first: if i>0 generate
		begin
		intermediatelsl(i)<= tmplsl(i-1)(N-(2**i)-1 downto 0)&((2**i)-1 downto 0 => '0');
		other_muxes: MUX21_GENERIC
		generic map (NBIT=>N)	
		port map(intermediatelsl(i),tmplsl(i-1) , B(i),tmplsl(i));
	end generate not_first;
end generate L_shifter;

    R_shifter_l: for i in 0 to log(N)-1 generate
            
    	begin
    	first: if i=0  generate
    		begin
    		intermediatelsr(i)<='0'&A(N-1 downto 1);
    		first_mux: MUX21_GENERIC
                      generic map (NBIT=>N)
                      port map ( intermediatelsr(i),A,B(i),tmplsr(0));
    	end  generate first;
    	not_first: if i>0 generate
    		begin
    		intermediatelsr(i)<=((2**i)-1 downto 0 => '0')&tmplsr(i-1)(N-1 downto (2**i));
    		other_muxes: MUX21_GENERIC
    		generic map (NBIT=>N)	
    		port map(intermediatelsr(i),tmplsr(i-1) , B(i),tmplsr(i));
    	end generate not_first;
    end generate R_shifter_l;  
    R_shifter_a: for i in 0 to log(N)-1 generate
            
    	begin
    	first: if i=0  generate
    		begin
    		intermediateasr(i)<=A(N-1)&A(N-1 downto 1);
    		first_mux: MUX21_GENERIC
                      generic map (NBIT=>N)
                      port map ( intermediateasr(i),A,B(i),tmpasr(0));
    	end  generate first;
    	not_first: if i>0 generate
    		begin
    		intermediateasr(i)<=((2**i)-1 downto 0 => tmpasr(i-1)(N-1))&tmpasr(i-1)(N-1 downto (2**i));
    		other_muxes: MUX21_GENERIC
    		generic map (NBIT=>N)	
    		port map(intermediateasr(i),tmpasr(i-1) , B(i),tmpasr(i));
    	end generate not_first;
    end generate R_shifter_a;     
    SHIFT: process (A, B, LOGIC_ARITH, LEFT_RIGHT, SHIFT_ROTATE,tmpasr,tmprr,tmprl,tmplsr,tmplsl)
        variable shift_amt: integer := 0;
        variable temp: std_logic_vector(N-1 downto 0);
    begin
        shift_amt := to_integer(unsigned(B));
        temp := A;

        if SHIFT_ROTATE = '0' then
            -- Rotate
            if LEFT_RIGHT = '0' then
                OUTPUT <= tmprr(log(N)-1);
            else
                OUTPUT <= tmprl(log(N)-1);
            end if;
        else
            -- Shift
            if LEFT_RIGHT = '0' then
                -- Right shift
                if LOGIC_ARITH = '0' then
                    -- Arithmetic
                    OUTPUT <= tmpasr(log(N)-1);
                else
                    -- Logical
	                OUTPUT <= tmplsr(log(N)-1);
                end if;
            else
                -- Left shift 
	            OUTPUT <= tmplsl(log(N)-1);
            end if;
        end if;


    end process;

end architecture BEHAVIORAL;

