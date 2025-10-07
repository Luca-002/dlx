library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
--ghdl -r -fsynopsys tb_dlx --vcd=dlx.vcd
entity tb_dlx is
end entity;

architecture sim of tb_dlx is

  signal Clk : std_logic := '0';
  signal Rst : std_logic := '0';


  constant CLK_PERIOD : time := 10 ns;  
  constant SIM_TIME   : time := 0.05 ms;    

  component DLX
    generic (
      IR_SIZE : integer := 32;
      PC_SIZE : integer := 32
    );
    port (
      Clk : in  std_logic;
      Rst : in  std_logic
    );
  end component;

begin
  clk_proc : process
  begin
    while now < SIM_TIME loop
      Clk <= '0';
      wait for CLK_PERIOD/2;
      Clk <= '1';
      wait for CLK_PERIOD/2;
    end loop;
    wait;
  end process;

  stim_proc : process
  begin
    -- keep DLX in reset for a few cycles 
    Rst <= '1';
    wait for 10 * CLK_PERIOD;
    Rst <= '0'; -- release reset
    report "reset released";
    wait for SIM_TIME - 10*CLK_PERIOD;
    report "simulation completed";
    wait;
  end process stim_proc;

  dlx_inst : DLX
    generic map (
      IR_SIZE => 32,
      PC_SIZE => 32
    )
    port map (
      Clk => Clk,
      Rst => Rst
    );

end architecture sim;
