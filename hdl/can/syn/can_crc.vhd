library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- based on 
-- http://srecord.sourceforge.net/crc16-ccitt.html
-- and https://www.can-cia.org/can-knowledge/can/crc/
entity can_crc is
    port ( 
            crc_val_cur  : in std_logic_vector (14 downto 0) := (others => '0');
            din : in  std_logic;
            crc_val_next : out std_logic_vector (14 downto 0) := (others => '0')
    );
end can_crc;

architecture rtl of can_crc is    
begin
     -- x15 + x14 + x10 + x8 + x7 +x4 +x3 + 1 
     crc_val_next(0) <= crc_val_cur(14) xor din;
     crc_val_next(1) <= crc_val_cur(0);
     crc_val_next(2) <= crc_val_cur(1);
     crc_val_next(3) <= crc_val_cur(2) xor (din xor crc_val_cur(14));
     crc_val_next(4) <= crc_val_cur(3) xor (din xor crc_val_cur(14));
     crc_val_next(5) <= crc_val_cur(4);
     crc_val_next(6) <= crc_val_cur(5);
     crc_val_next(7) <= crc_val_cur(6) xor (din xor crc_val_cur(14));
     crc_val_next(8) <= crc_val_cur(7) xor (din xor crc_val_cur(14));
     crc_val_next(9) <= crc_val_cur(8);
     crc_val_next(10)<= crc_val_cur(9) xor (din xor crc_val_cur(14));
     crc_val_next(11)<= crc_val_cur(10);
     crc_val_next(12)<= crc_val_cur(11);
     crc_val_next(13)<= crc_val_cur(12);
     crc_val_next(14)<= crc_val_cur(13) xor (din xor crc_val_cur(14));
end rtl;

