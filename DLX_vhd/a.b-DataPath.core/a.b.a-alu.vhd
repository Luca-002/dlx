library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

entity alu is   --TODO:test
    generic(
        DATA_WIDTH: integer:=32
    );
    port(
        INP1 					: in std_logic_vector(DATA_WIDTH-1 downto 0);		
		INP2 					: in std_logic_vector(DATA_WIDTH-1 downto 0);
        op                    : in aluOp;
        DATA_OUT                : out std_logic_vector(DATA_WIDTH-1 downto 0);
        A_gt_or_eq_B                : out std_logic;
        A_gt_B                : out std_logic;
        A_lt_or_eq_B                : out std_logic;
        A_lt_B                : out std_logic;
        A_eq_B                : out std_logic
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
		A :		in	std_logic_vector((NBIT/2)-1 downto 0);
		B :		in	std_logic_vector((NBIT/2)-1 downto 0);
		P :		out	std_logic_vector(NBIT-1 downto 0));
    end component;
    
    component comparator is
        generic(
        DATA_WIDTH: integer:=32
    );
    port(
        cout 					: in std_logic;		
		sum 					: in std_logic_vector(DATA_WIDTH-1 downto 0);
        A_gt_or_eq_B                : out std_logic;
        A_gt_B                : out std_logic;
        A_lt_or_eq_B                : out std_logic;
        A_lt_B                : out std_logic;
        A_eq_B                : out std_logic
    );
    end component;

        signal cin_adder, cout_adder: STD_LOGIC;
        signal adder_out: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

        signal shift_left, shift_logic,shift_rotate: STD_LOGIC;
        signal shifter_out: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

        signal logic_out: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

        signal multiplier_out: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);

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
            A => INP1(DATA_WIDTH/2-1 downto 0),         
            B => INP2(DATA_WIDTH/2-1 downto 0),
            P => multiplier_out
        );
    alu_comparator: comparator
     generic map(
        DATA_WIDTH => DATA_WIDTH
    )
     port map(
        cout => cout_adder,
        sum => adder_out,
        A_gt_or_eq_B => A_gt_or_eq_B,
        A_gt_B => A_gt_B,
        A_lt_or_eq_B => A_lt_or_eq_B,
        A_lt_B => A_lt_B,
        A_eq_B => A_eq_B
    );    
        process(op, adder_out, shifter_out, multiplier_out, logic_out)
        begin
            case op is
                when NOP =>  
                    DATA_OUT <= (others => '0');
                when ALU_ADD | ALU_SUB => 
                    DATA_OUT <= adder_out;
                when LLS | LRS | ALS | ARS | RR | RL =>  
                    DATA_OUT <= shifter_out;
                when ALU_AND | ALU_NAND | ALU_OR | ALU_NOR | ALU_XOR | ALU_XNOR =>  
                    DATA_OUT <= logic_out;
                when MULT =>  
                    DATA_OUT <= multiplier_out;
                when others =>
                    DATA_OUT <= (others => '0');
            end case;
        end process;

    
end struct;
