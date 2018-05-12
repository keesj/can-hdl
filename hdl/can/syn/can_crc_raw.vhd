library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- based on 
-- http://srecord.sourceforge.net/crc16-ccitt.html
-- and https://www.can-cia.org/can-knowledge/can/crc/
entity can_crc_raw is
    port ( 
            crc_val  : in std_logic_vector (14 downto 0) := (others => '0');
            din : in  std_logic;
            crc_next : out std_logic_vector (14 downto 0) := (others => '0')
    );
end can_crc_raw;

architecture rtl of can_crc_raw is    
begin
     -- x15 + x14 + x10 + x8 + x7 +x4 +x3 + 1 
    crc_next(0) <= crc_val(14) xor din;
    crc_next(1) <= crc_val(0);
    crc_next(2) <= crc_val(1);
    crc_next(3) <= crc_val(2) xor (din xor crc_val(14));
    crc_next(4) <= crc_val(3) xor (din xor crc_val(14));
    crc_next(5) <= crc_val(4);
    crc_next(6) <= crc_val(5);
    crc_next(7) <= crc_val(6) xor (din xor crc_val(14));
    crc_next(8) <= crc_val(7) xor (din xor crc_val(14));
    crc_next(9) <= crc_val(8);
    crc_next(10)<= crc_val(9) xor (din xor crc_val(14));
    crc_next(11)<= crc_val(10);
    crc_next(12)<= crc_val(11);
    crc_next(13)<= crc_val(12);
    crc_next(14)<= crc_val(13) xor (din xor crc_val(14));
end rtl;

