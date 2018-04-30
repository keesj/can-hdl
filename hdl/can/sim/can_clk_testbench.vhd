library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_clk_testbench is
end can_clk_testbench;

architecture behavior of can_clk_testbench is 

  signal quanta_clk_count : std_logic_vector(31 downto 0) := (1=>'0' , others =>'0');
  -- Inputs
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal can_rx_clk_sync: std_logic := '0';
  
   -- Outputs
  signal can_sample_set_clk: std_logic := '0';
  signal can_sample_check_clk: std_logic := '0';
  signal can_sample_get_clk: std_logic := '0';
  signal can_config_clk_sync_en: std_logic := '1';
  signal test_running :  std_logic := '1';

  
   -- Logic components
  constant clk_period : time := 10 ns;
  begin

  -- Component instantiation
  uut: entity work.can_clk port map(
    clk => clk ,
    rst => rst,
    quanta_clk_count => quanta_clk_count,
    can_rx_clk_sync => can_rx_clk_sync ,
    can_config_clk_sync_en => can_config_clk_sync_en,
    can_sample_set_clk => can_sample_set_clk ,
    can_sample_check_clk => can_sample_check_clk ,
    can_sample_get_clk => can_sample_get_clk 
  );

  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;  --for 0.5 ns signal is '0'.
    clk <= '1';
    wait for clk_period/2;  --for next 0.5 ns signal is '1'.
    if test_running = '0' then
      wait;
    end if;
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
    wait for 10 ms;
    test_running <= '0';
    wait; -- will wait forever
  end process tb;
   --  end test bench 
end;
