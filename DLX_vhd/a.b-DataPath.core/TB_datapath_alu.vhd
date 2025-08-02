
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.myTypes.all;

entity TB_alu is
end TB_alu;

architecture TEST of TB_alu is

    -- Component declaration
    component alu is
        generic (
            DATA_WIDTH: integer := 32
        );
        port (
            INP1             : in std_logic_vector(DATA_WIDTH-1 downto 0);
            INP2             : in std_logic_vector(DATA_WIDTH-1 downto 0);
            op               : in aluOp;
            DATA_OUT         : out std_logic_vector(DATA_WIDTH-1 downto 0);
            A_gt_or_eq_B     : out std_logic;
            A_gt_B           : out std_logic;
            A_lt_or_eq_B     : out std_logic;
            A_lt_B           : out std_logic;
            A_eq_B           : out std_logic
        );
    end component;

    -- Testbench signals
    signal INP1, INP2       : std_logic_vector(31 downto 0);
    signal OP_CODE          : aluOp;
    signal DATA_OUT         : std_logic_vector(31 downto 0);
    signal A_gt_or_eq_B     : std_logic;
    signal A_gt_B           : std_logic;
    signal A_lt_or_eq_B     : std_logic;
    signal A_lt_B           : std_logic;
    signal A_eq_B           : std_logic;

begin

    -- Instantiate ALU
    uut: alu
        port map(
            INP1         => INP1,
            INP2         => INP2,
            op           => OP_CODE,
            DATA_OUT     => DATA_OUT,
            A_gt_or_eq_B => A_gt_or_eq_B,
            A_gt_B       => A_gt_B,
            A_lt_or_eq_B => A_lt_or_eq_B,
            A_lt_B       => A_lt_B,
            A_eq_B       => A_eq_B
        );

    -- Stimulus
    process
    begin
        -- Test 1: ALU_ADD
        INP1 <= x"00000010";
        INP2 <= x"00000020";
        OP_CODE <= ALU_ADD;
        wait for 1 ns;
        assert DATA_OUT = x"00000030" report "Test 1 failed: ALU_ADD" severity error;
        assert A_lt_B = '1' report "Test 1 failed: Comparator A_lt_B" severity error;

        -- Test 2: ALU_SUB
        INP1 <= x"00000030";
        INP2 <= x"00000010";
        OP_CODE <= ALU_SUB;
        wait for 1 ns;
        assert DATA_OUT = x"00000020" report "Test 2 failed: ALU_SUB" severity error;
        assert A_gt_B = '1' report "Test 2 failed: Comparator A_gt_B" severity error;

        -- Test 3: ALU_AND
        INP1 <= x"F0F0F0F0";
        INP2 <= x"0F0F0F0F";
        OP_CODE <= ALU_AND;
        wait for 1 ns;
        assert DATA_OUT = x"00000000" report "Test 3 failed: ALU_AND" severity error;

        -- Test 4: ALU_OR
        OP_CODE <= ALU_OR;
        wait for 1 ns;
        assert DATA_OUT = x"FFFFFFFF" report "Test 4 failed: ALU_OR" severity error;

        -- Test 5: ALU_XOR
        OP_CODE <= ALU_XOR;
        wait for 1 ns;
        assert DATA_OUT = x"FFFFFFFF" report "Test 5 failed: ALU_XOR" severity error;

        -- Test 6: MULT
        INP1 <= x"00000005";
        INP2 <= x"00000003";
        OP_CODE <= MULT;
        wait for 1 ns;
        assert DATA_OUT = x"0000000F" report "Test 6 failed: MULT" severity error;

        -- Test 7: Shift Left Logical (LLS)
        INP1 <= x"00000001";
        INP2 <= x"00000002";  -- shift amount = 2
        OP_CODE <= LLS;
        wait for 1 ns;
        assert DATA_OUT = x"00000004" report "Test 7 failed: LLS" severity error;

        -- Test 8: Shift Right Logical (LRS)
        OP_CODE <= LRS;
        wait for 1 ns;
        assert DATA_OUT = x"00000000" report "Test 8 failed: LRS" severity error;

        -- Test 9: A_eq_B
        INP1 <= x"12345678";
        INP2 <= x"12345678";
        OP_CODE <= ALU_ADD;  -- ALU_ADD just to trigger comparator
        wait for 1 ns;
        assert A_eq_B = '1' report "Test 9 failed: A_eq_B not set" severity error;

        wait;
    end process;

end TEST;

configuration ALUTEST of TB_alu is
    for TEST
        for all: alu
            use entity work.alu(struct);
        end for;
    end for;
end ALUTEST;
