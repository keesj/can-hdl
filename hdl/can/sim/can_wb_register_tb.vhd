library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_wb_register_tb is
end can_wb_register_tb;

architecture sim of can_wb_register_tb is

  constant period: time := 10 ns;

  signal clk: std_logic := '1';
  signal rst: std_logic := '0';
  signal test_running :  std_logic := '1';



  signal wb_dat_o:   std_logic_vector(31 downto 0);
  signal wb_dat_i:   std_logic_vector(31 downto 0);
  signal wb_adr_i:   std_logic_vector(31 downto 0);
  signal wb_we_i:    std_logic := '0';
  signal wb_cyc_i:   std_logic := '0';
  signal wb_stb_i:   std_logic := '0';
  signal wb_ack_o:   std_logic;
  
  signal wb_in:   std_logic_vector(100 downto 0);
  signal wb_out:   std_logic_vector(100 downto 0);
  
  signal wb_dat_o_dly:   std_logic_vector(31 downto 0);
  
  --Define your Register addresses here

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
  
  --Define your external connections here

  signal can0_phy_tx    :  std_logic;
  signal can0_phy_tx_en :  std_logic;
  signal can0_phy_rx    :  std_logic;
begin

  --clk <= not clk after period/2;

  clk_process : process
  begin
      clk <= '0';
      wait for period/2;
      clk <= '1';
      wait for period/2;
      if test_running = '0' then
        wait;
      end if;
  end process;
  -- Reset
  process
  begin
    wait for 5 ns;
    rst <= '1';
    wait for 20 ns;
    rst <= '0';
    wait;
  end process;

  uut0: entity work.can_wb port map(
      wishbone_in => wb_in,
      wishbone_out => wb_out,
      tx  => can0_phy_tx,
      tx_en => can0_phy_tx_en,
      rx    => can0_phy_rx
  );
	
  wb_in(61) <= clk;
  wb_in(60) <= rst;
  wb_in(59 downto 28) <= wb_dat_i;
  wb_in(27 downto 3) <= wb_adr_i(24 downto 0);
  wb_in(2) <= wb_we_i;
  wb_in(1) <= wb_cyc_i;
  wb_in(0) <= wb_stb_i; 
  wb_dat_o <= wb_out(33 downto 2);
  wb_ack_o <= wb_out(1);
  --wb_inta_o <= wb_out(0);

  -- Delayed read
  wb_dat_o_dly<=transport wb_dat_o after 1 ps;

  process
    procedure wbwrite(a: in std_logic_vector(31 downto 0); d: in std_logic_vector(31 downto 0) ) is
    begin
      wb_cyc_i<='1';
      wb_stb_i<='1';
      wb_we_i<='1';
      wb_dat_i<=d;
      wb_adr_i<=a;
      wait until rising_edge(clk);
		if wb_ack_o /= '1' then
			wait until wb_ack_o='1';
		end if;
      wait until rising_edge(clk);
      wb_cyc_i<='0';
      wb_stb_i<='0';
      wb_we_i <='0';
    end procedure;

    procedure wbread( a: in std_logic_vector(31 downto 0); d: out std_logic_vector(31 downto 0)) is
    begin
      wb_cyc_i<='1';
      wb_stb_i<='1';
      wb_we_i<='0';
      wb_adr_i<=a;
      wait until rising_edge(clk);
		if wb_ack_o /= '1' then
			wait until wb_ack_o='1';
		end if;
      wait until rising_edge(clk);
      d := wb_dat_o_dly;
      wb_cyc_i<='0';
      wb_stb_i<='0';
      wb_we_i <='0';
    end procedure;

    variable r : std_logic_vector(31 downto 0);
    variable id : std_logic_vector(31 downto 0);
  begin
    
    wait until rst='1';
    wait until rst='0';
    wait until rising_edge(clk);

	-- This is where you should start providing your stimulus to test your design.
  
    wbread( REG_VERSION, r );   
    assert r(31 downto 0) = x"13371337" report "CAN VERSION MISMATCH "  & to_hstring(r) severity failure;

    wbread( REG_CONF, r );   
    assert r(31 downto 0) = x"00000000" report "CAN CONFIG MISMATCH "  & to_hstring(r) severity failure;

    wbwrite( REG_CONF, x"00000001");

    wbread( REG_CONF, r );   

    assert r(31 downto 0) = x"00000001" report "CAN CONFIG MISMATCH "  & to_hstring(r) severity failure;

    wbwrite( REG_SAMPLE_RATE, x"00000001");

    id := x"7fe00000";
    wbwrite( REG_TX_ID, id);

    wbwrite( REG_TX_DLC, x"00000008");
    wbwrite( REG_TX_DATA0, x"00000000");
    wbwrite( REG_TX_DATA0, x"00000008");
    wbwrite( REG_TX_VALID, x"00000001");
    wbwrite( REG_RX_DRR, x"00000001");
    for i in 0 to 1000 loop
      wbread( REG_STATUS, r ); 
      exit when r = x"00000008" ;
      report "STATUS " & to_hstring(r) ;
      wait for 1000 ns;
    end loop;
    wbread( REG_STATUS, r ); 
    assert r = x"00000008" report "Expected 0x00000008 status but got " & to_hstring(r) severity failure;
    wbread( REG_RX_ID, r ); 
    assert r = id report "Expected id " & to_hstring(id) & " but got " & to_hstring(r) severity failure;
    test_running <= '0';
    report "DONE";
    wait;
    
  end process;


end sim;
