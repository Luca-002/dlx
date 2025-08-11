library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_BTB is
end entity tb_BTB;

architecture sim of tb_BTB is
  constant BITS_PC    : integer := 32;
  constant BITS_INDEX : integer := 6;
  constant N_ENTRIES  : integer := 2**BITS_INDEX;

  signal clk    : std_logic := '0';
  signal reset  : std_logic := '1'; 

  signal pc            : std_logic_vector(BITS_PC-1 downto 0) := (others => '0');
  signal pc_branch     : std_logic_vector(BITS_PC-1 downto 0) := (others => '0');
  signal branch_taken  : std_logic := '0';
  signal target_branch : std_logic_vector(BITS_PC-1 downto 0) := (others => '0');
  signal update        : std_logic := '0';
  signal hit           : std_logic;
  signal target_pc     : std_logic_vector(BITS_PC-1 downto 0);

  constant CLK_PERIOD : time := 10 ns;

begin
  DUT: entity work.BTB
    generic map(
      BITS_PC    => BITS_PC,
      BITS_INDEX => BITS_INDEX
    )
    port map(
      clk           => clk,
      reset         => reset,
      pc            => pc,
      pc_branch     => pc_branch,
      branch_taken  => branch_taken,
      target_branch => target_branch,
      update        => update,
      hit           => hit,
      target_pc     => target_pc
    );

  clk_process: process
  begin
    while true loop
      clk <= '0';
      wait for CLK_PERIOD/2;
      clk <= '1';
      wait for CLK_PERIOD/2;
    end loop;
  end process;


  stim_proc: process
  begin
    reset <= '1';
    wait for 2 * CLK_PERIOD;
    reset <= '0';
    wait for CLK_PERIOD;

    -- Initial lookup before any update: should miss
    pc           <= x"00000010"; 
    update       <= '0';
    branch_taken <= '0';
    target_branch<= (others => '0');
    wait for CLK_PERIOD;
    assert hit = '0'
      report "Miss on fresh BTB must be '0'" severity error;

    -- Perform an update
    pc_branch     <= x"00000010";
    target_branch <= x"00000064"; 
    branch_taken  <= '1';
    update        <= '1';
    wait for CLK_PERIOD;
    update        <= '0';
    wait for CLK_PERIOD;

    -- Lookup same PC: should hit and return target
    pc <= x"00000010";
    wait for CLK_PERIOD;
    assert hit = '1'
      report "Hit expected after update" severity error;
    assert target_pc = x"00000064"
      report "Target PC mismatch" severity error;

    -- Lookup different PC: should miss
    pc <= x"00000100";
    wait for CLK_PERIOD;
    assert hit = '0'
      report "Miss expected for unseen PC" severity error;

    -- Update second entry: branch_taken = '0'
    pc_branch     <= x"00000100";
    target_branch <= x"000000C8"; 
    branch_taken  <= '0';
    update        <= '1';
    wait for CLK_PERIOD;
    update        <= '0';
    wait for CLK_PERIOD;

    -- Lookup PC=256: valid but taken='0', so miss
    pc <= x"00000100";
    wait for CLK_PERIOD;
    assert hit = '0'
      report "Miss expected when taken flag is '0'" severity error;
    report "BTB testbench completed" severity note;
    wait;
  end process;

end architecture sim;
