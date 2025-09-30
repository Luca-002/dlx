library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

entity DataPath is   
    generic(
        DATA_WIDTH: integer:=32;
        ADDR_WIDTH: integer:= 5
    );
    port(
        CLK 					: in std_logic;
		RST 					: in std_logic;	
        --IF
        IR_LATCH_EN        : in std_logic;
        PC_LATCH_EN        : in std_logic; 
        PC_TO_IRAM               : out std_logic_vector(DATA_WIDTH-1 downto 0);
        FLUSH               : out std_logic;
        --DE
        RegA_LATCH_EN      : in std_logic;  
        RegB_LATCH_EN      : in std_logic;  
        RegIMM_LATCH_EN    : in std_logic;  
        imm_to_be_stored   : in STD_LOGIC_VECTOR(31 downto 0);
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
        JUMP_EN        : in std_logic;          --true for both jump and branch
        JUMP            : in std_logic;         --true only for jump 
        --MEM
        BYTE             : in std_logic;
       
                 
        LMD_LATCH_EN       : in std_logic;
        SEL_MEM_ALU                      : in std_logic;  
        DATA_FROM_MEM           : in std_logic_vector(DATA_WIDTH-1 downto 0);
        
        DATA_TO_MEM                : out std_logic_vector(DATA_WIDTH-1 downto 0);
        MEM_ADDRESS             : out std_logic_vector(DATA_WIDTH-1 downto 0);
        --WB
        RF_WE                     : in std_logic;
        JAL:            in std_logic;
        HALF_WORD        : in std_logic;
        H_L             : in std_logic; --higher or lower part of the register
		S_U 			: in std_logic  --signed or unsigned write back
        );
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
        BYTE             : in std_logic;
        HALF_WORD :IN std_logic;
        H_L       :IN std_logic;
        S_U 	:IN std_logic;
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


    component MUX21_GENERIC is
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

    
    component BTB is
    generic (
        BITS_PC   : integer := 32;  
        BITS_INDEX  : integer := 6   
    );
    port (

        clk: in  std_logic;
        reset: in  std_logic;
        pc: in  std_logic_vector(BITS_PC-1 downto 0);
        pc_branch: in  std_logic_vector(BITS_PC-1 downto 0);
        branch_taken: in  std_logic;
        target_branch: in  std_logic_vector(BITS_PC-1 downto 0);
        update: in  std_logic; 
        hit: out std_logic;
        target_pc: out std_logic_vector(BITS_PC-1 downto 0)

    );
    end component;
    signal branch_taken: std_logic;
    signal pc, pc_next,pc_alu,pc_final: std_logic_vector(DATA_WIDTH-1 downto 0);    
    signal pc_plus4 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rd1,rd2,rd3: STD_LOGIC_VECTOR(4 DOWNTO 0);
    signal rf_out1, rf_out2: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal in1,A,B,im: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal eq,not_eq,branch_cond: STD_LOGIC_VECTOR(0 downto 0);    --they're vectors just in order to be able to use the generic mux
    signal alu_in1,alu_in2: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal alu_out, alu_out_reg: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal jump_addr: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal me: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal data_wb, wb_reg, out_mux_pc_wbreg: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);   
    signal branch_cond_nor_jump: STD_LOGIC;
    signal btb_target: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal pc1,pc2,pc3: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal pc_btb_mux_out: STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal btb_hit,hit1,hit2: STD_LOGIC_VECTOR(0 downto 0);
    signal jump_and_nothit: STD_LOGIC;
    signal write_address: STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
    signal restore_pc: std_logic;
    signal btb_update: std_logic;
    signal rf_enable: std_logic;
    signal byte_skew: STD_LOGIC;
    begin

       --Instruction Fetch
        
        register_pc: single_register
            generic map(
                N => DATA_WIDTH
                )
            port map(
              D     => pc_final,
              CK    => CLK,
              RESET => RST,
              EN => PC_LATCH_EN,
              Q     => pc
            );
        register_pc1: single_register
            generic map(
                N => DATA_WIDTH
                )
            port map(
              D     => pc,
              CK    => CLK,
              RESET => RST,
              EN => '1',
              Q     => pc1
            );
        register_pc2: single_register
            generic map(
                N => DATA_WIDTH
                )
            port map(
              D     => pc1,
              CK    => CLK,
              RESET => RST,
              EN => '1',
              Q     => pc2
            ); 
        register_pc3: single_register
            generic map(
                N => DATA_WIDTH
                )
            port map(
              D     => pc2,
              CK    => CLK,
              RESET => RST,
              EN => '1',
              Q     => pc3
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
        jump_and_nothit<=JUMP_EN and (not(hit2(0)));
        mux_jumpaddr_pcbtbmuxout: MUX21_GENERIC
         generic map(
            NBIT => DATA_WIDTH
        )
         port map(
            A => jump_addr,
            B => pc_btb_mux_out,
            SEL => jump_and_nothit,
            Y => pc_next
        );
        btb_update<=JUMP_EN and (not(hit2(0))); 
        BTB_inst: entity work.BTB
         generic map(
            BITS_PC => DATA_WIDTH,
            BITS_INDEX => 6
        )
         port map(
            clk => clk,
            reset => rst,
            pc => pc,
            pc_branch => pc2,         
            branch_taken => branch_taken,
            target_branch => jump_addr,
            update => btb_update,
            hit => btb_hit(0),
            target_pc => btb_target
        );
        mux_btbtarget_pcplus4: MUX21_GENERIC
         generic map(
            NBIT => DATA_WIDTH
        )
         port map(
            A => btb_target,
            B => pc_plus4,
            SEL => btb_hit(0),
            Y => pc_btb_mux_out
        );
        register_hit1: single_register
            generic map(
                N => 1
                )
            port map(
              D     => btb_hit,
              CK    => CLK,
              RESET => RST,
              EN => '1',
              Q     => hit1
            );
        register_hit2: single_register
            generic map(
                N => 1
                )
            port map(   
              D     => hit1,
              CK    => CLK,
              RESET => RST,
              EN => '1',
              Q     => hit2
            );
        branch_taken<=(not branch_cond_nor_jump) and JUMP_EN;
        FLUSH<=branch_taken xor hit2(0);
        restore_pc<=hit2(0) and (not(branch_taken));
         mux_pc2_pcnext: MUX21_GENERIC
         generic map(
            NBIT => DATA_WIDTH
        )
         port map(
            A => pc2,
            B => pc_next,
            SEL => restore_pc,
            Y => pc_final
        );
       --DECODE
        registerFile: register_file
         generic map(
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
         port map(
            CLK => CLK,
            RESET => RST,
            ENABLE => rf_enable,
            BYTE=>byte_skew,         
            HALF_WORD=>HALF_WORD,
            H_L =>H_L,           
            S_U =>S_U, 		
            RD1 => RFR1_EN,
            RD2 => RFR2_EN,
            WR => RF_WE,
            ADD_WR => write_address,
            ADD_RD1 => RS1,
            ADD_RD2 => RS2,
            DATAIN => out_mux_pc_wbreg,  
            OUT1 => rf_out1,
            OUT2 => rf_out2
        );
        rf_enable<=RF_EN or RF_WE;
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
        eq(0)<=or_reduce(A);
        not_eq<=not(eq);

        branch_cond_nor_jump<=branch_cond(0) nor JUMP;
        mux_pc_plus4_aluout: MUX21_GENERIC
         generic map(
            NBIT => DATA_WIDTH
        )
         port map(
            A => pc_plus4,
            B => alu_out,
            SEL => branch_cond_nor_jump,
            Y => jump_addr
        );
        mux_noteq_eq:MUX21_GENERIC
         generic map(
            NBIT => 1
        )
         port map(
            A => not_eq,
            B => eq,
            SEL => EQ_COND,
            Y => branch_cond
        );
        
        mux_A_pc: MUX21_GENERIC
         generic map(
            NBIT => DATA_WIDTH
        )
         port map(
            A => A,
            B => pc1,
            SEL => MUX_A,
            Y => alu_in1
        );
        mux_B_imm: MUX21_GENERIC
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
            CLK => CLK,
            rst => RST,
            INP1 => alu_in1,
            INP2 => alu_in2,
            op => op,            
            STANDARD_OUT =>alu_out
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
        byte_skew<=BYTE;
        DATA_TO_MEM<=me;
        MEM_ADDRESS<=alu_out_reg;
        mux_mem_alu: MUX21_GENERIC
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
        MUX21_32_rd: MUX21_GENERIC
         generic map(
            NBIT => ADDR_WIDTH
        )
         port map(
            A => "11111",
            B => rd3,
            SEL => JAL,
            Y => write_address
        );
        MUX21_pc3_wbreg: MUX21_GENERIC
         generic map(
            NBIT => DATA_WIDTH
        )
         port map(
            A => pc3,
            B => wb_reg,
            SEL => JAL,
            Y => out_mux_pc_wbreg
        );
end struct;
