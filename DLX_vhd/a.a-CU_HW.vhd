library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.myTypes.all;
--use work.all;
entity dlx_cu is
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
    RS1 					     : out std_logic_vector(4 downto 0);	
    RS2 					     : out std_logic_vector(4 downto 0);	
    RD 						     : out std_logic_vector(4 downto 0);   
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
    S_U 			    : out std_logic  --signed or unsigned write back
    );  

end dlx_cu;

architecture dlx_cu_hw of dlx_cu is
  type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
  signal cw_mem : mem_array := ("11110111111000001010000", -- R type
                                "00000000000000000000000",
                                "11001000000001100000000", -- J 
                                "11001000000001100011000", -- JAL 
                                "11101101000011000000000", -- BEQZ 
                                "11101101000001000000000", -- BNEZ
                                "00000000000000000000000", -- 
                                "00000000000000000000000",
                                "11101101101000001010000", -- ADD i (0X08): FILL IT!!!
                                "11101101101000001010000", -- ADDUI
                                "11101101101000001010000", -- SUBI
                                "11101101101000001010000", -- SUBUI
                                "11101101101000001010000", -- ANDI
                                "11101101101000001010000", -- ORI
                                "11101101101000001010000", -- XORI
                                "11001000100000001010110", -- LHI
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "11100101001001000000000", --JR
                                "11100101001001000001000", --JALR
                                "11101101101000001010000", --SLLI
                                "11000000000000000000000", --NOP
                                "11101101101000001010000", --SRLI
                                "11101101101000001010000", --SRAI
                                "11101101101000001010000", --SEQI
                                "11101101101000001010000", --SNEI
                                "11101101101000001010000", --slti
                                "11101101101000001010000", --sgti
                                "11101101101000001010000", --slei
                                "11101101101000001010000", --sgei
                                "00000000000000000000000", 
                                "00000000000000000000000",
                                "11101101101000011110001", --lb
                                "00000000000000000000000",
                                "11101101101000001110000", --LW
                                "11101101101000011110000", --LBU
                                "11101101101000001110100", --LHU
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "11111111101100010000000", --SB
                                "00000000000000000000000",
                                "11111111101100000000000", --SW
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "00000000000000000000000",
                                "11101101101000001010000", --SLTUI
                                "11101101101000001010000", --SGTUI
                                "00000000000000000000000",
                                "11101101101000001010000"  --SGEUI         
                                );
                                
                                
  signal IR_opcode, IR_opcode1 : std_logic_vector(OP_CODE_SIZE -1 downto 0);  -- OpCode part of IR
  signal IR_func : std_logic_vector(FUNC_SIZE-1 downto 0);   -- Func part of IR when Rtype
  signal cw   : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_mem


  -- control word is shifted to the correct stage
  signal cw1 : std_logic_vector(CW_SIZE -1 downto 0); -- first stage
  signal cw2 : std_logic_vector(CW_SIZE - 1 - 2 downto 0); -- second stage
  signal cw3 : std_logic_vector(CW_SIZE - 1 - 5 downto 0); -- third stage
  signal cw4 : std_logic_vector(CW_SIZE - 1 - 9 downto 0); -- fourth stage
  signal cw5 : std_logic_vector(CW_SIZE -1 - 13 downto 0); -- fifth stage
  signal restore_cw : std_logic;

  signal aluOpcode_i: aluOp := NOP; -- ALUOP defined in package
  signal aluOpcode1: aluOp := NOP;
  signal aluOpcode2: aluOp := NOP;
  signal aluOpcode3: aluOp := NOP;
  signal cw1_backup : std_logic_vector(CW_SIZE -1 downto 0); -- first stage
  signal cw2_backup : std_logic_vector(CW_SIZE - 1  downto 0); -- second stage
  signal cw3_backup : std_logic_vector(CW_SIZE - 1 - 2 downto 0); -- third stage

  signal IR_i,IR1: STD_LOGIC_VECTOR(31 downto 0);

 
begin  -- dlx_cu_rtl

  IR_opcode(5 downto 0) <= IR_IN(31 downto 26);
  IR_opcode1(5 downto 0) <= IR1(31 downto 26);
  IR_func(FUNC_SIZE-1 downto 0)  <= IR_IN(FUNC_SIZE - 1 downto 0);

  cw <= cw_mem(to_integer(unsigned(IR_opcode)));

  IR_LATCH_EN   <=cw1(CW_SIZE - 1);
  PC_LATCH_EN   <=cw1(CW_SIZE - 2);
  --DE 
  RegA_LATCH_EN <=cw2(CW_SIZE - 3);
  RegB_LATCH_EN <=cw2(CW_SIZE - 4);
  RegIMM_LATCH_EN<=cw2(CW_SIZE - 5);
  RFR1_EN       <=cw2(CW_SIZE - 6);
  RFR2_EN       <=cw2(CW_SIZE - 7);
  RF_EN         <=cw2(CW_SIZE - 8);
  --EX 
 
  ALU_OUTREG_EN <=cw3(CW_SIZE - 9);
  MUX_B         <=cw3(CW_SIZE - 10);
  MUX_A         <=cw3(CW_SIZE - 11);
  MEM_LATCH_EN  <=cw3(CW_SIZE - 12);
  EQ_COND       <=cw3(CW_SIZE - 13);
  JUMP_EN       <=cw3(CW_SIZE - 14);
  JUMP          <=cw3(CW_SIZE - 15);
  --MEM 
  BYTE          <=cw4(CW_SIZE - 16);
  LMD_LATCH_EN  <=cw4(CW_SIZE - 17);
  SEL_MEM_ALU   <=cw4(CW_SIZE - 18);
  --WB 
  RF_WE         <=cw5(CW_SIZE - 19);
  JAL           <=cw5(CW_SIZE - 20);
  HALF_WORD     <=cw5(CW_SIZE - 21);
  H_L           <=cw5(CW_SIZE - 22);
  S_U 			    <=cw5(CW_SIZE - 23);
  cw1<=cw;
  -- process to pipeline control words
  CW_PIPE: process (Clk, Rst)
  begin  -- process Clk
    if Rst = '1' then                  
      --cw1 <= (others => '0');
      cw2 <= (others => '0');
      cw3 <= (others => '0');
      cw4 <= (others => '0');
      cw5 <= (others => '0');
      aluOpcode1 <= NOP;
      aluOpcode2 <= NOP;
      aluOpcode3 <= NOP; 
      IR1 <= (others => '0');
      START_DIV <= '0';
      START_MUL <= '0';
      restore_cw <='0';
      ALU_OUTREG_COMB_SEQ <='0';
      ALU_OUTREG_MUL_DIV <= '0';
      cw1_backup<= (others =>'0');
      cw2_backup<= (others =>'0');
      cw3_backup<= (others =>'0');
    elsif Clk'event and Clk = '1' then  -- rising clock

      if FLUSH='1' then
        --cw1 <= "11"&(CW_SIZE -3  downto 0 => '0');
        cw2 <= (others => '0');
        cw3 <= (others => '0');
        aluOpcode1 <= NOP;
        aluOpcode2 <= NOP;
        aluOpcode3 <= NOP;
        IR1 <= (others => '0');

      elsif DIVISION_ENDED = '1' then 
        restore_cw <= '1';
        cw4 <= cw3(CW_SIZE - 1 - 9 downto 0); 
        cw5 <= cw4(CW_SIZE -1 - 13 downto 0);
        cw1_backup <= cw;
        cw2_backup <= cw1; 
        cw3_backup <= cw2;
        cw2 <= (others => '0'); --TODO fai gli stalli col flag (stall)
        cw3 <= (others => '0');
        ALU_OUTREG_MUL_DIV<='1';
        ALU_OUTREG_COMB_SEQ<='1';

      elsif MULTIPLICATION_ENDED = '1' then
        restore_cw <= '1'; 
        cw4 <= cw3(CW_SIZE - 1 - 9 downto 0); 
        cw5 <= cw4(CW_SIZE -1 - 13 downto 0);
        cw1_backup <= cw;
        cw2_backup <= cw1; 
        cw3_backup <= cw2;
        cw2 <= (others => '0');
        cw3 <= (others => '0');
        ALU_OUTREG_MUL_DIV<='0';
        ALU_OUTREG_COMB_SEQ<='1';

      elsif (CAN_READ = '0') or (CAN_WRITE = '0') then
        restore_cw <= '1'; 
        cw4 <= cw3(CW_SIZE - 1 - 9 downto 0); 
        cw5 <= cw4(CW_SIZE -1 - 13 downto 0);
        cw1_backup <= cw;
        cw2_backup <= cw1; 
        cw3_backup <= cw2;
        cw2 <= (others => '0');
        cw3 <= (others => '0');

      elsif restore_cw = '1' then 
        restore_cw <= '0'; 
        cw2 <= cw2_backup(CW_SIZE - 1 - 2 downto 0);
        cw3 <= cw3_backup(CW_SIZE - 1 - 5 downto 0);
        cw4 <= cw3(CW_SIZE - 1 - 9 downto 0); 
        cw5 <= cw4(CW_SIZE -1 - 13 downto 0);
      else 
        cw2 <= cw1(CW_SIZE - 1 - 2 downto 0);
        cw3 <= cw2(CW_SIZE - 1 - 5 downto 0);
        cw4 <= cw3(CW_SIZE - 1 - 9 downto 0); 
        cw5 <= cw4(CW_SIZE -1 - 13 downto 0);
        aluOpcode1 <= aluOpcode_i;
        aluOpcode2 <= aluOpcode1;
        aluOpcode3 <= aluOpcode2;
        if aluOpcode2 = DIV then 
          START_DIV <= '1';
        end if;
        if aluOpcode2 = MULT then 
          START_MUL <= '1';
        end if;
        IR1<=IR_i;
      end if;

    end if;
  end process CW_PIPE;

  op <= aluOpcode2;

  -- purpose: Generation of ALU OpCode
  -- type   : combinational
  -- inputs : IR_i
  -- outputs: aluOpcode
   ALU_OP_CODE_P : process (IR_opcode, IR_func)
   begin  -- process ALU_OP_CODE_P
	case to_integer(unsigned(IR_opcode)) is
	        -- case of R type requires analysis of FUNC
		when 0 =>
			case to_integer(unsigned(IR_func)) is
				when 4 => aluOpcode_i <= LLS; -- sll according to instruction set coding
				when 6 => aluOpcode_i <= LRS; -- srl
        when 7 => aluOpcode_i <= ARS; -- sra
        when 32 => aluOpcode_i <= ALU_ADD; -- add
        when 33 => aluOpcode_i <= ALU_ADD; -- addu
        when 34 => aluOpcode_i <= ALU_SUB; -- sub
        when 35 => aluOpcode_i <= ALU_SUB; -- subu
        when 36 => aluOpcode_i <= ALU_AND; -- and
        when 37 => aluOpcode_i <= ALU_OR; -- or
        when 38 => aluOpcode_i <= ALU_XOR; -- xor
        when 40 => aluOpcode_i <= SEQ; -- seq
        when 41 => aluOpcode_i <= SNE; -- sne
        when 42 => aluOpcode_i <= SLT; -- slt
        when 43 => aluOpcode_i <= SGT; -- sgt
        when 44 => aluOpcode_i <= SLE; -- sle
        when 45 => aluOpcode_i <= SGE; -- sge
        when 58 => aluOpcode_i <= SLTU; -- sltu
        when 59 => aluOpcode_i <= SGTU; -- sgtu
        when 60 => aluOpcode_i <= SLEU; -- sleu
        when 61 => aluOpcode_i <= SGEU; -- sgeu
        when 14 => aluOpcode_i <= MULT; -- mult
        when 15 => aluOpcode_i <= DIV; -- div
				when others => aluOpcode_i <= NOP;
			end case;
		when 2 => aluOpcode_i <= ALU_ADD; -- j
		when 3 => aluOpcode_i <= ALU_ADD; -- jal
    when 4 => aluOpcode_i <= ALU_ADD; -- BEQZ 
    when 5 => aluOpcode_i <= ALU_ADD; -- BNEZ
    when 8 => aluOpcode_i <= ALU_ADD;-- ADD i 
    when 9 => aluOpcode_i <= ALU_ADD;-- ADDUI
    when 10 => aluOpcode_i <= ALU_SUB;-- SUBI
    when 11 => aluOpcode_i <= ALU_SUB;-- SUBUI
    when 12 => aluOpcode_i <= ALU_AND;-- ANDI
    when 13 => aluOpcode_i <= ALU_OR;-- ORI
    when 14 => aluOpcode_i <= ALU_XOR;-- XORI
    when 15 => aluOpcode_i <= B;-- LHI
    when 18 => aluOpcode_i <= A;--JR
    when 19 => aluOpcode_i <= A;--JALR
    when 20 => aluOpcode_i <= LLS;--SLLI
    when 21 => aluOpcode_i <= NOP;--NOP
    when 22 => aluOpcode_i <= LRS;--SRLI
    when 23 => aluOpcode_i <= ARS;--SRAI
    when 24 => aluOpcode_i <= SEQ;--SEQI
    when 25 => aluOpcode_i <= SNE;--SNEI
    when 26 => aluOpcode_i <= SLT;--slti
    when 27 => aluOpcode_i <= SGT;--sgti
    when 28 => aluOpcode_i <= SLE;--slei
    when 29 => aluOpcode_i <= SGE;--sgei
    when 32 => aluOpcode_i <= ALU_ADD;--lb
    when 35 => aluOpcode_i <= ALU_ADD;--LW
    when 36 => aluOpcode_i <= ALU_ADD;--LBU
    when 37 => aluOpcode_i <= ALU_ADD;--LHU
    when 40 => aluOpcode_i <= ALU_ADD;--SB
    when 43 => aluOpcode_i <= ALU_ADD;--SW
    when 58 => aluOpcode_i <= SLTU;--SLTUI
    when 59 => aluOpcode_i <= SGTU;--SGTUI
    when 61 => aluOpcode_i <= SGEU;--SGEUI
		when others => aluOpcode_i <= NOP;
	 end case;
	end process ALU_OP_CODE_P;
  IR_i<=IR_IN;
  RS1<=IR1(25 downto 21);
  ASSIGN_RS2_RD_AND_IM : process (IR_opcode1)
   begin  
	case to_integer(unsigned(IR_opcode1)) is
    when 0 => RS2<=IR1(20 downto 16);
      RD <=IR1(15 downto 11);
    when others => RD <=IR1(20 downto 16);
    end case;
  case to_integer(unsigned(IR_opcode)) is
    when 2 | 3 => IM <=(32-26-1 downto 0 =>IR1(25))&IR1(25 downto 0);
    when 12 | 13 | 14 |20 | 22 | 23 | 15 => IM <= (32-16-1 downto 0 =>'0')&IR1(15 downto 0);
    when others => IM <= (32-16-1 downto 0 =>IR1(15))&IR1(15 downto 0);
    end case;
  end process;

end dlx_cu_hw;
