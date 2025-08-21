
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.myTypes.all;

entity TB_DataPath is
end TB_DataPath;

architecture TEST of TB_DataPath is

    -- Component declaration
    component DataPath is
        generic(
            DATA_WIDTH: integer := 32;
            ADDR_WIDTH: integer := 5
        );
        port(
            CLK              : in std_logic;
            RST              : in std_logic;
            -- IF
            IR_LATCH_EN      : in std_logic;
            INSTRUCTION      : in std_logic_vector(DATA_WIDTH-1 downto 0);
            PC_LATCH_EN      : in std_logic;
            PC_TO_IRAM       : out std_logic_vector(DATA_WIDTH-1 downto 0);
            -- DE
            I_J              : in std_logic;
            RegA_LATCH_EN    : in std_logic;
            RegB_LATCH_EN    : in std_logic;
            RegIMM_LATCH_EN  : in std_logic;
            RS1              : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            RS2              : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            RD               : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            RFR1_EN          : in std_logic;
            RFR2_EN          : in std_logic;
            RF_EN            : in std_logic;
            -- EX
            ALU_OUTREG_EN    : in std_logic;
            MUX_B            : in std_logic;
            MUX_A            : in std_logic;
            op               : in aluOp;
            MEM_LATCH_EN     : in std_logic;
            EQ_COND          : in std_logic;
            -- MEM
            JUMP_EN          : in std_logic;
            JUMP             : in std_logic;
            LMD_LATCH_EN     : in std_logic;
            SEL_MEM_ALU      : in std_logic;
            DATA_FROM_MEM    : in std_logic_vector(DATA_WIDTH-1 downto 0);

            DATA_TO_MEM      : out std_logic_vector(DATA_WIDTH-1 downto 0);
            MEM_ADDRESS      : out std_logic_vector((ADDR_WIDTH**2)-1 downto 0);
            -- WB
            RF_WE            : in std_logic
        );
    end component;

    -- Signals
    signal CLK              : std_logic := '0';
    signal RST              : std_logic := '0';
    signal IR_LATCH_EN      : std_logic := '0';
    signal INSTRUCTION      : std_logic_vector(31 downto 0) := (others => '0');
    signal PC_LATCH_EN      : std_logic := '0';
    signal PC_TO_IRAM       : std_logic_vector(31 downto 0);

    signal I_J              : std_logic := '0';
    signal RegA_LATCH_EN    : std_logic := '0';
    signal RegB_LATCH_EN    : std_logic := '0';
    signal RegIMM_LATCH_EN  : std_logic := '0';
    signal RS1, RS2, RD     : std_logic_vector(4 downto 0) := (others => '0');
    signal RFR1_EN, RFR2_EN, RF_EN : std_logic := '0';

    signal ALU_OUTREG_EN    : std_logic := '0';
    signal MUX_B, MUX_A     : std_logic := '0';
    signal OP_CODE          : aluOp := ALU_ADD;
    signal MEM_LATCH_EN     : std_logic := '0';
    signal EQ_COND          : std_logic := '0';

    signal JUMP_EN, JUMP    : std_logic := '0';
    signal LMD_LATCH_EN     : std_logic := '0';
    signal SEL_MEM_ALU      : std_logic := '0';
    signal DATA_FROM_MEM    : std_logic_vector(31 downto 0) := (others => '0');

    signal DATA_TO_MEM      : std_logic_vector(31 downto 0);
    signal MEM_ADDRESS      : std_logic_vector((5**2)-1 downto 0);
    signal RF_WE            : std_logic := '0';

    -- Clock generation
    constant CLK_PERIOD : time := 10 ns;
    signal stop_sim : boolean := false;

begin
    -- Clock process
    clk_process : process
    begin
        while not stop_sim loop
            CLK <= '0'; wait for CLK_PERIOD/2;
            CLK <= '1'; wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- DUT instantiation
    uut: DataPath
        port map(
            CLK => CLK,
            RST => RST,
            IR_LATCH_EN => IR_LATCH_EN,
            INSTRUCTION => INSTRUCTION,
            PC_LATCH_EN => PC_LATCH_EN,
            PC_TO_IRAM => PC_TO_IRAM,
            I_J => I_J,
            RegA_LATCH_EN => RegA_LATCH_EN,
            RegB_LATCH_EN => RegB_LATCH_EN,
            RegIMM_LATCH_EN => RegIMM_LATCH_EN,
            RS1 => RS1,
            RS2 => RS2,
            RD => RD,
            RFR1_EN => RFR1_EN,
            RFR2_EN => RFR2_EN,
            RF_EN => RF_EN,
            ALU_OUTREG_EN => ALU_OUTREG_EN,
            MUX_B => MUX_B,
            MUX_A => MUX_A,
            op => OP_CODE,
            MEM_LATCH_EN => MEM_LATCH_EN,
            EQ_COND => EQ_COND,
            JUMP_EN => JUMP_EN,
            JUMP => JUMP,
            LMD_LATCH_EN => LMD_LATCH_EN,
            SEL_MEM_ALU => SEL_MEM_ALU,
            DATA_FROM_MEM => DATA_FROM_MEM,
            DATA_TO_MEM => DATA_TO_MEM,
            MEM_ADDRESS => MEM_ADDRESS,
            RF_WE => RF_WE
        );

    -- Stimulus process
    stim_proc : process
    begin
        -- Reset
        RST <= '1';
        wait for 20 ns;
        RST <= '0';
        wait for 20 ns;

        -- Test 1: Instruction fetch (PC increment)
        IR_LATCH_EN <= '1';
        PC_LATCH_EN <= '1';
        INSTRUCTION <= x"00000010"; -- dummy instruction
        wait for CLK_PERIOD;
        IR_LATCH_EN <= '0';
        PC_LATCH_EN <= '0';
        wait for CLK_PERIOD;
        assert PC_TO_IRAM = x"00000000" report "PC not initialized to 0" severity warning;

        -- Test 2: ALU operation (ADD)
        RF_EN <= '1'; RFR1_EN <= '1'; RFR2_EN <= '1'; RF_WE <= '1';
        RS1 <= "00001"; RS2 <= "00010"; RD <= "00011";
        RegA_LATCH_EN <= '1'; RegB_LATCH_EN <= '1';
        MUX_A <= '0'; MUX_B <= '0';
        OP_CODE <= ALU_ADD;
        ALU_OUTREG_EN <= '1';
        wait for CLK_PERIOD;
        RegA_LATCH_EN <= '0'; RegB_LATCH_EN <= '0'; ALU_OUTREG_EN <= '0';

        -- TODO: Add asserts once register file contents are preloaded

        -- Test 3: Memory interface
        MEM_LATCH_EN <= '1';
        DATA_FROM_MEM <= x"11111111";
        LMD_LATCH_EN <= '1';
        SEL_MEM_ALU <= '0';
        wait for CLK_PERIOD;
        MEM_LATCH_EN <= '0'; LMD_LATCH_EN <= '0';

        -- Stop simulation
        stop_sim <= true;
        wait;
    end process;

end TEST;

configuration DATAPATH_TEST of TB_DataPath is
    for TEST
        for all: DataPath
            use entity work.DataPath(struct);
        end for;
    end for;
end DATAPATH_TEST;
