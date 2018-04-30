library ieee;
use ieee.std_logic_1164.all;

entity can_phy_testbench is
end can_phy_testbench;
 
architecture behavior of can_phy_testbench is 
    
   --inputs
   signal tx : std_logic := '0';
   signal tx_en : std_logic := '0';

   --bidirs
   signal can_l : std_logic;
   signal can_h : std_logic;

   --outputs
   signal rx : std_logic;
    
   -- no clocks detected in port list. replace <clock> below with 
   -- appropriate port name 
 
   constant clk_period : time := 10 ns;
 
begin
 
    -- instantiate the unit under test (uut)
   uut: entity work.can_phy port map (
          tx => tx,
          tx_en => tx_en,
          rx => rx,
          can_l => can_l,
          can_h => can_h
        );



   -- stimulus process
   stim_proc: process
   begin
      -- hold reset state for 100 ns.
      wait for 100 ns;

      tx<='1';
      wait for clk_period*10;
      
      tx<='0';
      wait for clk_period*10;
      
      tx_en<='1';
      wait for clk_period*10;
      
      tx<='1';
      wait for clk_period*10;
      
      tx<='0';
      wait for clk_period*10;
      
      tx_en<='0';
      wait for clk_period*10;
      -- insert stimulus here 

      wait;
   end process;
end;
