library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_send_testbench is
end can_send_testbench;

architecture behavior of can_send_testbench is 

  -- Inputs
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  
  signal tx    : std_logic := '0';
  signal tx_en : std_logic := '0';
  signal rx    : std_logic := '0';

  -- Logic components
  constant clk_period : time := 10 ns;
  begin

  -- Component instantiation
  uut: entity work.can_send port map(
    clk => clk ,
    rst => rst,
    phy_tx => tx,
    phy_tx_en => tx_en ,
    phy_rx => rx
  );

  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;  --for 0.5 ns signal is '0'.
    clk <= '1';
    wait for clk_period/2;  --for next 0.5 ns signal is '1'.
  end process;
   
  -- Test bench statements
  tb : process
  begin
    wait for 100 ns; -- wait until global set/reset completes
    -- add user defined stimulus here
    rst <= '1';
    wait until falling_edge(clk);
    wait until rising_edge(clk);
    rst <= '0';

    wait;
    --wait; -- will wait forever
  end process tb;
   --  end test bench 
end;
