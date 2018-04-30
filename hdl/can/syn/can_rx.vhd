library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_rx is
    port (  clk                 : in  std_logic;            
            can_id              : out std_logic_vector (31 downto 0) := (others => '0');-- 32 bit can_id + eff/rtr/err flags 
            can_dlc             : out std_logic_vector (3 downto 0)  := (others => '0');
            can_data            : out std_logic_vector (63 downto 0) := (others => '0');
            can_valid           : out std_logic := '0';

            can_drr             : in  std_logic; -- allow to recieve a frame
            status              : out std_logic_vector (31 downto 0);

            can_id_filter       : in  std_logic_vector (31 downto 0);
            can_id_filter_mask  : in  std_logic_vector (31 downto 0);

            can_signal_get      : in  std_logic; -- signal to set/change a value on the bus

            can_rx_clk_sync_en  : in  std_logic := '0'; -- enable syncing on changing tx input
            can_rx_clk_sync     : out std_logic := '0'; -- signal to synchronize the clock with values on the bus

            --We use to have the tx line here but timing of this module (the time of sampling)
            --Does not match the timing to send bits so instead we redirect this responsability
            --to an ohter module
            can_phy_ack_req     : out std_logic := '0'; -- request to send an ack request the next bit time
            can_phy_rx          : in  std_logic
    );
end can_rx;

architecture rtl of can_rx is

    -- can_*_buf are used to keep the locally recieved bits from can
    signal can_id_rx_buf   : std_logic_vector (31 downto 0) := (others => '0');-- 32 bit can_id + eff/rtr/err flags 
    signal can_dlc_rx_buf  : std_logic_vector (3 downto 0)  := (others => '0');
    signal can_data_rx_buf : std_logic_vector (63 downto 0) := (others => '0');
    signal can_crc_rx_buf  : std_logic_vector (14 downto 0) := (others => '0');

    signal can_data_ready  : std_logic                      :='0';

    --buffer for filter values (are read on can_drr)
    signal can_id_filter_buf       : std_logic_vector (31 downto 0) := (others => '0');
    signal can_id_filter_mask_buf  : std_logic_vector (31 downto 0) := (others => '0');

    -- this is the calculated crc value based on the incomming bits
    signal can_crc_calculated : std_logic_vector (14 downto 0) := (others => '0');
    
    --Those are the previous and current buffer where the current buffer equals
    -- the previous buffer + the current rx value
    signal shift_buff : std_logic_vector (127 downto 0) := (others => '0');
    signal buff_current : std_logic_vector (127 downto 0) := (others => '0');

    -- Counter used to count the bits recieved
    signal can_bit_counter : unsigned (7 downto 0) := (others => '0');

    signal can_prev_rx : std_logic := '1';

    -- Two buffers to keep the last bits sent to detect when we need bit stuffing
    --https://en.wikipedia.org/wiki/CAN_bus#Bit_stuffing
    --CAN uses NRZ encoding and bit stuffing
    --After 5 identical bits, a stuff bit of opposite value is added.
    --But not in the CRC delimiter, ACK, and end of frame fields.
    signal bit_shift_one_bits : std_logic_vector(4 downto 0) := (others =>'0');
    signal bit_shift_zero_bits : std_logic_vector(4 downto 0) := (others => '1');
   
    -- The lsb of the can_id register signifies a can rtr packet
    alias  can_rtr_rx_buf  : std_logic is can_id_rx_buf(0);

    -- State
    type can_states is (
          can_state_idle,
          can_state_start_of_frame, -- 1 bit
          can_state_arbitration,    -- 12 bit = 11 bit id + req remote
          can_state_control,        -- 6 bit  = id-ext + 0 + 4 bit dlc
          can_state_data,           -- 0-64 bits (8 * dlc)
          can_state_crc,            -- 15 bits + 1 bit crc delimiter
          can_state_ack_slot,       -- 1 bit
          can_state_ack_delimiter,  -- 1 bit 
          can_state_eof             -- 7 bit
    );

    signal can_rx_state: can_states := can_state_idle;

    signal bit_stuffing_required : std_logic := '0';
    signal bit_stuffing_value : std_logic := '0';
    signal bit_stuffing_en : std_logic := '1';

    signal crc_din : std_logic := '0';
    signal crc_ce : std_logic := '0';
    signal crc_rst : std_logic := '0';
    signal crc_data : std_logic_vector(14 downto 0);

    signal crc_error : std_logic := '0';
begin

    crc: entity work.can_crc port map(
        clk => clk,
        din => crc_din,
        ce => crc_ce,
        rst => crc_rst,
        crc => crc_data
      );

    -- status / next state logic
    -- bit[0] of the status register signifies the logic is busy. the rest is unused
    status(0) <='0' when can_rx_state = can_state_idle else '1';
    status(1) <= crc_error;
    status(2) <= can_data_ready; -- data is ready to be read
    status(31 downto 3) <= (others => '0');

    -- The bit shift buffers are filled for evey bit time
    bit_stuffing_required <= '1' when  (bit_shift_one_bits = "11111" or bit_shift_zero_bits = "00000") and bit_stuffing_en = '1'  else '0';
    bit_stuffing_value <= '0' when  bit_shift_one_bits = "11111"  else '1';

    -- For crc we never take stuffing into account and look at the current bit sent out
    crc_din <= shift_buff(0);
    --crc_din <= can_phy_rx;

    -- this forms the buffer we want to look into looking at the current values of the buffer
    buff_current <= shift_buff(126 downto 0) & can_phy_rx;

    count: process(clk)
    begin
        if rising_edge(clk) then
            -- For crc we need to assert the signal only for one clock cycle hence we reset
            -- to 0 every cycle
            crc_ce <= '0';
            can_rx_clk_sync <= '0';
            can_prev_rx <= can_phy_rx;

            if can_drr = '1' then
                report "CAN CLEAR";
                -- Empty internal buffers
                can_id_rx_buf <= (others => '0');
                can_dlc_rx_buf <= (others => '0');
                can_data_rx_buf <= (others => '0');
                can_valid <= '0';
                can_id_filter_buf <= can_id_filter;
                can_id_filter_mask_buf <= can_id_filter_mask;
                crc_error <= '0';
                can_data_ready <= '0';
            end if;


            if can_phy_rx /= can_prev_rx then
                can_rx_clk_sync <= '1';
            end if;

            -- starting happens starting with a 0 bit value

            if can_phy_rx ='0' and (can_rx_state = can_state_idle) and crc_error ='0' then
                report "CAN START";
                bit_stuffing_en <='1';
                -- and prepare next fields
                -- 13 bits  <= start of frame + id (11 bit) + rtr
                shift_buff <= (others => '0');    
                can_bit_counter <= (others => '0');
                
                if can_rx_clk_sync_en = '1' then
                    report "GOING TO START OF FRAME";
                    can_rx_state <= can_state_start_of_frame;
                    can_rx_clk_sync <= '1';
                else
                    -- this sample is already the SOF bit hence directly
                    -- go to the next state
                    can_rx_state <= can_state_arbitration;
                end if;
                --reset stuffing (enable is done in SOF)
                bit_shift_one_bits <= (others => '0');
                bit_shift_zero_bits  <= (others => '1');
                crc_rst <= '1';
                
            elsif can_signal_get = '1' then
                can_phy_ack_req <='0'; -- if can_phy_ack_req was set put it back to 0 after on can frame time
                --report "STATE " & can_states'image(can_rx_state) ;
                if bit_stuffing_required = '1' and bit_stuffing_en ='1' then
                    report "RX STUFFING(SKIPPING)";
                    bit_shift_one_bits <= (0=> bit_stuffing_value , others => '0');
                    bit_shift_zero_bits  <= (0=>bit_stuffing_value, others => '1');
                else
                    --shift bits in
                    shift_buff <= buff_current;
                    bit_shift_one_bits <= bit_shift_one_bits(3 downto 0) & can_phy_rx;
                    bit_shift_zero_bits <= bit_shift_zero_bits(3 downto 0) & can_phy_rx;
                    can_bit_counter <= can_bit_counter +1; 
                    crc_rst <= '0';

                    case can_rx_state is
                        when can_state_idle =>
                            --report "IDLE";
                            bit_stuffing_en <='0';
                            crc_ce <= '0';
                        when can_state_start_of_frame =>
                            report "SOF";
                            bit_stuffing_en <='1';
                            crc_ce <= '1';  
                            --perpare next state
                            can_bit_counter <= (others => '0');
                            can_rx_state <= can_state_arbitration;
                        when can_state_arbitration =>
                            report "AR bytes";
                            crc_ce <= '1';
                            if can_bit_counter = 11  then
                                --prare next state
                                --shift_buff(127 downto 115) <= '0' & can_id(31 downto 21) & can_id(0);
                              --  report "AR DONE " &  to_hstring(buff_current(11 downto 1));
                                can_id_rx_buf <= (others => '0');
                                can_id_rx_buf(31 downto 21) <= buff_current(11 downto 1);
                                can_rtr_rx_buf<= buff_current(0);
                                can_bit_counter <=(others => '0');
                                --filter here if needed
                                -- if can_id ^ can_filter_mask  = can_filter_id goto controle else goto sleep
                               can_rx_state <= can_state_control;
--                               if  buff_current(11 downto 1) or can_id_filter_mask_buf(31 downto 21) =  can_id_filter_buf(31 downto 21) then
--                                    can_rx_state <= can_state_control;
--                                else
--                                    report "RX FILTER DOES NOT MATCH";
--                                    can_rx_state <= can_state_idle;
--                                    crc_error <= '0';
--                                end if;
                            end if;
                        when can_state_control =>
                            report "Control bytes";
                            crc_ce <= '1';
                            if can_bit_counter = 5 then
                                --report "DLC " &  to_hstring(buff_current(3 downto 0));
                                can_dlc_rx_buf <= buff_current(3 downto 0);
                                can_bit_counter <=(others => '0');
                                if buff_current(3 downto 0) = "0000" then
                                    can_rx_state <= can_state_crc;
                                    -- the next bit is going to be the CRC do not update crc
                                    crc_ce <= '0';
                                else 
                                    can_rx_state <= can_state_data;
                                end if;
                            end if;
                        when can_state_data =>
                            report "Data";
                            crc_ce <= '1';
                            
                            if can_bit_counter = (8 * unsigned(can_dlc_rx_buf)) -1   then
                                -- the next bit is going to be the CRC do not update crc
                                for i in 1 to 8 loop
                                    if i = unsigned(can_dlc_rx_buf) then
                                        can_data_rx_buf((i * 8) -1 downto 0) <=   buff_current((i * 8) -1 downto 0);
                                    end if;
                                end loop;
                                
                                crc_ce <= '1';
                                can_bit_counter <= (others => '0');
                                can_rx_state <= can_state_crc;
                            end if;
                        when can_state_crc =>
                            report "CRC";
                            if can_bit_counter = 1 then
                                can_crc_calculated <= crc_data;-- this is the recalculated recived buffer
                            end if;
                            if can_bit_counter = 14 then
                                can_crc_rx_buf <= buff_current(14 downto 0);
                                can_bit_counter <= (others => '0');
                                can_rx_state <= can_state_ack_slot;
                                crc_rst <= '1';
                                -- push ack slot and delimiter
                                shift_buff(127 downto 126) <= "0" & "1";
                            end if;
                        when can_state_ack_slot =>
                            can_bit_counter <= (others => '0');
                            can_rx_state <= can_state_ack_delimiter;
                            if can_crc_rx_buf = can_crc_calculated then
                                report "CRC MATCH";
                                can_phy_ack_req <= '1';
                            else 
                                report "CRC ERROR";
                                crc_error <= '1';
                                crc_rst <= '1';
                                --can_rx_state <= can_state_idle;
                            end if;
                        when can_state_ack_delimiter =>
                            can_bit_counter <= (others => '0');
                            can_rx_state <= can_state_eof;
                        when can_state_eof =>

                            -- disable stuffing for those bits
                            bit_stuffing_en <='0';
                            if can_bit_counter = 6 then
                                crc_rst <= '1';--reset CRC for the next round
                                can_id <= can_id_rx_buf;
                                can_dlc <= can_dlc_rx_buf;
                                can_data <= can_data_rx_buf;
                                can_valid  <= '1';
                                can_data_ready <= '1';
                                can_rx_state <= can_state_idle;
                            end if;                            
                    end case;
                end if;
            end if;
        end if;
    end process;
end rtl;
