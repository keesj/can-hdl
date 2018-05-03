library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_send is
    port (
        clk : in std_logic;
        rst : in std_logic;

        -- phy signals
        phy_tx    : out std_logic;
        phy_tx_en : out std_logic;
        phy_rx    : in std_logic
    );
end can_send;

architecture behavior of can_send is

    signal can0_can_sample_rate :  std_logic_vector (31 downto 0) := (others => '0'); --
    signal can0_rst :  std_logic := '0';
    signal can0_can_tx_id    :  std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
    signal can0_can_tx_dlc   :  std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
    signal can0_can_tx_data  :  std_logic_vector (63 downto 0) := (others => '0'); -- data
    signal can0_can_tx_valid :  std_logic := '0';    --Sync signal to read the values and start pushing them on the bus
    signal can0_can_rx_id    :  std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
    signal can0_can_rx_dlc   :  std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
    signal can0_can_rx_data  :  std_logic_vector (63 downto 0) := (others => '0'); -- data
    signal can0_can_rx_valid :  std_logic := '0';    --Sync that the data is valid
    signal can0_can_rx_drr   :  std_logic := '0';     --rx data read ready (the fields can be invaludated and a new frame can be accepter)
    signal can0_can_status   :  std_logic_vector (31 downto 0) := (others => '0');
    signal can0_can_rx_id_filter       :   std_logic_vector (31 downto 0) := (others => '0');
    signal can0_can_rx_id_filter_mask  :   std_logic_vector (31 downto 0) := (others => '0');

    type can_send_states is (
        can_send_state_initial,
        can_send_state_wait_for_ready,
        can_send_state_send_request
    );

    signal can_send_state: can_send_states := can_send_state_initial;
begin
    can0_can_rx_id_filter <= (others => '0');
    can0_can_rx_id_filter_mask <= (others => '0');
    can0_can_rx_drr <= '0';

    uut0: entity work.can port map(
        clk => clk,
        rst => rst,
        can_sample_rate=> can0_can_sample_rate,
        can_tx_id  => can0_can_tx_id,
        can_tx_dlc => can0_can_tx_dlc,
        can_tx_data => can0_can_tx_data,
        can_tx_valid => can0_can_tx_valid,
        can_rx_id  => can0_can_rx_id,
        can_rx_dlc => can0_can_rx_dlc,
        can_rx_data => can0_can_rx_data,
        can_rx_valid => can0_can_rx_valid,
        can_rx_drr => can0_can_rx_drr,
        can_status => can0_can_status,
        can_rx_id_filter => can0_can_rx_id_filter,
        can_rx_id_filter_mask => can0_can_rx_id_filter_mask,
        phy_tx  => phy_tx,
        phy_tx_en => phy_tx_en,
        phy_rx    => phy_rx
    );


    sending_stuff : process(clk)
    begin
        if rising_edge(clk) then
            can0_can_tx_valid <= '0';
            if rst = '1' then
                can_send_state <= can_send_state_initial;
            else 
                case can_send_state is
                    when can_send_state_initial =>
                        can0_can_sample_rate <= std_logic_vector(to_unsigned(1,32));
                        can_send_state <= can_send_state_wait_for_ready;
                    when can_send_state_wait_for_ready =>
                        if can0_can_status(2 downto 0) = "000" then
                            can_send_state <= can_send_state_send_request;
                        end if;
                    when can_send_state_send_request =>
                        can0_can_tx_id(31 downto 21) <= "01000001101";
                        can0_can_tx_id(0) <= '0';
                        can0_can_tx_dlc <= x"8";
                        can0_can_tx_data <= x"ff01020304050607";
                        can0_can_tx_valid <= '1'; 
                        can_send_state <= can_send_state_wait_for_ready;
                end case;
            end if;
        end if;
    end process;
end behavior;
