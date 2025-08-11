library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divider is
    generic(NBIT: integer:=32);
    port (
        clk     : in  std_logic;
        rst     : in std_logic;
        start   : in  std_logic;
        dividend: in  std_logic_vector(NBIT-1 downto 0);
        divisor : in std_logic_vector(NBIT-1 downto 0);
        quotient: out std_logic_vector(NBIT-1 downto 0);
        remainder: out std_logic_vector(NBIT-1 downto 0);
        done    : out std_logic
    );
end entity;
architecture behavioral of divider is

    component MUX21_GENERIC is
        generic (NBIT: integer:= 32);
	    Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
		B:	In	std_logic_vector(NBIT-1 downto 0);
		SEL:	In	std_logic;
		Y:	Out	std_logic_vector(NBIT-1 downto 0));
        end component;

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

    
    signal Q, R2, D, R: STD_LOGIC_VECTOR(2*NBIT-1 downto 0);
    signal adder_out: std_logic_vector(2*NBIT-1 downto 0);
    signal add1_alg,add2_alg : std_logic_vector(2*NBIT-1 downto 0);
    signal add2_fix : std_logic_vector(2*NBIT-1 downto 0);
    signal add1,add2 : std_logic_vector(2*NBIT-1 downto 0);
    signal cin_alg,cin, notr2msb: std_logic_vector(0 downto 0);
    signal done_signal: STD_LOGIC;
    signal notQ: STD_LOGIC_VECTOR(2*NBIT-1 downto 0);
    signal fixing_res1,fixing_res2,end_signal: STD_LOGIC;
    begin
        
        notQ<=not(Q);
        notr2msb<=not(R2(2*NBIT-1 downto 2*NBIT-1));
        mux21_r_2r: MUX21_GENERIC
         generic map(
            NBIT => 2*NBIT
        )
         port map(
            A => Q,
            B => R2,
            SEL => done_signal,
            Y => add1_alg
        );
        mux21_r_add1alg: MUX21_GENERIC
         generic map(
            NBIT => 2*NBIT
        )
         port map(
            A => R,
            B => add1_alg,
            SEL => fixing_res2,
            Y => add1
        );
        mux21_notr_d: MUX21_GENERIC
         generic map(
            NBIT => 2*NBIT
        )
         port map(
            A => notQ,
            B => D,
            SEL => done_signal,
            Y => add2_alg
        );
        mux21_1_notr2msb: MUX21_GENERIC
         generic map(
            NBIT => 1
        )
         port map(
            A => "1",
            B => notr2msb,
            SEL => done_signal,
            Y => cin_alg
        );
        mux21_0_cin_alg: MUX21_GENERIC
         generic map(
            NBIT => 1
        )
         port map(
            A => "0",
            B => cin_alg,
            SEL => fixing_res2,
            Y => cin
        );
        mux21_1_add2alg: MUX21_GENERIC
         generic map(
            NBIT => 2*NBIT
        )
         port map(
            A => (2*NBIT-1 downto 1 =>'0')&'1',
            B => add2_alg,
            SEL => fixing_res1,
            Y => add2_fix
        );
        mux21_D_add2fix: MUX21_GENERIC
         generic map(
            NBIT => 2*NBIT
        )
         port map(
            A => D,
            B => add2_fix,
            SEL => fixing_res2,
            Y => add2
        );
        R2<=R(2*NBIT-2 downto 0) & '0' ;
        div_adder:adder
        generic map (2*NBIT)
		port map (
            A    => add1,
            B    => add2,
            Cin  => cin(0),
            S    => adder_out,
            Cout => open    
        );
        
        process(CLK)
        variable timer: std_logic_vector(NBIT-1 downto 0);
        begin
            if rst='1' then
                fixing_res1<='0';
                fixing_res2<='0';
                end_signal<='1';
                done<='0';
            else
                if rising_edge(CLK) then
                    if start='1' and end_signal='1' then  
                        D <= divisor & (NBIT-1 downto 0 =>'0');
                        R <= (NBIT-1 downto 0 =>'0') & dividend;
                        Q <= (others => '0');
                        done_signal <= '0';
                        fixing_res1<='0';
                        fixing_res2<='0';
                        end_signal<='0';
                        done<='0';
                        timer:=(NBIT-2 downto 0=>'0')&'1';
                    else
                        if end_signal='0' then
                            if done_signal='0' then
                                if R(2*NBIT-1)='0' then
                                    Q<=Q(2*NBIT-2 downto 0) & '1' ;
                                else
                                    Q<=Q(2*NBIT-2 downto 0) & '0' ;
                                end if;
                                R<=adder_out;
                                timer:=timer(NBIT-2 downto 0) & '0' ;
                                if timer=(NBIT-1 downto 0 =>'0') then
                                    done_signal<='1';
                                end if;
                            else
                                if R(2*NBIT-1)='1'then
                                    if fixing_res2='1' then
                                        remainder<=adder_out(2*NBit-1 downto NBit);
                                        done<='1';
                                        fixing_res2<='0';
                                        end_signal<='1';
                                    else 
                                        if fixing_res1='1' then
                                            quotient<=adder_out(NBIT-1 downto 0);
                                            fixing_res2<='1';
                                            fixing_res1<='0';
                                        else
                                            fixing_res1<='1';
                                            Q<=adder_out;
                                        end if ;
                                    end if;  
                                else
                                    quotient<=adder_out(NBIT-1 downto 0);
                                    remainder<=R(2*NBit-1 downto NBit);
                                    done<='1';
                                    end_signal<='1';
                                end if;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end process;
    end behavioral;