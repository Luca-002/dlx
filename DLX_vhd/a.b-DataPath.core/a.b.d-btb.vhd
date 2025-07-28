library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BTB is
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
end entity BTB;

architecture rtl of BTB is
  type pc_matrix  is array (0 to (BITS_INDEX**2)-1) of std_logic_vector(BITS_PC-1 downto 0);

  signal start   : pc_matrix;
  signal target   : pc_matrix;
  signal valid,taken : std_logic_vector((BITS_INDEX**2)-1 downto 0);


  signal cur_index,branch_index: std_logic_vector(BITS_INDEX-1 downto 0);
  signal mem_pc: std_logic_vector(BITS_PC-1 downto 0);
begin
  process(pc, start, target, valid,taken)

  begin
    cur_index<=pc(BITS_INDEX+1 downto 2);
    mem_pc<=target(to_integer(unsigned(cur_index)));
    if (valid(to_integer(unsigned(cur_index))) = '1' and pc = mem_pc and taken(to_integer(unsigned(cur_index)))='1') then
      hit   <= '1';
      target_pc <= mem_pc;
    else
      hit   <= '0';
      target_pc <= (others => '0');
    end if;
  end process;

  update_proc: process(clk)
  begin
    branch_index<=pc_branch(BITS_INDEX+1 downto 2);
    if rising_edge(clk) then
      if reset = '1' then
        for i in 0 to (BITS_PC**2)-1 loop
          taken(i)<='0';
          valid(i) <= '0';
          target(i)<=(others => '0');
          start(i)<=(others => '0');
        end loop;
      else
        if (update = '1' ) then
            start(to_integer(unsigned(cur_index)))<=pc_branch;
            target(to_integer(unsigned(cur_index)))<=target_branch;
            valid(to_integer(unsigned(cur_index)))<='1';
            taken(to_integer(unsigned(cur_index)))<=branch_taken;
        end if;
      end if;
    end if;
  end process;

end architecture rtl;