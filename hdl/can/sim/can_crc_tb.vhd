library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity can_crc_tb is
end can_crc_tb;

architecture behavior of can_crc_tb is 

  signal data : std_logic_vector(7 downto 0) := "01010101";
  signal din: std_logic;
  constant clk_period : time := 10 ns;
  
  signal crc_data : std_logic_vector(14 downto 0);
  signal crc_data_next : std_logic_vector(14 downto 0);
  signal crc_din : std_logic := '0';
 begin
     uut: entity work.can_crc port map(
      crc_val_cur => crc_data,
      din => din,
      crc_val_next => crc_data_next
     );



  tb : process is
    file tb_data : text open READ_MODE is "hdl/can/sim/test_data/can_crc_tb_data.hex";
    variable l : line;
    variable data_in : std_logic_vector(7 downto 0);
    variable crc_in : std_logic_vector(14 downto 0);
  begin
    while not endfile(tb_data) loop
      readline(tb_data,l);
      hread(l, data_in);
      hread(l,crc_in);


      data <= data_in;
      crc_data <= (others => '0');


      wait for 10 ns;


      report "new ROUND";
      for i in 0 to 7 loop
        din <= data(7);
        data <=  data(6 downto 0) & '0';
        report "DATA " & std_logic'image(data(7));
        wait for 10 ns;
        crc_data <= crc_data_next;
      end loop;
      report "CRC " & to_hstring(crc_data);
      --why??
      wait for 10 ns;
      report "CRC " & to_hstring(crc_data);
      assert crc_data = crc_in report "CRC mismatch input " & to_hstring(data_in) & " crc=" & to_hstring(crc_data) & " expected crc=" & to_hstring(crc_in) severity failure;
    end loop;
    report "DONE";
    wait;
  end process tb;
end;
