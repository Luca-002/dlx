
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.myTypes.all;

entity TB_DataPath is
end TB_DataPath;

architecture TEST of TB_DataPath is

    -- Component under test
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
    signal CLK, RST         : std_logic := '0';
    signal IR_LATCH_EN      : std_logic := '0';
    signal INSTRUCTION      : std_logic_vector(31 downto 0) := (others => '0');
    signal PC_LATCH_EN      : std_logic := '0';
    signal PC_TO_IRAM       : std_logic_vector(31 downto 0);

    signal I_J              : std_logic := '0';
    signal RegA_LATCH_EN    : std_logic := '0';
    signal RegB_LATCH_EN    : std_logic := '0';
    signal RegIMM_LATCH_EN  : std_logic := '0';
    signal RS1, RS2, RD     : std_logic_vector(4 downto 0) := (others => '0');
    signal RFR1_EN, RFR2_EN : std_logic := '0';
    signal RF_EN            : std_logic := '0';

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

    -- Clock generator
    constant CLK_PERIOD : time := 10 ns;
    signal stop_clk : boolean := false;

begin

    -- Instantiate DUT
    uut: DataPath
        port map(
            CLK           => CLK,
            RST           => RST,
            IR_LATCH_EN   => IR_LATCH_EN,
            INSTRUCTION   => INSTRUCTION,
            PC_LATCH_EN   => PC_LATCH_EN,
            PC_TO_IRAM    => PC_TO_IRAM,
            I_J           => I_J,
            RegA_LATCH_EN => RegA_LATCH_EN,
            RegB_LATCH_EN => RegB_LATCH_EN,
            RegIMM_LATCH_EN => RegIMM_LATCH_EN,
            RS1           => RS1,
            RS2           => RS2,
            RD            => RD,
            RFR1_EN       => RFR1_EN,
            RFR2_EN       => RFR2_EN,
            RF_EN         => RF_EN,
            ALU_OUTREG_EN => ALU_OUTREG_EN,
            MUX_B         => MUX_B,
            MUX_A         => MUX_A,
            op            => OP_CODE,
            MEM_LATCH_EN  => MEM_LATCH_EN,
            EQ_COND       => EQ_COND,
            JUMP_EN       => JUMP_EN,
            JUMP          => JUMP,
            LMD_LATCH_EN  => LMD_LATCH_EN,
            SEL_MEM_ALU   => SEL_MEM_ALU,
            DATA_FROM_MEM => DATA_FROM_MEM,
            DATA_TO_MEM   => DATA_TO_MEM,
            MEM_ADDRESS   => MEM_ADDRESS,
            RF_WE         => RF_WE
        );

    -- Clock process
    clk_process : process
    begin
        while not stop_clk loop
            CLK <= '0';
            wait for CLK_PERIOD/2;
            CLK <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Stimulus
    stim_proc : process
        variable pc_before, pc_after : std_logic_vector(31 downto 0);
    begin
        -- Reset
        RST <= '1';
        wait for 2*CLK_PERIOD;
        RST <= '0';
        wait for 2*CLK_PERIOD;

        -- Phase 1: Normal fetch (no branch)
        IR_LATCH_EN <= '1';
        PC_LATCH_EN <= '1';
        INSTRUCTION <= x"00000001";  -- dummy
        wait for CLK_PERIOD;
        IR_LATCH_EN <= '0';
        PC_LATCH_EN <= '0';
        pc_before := PC_TO_IRAM;

        -- Phase 2: Simulate a branch/jump -> BTB learns target
        JUMP_EN <= '1';
        JUMP    <= '1';
        wait for CLK_PERIOD;
        JUMP_EN <= '0';
        JUMP    <= '0';
        pc_after := PC_TO_IRAM;

        assert pc_after /= pc_before
            report "BTB training failed: PC did not change on branch" severity error;

        -- Phase 3: Fetch again from same PC, expect BTB HIT
        wait for 3*CLK_PERIOD;  -- allow pipeline delay
        pc_before := PC_TO_IRAM;
        wait for CLK_PERIOD;
        pc_after := PC_TO_IRAM;

        assert pc_after = pc_before
            report "BTB failed: Did not redirect to stored target" severity error;

        -- Done
        wait for 50 ns;
        stop_clk <= true;
        wait;
    end process;

end TEST;

configuration DATAPATHTEST of TB_DataPath is
    for TEST
        for all: DataPath
            use entity work.DataPath(struct);
        end for;
    end for;
end DATAPATHTEST;

