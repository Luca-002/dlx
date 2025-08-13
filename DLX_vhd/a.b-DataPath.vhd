library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

entity DataPath is   --add NPC and use it as intput to MUX A, might need to multiply immediate addresses by 4 based on how they're calculated, need jumpÃ¨ before branch, not other way around
    generic(
        DATA_WIDTH: integer:=32;
        ADDR_WIDTH: integer:= 5
    );
    port(
        CLK 					: in std_logic;
		RST 					: in std_logic;	
        --IF
        IR_LATCH_EN        : in std_logic;
        INSTRUCTION        : in std_logic_vector(DATA_WIDTH-1 downto 0);
        PC_LATCH_EN        : in std_logic; 
        PC_TO_IRAM               : out std_logic_vector(DATA_WIDTH-1 downto 0);
        --DE
        I_J                : in std_logic;
        RegA_LATCH_EN      : in std_logic;  
        RegB_LATCH_EN      : in std_logic;  
        RegIMM_LATCH_EN    : in std_logic;  
		RS1 					: in std_logic_vector(ADDR_WIDTH-1 downto 0);	
		RS2 					: in std_logic_vector(ADDR_WIDTH-1 downto 0);	
		RD 						: in std_logic_vector(ADDR_WIDTH-1 downto 0);
        RFR1_EN                     : in std_logic;
        RFR2_EN                     : in std_logic; 
        RF_EN                       :in std_logic;

        --EX
        ALU_OUTREG_EN      : in std_logic;  
        MUX_B                      : in std_logic;  
        MUX_A                     : in std_logic;  
        op                      : in aluOp; 
        MEM_LATCH_EN      : in std_logic;
        EQ_COND            : in std_logic;
        --MEM
        JUMP_EN        : in std_logic;
        JUMP            : in std_logic;
        LMD_LATCH_EN       : in std_logic;
        SEL_MEM_ALU                      : in std_logic;  
        DATA_FROM_MEM           : in std_logic_vector(DATA_WIDTH-1 downto 0);
        
        DATA_TO_MEM                : out std_logic_vector(DATA_WIDTH-1 downto 0);
        MEM_ADDRESS             : out std_logic_vector((ADDR_WIDTH**2)-1 downto 0);
        --WB
        RF_WE                     : in std_logic);
end DataPath;
architecture struct of DataPath is

    function or_reduce(v: std_logic_vector) return std_logic is
		variable res: std_logic := '0';
	  begin
		for i in v'range loop
		  res := res or v(i);
		end loop;
		return res;
	  end function;


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
        EN    : in  std_logic;   
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
    
    signal IMM_I_TYPE,IMM_J_TYPE,imm_i_ext, imm_j_ext,imm_to_be_stored: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal pc, pc_next,pc_jump,cur_instruction : std_logic_vector(DATA_WIDTH-1 downto 0);    
    signal pc_plus4 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rd1,rd2,rd3: STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal rf_out1, rf_out2: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal in1,A,B,im: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal eq_tmp: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal eq,not_eq,branch_cond: STD_LOGIC_VECTOR(0 downto 0);    --they're vectors just in order to be able to use the generic mux
    signal alu_in1,alu_in2: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal alu_out, alu_out_reg: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal jump_addr: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal me: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal data_wb, wb_reg: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);


    signal branch_cond_or_jump: STD_LOGIC;
    begin

       --Instruction Fetch
        register_ir:single_register
         generic map(
            N => DATA_WIDTH
        )
         port map(
            D => INSTRUCTION,
            CK => CLK,
            RESET => RST,
            EN => IR_LATCH_EN,
            Q => cur_instruction
        );
        IMM_I_TYPE<=cur_instruction(31 downto 16);
        IMM_J_TYPE<=cur_instruction(31 downto 7);
        register_pc: single_register
            generic map(
                N => DATA_WIDTH
                )
            port map(
              D     => pc_next,
              CK    => CLK,
              RESET => RST,
              EN => PC_LATCH_EN,
              Q     => pc
            );
        PC_TO_IRAM<=pc;
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
       mux_jumpaddr_pcplus4: mux21
         generic map(
            NBIT => DATA_WIDTH
        )
         port map(
            A => jump_addr,
            B => pc_plus4,
            SEL => JUMP_EN,
            Y => pc_next
        );
         

       --DECODE
        imm_i_ext<=(DATA_WIDTH-16-1 downto 0 =>IMM_I_TYPE(15))&IMM_I_TYPE;
        imm_j_ext<=(DATA_WIDTH-26-1 downto 0 =>IMM_J_TYPE(25))&IMM_J_TYPE;
        registerFile: register_file
         generic map(
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
         port map(
            CLK => CLK,
            RESET => RST,
            ENABLE => RF_EN,
            RD1 => RFR1_EN,
            RD2 => RFR2_EN,
            WR => RF_WE,
            ADD_WR => rd3,
            ADD_RD1 => RS1,
            ADD_RD2 => RS2,
            DATAIN => wb_reg,  
            OUT1 => rf_out1,
            OUT2 => rf_out2
        );

        register_A:single_register
         generic map(
            N => DATA_WIDTH
        )
         port map(
            D => rf_out1,
            CK => CLK,
            RESET => RST,
            EN => RegA_LATCH_EN,
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
            EN => RegB_LATCH_EN,
            Q => B
        );

        mux_immi_immj: mux21
         generic map(
            NBIT => DATA_WIDTH
        )
         port map(
            A => imm_i_ext,
            B => imm_j_ext,
            SEL => I_J,
            Y => imm_to_be_stored
        );

        register_imm: single_register
         generic map(
            N => DATA_WIDTH
        )
         port map(
            D => imm_to_be_stored,
            CK => CLK,
            RESET => RST,
            EN => RegIMM_LATCH_EN,
            Q => im
        );


         register_rd1: single_register
         generic map(
            N =>ADDR_WIDTH
        )
         port map(
            D => RD,
            CK => ClK,
            RESET => rst,
            EN => '1',
            Q => rd1
        );

        --EXECUTE
        process(A,B)
            begin
                for i in 0 to DATA_WIDTH-1 loop
                    eq_tmp(i)<=A(i) xor B(i);
                end loop;
        end process;
        eq(0)<=or_reduce(eq_tmp);
        not_eq<=not(eq);
        
        mux_im_pc_plus4: mux21
         generic map(
            NBIT => DATA_WIDTH
        )
         port map(
            A => im,
            B => pc_plus4,
            SEL => JUMP,
            Y => pc_jump
        );
        branch_cond_or_jump<=branch_cond(0) or JUMP;
        mux_pc_jump_aluout: MUX21
         generic map(
            NBIT => DATA_WIDTH
        )
         port map(
            A => pc_jump,
            B => alu_out,
            SEL => branch_cond_or_jump,
            Y => jump_addr
        );
        mux_noteq_eq:mux21
         generic map(
            NBIT => 1
        )
         port map(
            A => not_eq,
            B => eq,
            SEL => EQ_COND,
            Y => branch_cond
        );
        mux_A_pc: mux21
         generic map(
            NBIT => DATA_WIDTH
        )
         port map(
            A => A,
            B => pc,
            SEL => MUX_A,
            Y => alu_in1
        );
        mux_B_imm: mux21
         generic map(
            NBIT => DATA_WIDTH
        )
         port map(
            A => B,
            B => im,
            SEL => MUX_B,
            Y => alu_in2
        );


        alu_instance: alu
         generic map(
            DATA_WIDTH => DATA_WIDTH
        )
         port map(
            INP1 => alu_in1,
            INP2 => alu_in2,
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
            EN => ALU_OUTREG_EN,
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
            EN => MEM_LATCH_EN,
            Q => me
        );


        register_rd2: single_register
         generic map(
            N => ADDR_WIDTH
        )
         port map(
            D => rd1,
            CK => CLK,
            RESET => RST,
            EN => '1',
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
            SEL => SEL_MEM_ALU,
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
            EN => LMD_LATCH_EN,
            Q => wb_reg
        );
        register_rd3: single_register
         generic map(
            N => ADDR_WIDTH
        )
         port map(
            D => rd2,
            CK => CLK,
            RESET => RST,
            EN => '1',
            Q => rd3
        );
        --WRITE BACK

end struct;