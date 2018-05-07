library ieee;
use ieee.std_logic_1164.all;

entity can_tx_mux is
    port(
        clk            : in  std_logic;
        tx             : in  std_logic;
        tx_en          : in  std_logic;

        tx_out         : out std_logic;
        tx_out_en      : out std_logic;

        can_ack_req    : in  std_logic;
        can_signal_set : in  std_logic
    );
end can_tx_mux;

architecture rtl of can_tx_mux is
    signal do_ack : std_logic := '0';
begin
    tx_out <= tx when do_ack ='0' else '1';
    tx_out_en <= tx_en when do_ack ='0' else '1';

    ack_process : process(clk)
    begin
        if rising_edge(clk) then
            if can_signal_set = '1' then
                do_ack <= '0';
                if can_ack_req = '1' then
                    report "ACK RESPONSE";
                    do_ack <= '1';
                end if;
            end if;
        end if;
    end process;
end rtl;
