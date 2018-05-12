library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity can_crc_tb is
end can_crc_tb;

architecture behavior of can_crc_tb is 

  signal data : std_logic_vector(7 downto 0) := "01010101";
  signal clk : std_logic;
  signal din: std_logic;
  signal ce: std_logic;
  signal rst : std_logic;
  signal crc: std_logic_vector(14 downto 0);
  signal test_running :  std_logic := '1';
  
  constant clk_period : time := 10 ns;
  
 begin
     uut: entity work.can_crc port map(
      clk => clk,
      din => din,
      ce => ce,
      rst => rst,
      crc => crc
     );

   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
        if test_running ='0' then
          wait;
        end if;
   end process;
  

  tb : process is
    file tb_data : text open READ_MODE is "test_data/can_crc_tb_data.hex";
    variable l : line;
    variable data_in : std_logic_vector(7 downto 0);
    variable crc_in : std_logic_vector(14 downto 0);
  begin
    while not endfile(tb_data) loop
      readline(tb_data,l);
      hread(l, data_in);
      hread(l,crc_in);

      data <= data_in;
      rst <= '1';   
      wait until rising_edge(clk);
      rst <= '0';

      report "new ROUND";
      for i in 0 to 7 loop
        din <= data(7);
        data <=  data(6 downto 0) & '0';
        report "DATA " & std_logic'image(data(7));
        ce <='1';
        wait until rising_edge(clk);
        ce <='0';
      end loop;
      report "CRC " & to_hstring(crc);
      --why??
      wait until rising_edge(clk);
      report "CRC " & to_hstring(crc);
      assert crc = crc_in report "CRC mismatch input " & to_hstring(data_in) & " crc=" & to_hstring(crc) & " expected crc=" & to_hstring(crc_in) severity failure;
    end loop;
    report "DONE";
    test_running <='0';
    wait;
  end process tb;
end;
