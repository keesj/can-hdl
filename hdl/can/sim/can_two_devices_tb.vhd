library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_two_devices_tb is
end can_two_devices_tb;

architecture behavior of can_two_devices_tb is
    signal test_running :  std_logic := '1';
    signal clk :  std_logic;

    signal can0_can_config : std_logic_vector (31 downto 0) :=  (others => '0');
    signal can0_can_sample_rate :  std_logic_vector (31 downto 0) := (others => '0'); --
    signal can0_rst :  std_logic;
    signal can0_can_tx_id    :  std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
    signal can0_can_tx_dlc   :  std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
    signal can0_can_tx_data  :  std_logic_vector (63 downto 0) := (others => '0'); -- data
    signal can0_can_tx_valid :  std_logic := '0';    --Sync signal to read the values and start pushing them on the bus
    signal can0_can_rx_id    :  std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
    signal can0_can_rx_dlc   :  std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
    signal can0_can_rx_data  :  std_logic_vector (63 downto 0) := (others => '0'); -- data
    signal can0_can_rx_valid :  std_logic := '0';    --Sync that the data is valid
    signal can0_can_rx_drr   :  std_logic := '0';     --rx data read ready (the fields can be invaludated and a new frame can be accepter)
    signal can0_can_status   :  std_logic_vector (31 downto 0) := (others => '0');
    signal can0_can_rx_id_filter       :   std_logic_vector (31 downto 0) := (others => '0');
    signal can0_can_rx_id_filter_mask  :   std_logic_vector (31 downto 0) := (others => '0');
    signal can0_phy_tx    :  std_logic;
    signal can0_phy_tx_en :  std_logic;
    signal can0_phy_rx    :  std_logic;

    signal can1_can_sample_rate :  std_logic_vector (31 downto 0) := (others => '0'); --
    signal can1_rst :  std_logic;
    signal can1_can_config : std_logic_vector (31 downto 0) :=  (others => '0');
    signal can1_can_tx_id    :  std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
    signal can1_can_tx_dlc   :  std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
    signal can1_can_tx_data  :  std_logic_vector (63 downto 0) := (others => '0'); -- data
    signal can1_can_tx_valid :  std_logic := '0';    --Sync signal to read the values and start pushing them on the bus
    signal can1_can_rx_id    :  std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
    signal can1_can_rx_dlc   :  std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
    signal can1_can_rx_data  :  std_logic_vector (63 downto 0) := (others => '0'); -- data
    signal can1_can_rx_valid :  std_logic := '0';    --Sync that the data is valid
    signal can1_can_rx_drr   :  std_logic := '0';     --rx data read ready (the fields can be invaludated and a new frame can be accepter)
    signal can1_can_status   :  std_logic_vector (31 downto 0) := (others => '0');
    signal can1_can_rx_id_filter       :   std_logic_vector (31 downto 0) := (others => '0');
    signal can1_can_rx_id_filter_mask  :   std_logic_vector (31 downto 0) := (others => '0');
    signal can1_phy_tx    :  std_logic;
    signal can1_phy_tx_en :  std_logic;
    signal can1_phy_rx    :  std_logic;

    constant clk_period : time := 10 ns;
begin

    uut0: entity work.can port map(
        clk => clk,
        rst => can0_rst,
        can_config => can0_can_config,
        can_sample_rate=> can0_can_sample_rate,
        can_tx_id  => can0_can_tx_id,
        can_tx_dlc => can0_can_tx_dlc,
        can_tx_data => can0_can_tx_data,
        can_tx_valid => can0_can_tx_valid,
        can_rx_id  => can0_can_rx_id,
        can_rx_dlc => can0_can_rx_dlc,
        can_rx_data => can0_can_rx_data,
        can_rx_valid => can0_can_rx_valid,
        can_rx_drr => can0_can_rx_drr,
        can_status => can0_can_status,
        can_rx_id_filter => can0_can_rx_id_filter,
        can_rx_id_filter_mask => can0_can_rx_id_filter_mask,
        phy_tx  => can0_phy_tx,
        phy_tx_en => can0_phy_tx_en,
        phy_rx    => can0_phy_rx
    );

    uut1: entity work.can port map(
        clk => clk,
        rst => can1_rst,
        can_config => can1_can_config,
        can_sample_rate=> can1_can_sample_rate,
        can_tx_id  => can1_can_tx_id,
        can_tx_dlc => can1_can_tx_dlc,
        can_tx_data => can1_can_tx_data,
        can_tx_valid => can1_can_tx_valid,
        can_rx_id  => can1_can_rx_id,
        can_rx_dlc => can1_can_rx_dlc,
        can_rx_data => can1_can_rx_data,
        can_rx_valid => can1_can_rx_valid,
        can_rx_drr => can1_can_rx_drr,
        can_status => can1_can_status,
        can_rx_id_filter => can1_can_rx_id_filter,
        can_rx_id_filter_mask => can1_can_rx_id_filter_mask,
        phy_tx  => can1_phy_tx,
        phy_tx_en => can1_phy_tx_en,
        phy_rx    => can1_phy_rx
    );

    --wire up (we should add the can_phy in here)
    can1_phy_rx <= can0_phy_tx when can0_phy_tx_en = '1' else '1';

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
        if test_running = '0' then
          wait;
        end if;
    end process;

    can0_test : process
    begin

        --reset can busses
        can0_rst <= '1';
        can1_rst <= '1';
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        can0_rst <= '0';
        can1_rst <= '0';

        --set sample rate
        can0_can_sample_rate <=  std_logic_vector(to_unsigned(3,32));
        can1_can_sample_rate <=  std_logic_vector(to_unsigned(3,32));

        wait until rising_edge(clk);
        wait until falling_edge(clk);

        for i in 0 to 2 loop
            --prepare to recieve some data
            can1_can_rx_drr <= '1';
            wait until rising_edge(clk);
            wait until falling_edge(clk);
            can1_can_rx_drr <= '0';

            wait until rising_edge(clk);
            wait until falling_edge(clk);


            can0_can_tx_id(31 downto 21) <= "10000000000";
            can0_can_tx_id(0) <= '0';
            can0_can_tx_dlc <= x"8";
            can0_can_tx_data <= x"ff01020304050607";

            can0_can_tx_valid <= '1'; 
            wait until rising_edge(clk);
            wait until falling_edge(clk);
            can0_can_tx_valid <= '0';

            wait until can1_can_status(0) ='0';
            assert can1_can_rx_id = can0_can_tx_id report "CAN ID ERROR input=" & 
                to_hstring(can0_can_tx_id(31 downto 21)) &
                " output=" &
                to_hstring(can1_can_rx_id(31 downto 21)) 
                severity failure;
            assert can1_can_status(2) = '0' report "CAN RX CRC ERROR" severity failure;
        end loop;
        
        report "DONE";
        test_running <= '0';
        wait;
        --set sample rate

    end process;
end;
