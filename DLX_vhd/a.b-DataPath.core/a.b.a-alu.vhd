library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

entity alu is   
    generic(
        DATA_WIDTH: integer:=32
    );
    port(
        CLK                     : in std_logic;
        RST                     : in std_logic;
        INP1 					: in std_logic_vector(DATA_WIDTH-1 downto 0);		
		    INP2 					: in std_logic_vector(DATA_WIDTH-1 downto 0);
        op                    : in aluOp;
        STANDARD_OUT                : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DIV_OUT                     : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
        MUL_OUT                     : OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
        DONE_DIV                : out std_logic;
        DONE_MUL                : out std_logic
    );
end alu;

architecture struct of alu is

    component adder is
        generic (
		NBIT :		integer := 32;
		NBIT_PER_BLOCK: integer := 4);
	port (
		A :		in	std_logic_vector(NBIT-1 downto 0);
		B :		in	std_logic_vector(NBIT-1 downto 0);
		Cin :	in	std_logic;
		S :		out	std_logic_vector(NBIT-1 downto 0);
		Cout :	out	std_logic);
        end component;


    component shifter is 
    generic(N: integer);
	port(	A: in std_logic_vector(N-1 downto 0);
		B: in std_logic_vector(4 downto 0);
		LOGIC_ARITH: in std_logic;	-- 1 = logic, 0 = arith
		LEFT_RIGHT: in std_logic;	-- 1 = left, 0 = right
		SHIFT_ROTATE: in std_logic;	-- 1 = shift, 0 = rotate
		OUTPUT: out std_logic_vector(N-1 downto 0)
	);
        end component;


    component logic_unit is
        generic(NBIT: integer:=32);
    port(
		A :		in	std_logic_vector(NBIT-1 downto 0);
		B :		in	std_logic_vector(NBIT-1 downto 0);
        op:     in aluOp;
        result: out STD_LOGIC_VECTOR(NBIT-1 downto 0)
    );
        end component;

        
    component multiplier is 
    generic (
		NBIT :		integer := 8);
	port (
		CLK:	in std_logic;
		rst: 	in std_logic;
		A :		in	std_logic_vector((NBIT/2)-1 downto 0);
		B :		in	std_logic_vector((NBIT/2)-1 downto 0);
		P :		out	std_logic_vector(NBIT-1 downto 0));
    end component;
    
    component comparator is
        generic(
        DATA_WIDTH: integer := 32
    );
    port(
        cout : in  std_logic;   
        A : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        B : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        sum : in  std_logic_vector(DATA_WIDTH-1 downto 0); 
        A_gt_or_eq_B: out std_logic;  
        A_gt_B : out std_logic;  
        A_lt_or_eq_B: out std_logic;  
        A_lt_B: out std_logic;  
        A_eq_B: out std_logic;  
        A_ge_u: out std_logic;  
        A_gt_u: out std_logic;  
        A_le_u: out std_logic;  
        A_lt_u: out std_logic   
    );
    end component;

    component divider is
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
    end component;

        signal cin_adder, cout_adder: STD_LOGIC;
        signal adder_out: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

        signal shift_left, shift_logic,shift_rotate: STD_LOGIC;
        signal shifter_out: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

        signal logic_out: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

        signal multiplier_out: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

        signal A_gt_or_eq_B,A_gt_B,A_lt_or_eq_B,A_lt_B,A_eq_B: STD_LOGIC; 

        signal div_quotient, div_remainder: STD_LOGIC_VECTOR(DATA_WIDTH -1 downto 0);
        signal div_start, div_done: STD_LOGIC;
        signal A_ge_u, A_gt_u, A_le_u, A_lt_u: STD_LOGIC;
        signal multiplier_finished_tracker: STD_LOGIC_VECTOR(1 downto 0); 
    begin
    cin_adder<= '1' when op = ALU_SUB else '0';
        
    alu_adder: adder
        generic map (
            NBIT => DATA_WIDTH,
            NBIT_PER_BLOCK => 4
        )
        port map (
            A    => INP1,
            B    => INP2,
            Cin  => cin_adder,
            S    => adder_out,
            Cout => cout_adder
        );

    shift_left <= '1' when (op = LLS) or (op = RL) else '0';                    
    shift_logic <= '1'  when (op = LLS) or (op = LRS) else '0'; 
    shift_rotate<= '0'  when (op = RR) or (op = RL) else '1'; 
    alu_shifter: shifter
        generic map (N => DATA_WIDTH)
        port map (
            A           => INP1,
            B           => INP2(4 downto 0),   
            LOGIC_ARITH => shift_logic,  
            LEFT_RIGHT  => shift_left,         
            SHIFT_ROTATE=> shift_rotate,       
            OUTPUT      => shifter_out
        );

    alu_logic: logic_unit
        generic map (NBIT => DATA_WIDTH)
        port map (
            A      => INP1,
            B      => INP2,
            op     => op,        
            result => logic_out
        );

    alu_mult: multiplier
        generic map (NBIT => DATA_WIDTH)
        port map (
            CLK => CLK,
            rst=> RST,
            A => INP1(DATA_WIDTH/2-1 downto 0),         
            B => INP2(DATA_WIDTH/2-1 downto 0),
            P => multiplier_out
        );

    alu_div: entity work.divider
     generic map(
        NBIT => DATA_WIDTH
    )
     port map(
        clk => clk,
        rst => rst,
        start => div_start,
        dividend => INP1,
        divisor => INP2,
        quotient => div_quotient,
        remainder => div_remainder,
        done => div_done
    );
    alu_comparator: comparator
     generic map(
        DATA_WIDTH => DATA_WIDTH
    )
     port map(
        cout => cout_adder,
        A => INP1,
        B => INP2,
        sum => adder_out,
        A_gt_or_eq_B => A_gt_or_eq_B,
        A_gt_B => A_gt_B,
        A_lt_or_eq_B => A_lt_or_eq_B,
        A_lt_B => A_lt_B,
        A_eq_B => A_eq_B,
        A_ge_u => A_ge_u,
        A_gt_u => A_gt_u,
        A_le_u => A_le_u,
        A_lt_u => A_lt_u
    );    
       process(op, adder_out, shifter_out, multiplier_out, logic_out,
        A_eq_B, A_gt_or_eq_B, A_gt_B, A_lt_or_eq_B, A_lt_B,
        A_ge_u, A_gt_u, A_lt_u)  
        begin
            case op is
                when NOP =>  
                    STANDARD_OUT <= (others => '0');
                when A =>
                    STANDARD_OUT <= INP1;
                when ALU_ADD | ALU_SUB => 
                    STANDARD_OUT <= adder_out;
            
                when LLS | LRS | ALS | ARS | RR | RL => 
                    STANDARD_OUT <= shifter_out;
            
                when ALU_AND | ALU_NAND | ALU_OR | ALU_NOR | ALU_XOR | ALU_XNOR =>  
                    STANDARD_OUT <= logic_out;
            

                when SEQ =>  
                    if A_eq_B = '1' then
                        STANDARD_OUT <= (DATA_WIDTH-1 downto 1 => '0') & '1';
                    else
                        STANDARD_OUT <= (others => '0');
                    end if;
                    
                when SNE =>  
                    if A_eq_B = '0' then
                        STANDARD_OUT <= (DATA_WIDTH-1 downto 1 => '0') & '1';
                    else
                        STANDARD_OUT <= (others => '0');
                    end if; 
                    
                when SGE =>  
                    if A_gt_or_eq_B = '1' then
                        STANDARD_OUT <= (DATA_WIDTH-1 downto 1 => '0') & '1';
                    else
                        STANDARD_OUT <= (others => '0');
                    end if;  
                    
                when SGT =>  
                    if A_gt_B = '1' then
                        STANDARD_OUT <= (DATA_WIDTH-1 downto 1 => '0') & '1';
                    else
                        STANDARD_OUT <= (others => '0');
                    end if;
                    
                when SLE =>  
                    if A_lt_or_eq_B = '1' then
                        STANDARD_OUT <= (DATA_WIDTH-1 downto 1 => '0') & '1';
                    else
                        STANDARD_OUT <= (others => '0');
                    end if;
                    
                when SLT =>  
                    if A_lt_B = '1' then
                        STANDARD_OUT <= (DATA_WIDTH-1 downto 1 => '0') & '1';
                    else
                        STANDARD_OUT <= (others => '0');
                    end if;

                when SGEU =>
                    if A_ge_u = '1' then
                        STANDARD_OUT <= (DATA_WIDTH-1 downto 1 => '0') & '1';
                    else
                        STANDARD_OUT <= (others => '0');
                    end if;
                    
                when SGTU =>
                    if A_gt_u = '1' then
                        STANDARD_OUT <= (DATA_WIDTH-1 downto 1 => '0') & '1';
                    else
                        STANDARD_OUT <= (others => '0');
                    end if;
                    
                when SLTU =>
                    if A_lt_u = '1' then
                        STANDARD_OUT <= (DATA_WIDTH-1 downto 1 => '0') & '1';
                    else
                        STANDARD_OUT <= (others => '0');
                    end if;
                    
                when others =>
                    STANDARD_OUT <= (others => '0');
            end case;
        MUL_OUT<=multiplier_out;
        end process;



process(clk, rst)
begin
    if rst = '1' then
        multiplier_finished_tracker <= (others => '0');
        DONE_MUL <= '0';
    elsif rising_edge(clk) then
        if op = MULT then
            multiplier_finished_tracker(0) <= '1';
        else
            multiplier_finished_tracker(0) <= '0';
        end if;

        DONE_MUL <= multiplier_finished_tracker(1);
        multiplier_finished_tracker(1) <= multiplier_finished_tracker(0);
    end if;
end process;


    
end struct;
