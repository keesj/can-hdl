library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity can_tx_tb is
end can_tx_tb;

architecture behavior of can_tx_tb is
    signal test_running:   std_logic := '1';
    signal clk         :   std_logic := '0';            
    signal can_id      :   std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
    signal can_dlc     :   std_logic_vector (3 downto 0) := (others => '0');
    signal can_data    :   std_logic_vector (63 downto 0) := (others => '0');
    signal can_valid   :   std_logic := '0';
    signal status      :  std_logic_vector (31 downto 0):= (others => '0');
    signal can_signal_set : std_logic := '0';
    signal can_signal_check : std_logic := '0';
    signal can_signal_get : std_logic := '0';
    signal can_phy_tx     :   std_logic:= '0';
    signal can_phy_tx_en  :   std_logic:= '0';
    signal can_phy_rx     :  std_logic:= '0';


    signal can_tx_out         : std_logic_vector(126 downto 0) := (others =>'1');
    signal can_tx_out_len     : integer := 0;


    constant clk_period : time := 10 ns;

begin
    uut: entity work.can_tx port map(
        clk => clk, 
        can_id  => can_id,
        can_dlc => can_dlc,
        can_data   => can_data,
        can_valid  => can_valid,
        status     => status,
        can_signal_set => can_signal_set,
        can_signal_check => can_signal_check, -- unused in this test
        can_phy_tx  => can_phy_tx,
        can_phy_tx_en  => can_phy_tx_en,
        can_phy_rx     => can_phy_rx
    );

   --can_signal_set <=clk;
   can_phy_rx <= can_phy_tx;

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
            if can_signal_get ='1'  then
                if can_phy_tx_en ='1' then
                    can_tx_out <=  can_tx_out(125 downto 0) & can_phy_tx ;
                    can_tx_out_len <= can_tx_out_len +1;
                end if;
            end if;
            if can_valid = '1' then
                can_tx_out <= (others => '1');
                can_tx_out_len <=0;
            end if;
        end if;
   end process;

  -- Test bench statements
  tb : process
    file tb_data : text open READ_MODE is "test_data/can_tx_tb_data.hex";

    file tb_out : text open WRITE_MODE is "can_tx_tb_data_out.hex";
    variable l : line;
    variable out_l : line;
    --00014 0 01 0122334455667788 5C70
    variable can_in_id : std_logic_vector(10 downto 0);
    variable can_in_rtr : std_logic;
    variable can_in_dlc : std_logic_vector(3 downto 0);  
    variable can_in_data : std_logic_vector(63 downto 0);
    variable can_in_crc : std_logic_vector(14 downto 0);
    variable can_out_len_expected : std_logic_vector(7 downto 0);
    variable can_tx_out_expected :  std_logic_vector(126 downto 0);
  begin

    wait for 10 ns; -- wait until global set/reset completes
    while not endfile(tb_data) loop
        --ID  R 
        --00d 0 8 436f707972696768 6F 7FFF8234421B7B83E2E4D2CED1D1F07F # https://github.com/EliasOenal/sigrok-dumps/blob/master/can/arbitrary_traffic/bsd_license_can_standard_500k.logicdata
        readline(tb_data,l);
        hread(l, can_in_id);
        read(l,  can_in_rtr);
        hread(l, can_in_dlc);
        hread(l, can_in_data);
        hread(l, can_out_len_expected);
        hread(l, can_tx_out_expected);

        can_id(31 downto 21) <= can_in_id;
        can_id(0) <= can_in_rtr;
        can_dlc <= can_in_dlc;
        can_data <= can_in_data;

        can_valid <= '1'; 
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        can_valid <= '0';
        wait until status(0) ='0';
        
        -- now check len and value

        assert (can_tx_out = can_tx_out_expected) 
          report "Unexpected contents (expected=" & to_hstring(can_tx_out_expected) & ", actual=" & to_hstring(can_tx_out) & ")"
          severity failure;
        assert (std_logic_vector(to_unsigned(can_tx_out_len,8)) = can_out_len_expected) 
          report "Unexpexted length (expected="   & to_hstring(can_out_len_expected) & ", actual=" & to_hstring(to_unsigned(can_tx_out_len,8)) & ") "
          severity failure;          
        --write recieved length and data
        hwrite(out_l,std_logic_vector(to_unsigned(can_tx_out_len,8)));
        write(out_l,String'(" "));
        hwrite(out_l,can_tx_out);
        writeline(tb_out,out_l);        
    end loop;
    test_running <= '0';

    wait; -- will wait forever
  end process tb; 
end;
