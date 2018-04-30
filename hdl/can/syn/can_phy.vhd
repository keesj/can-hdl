library ieee;
use ieee.std_logic_1164.all;

entity can_phy is
    port ( 
        tx            : in    std_logic;
        tx_en         : in    std_logic;
        rx            : out   std_logic;
        can_collision : out   std_logic; --detect detect collisions
        can_l         : inout std_logic;
        can_h         : inout std_logic
    );
end can_phy;

architecture rtl of can_phy is
    signal rx_out : std_logic; --create rx_out as buffer
begin
    rx <= rx_out;
    --driving the can bus when en is enabled
    can_l <= tx when (tx_en = '1') else 'Z';
    can_h <= not tx when (tx_en = '1') else 'Z';
    
    -- alway assign rx to can_h
    rx_out <= '1' when can_h = '1' and can_l ='0' else '0';
    
    --we can only detect when we send a 1 but the bus remains low
    can_collision <= '1' when tx ='1' and tx_en = '1' and not rx_out ='0' else '0';
end rtl;
