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

    signal D, R, Q, R2, timer: std_logic_vector(NBIT-1 downto 0);
    signal adder_out: std_logic_vector(NBIT-1 downto 0);
    signal add1,add2 : std_logic_vector(NBIT-1 downto 0);
    signal cin, notr2msb: std_logic_vector(0 downto 0);
    signal done_signal: STD_LOGIC;
    signal notQ: STD_LOGIC_VECTOR(NBIT-1 downto 0);
    begin
        notQ<=not(Q);
        notr2msb<=not(R2(NBIT-1 downto NBIT-1));
        mux21_r_2r: MUX21_GENERIC
         generic map(
            NBIT => NBIT
        )
         port map(
            A => Q,
            B => R2,
            SEL => done_signal,
            Y => add1
        );
        mux21_notr_d: MUX21_GENERIC
         generic map(
            NBIT => NBIT
        )
         port map(
            A => notQ,
            B => D,
            SEL => done_signal,
            Y => add2
        );
        mux21_1_notr2msb: MUX21_GENERIC
         generic map(
            NBIT => 1
        )
         port map(
            A => "1",
            B => notr2msb,
            SEL => done_signal,
            Y => cin
        );
        R2<=R(NBIT-2 downto 0) & '0' ;
        div_adder:adder
        generic map (NBIT)
		port map (
            A    => add1,
            B    => add2,
            Cin  => cin(0),
            S    => adder_out,
            Cout => open    
        );
        process(CLK)
        begin
            if rst='1' then
                done_signal<='1';
            else
                if rising_edge(CLK) then
                    if start='1' and done_signal='1' then
                        D <= divisor;
                        R <= dividend(NBIT-2 downto 0) & '0';
                        Q <= (others => '0');
                        done_signal <= '0';
                        timer<=(NBIT-2 downto 0=>'0')&'1';
                    else
                        if done_signal='0' then
                            if R(NBIT-1)='0' then
                                Q<=Q(NBIT-2 downto 0) & '1' ;
                            else
                                Q<=Q(NBIT-2 downto 0) & '0' ;
                            end if;
                            R<=adder_out;
                            timer<=timer(NBIT-2 downto 0) & '0' ;
                            if R=(NBIT-1 downto 0=>'0') or timer=(NBIT-1 downto 0 =>'0') then
                                done_signal<='1';
                                quotient<=adder_out;
                                remainder<=R;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end process;
        done<=done_signal;
    end behavioral;