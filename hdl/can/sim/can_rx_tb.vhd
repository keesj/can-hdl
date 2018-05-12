library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity can_rx_tb is
end can_rx_tb;

architecture behavior of can_rx_tb is
    signal test_running:   std_logic := '1';            
    signal clk         :   std_logic := '0';            
    signal can_id      :   std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
    signal can_dlc     :   std_logic_vector (3 downto 0) := (others => '0');
    signal can_data    :   std_logic_vector (63 downto 0) := (others => '0');
    signal can_valid   :   std_logic := '0';
    signal can_drr     :   std_logic := '0';-- clear buffers
    signal status      :  std_logic_vector (31 downto 0):= (others => '0');

    signal can_id_filter      :   std_logic_vector (31 downto 0) := (others => '0');
    signal can_id_filter_mask :   std_logic_vector (31 downto 0) := (others => '0');
    signal can_signal_set : std_logic := '0';
    signal can_signal_check : std_logic := '0';
    signal can_signal_get : std_logic := '0';    
    signal can_rx_clk_sync   :   std_logic := '0';
    signal can_rx_clk_sync_en : std_logic := '1';
    signal can_phy_ack_req     :   std_logic:= '0';
    signal can_phy_rx     :  std_logic:= '1';


    signal can_tx_out         : std_logic_vector(126 downto 0) := (others =>'1');
    signal can_tx_out_len     : integer := 0;

    signal can_tx_out_input         : std_logic_vector(126 downto 0) := (others =>'1');
    signal can_tx_out_len_input     : integer := 0;


    constant clk_period : time := 10 ns;

begin
    uut: entity work.can_rx port map(
        clk => clk, 
        can_id  => can_id,
        can_dlc => can_dlc,
        can_data   => can_data,
        can_valid  => can_valid,
        can_drr => can_drr,
        status     => status,
        can_id_filter => can_id_filter,
        can_id_filter_mask => can_id_filter_mask,
        can_signal_get => can_signal_get,
        can_rx_clk_sync_en => can_rx_clk_sync_en,
        can_rx_clk_sync => can_rx_clk_sync,
        can_phy_ack_req  => can_phy_ack_req,
        can_phy_rx     => can_phy_rx
    );

   --can_signal_set <=clk;

   clk_process :process
   begin
	if test_running ='0' then
		wait;
	end if;
        for i in 0 to 9 loop
            if i = 0 then
              can_signal_set <= '1';
            end if;
            if i = 4 then
                can_signal_check <= '1';
            end if;
            
            if i = 7 then
                can_signal_get <='1';
            end if;

            clk <= '1';
            wait for clk_period/2;  --for 0.5 ns signal is '0'.
            clk <= '0';
            wait for clk_period/2;  --for next 0.5 ns signal is

            if i = 7 then 
                can_signal_get <='0';
            end if;
            if i = 4 then
                can_signal_check <= '0';
            end if;

            if i = 0 then
                can_signal_set <= '0';
            end if;
        end loop;
   end process;
   
   data_out :process(clk)
   begin
        if rising_edge(clk) 
        then
            if can_drr = '1' then
                can_tx_out     <= can_tx_out_input;
                can_tx_out_len <= can_tx_out_len_input;
                report "Set base value " & integer'image(can_tx_out_len_input);
            elsif can_signal_set ='1'  then
                if can_tx_out_len > 0 then
                    can_phy_rx     <= can_tx_out(126);
                    can_tx_out     <= can_tx_out(125 downto 0) & '1';
                    can_tx_out_len <= can_tx_out_len -1;
                else 
                    can_phy_rx <= '1';
                end if;
            end if;
        end if;
   end process;

  -- Test bench statements
  tb : process
    file tb_data : text open READ_MODE is "hdl/can/sim/test_data/can_rx_tb_data.hex";

    file tb_out : text open WRITE_MODE is "can_rx_tb_data_out.hex";
    variable l : line;
    variable out_l : line;
    --00014 0 01 0122334455667788 5C70
    variable can_in_id_expected : std_logic_vector(10 downto 0);
    variable can_in_rtr_expected : std_logic;
    variable can_in_dlc_expected : std_logic_vector(3 downto 0);  
    variable can_in_data_expected : std_logic_vector(63 downto 0);
    variable can_out_len_to_send : std_logic_vector(7 downto 0);
    variable can_tx_out_to_send :  std_logic_vector(126 downto 0);
  begin

    wait for 10 ns; -- wait until global set/reset completes
    while not endfile(tb_data) loop
        --ID  R 
        --00d 0 8 436f707972696768 6F 7FFF8234421B7B83E2E4D2CED1D1F07F # https://github.com/EliasOenal/sigrok-dumps/blob/master/can/arbitrary_traffic/bsd_license_can_standard_500k.logicdata
        --read in the same format as the can tx example
        readline(tb_data,l);
        hread(l, can_in_id_expected);
        read(l,  can_in_rtr_expected);
        hread(l, can_in_dlc_expected);
        hread(l, can_in_data_expected);
        hread(l, can_out_len_to_send);
        hread(l, can_tx_out_to_send);

        for i in 0 to 1 loop
            can_tx_out_len_input <= to_integer(unsigned(can_out_len_to_send));

            --can_tx_out_len_input <= 15;
            can_tx_out_len_input <= 128;
            can_tx_out_input <= can_tx_out_to_send;

            if i = 1 then
                can_tx_out_input(30) <= not can_tx_out_to_send(30);
            end if;


            can_drr <= '1'; 
            wait until rising_edge(clk);
            wait until falling_edge(clk);
            assert status(2) = '0' report "Data ready should be 0 but is " & to_hstring(status(2 downto 0)) severity failure;
            can_drr <= '0';
            wait until status(0) ='0';
            
            if i = 1 then
                --expect crc error
                assert (status(1 downto 0) = "10") report "Expected CRC error status status=" & to_hstring(status) severity failure;
            else 
                assert status(2) = '1' report "Data ready should be 1 but is " & to_hstring(status(2 downto 0)) severity failure;
                assert (status(1 downto 0) = "00") report "NON null status " & to_hstring(status) severity failure;
                assert (can_in_id_expected = can_id(31 downto 21)) 
                report "Unexpexted ID (expected="  & to_hstring(can_in_id_expected) & ") actual(" & to_hstring(can_id(31 downto 21)) & ")" severity failure;

                
                assert (can_in_dlc_expected = can_dlc) 
                report "Unexpexted DLC "  & to_hstring(can_in_dlc_expected) & " " & to_hstring(can_dlc) severity failure;

                assert (can_in_data_expected = can_data) 
                report "Unexpexted DATA "  & to_hstring(can_in_data_expected) & " " & to_hstring(can_data) severity failure ;
            end if;
        end loop;
    end loop;

    report "DONE";
    test_running <= '0';
    wait; -- will wait forever
  end process tb; 
end;
