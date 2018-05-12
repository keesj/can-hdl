library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_tx is
    port (  clk              : in  std_logic;            
            can_id           : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags 
            can_dlc          : in  std_logic_vector (3 downto 0);
            can_data         : in  std_logic_vector (63 downto 0);
            can_valid        : in  std_logic;
            status           : out std_logic_vector (31 downto 0);
            can_signal_set   : in  std_logic; -- signal to set/change a value on the bus
            can_signal_check : in  std_logic; -- signal to check the value on the bus
            can_phy_tx       : out std_logic;
            can_phy_tx_en    : out std_logic;
            can_phy_rx       : in  std_logic
    );
end can_tx;

architecture rtl of can_tx is
    signal can_id_buf   : std_logic_vector (31 downto 0) := (others => '0');-- 32 bit can_id + eff/rtr/err flags 
    signal can_dlc_buf  : std_logic_vector (3 downto 0) := (others => '0');
    signal can_data_buf : std_logic_vector (63 downto 0) := (others => '0');

    signal can_phy_tx_buf : std_logic := '0';
    signal can_phy_tx_en_buf : std_logic := '0';
    signal can_crc_buf : std_logic_vector (14 downto 0) := (others => '0');
    
    signal shift_buff : std_logic_vector (127 downto 0) := (others => '0');

    -- Counter used to count the bits sent
    signal can_bit_counter : unsigned (7 downto 0) := (others => '0');
    

    -- Two buffers to keep the last bits sent to detect when we need bit stuffing
    --https://en.wikipedia.org/wiki/CAN_bus#Bit_stuffing
    --CAN uses NRZ encoding and bit stuffing
    --After 5 identical bits, a stuff bit of opposite value is added.
    --But not in the CRC delimiter, ACK, and end of frame fields.
    signal bit_shift_one_bits : std_logic_vector(4 downto 0) := (others =>'0');
    signal bit_shift_zero_bits : std_logic_vector(4 downto 0) := (others => '1');
    alias can_logic_bit_next : std_logic is shift_buff(127);

    ---- sff(11 bit) and eff (29 bit)  is set in the msb  of can_id
    -- Code kept here as as start of extended mode support
    --alias  can_sff_buf  : std_logic_vector is can_id_buf(10 downto 0) ;
    --alias  can_eff_buf  : std_logic is can_id_buf(31);

    -- The lsb of the can_id register signifies a can rtr packet
    alias  can_rtr  : std_logic is can_id_buf(30);

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

    signal can_tx_state: can_states := can_state_idle;

    signal bit_stuffing_required : std_logic := '0';
    signal bit_stuffing_value : std_logic := '0';
    signal next_tx_value : std_logic := '0';
    signal bit_stuffing_en : std_logic := '1';


    signal crc_data : std_logic_vector(14 downto 0);
    signal crc_data_next : std_logic_vector(14 downto 0);
    signal crc_din : std_logic := '0';

    signal can_lost_arbitration :  std_logic := '0';
begin

    crc: entity work.can_crc_raw port map(
        crc_val_cur => crc_data,
        din => crc_din,
        crc_val_next => crc_data_next
      );

    -- buffers for phy tx and tx_en to be able to read their state
    can_phy_tx_en <= can_phy_tx_en_buf;
    can_phy_tx <= can_phy_tx_buf when can_phy_tx_en_buf ='1' else '1';


    -- status / next state logic
    -- bit[0] of the status register signifies the logic is busy. the rest is unused
    status(0) <= '0' when can_tx_state = can_state_idle else '1';
    status(1) <= can_lost_arbitration;
    status(31 downto 2) <= (others => '0');

    -- The bit shift buffers are filled for evey bit time
    bit_stuffing_required <= '1' when  (bit_shift_one_bits = "11111" or bit_shift_zero_bits = "00000") and bit_stuffing_en = '1'  else '0';
    bit_stuffing_value <= '0' when  bit_shift_one_bits = "11111"  else '1';

    -- determine the next value to shift (either the head of the fifo buffer or the stuffing value)
    next_tx_value <= bit_stuffing_value when bit_stuffing_required = '1' else shift_buff(127);
    -- For crc we never take stuffing into account and look at the current bit sent out
    crc_din <= shift_buff(127);
    
    count: process(clk)
    begin
        if rising_edge(clk) then
            -- For crc we need to assert the signal only for one clock cycle hence we reset
            -- to 0 every cycle
            if can_valid ='1' and can_tx_state = can_state_idle then
                report "CANUP";

                -- Copy the data to the internal buffers
                can_id_buf <= can_id;
                can_dlc_buf <= can_dlc;
                can_data_buf <= can_data;
                can_lost_arbitration <= '0';

                -- and prepare next fields
                -- 13 bits  <= start of frame + id (11 bit) + rtr
                shift_buff(127 downto 115) <= '0' & can_id(31 downto 21) & can_id(0);
                -- 6 bits <= IDE + reservered + dlc
                shift_buff(114 downto 109) <= "0" & "0" & can_dlc;
                -- 64 bits data (we always copy)
                shift_buff(108 downto 45) <= can_data;
                
                -- We probably 
                can_bit_counter <= (others => '0');
                can_tx_state <= can_state_start_of_frame;
                --reset stuffing (enable is done in SOF)
                bit_shift_one_bits <= "00000";
                bit_shift_zero_bits  <= "11111";
                crc_data <= (others => '0');
            elsif can_signal_set = '1' then
                can_phy_tx_buf <= next_tx_value ;
                
                if bit_stuffing_required = '1' then
                    report "STUFFING";
                    bit_shift_one_bits <= (0=> bit_stuffing_value , others => '0');
                    bit_shift_zero_bits  <= (0=>bit_stuffing_value, others => '1');
                else
                    --shift bits for the next round
                    shift_buff(127 downto 0) <= shift_buff(126 downto 0) & "0";
                    bit_shift_one_bits <= bit_shift_one_bits(3 downto 0) & next_tx_value;
                    bit_shift_zero_bits <= bit_shift_zero_bits(3 downto 0) & next_tx_value;

                    can_bit_counter <= can_bit_counter +1; 
                    
                    case can_tx_state is
                        when can_state_idle =>
                            --report "IDLE";
                            --this code is never reached!!! 
                            can_phy_tx_en_buf <= '0';
                            bit_stuffing_en <='0';
                        when can_state_start_of_frame =>
                            report "SOF";
                            bit_stuffing_en <='1';
                            can_phy_tx_en_buf <= '1';
                            crc_data <= crc_data_next;
                            --perpare next state
                            can_bit_counter <= (others => '0');
                            can_tx_state <= can_state_arbitration;
                        when can_state_arbitration =>
                            report "AR bytes";
                            crc_data <= crc_data_next;
                            if can_bit_counter = 11  then
                                --prare next state
                                can_bit_counter <=(others => '0');
                                can_tx_state <= can_state_control;
                            end if;
                        when can_state_control =>
                            report "Control bytes";
                            crc_data <= crc_data_next;
                            if can_bit_counter = 5 then
                                can_bit_counter <=(others => '0');
                                if can_dlc_buf = "0000" then
                                    can_tx_state <= can_state_crc;
                                    -- the next bit is going to be the CRC do not update crc
                                else 
                                    can_tx_state <= can_state_data;
                                end if;
                            end if;
                        when can_state_data =>
                            report "Data";
                            crc_data <= crc_data_next;
                            
                            if can_bit_counter = (8 * unsigned(can_dlc_buf)) -1 then
                                -- the next bit is going to be the CRC do not update crc
                                can_bit_counter <= (others => '0');
                                can_tx_state <= can_state_crc;
                                can_crc_buf <= crc_data_next;
                                shift_buff(127 downto 113) <= crc_data_next;
                            end if;
                        when can_state_crc =>
                            report "CRC";
                            if can_bit_counter = 15 then
                                can_bit_counter <= (others => '0');
                                can_tx_state <= can_state_ack_delimiter;
                                crc_data <= (others => '0');
                                -- push ack slot and delimiter
                                shift_buff(127 downto 126) <= "0" & "1";
                            end if;
                        when can_state_ack_slot =>
                            can_bit_counter <= (others => '0');
                            can_tx_state <= can_state_ack_delimiter;
                        when can_state_ack_delimiter => 
                            can_bit_counter <= (others => '0');
                            can_tx_state <= can_state_eof;
                            shift_buff(127 downto 121) <= "1111111";
                        when can_state_eof =>
                            report "EOF";
                            -- disable stuffing for those bits
                            bit_stuffing_en <='0';
                            if can_bit_counter = 6 then
                                can_tx_state <= can_state_idle;
                                can_phy_tx_en_buf <= '0';
                            end if;
                    end case;
                end if;
            elsif can_signal_check = '1' then
                if can_tx_state = can_state_arbitration then
                    report "AR CHECK";
                    --check first 11 bits (not resent stuff)
                    if can_phy_tx_buf = '1' and can_phy_rx = '0' then
                        report "LOST ARBITRATION";
                        can_lost_arbitration <= '1';
                        --if we lost artibration we probably also need to go into idle and such...
                    end if;
                end if;
            end if;
        end if;
    end process;
end rtl;
