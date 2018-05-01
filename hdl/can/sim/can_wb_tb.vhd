library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_wb_testbench is
end can_wb_testbench;

architecture behavior of can_wb_testbench is
    signal test_running :  std_logic := '1';


    signal clk :  std_logic;

    signal can0_phy_tx    :  std_logic;
    signal can0_phy_tx_en :  std_logic;
    signal can0_phy_rx    :  std_logic;

    constant clk_period : time := 10 ns;

    signal wishbone_in  : std_logic_vector (100 downto 0) := (others => '0');
    signal wishbone_out : std_logic_vector (100 downto 0) := (others => '0');

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

begin

      -- Unpack the wishbone array into signals so the modules code is not confusing. - Don't touch.
  wishbone_in(61) <= wb_clk_i;          -- clock
  wishbone_in(60) <= wb_rst_i;           -- reset signal
  wishbone_in(59 downto 28) <= wb_dat_i ;-- the date the master wishes to write
  wishbone_in(27 downto 3) <= wb_adr_i(24 downto 0);  -- contains the address of the request
  wishbone_in(2) <= wb_we_i;             -- true for any write requests
  wishbone_in(1) <= wb_cyc_i;           -- is true any time a wishbone transaction is taking place
  wishbone_in(0) <= wb_stb_i;          -- is true for any bus transaction request.

  wb_dat_o <= wishbone_out(33 downto 2);
  wb_ack_o <= wishbone_out(1);
  wb_inta_o <= wishbone_out(0);
  -- End unpacking Wishbone signals
  
        -- Unpack the wishbone array into signals so the modules code is not confusing. - Don't touch.

    -- End unpacking Wishbone signals

    uut0: entity work.can_wb port map(
        wishbone_in => wishbone_in,
        wishbone_out => wishbone_out,
        tx  => can0_phy_tx,
        tx_en => can0_phy_tx_en,
        rx    => can0_phy_rx
    );

    clk_process : process
    begin
        clk <= '0';
        wb_clk_i <= '0';
        wait for clk_period/2;
        clk <= '1';
        wb_clk_i <= '1';
        wait for clk_period/2;
        if test_running = '0' then
          wait;
        end if;
    end process;

    can0_test : process
    begin
        wait for clk_period * 40;

        wait until rising_edge(clk);
        wait until falling_edge(clk);
        
        -- try to get the version
        wb_cyc_i <= '1';
        wb_stb_i <= '1';
        wb_we_i  <= '0';
        wb_adr_i <= (31 downto 8 =>'0' ) & x"00";

        wait until rising_edge(clk);
        wait until falling_edge(clk);

        wb_cyc_i <= '0';
        --can0_version
        
        assert wb_dat_o = x"13371337" report "DATA unexpected version " & to_hstring(wb_dat_o) severity failure;

        -- try to get the initial config
        wb_adr_i <= (31 downto 8 =>'0' ) & x"02";
        wb_cyc_i <= '1';
        wb_stb_i <= '1';
        wb_we_i  <= '0';

        wait until rising_edge(clk);
        wait until falling_edge(clk);
        wb_cyc_i <= '0';
        assert wb_dat_o = x"00000000" report "Config test expected empty but got " & to_hstring(wb_dat_o) severity failure;


        wait until rising_edge(clk);
        wait until falling_edge(clk);

        -- write config
        wb_adr_i <= (31 downto 8 =>'0' ) & x"02";
        wb_dat_i <= x"00000001";
        wb_cyc_i <= '1';
        wb_stb_i <= '1';
        wb_we_i  <= '1';
        wait until rising_edge(clk);
        wait until falling_edge(clk);

        wb_cyc_i <= '0';

        -- read back now (and expect 1 as value)
        wb_adr_i <= (31 downto 8 =>'0' ) & x"02";
        wb_cyc_i <= '1';
        wb_stb_i <= '1';
        wb_we_i  <= '0';

        wait until rising_edge(clk);
        wait until falling_edge(clk);

        wb_cyc_i <= '0';

        assert wb_dat_o = x"00000001" report "Config test expected 1 but got " & to_hstring(wb_dat_o) severity failure;

        -- try to get the version
        wb_adr_i <= (31 downto 8 =>'0' ) & x"00";
        wb_cyc_i <= '1';
        wb_stb_i <= '1';
        wb_we_i  <= '0';

        wait until rising_edge(clk);
        wait until falling_edge(clk);

        wb_cyc_i <= '0';
        --can0_version
        
        assert wb_dat_o = x"13371337" report "DATA unexpected version " & to_hstring(wb_dat_o) severity failure;

        test_running <= '0';
        report "DONE";
        wait;
        --set sample rate

    end process;
end;
