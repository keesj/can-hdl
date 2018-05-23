library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_clk is
    generic (
        system_freq : integer := 96000000 -- the system frequency
    );
    port ( clk                    : in  std_logic;
           rst                    : in  std_logic;
           clk_bit_count          : in  std_logic_vector(31 downto 0) := (0=>'1', others => '0');
           can_config_clk_sync_en : in  std_logic;
           can_rx_clk_sync        : in  std_logic;  -- signal to sync with the bit clock
           can_sample_set_clk     : out std_logic;  -- Signal an outgoing sample must be set (firest quanta)
           can_sample_check_clk   : out std_logic;  -- Signal the value of a signal can be checked to detect collision
           can_sample_get_clk     : out std_logic
    ); -- Singal that the incommint sample can be read
end can_clk;

architecture rtl of can_clk is
    signal quanta_counter           : integer    := 0;
    signal counter                  : integer    := 0;
    signal can_sample_set_clk_buf   : std_logic  := '0';
    signal can_sample_check_clk_buf : std_logic  := '0';
    signal can_sample_get_clk_buf   :  std_logic := '0';

    constant divider : integer := 10;
begin
    can_sample_set_clk <= can_sample_set_clk_buf;
    can_sample_check_clk <= can_sample_check_clk_buf;
    can_sample_get_clk <= can_sample_get_clk_buf;

    -- Input clock is 96 Mhz
    -- Can bit time if 500.000 hence we want 10 faster
    -- 500 khz
    count: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- start with counter =0 to ensure the 
                -- next clock cycle the code gets triggered imediately
                counter <= 0;
                quanta_counter <= 0;
            elsif can_rx_clk_sync = '1' and can_config_clk_sync_en = '1' then
                --reset counters 
                counter <= 0;
                quanta_counter <= 0;
                report "RESET COUNTER";
            else
                can_sample_set_clk_buf   <= '0';
                can_sample_check_clk_buf <= '0';
                can_sample_get_clk_buf   <= '0' ;
                
                counter <= counter + divider;
                if counter >= 0 then
                    counter <= counter - to_integer(unsigned(clk_bit_count));

                    quanta_counter <= quanta_counter +1;
                    if quanta_counter = 9 then
                      quanta_counter <= 0;
                    end if;
                    if  quanta_counter = 0 then
                        can_sample_set_clk_buf <= '1';
                    end if;
                    if  quanta_counter = 7 then
                        can_sample_check_clk_buf <= '1';
                    end if;
                    if  quanta_counter = 7 then
                          can_sample_get_clk_buf <= '1';
                    end if;
                end if;
            end if; 
        end if;
    end process;
end rtl;
