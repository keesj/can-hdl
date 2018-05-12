library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- based on 
-- http://srecord.sourceforge.net/crc16-ccitt.html
-- and https://www.can-cia.org/can-knowledge/can/crc/
entity can_crc is
    port ( 
            clk : in  std_logic;
            din : in  std_logic;
            ce  : in  std_logic;
            rst : in  std_logic;
            crc : out std_logic_vector(14 downto 0)
    );
end can_crc;

architecture rtl of can_crc is
    signal crc_next : std_logic_vector (14 downto 0) := (others => '0');
    signal crc_val  : std_logic_vector (14 downto 0) := (others => '0');
begin
    crc <= crc_val;

    can_crc_raw : entity work.can_crc_raw port map(
        crc_val => crc_val,
        din => din,
        crc_next=> crc_next
    );

    count: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                 crc_val <= (others => '0');
            else
                if ce = '1' then
                    crc_val <= crc_next;
                end if;
            end if;
        end if;
    end process;
end rtl;

