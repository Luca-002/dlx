library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;

entity DLX is
  generic (
    IR_SIZE      : integer := 32;       -- Instruction Register Size
    PC_SIZE      : integer := 32       -- Program Counter Size
    );       -- ALU_OPC_SIZE if explicit ALU Op Code Word Size
  port (
    Clk : in std_logic;
    Rst : in std_logic);                -- Active Low
end DLX;


-- This architecture is currently not complete
-- it just includes:
-- instruction register (complete)
-- program counter (complete)
-- instruction ram memory (complete)
-- control unit (UNCOMPLETE)
--
architecture dlx_rtl of DLX is

 --------------------------------------------------------------------
 -- Components Declaration
 --------------------------------------------------------------------
  
  --Instruction Ram
  component IRAM
    port (
      Rst  : in  std_logic;
      Addr : in  std_logic_vector(PC_SIZE - 1 downto 0);
      Dout : out std_logic_vector(IR_SIZE - 1 downto 0));
  end component;

  component DRAM is
    generic (
        ADDR_WIDTH : integer := 8;  
        DATA_WIDTH : integer := 32 
    );
    port (
        clk        : in  std_logic;                           
        reset      : in  std_logic; 
        BYTE             : in std_logic;                               
        we         : in  std_logic;                               
        addr       : in  std_logic_vector(ADDR_WIDTH-1 downto 0);    
        data_in : in  std_logic_vector(DATA_WIDTH-1 downto 0);       
        data_out  : out std_logic_vector(DATA_WIDTH-1 downto 0)      
    );
  end component;

 component DataPath is   
       generic(
        DATA_WIDTH: integer:=32;
        ADDR_WIDTH: integer:= 5
    );
    port(
        CLK                     : in std_logic;
		RST                     : in std_logic;    
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
        RS1                     : in std_logic_vector(ADDR_WIDTH-1 downto 0);   
        RS2                     : in std_logic_vector(ADDR_WIDTH-1 downto 0);   
        RD                      : in std_logic_vector(ADDR_WIDTH-1 downto 0);   
        RFR1_EN                     : in std_logic;
        RFR2_EN                     : in std_logic; 
        RF_EN                       :in std_logic;

        --EX
        ALU_OUTREG_MUL_DIV: in STD_LOGIC;
        ALU_OUTREG_COMB_SEQ: in STD_LOGIC;
        ALU_OUTREG_EN      : in std_logic;  
        MUX_B                      : in std_logic;  
        MUX_A                     : in std_logic;  
        op                      : in aluOp; 
        MEM_LATCH_EN      : in std_logic;
        EQ_COND            : in std_logic;
        JUMP_EN        : in std_logic;          --true for both jump and branch
        JUMP            : in std_logic;         --true only for jump 
        CAN_READ         : out STD_LOGIC;
        CAN_WRITE        : out STD_LOGIC;
        START_MUL        : in STD_LOGIC;
        START_DIV        : in STD_LOGIC;
        MULTIPLICATION_ENDED: out STD_LOGIC;
        DIVISION_ENDED: out STD_LOGIC;

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
 end component;
  -- Control Unit
  component dlx_cu
  generic (
    MICROCODE_MEM_SIZE :     integer := 62;  -- Microcode Memory Size
    FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
    OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
    -- ALU_OPC_SIZE       :     integer := 6;  -- ALU Op Code Word Size
    IR_SIZE            :     integer := 32;  -- Instruction Register Size    
    CW_SIZE            :     integer := 23);  -- Control Word Size
  port (
    Clk                : in  std_logic;  -- Clock
    Rst                : in  std_logic;  -- Reset:Active-Low



    IR_IN              : in std_logic_vector(31 downto 0);
    --IF
    IR_LATCH_EN        : out std_logic;
    PC_LATCH_EN        : out std_logic; 
    FLUSH               : in std_logic;
    --DE
    RegA_LATCH_EN      : out std_logic;  
    RegB_LATCH_EN      : out std_logic;  
    RegIMM_LATCH_EN    : out std_logic;  
    IM                 : out std_logic_vector(31 downto 0);
    RS1 			     : out std_logic_vector(4 downto 0);    
    RS2 			     : out std_logic_vector(4 downto 0);    
    RD 			     : out std_logic_vector(4 downto 0);   
    RFR1_EN                     : out std_logic;
    RFR2_EN                     : out std_logic; 
    RF_EN                       : out std_logic;
    --EX
    DIVISION_ENDED     : in  std_logic;
    MULTIPLICATION_ENDED : in std_logic; 
    ALU_OUTREG_EN      : out std_logic;  
    MUX_B                      : out std_logic;  
    MUX_A                     : out std_logic;  
    op                      : out aluOp; 

    MEM_LATCH_EN      : out std_logic;
    EQ_COND            : out std_logic;
    JUMP_EN        : out std_logic;          --true for both jump and branch
    JUMP            : out std_logic;         --true only for jump 
    CAN_READ         : in STD_LOGIC;
    CAN_WRITE        : in STD_LOGIC;        
    START_MUL        : out STD_LOGIC;
    START_DIV        : out STD_LOGIC; 
    ALU_OUTREG_MUL_DIV: out STD_LOGIC;
    ALU_OUTREG_COMB_SEQ: out STD_LOGIC;
    --MEM
    BYTE             : out std_logic;

    LMD_LATCH_EN       : out std_logic;
    SEL_MEM_ALU                      : out std_logic;  
    --WB
    RF_WE                     : out std_logic;
    JAL:            out std_logic;
    HALF_WORD        : out std_logic;
    H_L             : out std_logic; --higher or lower part of the register
    S_U 				    : out std_logic  --signed or unsigned write back
    );  

  end component;
  signal IRam_DOut : std_logic_vector(IR_SIZE - 1 downto 0);
  signal IR_LATCH_EN_i : std_logic;
  signal NPC_LATCH_EN_i : std_logic;
  signal RegA_LATCH_EN_i : std_logic;
  signal RegB_LATCH_EN_i : std_logic;
  signal RegIMM_LATCH_EN_i : std_logic;
  signal EQ_COND_i : std_logic;
  signal JUMP_EN_i : std_logic;
  signal JUMP_i : std_logic;
  signal ALU_OPCODE_i : aluOp;
  signal MUXA_SEL_i : std_logic;
  signal MUXB_SEL_i : std_logic;
  signal ALU_OUTREG_EN_i : std_logic;
  signal DRAM_WE_i : std_logic;
  signal LMD_LATCH_EN_i : std_logic;
  signal PC_LATCH_EN_i : std_logic;
  signal WB_MUX_SEL_i : std_logic;
  signal RF_WE_i : std_logic;
  signal RS1_i : std_logic_vector(4 downto 0);
  signal RS2_i : std_logic_vector(4 downto 0);
  signal RD_i  : std_logic_vector(4 downto 0);
  signal RFR1_EN_i : std_logic;
  signal RFR2_EN_i : std_logic;
  signal RF_EN_i : std_logic;
  signal BYTE_i : std_logic;
  signal MEM_LATCH_EN_i : std_logic;
  signal SEL_MEM_ALU_i : std_logic;
  signal JAL_i : std_logic;
  signal HALF_WORD_i : std_logic;
  signal H_L_i : std_logic;
  signal S_U_i : std_logic;

  -- Added missing handshake / status signals between CU and DataPath
  signal CAN_READ_i : std_logic;
  signal CAN_WRITE_i : std_logic;
  signal START_MUL_i : std_logic;
  signal START_DIV_i : std_logic;
  signal MULTIPLICATION_ENDED_i : std_logic;
  signal DIVISION_ENDED_i : std_logic;
  signal ALU_OUTREG_MUL_DIV_i : std_logic;
  signal ALU_OUTREG_COMB_SEQ_i : std_logic;

  signal IMM_i: std_logic_vector(31 downto 0);
  signal DATA_TO_MEM_sig  : std_logic_vector(31 downto 0);
  signal DATA_FROM_MEM_sig: std_logic_vector(31 downto 0);
  signal PC_TO_IRAM_sig : std_logic_vector(31 downto 0);
  signal FLUSH_sig : std_logic;
  signal MEM_ADDRESS_sig : std_logic_vector(31 downto 0);
  signal DRAM_ADDR_sig : std_logic_vector(15 downto 0);

  begin  -- DLX


    -- Instruction Ram Instantiation
    IRAM_I: IRAM
      port map (
          Rst  => Rst,
          Addr => PC_TO_IRAM_sig,
          Dout => IRam_DOut);

  DRAM_ADDR_sig <= MEM_ADDRESS_sig(15 downto 0);

  DRAM_I: DRAM
    generic map (
      ADDR_WIDTH => 16,  --IMPORTANT: change for synthesis
      DATA_WIDTH => 32
    )
    port map (
      clk     => Clk,
      reset   => Rst,
      BYTE    => BYTE_i,
      we      => DRAM_WE_i,
      addr    => DRAM_ADDR_sig,
      data_in => DATA_TO_MEM_sig,
      data_out=> DATA_FROM_MEM_sig
    );

  DP_I: DataPath
    generic map (
      DATA_WIDTH => 32,
      ADDR_WIDTH => 5 
    )
    port map (
      CLK => Clk,
      RST => Rst,

      -- IF
      IR_LATCH_EN     => IR_LATCH_EN_i,
      PC_LATCH_EN     => PC_LATCH_EN_i,
      PC_TO_IRAM      => PC_TO_IRAM_sig,
      FLUSH           => FLUSH_sig,

      -- DE
      RegA_LATCH_EN   => RegA_LATCH_EN_i,
      RegB_LATCH_EN   => RegB_LATCH_EN_i,
      RegIMM_LATCH_EN => RegIMM_LATCH_EN_i,
      imm_to_be_stored => IMM_i,
      RS1             => RS1_i,
      RS2             => RS2_i,
      RD              => RD_i,
      RFR1_EN         => RFR1_EN_i,
      RFR2_EN         => RFR2_EN_i,
      RF_EN           => RF_EN_i,

      -- EX
      ALU_OUTREG_EN   => ALU_OUTREG_EN_i,
      ALU_OUTREG_MUL_DIV => ALU_OUTREG_MUL_DIV_i,
      ALU_OUTREG_COMB_SEQ => ALU_OUTREG_COMB_SEQ_i,
      MUX_B           => MUXB_SEL_i,
      MUX_A           => MUXA_SEL_i,
      op              => ALU_OPCODE_i,
      MEM_LATCH_EN    => MEM_LATCH_EN_i,
      EQ_COND         => EQ_COND_i,
      CAN_READ        => CAN_READ_i,
      CAN_WRITE       => CAN_WRITE_i,
      START_MUL       => START_MUL_i,
      START_DIV       => START_DIV_i,
      MULTIPLICATION_ENDED => MULTIPLICATION_ENDED_i,
      DIVISION_ENDED  => DIVISION_ENDED_i,

      -- MEM
      BYTE            => BYTE_i,
      JUMP_EN         => JUMP_EN_i,
      JUMP            => JUMP_i,
      LMD_LATCH_EN    => LMD_LATCH_EN_i,
      SEL_MEM_ALU     => SEL_MEM_ALU_i,
      DATA_FROM_MEM   => DATA_FROM_MEM_sig,

      DATA_TO_MEM     => DATA_TO_MEM_sig,
      MEM_ADDRESS     => MEM_ADDRESS_sig,

      -- WB
      RF_WE           => RF_WE_i,
      JAL             => JAL_i,
      HALF_WORD       => HALF_WORD_i,
      H_L             => H_L_i,
      S_U             => S_U_i
    );


  CU_I: dlx_cu
    generic map (
      MICROCODE_MEM_SIZE => 62,
      FUNC_SIZE => 11,
      OP_CODE_SIZE => 6,
      IR_SIZE => 32,
      CW_SIZE => 23
    )
    port map (
      Clk   => Clk,
      Rst   => Rst,
      IR_IN => IRam_DOut,

      -- IF
      IR_LATCH_EN   => IR_LATCH_EN_i,
      PC_LATCH_EN   => PC_LATCH_EN_i,
      FLUSH         => FLUSH_sig, 

      -- DE
      RegA_LATCH_EN => RegA_LATCH_EN_i,
      RegB_LATCH_EN => RegB_LATCH_EN_i,
      RegIMM_LATCH_EN => RegIMM_LATCH_EN_i,
      IM => IMM_i,
      RS1           => RS1_i,
      RS2           => RS2_i,
      RD            => RD_i,
      RFR1_EN       => RFR1_EN_i,
      RFR2_EN       => RFR2_EN_i,
      RF_EN         => RF_EN_i,

      -- EX
      DIVISION_ENDED => DIVISION_ENDED_i,
      MULTIPLICATION_ENDED => MULTIPLICATION_ENDED_i,
      ALU_OUTREG_EN => ALU_OUTREG_EN_i,
      MUX_B         => MUXB_SEL_i,
      MUX_A         => MUXA_SEL_i,
      op            => ALU_OPCODE_i,
      MEM_LATCH_EN  => MEM_LATCH_EN_i,
      EQ_COND       => EQ_COND_i,
      CAN_READ      => CAN_READ_i,
      CAN_WRITE     => CAN_WRITE_i,
      START_MUL     => START_MUL_i,
      START_DIV     => START_DIV_i,
      ALU_OUTREG_MUL_DIV => ALU_OUTREG_MUL_DIV_i,
      ALU_OUTREG_COMB_SEQ => ALU_OUTREG_COMB_SEQ_i,

      -- MEM
      BYTE          => BYTE_i,
      JUMP_EN       => JUMP_EN_i,
      JUMP          => JUMP_i,
      LMD_LATCH_EN  => LMD_LATCH_EN_i,
      SEL_MEM_ALU   => SEL_MEM_ALU_i,

      -- WB
      RF_WE         => RF_WE_i,
      JAL           => JAL_i,
      HALF_WORD     => HALF_WORD_i,
      H_L           => H_L_i,
      S_U           => S_U_i
    );

    
end dlx_rtl;
