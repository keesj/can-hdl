library ieee;
use ieee.std_logic_1164.all;

entity can is
    port (
        -- Standard signals
        clk : in std_logic;
        rst : in std_logic;
        
        can_config : in std_logic_vector(31 downto 0)  := (others => '0'); -- controller conig lsb = loopback enable
        can_sample_rate : in std_logic_vector(31 downto 0) := (0=>'1' , others => '0');
        
        --can TX related
        can_tx_id    : in std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
        can_tx_dlc   : in std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
        can_tx_data  : in std_logic_vector (63 downto 0) := (others => '0'); -- data
        can_tx_valid : in std_logic := '0';    --Sync signal to read the values and start pushing them on the bus

        --can RX related
        can_rx_id    : out std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
        can_rx_dlc   : out std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
        can_rx_data  : out std_logic_vector (63 downto 0) := (others => '0'); -- data
        can_rx_valid : out std_logic := '0';    --Sync that the data is valid
        can_rx_drr   : in std_logic := '0';     --rx data read ready (the fields can be invaludated and a new frame can be accepter)

        can_status   : out std_logic_vector (31 downto 0) := (others => '0');

        -- can_rx_filter
        can_rx_id_filter       : in  std_logic_vector (31 downto 0) := (others => '0');
        can_rx_id_filter_mask  : in  std_logic_vector (31 downto 0) := (others => '0');

        -- phy signals
        phy_tx    : out std_logic;
        phy_tx_en : out std_logic;
        phy_rx    : in std_logic
    );
end can;

architecture behavior of can is

  signal phy_rx_post_loopback_mux : std_logic := '0';

  -- tx signal for muxing
  signal can_phy_pre_mux_tx : std_logic := '0';
  signal can_phy_pre_mux_tx_en : std_logic := '0';

  -- Signals
  signal can_rx_clk_sync: std_logic := '0';         -- Start of frame detected
  signal can_rx_clk_sync_en : std_logic := '1';     -- Enable clock sync
  signal can_clk_sample_set_clk: std_logic := '0';   --Sync Signal to set a value on the can bus
  signal can_clk_sample_check_clk: std_logic := '0'; --Sync Signal to check a value on the can bus
  signal can_clk_sample_get_clk: std_logic := '0';   --Sync Signal to read the value of a signal
  signal clk_bit_count : std_logic_vector (31 downto 0) := (0 =>'1' , others => '0');
  signal can_phy_ack_req: std_logic := '0'; --Signal from the rx module to the tx module to send an ack bit

  signal can_tx_status : std_logic_vector (31 downto 0):= (others => '0'); --transmit status
  signal can_rx_status : std_logic_vector (31 downto 0):= (others => '0'); --recieve status

  alias can_config_loopback is can_config(0);
  alias can_config_clk_sync_en is can_config(1); -- enable clock sync
begin

  -- implement loop back if requesed
  phy_rx_post_loopback_mux <= can_phy_pre_mux_tx  when can_config_loopback ='1' else phy_rx;

  --make can_status 0 the rx busy  and can_status 1 the tx_busy
  can_status(0) <= can_rx_status(0); -- rx status 0 = idle , 1 = busy 
  can_status(1) <= can_tx_status(0); -- tx status 0 = idle , 1 = busy 
  can_status(2) <= can_rx_status(1); -- rx crc error
  can_status(3) <= can_rx_status(2); -- rx data ready
  can_status(4) <= can_tx_status(1); -- tx lost artibration error
  can_status(31 downto 5) <= (others => '0');
  clk_bit_count <= can_sample_rate;

  can_tx_mux : entity work.can_tx_mux port map(
        clk   => clk,
        tx    => can_phy_pre_mux_tx,
        tx_en => can_phy_pre_mux_tx_en,

        tx_out    => phy_tx,
        tx_out_en => phy_tx_en,

        can_ack_req => can_phy_ack_req,
        can_signal_set => can_clk_sample_set_clk
  );

  -- can clock generation 
  can_clk: entity work.can_clk port map(
    clk => clk ,
    rst => rst,
    clk_bit_count => clk_bit_count,
    can_rx_clk_sync => can_rx_clk_sync ,
    can_config_clk_sync_en => can_config_clk_sync_en,
    can_sample_set_clk => can_clk_sample_set_clk ,
    can_sample_check_clk => can_clk_sample_check_clk ,
    can_sample_get_clk => can_clk_sample_get_clk 
  );
  
  -- can sending of messages
  can_tx: entity work.can_tx port map(
        clk => clk, 
        can_id  => can_tx_id,
        can_dlc => can_tx_dlc,
        can_data   => can_tx_data,
        can_valid  => can_tx_valid,
        status     => can_tx_status,
        can_signal_set => can_clk_sample_set_clk,
        can_signal_check => can_clk_sample_check_clk,
        can_phy_tx  => can_phy_pre_mux_tx,
        can_phy_tx_en  => can_phy_pre_mux_tx_en,
        can_phy_rx     => phy_rx
    );
    
  can_rx: entity work.can_rx port map(
    clk => clk,
    can_id => can_rx_id,
    can_dlc => can_rx_dlc,    
    can_data => can_rx_data,
    can_valid => can_rx_valid,
    can_drr  =>   can_rx_drr,
    status  => can_rx_status,
    can_id_filter => can_rx_id_filter,
    can_id_filter_mask => can_rx_id_filter_mask,
    can_signal_get => can_clk_sample_get_clk,
    can_rx_clk_sync_en   => can_rx_clk_sync_en, --sync signal from the recieve module to the clock module
    can_rx_clk_sync   => can_rx_clk_sync, --sync signal from the recieve module to the clock module
    can_phy_ack_req => can_phy_ack_req,
    can_phy_rx   => phy_rx_post_loopback_mux
  );
end;
