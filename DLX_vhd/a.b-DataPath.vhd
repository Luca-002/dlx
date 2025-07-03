library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

entity DataPath is   --TODO: add enable to registers, change sontrol signals
    generic(
        DATA_WIDTH: integer:=32;
        NBIT_IMMEDIATE: integer :=16;
        ADDR_WIDTH: integer:= 5
    );
    port(
        CLK 					: in std_logic;
		RST 					: in std_logic;
		INP1 					: in std_logic_vector(DATA_WIDTH-1 downto 0);		
		INP2 					: in std_logic_vector(DATA_WIDTH-1 downto 0);				
		RS1 					: in std_logic_vector(ADDR_WIDTH-1 downto 0);	
		RS2 					: in std_logic_vector(ADDR_WIDTH-1 downto 0);	
		RD 						: in std_logic_vector(ADDR_WIDTH-1 downto 0);
        EN2                     : in std_logic;    
        RF1                     : in std_logic;
        RF2                     : in std_logic; 
        EN3                     : in std_logic;  
        S1                      : in std_logic;  
        S2                      : in std_logic;  
        op                      : in aluOp;
        EN4                     : in std_logic;  
        RM                      : in std_logic;
        WM                      : in std_logic;  
        S3                      : in std_logic;  
        WF1                     : in std_logic;
        
        DATA_FROM_MEM           : in std_logic_vector(DATA_WIDTH-1 downto 0);
        PC_TO_MEM               : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DATA_TO_MEM                : out std_logic_vector(DATA_WIDTH-1 downto 0);
        MEM_ADDRESS             : out std_logic_vector((ADDR_WIDTH**2)-1 downto 0));  
end DataPath;
architecture struct of DataPath is

    component register_file is
        generic (
		DATA_WIDTH : integer := 32;
		ADDR_WIDTH : integer := 5
	);
 	port ( CLK: 		IN std_logic;
        RESET: 	IN std_logic;
	 	ENABLE: 	IN std_logic;
	 	RD1: 		IN std_logic;
	 	RD2: 		IN std_logic;
	 	WR: 		IN std_logic;
	 	ADD_WR: 	IN std_logic_vector(ADDR_WIDTH - 1 downto 0);
	 	ADD_RD1: 	IN std_logic_vector(ADDR_WIDTH - 1 downto 0);
	 	ADD_RD2: 	IN std_logic_vector(ADDR_WIDTH - 1 downto 0);
	 	DATAIN: 	IN std_logic_vector(DATA_WIDTH - 1 downto 0);
        OUT1: 		OUT std_logic_vector(DATA_WIDTH - 1 downto 0);
	 	OUT2: 		OUT std_logic_vector(DATA_WIDTH - 1 downto 0));
        end component;


    component single_register is
        Generic(N: integer:= 32);
	Port (	D:	In	std_logic_vector(N-1 downto 0);
		CK:	In	std_logic;
		RESET:	In	std_logic;
		Q:	Out	std_logic_vector(N-1 downto 0));
        end component;


    component MUX21 is
        generic (NBIT: integer:= 32);
	    Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
		B:	In	std_logic_vector(NBIT-1 downto 0);
		SEL:	In	std_logic;
		Y:	Out	std_logic_vector(NBIT-1 downto 0));
        end component;

    component alu is
        generic(
        DATA_WIDTH: integer:=32
    );
    port(
        INP1 					: in std_logic_vector(DATA_WIDTH-1 downto 0);		
		INP2 					: in std_logic_vector(DATA_WIDTH-1 downto 0);
        op                    : in aluOp;
        DATA_OUT                : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
    end component;
        
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
    
    signal pc, pc_next : std_logic_vector(DATA_WIDTH-1 downto 0);    
    signal pc_plus4 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rd1,rd2,rd3: STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal rf_out1, rf_out2: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal in1,A,B,in2: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal alu_in1, alu_in2: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal alu_out, alu_out_reg: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal me: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal data_wb, wb_reg: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    begin

       --Instruction Fetch

        register_pc: single_register
            generic map(
                N => DATA_WIDTH
                )
            port map(
              D     => pc_next,
              CK    => CLK,
              RESET => RST,
              Q     => pc
            );
        PC_TO_MEM<=pc;
        PC_adder: adder
            generic map(
                NBIT => DATA_WIDTH,
                NBIT_PER_BLOCK=>4
                )
            port map(
              A     => pc,
              B     => (DATA_WIDTH-1-3 downto 0 => '0') & "100",
              Cin  => '0',
              S => pc_plus4
            );
        register_npc: single_register
         generic map(
            N => 1
        )
         port map(
            D => pc_plus4,
            CK => CLK,
            RESET => RST,
            Q => pc_next
        ); --TODO: implement jumps

       --DECODE

        registerFile: register_file
         generic map(
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
         port map(
            CLK => CLK,
            RESET => RST,
            ENABLE => EN2,
            RD1 => RF1,
            RD2 => RF2,
            WR => WF1,
            ADD_WR => rd3,
            ADD_RD1 => RS1,
            ADD_RD2 => RS2,
            DATAIN => wb_reg,  
            OUT1 => rf_out1,
            OUT2 => rf_out2
        );


        register_in1:single_register
         generic map(
            N => DATA_WIDTH
        )
         port map(
            D => INP1,
            CK => CLK,
            RESET => RST,
            Q => in1
        );


        register_A:single_register
         generic map(
            N => DATA_WIDTH
        )
         port map(
            D => rf_out1,
            CK => CLK,
            RESET => RST,
            Q => A
        );


        register_B: single_register
         generic map(
            N => DATA_WIDTH
        )
         port map(
            D => rf_out2,
            CK => CLK,
            RESET => RST,
            Q => B
        );


        register_in2: single_register
         generic map(
            N => DATA_WIDTH
        )
         port map(
            D => INP2,
            CK => CLK,
            RESET => RST,
            Q => in2
        );


         register_rd1: single_register --using register as ff
         generic map(
            N =>1
        )
         port map(
            D => RD,
            CK => ClK,
            RESET => rst,
            Q => rd1
        );

        --EXECUTE

        mux_in1_A: mux21
         generic map(
            NBIT => DATA_WIDTH
        )
         port map(
            A => in1,
            B => A,
            SEL => S1,
            Y => alu_in1
        );


        mux_B_in2: mux21
         generic map(
            NBIT => DATA_WIDTH
        )
         port map(
            A => B,
            B => in2,
            SEL => S2,
            Y => alu_in2
        );


        alu_: entity work.alu
         generic map(
            DATA_WIDTH => DATA_WIDTH
        )
         port map(
            INP1 => INP1,
            INP2 => INP2,
            op => op,            
            DATA_OUT =>alu_out
        );


        register_alu_out: single_register
         generic map(
            N => DATA_WIDTH
        )
         port map(
            D => alu_out,
            CK => CLK,
            RESET => RST,
            Q => alu_out_reg
        );


        register_me: single_register
         generic map(
            N => DATA_WIDTH
        )
         port map(
            D => B,
            CK => CLK,
            RESET => RST,
            Q => me
        );


        register_rd2: single_register
         generic map(
            N => 1
        )
         port map(
            D => rd1,
            CK => CLK,
            RESET => RST,
            Q => rd2
        );

        --MEMORY

        DATA_TO_MEM<=me;
        MEM_ADDRESS<=alu_out_reg;
        mux_mem_alu: mux21
         generic map(
            NBIT => DATA_WIDTH
        )
         port map(
            A => DATA_FROM_MEM,
            B => alu_out_reg,
            SEL => S3,
            Y => data_wb
        );
        register_memory: single_register
         generic map(
            N => DATA_WIDTH
        )
         port map(
            D => data_wb,
            CK => CLK,
            RESET => RST,
            Q => wb_reg
        );
        register_rd3: single_register
         generic map(
            N => 1
        )
         port map(
            D => rd2,
            CK => CLK,
            RESET => RST,
            Q => rd3
        );
        --WRITE BACK

end struct;