library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity can_wb is
   port ( wishbone_in  : in    std_logic_vector (100 downto 0); 
          wishbone_out : out   std_logic_vector (100 downto 0);
 
          --non wishbone connections
          tx    : out std_logic;
          tx_en : out std_logic;
          rx    : in std_logic
        );
end can_wb;

architecture behavior of can_wb is

  -- excelent documentation here
  -- http://zipcpu.com/zipcpu/2017/05/29/simple-wishbone.html
  --WB
  signal  wb_clk_i:    std_logic;                     -- Wishbone clock
  signal  wb_rst_i:    std_logic;                     -- Wishbone reset (synchronous)
  signal  wb_dat_i:    std_logic_vector(31 downto 0); -- Wishbone data input  (32 bits)
  signal  wb_adr_i:    std_logic_vector(31 downto 0); -- Wishbone address input  (32 bits)
  signal  wb_we_i:     std_logic;                     -- Wishbone write enable signal
  signal  wb_cyc_i:    std_logic;                     -- Wishbone cycle signal
  signal  wb_stb_i:    std_logic;                     -- Wishbone strobe signal  
    
  signal  wb_dat_o:    std_logic_vector(31 downto 0); -- Wishbone data output (32 bits)
  signal  wb_ack_o:    std_logic;                     -- Wishbone acknowledge out signal
  signal  wb_inta_o:   std_logic;

  signal version                    : std_logic_vector( 31 downto 0)  := x"13371337";
  signal can0_config                : std_logic_vector( 31 downto 0)  := (others => '0');

  signal can0_can_sample_rate       : std_logic_vector (31 downto 0) := (others => '0'); --
  signal can0_rst                   : std_logic;
  signal can0_can_tx_id             : std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
  signal can0_can_tx_dlc            : std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
  signal can0_can_tx_data           : std_logic_vector (63 downto 0) := (others => '0'); -- data
  signal can0_can_tx_valid          : std_logic := '0';    --Sync signal to read the values and start pushing them on the bus
  signal can0_can_rx_id             : std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
  signal can0_can_rx_dlc            : std_logic_vector (3 downto 0) := (others => '0');  -- data length
  signal can0_can_rx_data           : std_logic_vector (63 downto 0) := (others => '0'); -- data
  signal can0_can_rx_valid          : std_logic := '0';    --Sync that the data is valid
  signal can0_can_rx_drr            : std_logic := '0';     --rx data read ready (the fields can be invaludated and a new frame can be accepter)
  signal can0_can_status            : std_logic_vector (31 downto 0) := (others => '0');
  signal can0_can_rx_id_filter      : std_logic_vector (31 downto 0) := (others => '0');
  signal can0_can_rx_id_filter_mask : std_logic_vector (31 downto 0) := (others => '0');
  signal can0_phy_tx                : std_logic;
  signal can0_phy_tx_en             : std_logic;
  signal can0_phy_rx                : std_logic;

  --00 RO version h"13371337'
  -- 01 RO status bit 0 denotes a transmit request. bit 1 a read to receive singal
  -- 02 RW CONF  (loopback,selftest )

  -- 03 RW CONF sample rate
  -- 04 RW CONF RX id filter
  -- 05 RW CONF RX id filter mask

  -- 06 RW TX tx_id (11 msb are id) and lsb is request response
  -- 07 RW TX the 4 lsb bytes are the data length (code)
  -- 08 RW TX bits 31 to 0 of the data 
  -- 09 RW bits 63 to 32 of the data 
  -- 0A WO TX_VALID

  -- 0B RO RX tx _id (11 msb are id) and lsb is request response
  -- 0C RO RX LCD the 4 lsb bytes are the data length (code)
  -- 0d RO RX RX_DAT0 
  -- 0e RO RX RX_DAT1
  -- 0f WO TX_DATA_READ_READY (the data has been read)

  constant REG_VERSION        : std_logic_vector(31 downto 0) := x"00000000";
  constant REG_STATUS         : std_logic_vector(31 downto 0) := x"00000001";
  constant REG_CONF           : std_logic_vector(31 downto 0) := x"00000002";
  constant REG_SAMPLE_RATE    : std_logic_vector(31 downto 0) := x"00000003";
  constant REG_ID_FILTER      : std_logic_vector(31 downto 0) := x"00000004";
  constant REG_ID_FILTER_MASK : std_logic_vector(31 downto 0) := x"00000005";

  constant REG_TX_ID          : std_logic_vector(31 downto 0) := x"00000006";
  constant REG_TX_DLC         : std_logic_vector(31 downto 0) := x"00000007";
  constant REG_TX_DATA0       : std_logic_vector(31 downto 0) := x"00000008";
  constant REG_TX_DATA1       : std_logic_vector(31 downto 0) := x"00000009";
  constant REG_TX_VALID       : std_logic_vector(31 downto 0) := x"0000000a";

  constant REG_RX_ID          : std_logic_vector(31 downto 0) := x"0000000b";
  constant REG_RX_DLC         : std_logic_vector(31 downto 0) := x"0000000c";
  constant REG_RX_DATA0       : std_logic_vector(31 downto 0) := x"0000000d";
  constant REG_RX_DATA1       : std_logic_vector(31 downto 0) := x"0000000e";
  constant REG_RX_DRR         : std_logic_vector(31 downto 0) := x"0000000f";


begin

  -- Unpack the wishbone array into signals so the modules code is not confusing. - Don't touch.
  wb_clk_i <= wishbone_in(61);           -- clock
  wb_rst_i <= wishbone_in(60);           -- reset signal
  wb_dat_i <= wishbone_in(59 downto 28); -- the date the master wishes to write
  -- bits 27-23 are the slave address or similar on zpuino?
  wb_adr_i <= "000000000000" & wishbone_in(22 downto 3);  -- contains the address of the request
  wb_we_i  <= wishbone_in(2);             -- true for any write requests
  wb_cyc_i <= wishbone_in(1);            -- is true any time a wishbone transaction is taking place
  wb_stb_i <= wishbone_in(0);            -- is true for any bus transaction request.

  wishbone_out(33 downto 2) <= wb_dat_o;
  wishbone_out(1)           <= wb_ack_o;
  wishbone_out(0)           <= wb_inta_o;
  -- End unpacking Wishbone signals

  can0: entity work.can port MAP(
        clk => wb_clk_i,
        rst => can0_rst,
        can_config => can0_config,
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
        phy_tx  => tx,
        phy_tx_en => tx_en,
        phy_rx    => rx
);

  can0_rst <= wishbone_in(60);

  --wb 
  wb_ack_o <= '1' when wb_cyc_i='1' and wb_stb_i='1' else '0';

  -- wishbone read requests
  process(wb_adr_i,wb_clk_i)
  begin
    if wb_cyc_i='1' and wb_stb_i='1' and wb_we_i='0' then
      case wb_adr_i is
        when REG_VERSION        => wb_dat_o <= version;
        when REG_STATUS         => wb_dat_o <= can0_can_status ;
        when REG_CONF           => wb_dat_o <= can0_config;
        when REG_SAMPLE_RATE    => wb_dat_o <= can0_can_sample_rate;
        when REG_ID_FILTER      => wb_dat_o <= can0_can_rx_id_filter;
        when REG_ID_FILTER_MASK => wb_dat_o <= can0_can_rx_id_filter_mask;
        when REG_TX_ID          => wb_dat_o <= can0_can_tx_id;                           -- not very usefull
        when REG_TX_DLC         => wb_dat_o <= (31 downto 4 => '0')  & can0_can_tx_dlc;  -- not very usefull
        when REG_TX_DATA0       => wb_dat_o <= can0_can_tx_data(63 downto 32);           -- not very usefull
        when REG_TX_DATA1       => wb_dat_o <= can0_can_tx_data(31 downto 0 );           -- not very usefull
        when REG_TX_VALID       => wb_dat_o <=  (31 downto 1 => '0') & can0_can_tx_valid;-- not very usefull(will read 0)
        when REG_RX_ID          => wb_dat_o <= can0_can_rx_id;
        when REG_RX_DLC         => wb_dat_o <= (31 downto 4 => '0') & can0_can_rx_dlc;
        when REG_RX_DATA0       => wb_dat_o <= can0_can_rx_data(63 downto 32);
        when REG_RX_DATA1       => wb_dat_o <= can0_can_rx_data(31 downto 0);
        when REG_RX_DRR         => -- skip wb_dat_o <= allzero(31 downto 1) & can0_can_rx_drr;
        when others             => wb_dat_o <= (others => '-'); -- Return undefined for all other addresses
      end case;
    end if;
  end process;

  -- wishbone write requests
  process(wb_clk_i)
  begin
    if rising_edge(wb_clk_i) then  -- Synchronous to the rising edge of the clock
      can0_can_rx_drr <= '0';
      can0_can_tx_valid <= '0';
      if wb_cyc_i='1' and wb_stb_i='1' and wb_we_i='1' then
        case wb_adr_i is
          -- configuration fields
          when REG_VERSION        =>  --ignore version
          when REG_STATUS         => -- ignore can0_can_status <=  wb_dat_i;
          when REG_CONF           => can0_config                    <= wb_dat_i;
          when REG_SAMPLE_RATE    => can0_can_sample_rate           <= wb_dat_i;
          when REG_ID_FILTER      => can0_can_rx_id_filter          <= wb_dat_i;
          when REG_ID_FILTER_MASK => can0_can_rx_id_filter_mask     <= wb_dat_i;
          when REG_TX_ID          => can0_can_tx_id                 <= wb_dat_i;
          when REG_TX_DLC         => can0_can_tx_dlc                <= wb_dat_i(3 downto 0);
          when REG_TX_DATA0       => can0_can_tx_data(63 downto 32) <= wb_dat_i;--assuming little endian the low value of the int is at index 0
          when REG_TX_DATA1       => can0_can_tx_data(31 downto  0) <= wb_dat_i;
          when REG_TX_VALID       => can0_can_tx_valid              <= wb_dat_i(0);
          when REG_RX_ID          =>  -- skip can0_can_rx_id <=  wb_dat_i;
          when REG_RX_DLC         =>  -- skip can0_can_rx_dlc <=  wb_dat_i;
          when REG_RX_DATA0       =>  -- skip  can0_can_rx_data(31 downto 0) <=  wb_dat_i;
          when REG_RX_DATA1       =>  -- skip can0_can_rx_data(63 downto 32) <=  wb_dat_i;
          when REG_RX_DRR         => can0_can_rx_drr                <= wb_dat_i(0);
          when others => 
        end case;
      end if;
    end if;
  end process;
end behavior;
