--------------------------------------------------------------------------------
-- Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.7
--  \   \         Application : sch2hdl
--  /   /         Filename : Papilio_Pro.vhf
-- /___/   /\     Timestamp : 05/07/2018 23:06:20
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: sch2hdl -sympath /home/keesj/projects/DesignLab_Examples/libraries/VGA_ZPUino -sympath /home/keesj/projects/DesignLab_Examples/libraries/ZPUino_2 -sympath /home/keesj/projects/DesignLab_Examples/libraries/Papilio_Hardware -sympath /home/keesj/projects/DesignLab_Examples/libraries/can_wb -sympath /home/keesj/projects/DesignLab_Examples/libraries/HQVGA -sympath /home/keesj/projects/DesignLab_Examples/libraries/ZPUino_Wishbone_Peripherals -sympath /home/keesj/projects/DesignLab_Examples/libraries/Gameduino -sympath /home/keesj/projects/DesignLab_Examples/libraries/VGA_ZXSpectrum -sympath /home/keesj/projects/DesignLab_Examples/libraries/Benchy -sympath /home/keesj/projects/DesignLab_Examples/libraries/Robot_Control_Library -sympath /home/keesj/projects/DesignLab_Examples/libraries/Building_Blocks -sympath /home/keesj/projects/DesignLab_Examples/libraries/Clocks -sympath /home/keesj/projects/DesignLab_Examples/libraries/RGB_Matrix -sympath /home/keesj/projects/DesignLab_Examples/libraries/BitCoin_Miner -sympath /home/keesj/projects/DesignLab_Examples/libraries/clocks -sympath /home/keesj/projects/github/can-hdl/DesignLab_Examples/libraries/can_wb/circuit/LX9 -intstyle ise -family spartan6 -flat -suppress -vhdl /home/keesj/projects/github/can-hdl/DesignLab_Examples/libraries/can_wb/circuit/LX9/Papilio_Pro.vhf -w /home/keesj/projects/github/can-hdl/DesignLab_Examples/libraries/can_wb/circuit/Papilio_Pro.sch
--Design Name: Papilio_Pro
--Device: spartan6
--Purpose:
--    This vhdl netlist is translated from an ECS schematic. It can be 
--    synthesized and simulated, but it should not be modified. 
--

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity Papilio_Pro is
   port ( ext_pins_in    : in    std_logic_vector (100 downto 0); 
          WING_AL2       : in    std_logic; 
          WING_CL1       : in    std_logic; 
          WING_CL2       : in    std_logic; 
          WING_CL3       : in    std_logic; 
          WING_CL4       : in    std_logic; 
          WING_CL5       : in    std_logic; 
          ext_pins_out   : out   std_logic_vector (100 downto 0); 
          WING_AL0       : out   std_logic; 
          WING_AL1       : out   std_logic; 
          WING_CL0       : out   std_logic; 
          ext_pins_inout : inout std_logic_vector (100 downto 0); 
          WING_AH0       : inout std_logic; 
          WING_AH1       : inout std_logic; 
          WING_AH2       : inout std_logic; 
          WING_AH3       : inout std_logic; 
          WING_AH4       : inout std_logic; 
          WING_AH5       : inout std_logic; 
          WING_AH6       : inout std_logic; 
          WING_AH7       : inout std_logic; 
          WING_BH0       : inout std_logic; 
          WING_BH1       : inout std_logic; 
          WING_BH2       : inout std_logic; 
          WING_BH3       : inout std_logic; 
          WING_BH4       : inout std_logic; 
          WING_BH5       : inout std_logic; 
          WING_BH6       : inout std_logic; 
          WING_BH7       : inout std_logic; 
          WING_BL0       : inout std_logic; 
          WING_BL1       : inout std_logic; 
          WING_BL2       : inout std_logic; 
          WING_BL3       : inout std_logic; 
          WING_BL4       : inout std_logic; 
          WING_BL5       : inout std_logic; 
          WING_BL6       : inout std_logic; 
          WING_BL7       : inout std_logic; 
          WING_CH0       : inout std_logic; 
          WING_CH1       : inout std_logic; 
          WING_CH2       : inout std_logic; 
          WING_CH3       : inout std_logic; 
          WING_CH4       : inout std_logic; 
          WING_CH5       : inout std_logic; 
          WING_CH6       : inout std_logic; 
          WING_CH7       : inout std_logic);
end Papilio_Pro;

architecture BEHAVIORAL of Papilio_Pro is
   attribute brams      : string ;
   signal XLXN_325                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_326                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_327                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_328                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_329                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_330                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_331                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_332                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_333                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_334                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_335                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_336                                  : std_logic_vector (7 
         downto 0);
   signal XLXN_408                                  : std_logic_vector (200 
         downto 0);
   signal XLXN_409                                  : std_logic_vector (200 
         downto 0);
   signal XLXN_479                                  : std_logic_vector (100 
         downto 0);
   signal XLXN_480                                  : std_logic_vector (100 
         downto 0);
   signal XLXN_481                                  : std_logic;
   signal WING_AL0_DUMMY                            : std_logic;
   signal WING_AL1_DUMMY                            : std_logic;
   signal XLXI_38_Flex_Pin_out_0_openSignal         : std_logic;
   signal XLXI_38_Flex_Pin_out_1_openSignal         : std_logic;
   signal XLXI_38_Flex_Pin_out_2_openSignal         : std_logic;
   signal XLXI_38_Flex_Pin_out_3_openSignal         : std_logic;
   signal XLXI_38_Flex_Pin_out_4_openSignal         : std_logic;
   signal XLXI_38_Flex_Pin_out_5_openSignal         : std_logic;
   signal XLXI_51_wishbone_slot_video_in_openSignal : std_logic_vector (100 
         downto 0);
   signal XLXI_51_wishbone_slot_6_out_openSignal    : std_logic_vector (100 
         downto 0);
   signal XLXI_51_wishbone_slot_8_out_openSignal    : std_logic_vector (100 
         downto 0);
   signal XLXI_51_wishbone_slot_9_out_openSignal    : std_logic_vector (100 
         downto 0);
   signal XLXI_51_wishbone_slot_10_out_openSignal   : std_logic_vector (100 
         downto 0);
   signal XLXI_51_wishbone_slot_11_out_openSignal   : std_logic_vector (100 
         downto 0);
   signal XLXI_51_wishbone_slot_12_out_openSignal   : std_logic_vector (100 
         downto 0);
   signal XLXI_51_wishbone_slot_13_out_openSignal   : std_logic_vector (100 
         downto 0);
   signal XLXI_51_wishbone_slot_14_out_openSignal   : std_logic_vector (100 
         downto 0);
   signal XLXI_52_la7_openSignal                    : std_logic;
   component Wing_GPIO
      port ( wt_miso : inout std_logic_vector (7 downto 0); 
             wt_mosi : inout std_logic_vector (7 downto 0));
   end component;
   
   component Papilio_Default_Wing_Pinout
      port ( WING_AH0         : inout std_logic; 
             WING_AH1         : inout std_logic; 
             WING_AH2         : inout std_logic; 
             WING_AH3         : inout std_logic; 
             WING_AH4         : inout std_logic; 
             WING_AH5         : inout std_logic; 
             WING_AH6         : inout std_logic; 
             WING_AH7         : inout std_logic; 
             WING_AL0         : inout std_logic; 
             WING_AL1         : inout std_logic; 
             WING_AL2         : inout std_logic; 
             WING_AL3         : inout std_logic; 
             WING_AL4         : inout std_logic; 
             WING_AL5         : inout std_logic; 
             WING_AL6         : inout std_logic; 
             WING_AL7         : inout std_logic; 
             WING_BH0         : inout std_logic; 
             WING_BH1         : inout std_logic; 
             WING_BH2         : inout std_logic; 
             WING_BH3         : inout std_logic; 
             WING_BH4         : inout std_logic; 
             WING_BH5         : inout std_logic; 
             WING_BH6         : inout std_logic; 
             WING_BH7         : inout std_logic; 
             WING_BL0         : inout std_logic; 
             WING_BL1         : inout std_logic; 
             WING_BL2         : inout std_logic; 
             WING_BL3         : inout std_logic; 
             WING_BL4         : inout std_logic; 
             WING_BL5         : inout std_logic; 
             WING_BL6         : inout std_logic; 
             WING_BL7         : inout std_logic; 
             WING_CL0         : inout std_logic; 
             WING_CL1         : inout std_logic; 
             WING_CL2         : inout std_logic; 
             WING_CL3         : inout std_logic; 
             WING_CL4         : inout std_logic; 
             WING_CL5         : inout std_logic; 
             WING_CL6         : inout std_logic; 
             WING_CL7         : inout std_logic; 
             WING_CH0         : inout std_logic; 
             WING_CH1         : inout std_logic; 
             WING_CH2         : inout std_logic; 
             WING_CH3         : inout std_logic; 
             WING_CH4         : inout std_logic; 
             WING_CH5         : inout std_logic; 
             WING_CH6         : inout std_logic; 
             WING_CH7         : inout std_logic; 
             gpio_bus_out     : in    std_logic_vector (200 downto 0); 
             gpio_bus_in      : out   std_logic_vector (200 downto 0); 
             WingType_miso_BH : inout std_logic_vector (7 downto 0); 
             WingType_miso_BL : inout std_logic_vector (7 downto 0); 
             WingType_miso_AH : inout std_logic_vector (7 downto 0); 
             WingType_mosi_BL : inout std_logic_vector (7 downto 0); 
             WingType_mosi_BH : inout std_logic_vector (7 downto 0); 
             WingType_mosi_CL : inout std_logic_vector (7 downto 0); 
             WingType_mosi_AH : inout std_logic_vector (7 downto 0); 
             WingType_miso_CL : inout std_logic_vector (7 downto 0); 
             WingType_miso_CH : inout std_logic_vector (7 downto 0); 
             WingType_mosi_CH : inout std_logic_vector (7 downto 0); 
             WingType_mosi_AL : inout std_logic_vector (7 downto 0); 
             WingType_miso_AL : inout std_logic_vector (7 downto 0); 
             Flex_Pin_out_0   : in    std_logic; 
             Flex_Pin_out_1   : in    std_logic; 
             Flex_Pin_out_2   : in    std_logic; 
             Flex_Pin_out_3   : in    std_logic; 
             Flex_Pin_out_4   : in    std_logic; 
             Flex_Pin_out_5   : in    std_logic; 
             Flex_Pin_in_0    : out   std_logic; 
             Flex_Pin_in_1    : out   std_logic; 
             Flex_Pin_in_2    : out   std_logic; 
             Flex_Pin_in_3    : out   std_logic; 
             Flex_Pin_in_4    : out   std_logic; 
             Flex_Pin_in_5    : out   std_logic);
   end component;
   
   component can_wb
      port ( wishbone_in  : in    std_logic_vector (100 downto 0); 
             wishbone_out : out   std_logic_vector (100 downto 0); 
             tx           : out   std_logic; 
             tx_en        : out   std_logic; 
             rx           : in    std_logic);
   end component;
   
   component ZPUino_Papilio_Pro_V2
      port ( gpio_bus_out            : out   std_logic_vector (200 downto 0); 
             gpio_bus_in             : in    std_logic_vector (200 downto 0); 
             clk_96Mhz               : out   std_logic; 
             clk_1Mhz                : out   std_logic; 
             clk_osc_32Mhz           : out   std_logic; 
             ext_pins_in             : in    std_logic_vector (100 downto 0); 
             ext_pins_out            : out   std_logic_vector (100 downto 0); 
             ext_pins_inout          : inout std_logic_vector (100 downto 0); 
             wishbone_slot_5_out     : in    std_logic_vector (100 downto 0); 
             wishbone_slot_5_in      : out   std_logic_vector (100 downto 0); 
             wishbone_slot_6_in      : out   std_logic_vector (100 downto 0); 
             wishbone_slot_6_out     : in    std_logic_vector (100 downto 0); 
             wishbone_slot_8_in      : out   std_logic_vector (100 downto 0); 
             wishbone_slot_8_out     : in    std_logic_vector (100 downto 0); 
             wishbone_slot_9_in      : out   std_logic_vector (100 downto 0); 
             wishbone_slot_9_out     : in    std_logic_vector (100 downto 0); 
             wishbone_slot_10_in     : out   std_logic_vector (100 downto 0); 
             wishbone_slot_10_out    : in    std_logic_vector (100 downto 0); 
             wishbone_slot_11_in     : out   std_logic_vector (100 downto 0); 
             wishbone_slot_11_out    : in    std_logic_vector (100 downto 0); 
             wishbone_slot_12_in     : out   std_logic_vector (100 downto 0); 
             wishbone_slot_12_out    : in    std_logic_vector (100 downto 0); 
             wishbone_slot_13_in     : out   std_logic_vector (100 downto 0); 
             wishbone_slot_13_out    : in    std_logic_vector (100 downto 0); 
             wishbone_slot_14_in     : out   std_logic_vector (100 downto 0); 
             wishbone_slot_14_out    : in    std_logic_vector (100 downto 0); 
             wishbone_slot_video_in  : in    std_logic_vector (100 downto 0); 
             wishbone_slot_video_out : out   std_logic_vector (100 downto 0));
   end component;
   
   component BENCHY_sa_SumpBlaze_LogicAnalyzer8
      generic( brams : integer :=  12);
      port ( clk_32Mhz : in    std_logic; 
             la0       : in    std_logic; 
             rx        : in    std_logic; 
             tx        : out   std_logic; 
             la1       : in    std_logic; 
             la2       : in    std_logic; 
             la3       : in    std_logic; 
             la4       : in    std_logic; 
             la5       : in    std_logic; 
             la6       : in    std_logic; 
             la7       : in    std_logic);
   end component;
   attribute brams of BENCHY_sa_SumpBlaze_LogicAnalyzer8 : component is "12";
   
begin
   WING_AL0 <= WING_AL0_DUMMY;
   WING_AL1 <= WING_AL1_DUMMY;
   XLXI_22 : Wing_GPIO
      port map (wt_miso(7 downto 0)=>XLXN_325(7 downto 0),
                wt_mosi(7 downto 0)=>XLXN_326(7 downto 0));
   
   XLXI_23 : Wing_GPIO
      port map (wt_miso(7 downto 0)=>XLXN_327(7 downto 0),
                wt_mosi(7 downto 0)=>XLXN_328(7 downto 0));
   
   XLXI_24 : Wing_GPIO
      port map (wt_miso(7 downto 0)=>XLXN_329(7 downto 0),
                wt_mosi(7 downto 0)=>XLXN_330(7 downto 0));
   
   XLXI_25 : Wing_GPIO
      port map (wt_miso(7 downto 0)=>XLXN_331(7 downto 0),
                wt_mosi(7 downto 0)=>XLXN_332(7 downto 0));
   
   XLXI_26 : Wing_GPIO
      port map (wt_miso(7 downto 0)=>XLXN_333(7 downto 0),
                wt_mosi(7 downto 0)=>XLXN_334(7 downto 0));
   
   XLXI_27 : Wing_GPIO
      port map (wt_miso(7 downto 0)=>XLXN_335(7 downto 0),
                wt_mosi(7 downto 0)=>XLXN_336(7 downto 0));
   
   XLXI_38 : Papilio_Default_Wing_Pinout
      port map (Flex_Pin_out_0=>XLXI_38_Flex_Pin_out_0_openSignal,
                Flex_Pin_out_1=>XLXI_38_Flex_Pin_out_1_openSignal,
                Flex_Pin_out_2=>XLXI_38_Flex_Pin_out_2_openSignal,
                Flex_Pin_out_3=>XLXI_38_Flex_Pin_out_3_openSignal,
                Flex_Pin_out_4=>XLXI_38_Flex_Pin_out_4_openSignal,
                Flex_Pin_out_5=>XLXI_38_Flex_Pin_out_5_openSignal,
                gpio_bus_out(200 downto 0)=>XLXN_408(200 downto 0),
                Flex_Pin_in_0=>open,
                Flex_Pin_in_1=>open,
                Flex_Pin_in_2=>open,
                Flex_Pin_in_3=>open,
                Flex_Pin_in_4=>open,
                Flex_Pin_in_5=>open,
                gpio_bus_in(200 downto 0)=>XLXN_409(200 downto 0),
                WingType_miso_AH(7 downto 0)=>XLXN_333(7 downto 0),
                WingType_miso_AL(7 downto 0)=>XLXN_335(7 downto 0),
                WingType_miso_BH(7 downto 0)=>XLXN_329(7 downto 0),
                WingType_miso_BL(7 downto 0)=>XLXN_331(7 downto 0),
                WingType_miso_CH(7 downto 0)=>XLXN_325(7 downto 0),
                WingType_miso_CL(7 downto 0)=>XLXN_327(7 downto 0),
                WingType_mosi_AH(7 downto 0)=>XLXN_334(7 downto 0),
                WingType_mosi_AL(7 downto 0)=>XLXN_336(7 downto 0),
                WingType_mosi_BH(7 downto 0)=>XLXN_330(7 downto 0),
                WingType_mosi_BL(7 downto 0)=>XLXN_332(7 downto 0),
                WingType_mosi_CH(7 downto 0)=>XLXN_326(7 downto 0),
                WingType_mosi_CL(7 downto 0)=>XLXN_328(7 downto 0),
                WING_AH0=>WING_AH0,
                WING_AH1=>WING_AH1,
                WING_AH2=>WING_AH2,
                WING_AH3=>WING_AH3,
                WING_AH4=>WING_AH4,
                WING_AH5=>WING_AH5,
                WING_AH6=>WING_AH6,
                WING_AH7=>WING_AH7,
                WING_AL0=>open,
                WING_AL1=>open,
                WING_AL2=>open,
                WING_AL3=>open,
                WING_AL4=>open,
                WING_AL5=>open,
                WING_AL6=>open,
                WING_AL7=>open,
                WING_BH0=>WING_BH0,
                WING_BH1=>WING_BH1,
                WING_BH2=>WING_BH2,
                WING_BH3=>WING_BH3,
                WING_BH4=>WING_BH4,
                WING_BH5=>WING_BH5,
                WING_BH6=>WING_BH6,
                WING_BH7=>WING_BH7,
                WING_BL0=>WING_BL0,
                WING_BL1=>WING_BL1,
                WING_BL2=>WING_BL2,
                WING_BL3=>WING_BL3,
                WING_BL4=>WING_BL4,
                WING_BL5=>WING_BL5,
                WING_BL6=>WING_BL6,
                WING_BL7=>WING_BL7,
                WING_CH0=>WING_CH0,
                WING_CH1=>WING_CH1,
                WING_CH2=>WING_CH2,
                WING_CH3=>WING_CH3,
                WING_CH4=>WING_CH4,
                WING_CH5=>WING_CH5,
                WING_CH6=>WING_CH6,
                WING_CH7=>WING_CH7,
                WING_CL0=>open,
                WING_CL1=>open,
                WING_CL2=>open,
                WING_CL3=>open,
                WING_CL4=>open,
                WING_CL5=>open,
                WING_CL6=>open,
                WING_CL7=>open);
   
   XLXI_41 : can_wb
      port map (rx=>WING_AL2,
                wishbone_in(100 downto 0)=>XLXN_479(100 downto 0),
                tx=>WING_AL0_DUMMY,
                tx_en=>WING_AL1_DUMMY,
                wishbone_out(100 downto 0)=>XLXN_480(100 downto 0));
   
   XLXI_51 : ZPUino_Papilio_Pro_V2
      port map (ext_pins_in(100 downto 0)=>ext_pins_in(100 downto 0),
                gpio_bus_in(200 downto 0)=>XLXN_409(200 downto 0),
                wishbone_slot_video_in(100 downto 
            0)=>XLXI_51_wishbone_slot_video_in_openSignal(100 downto 0),
                wishbone_slot_5_out(100 downto 0)=>XLXN_480(100 downto 0),
                wishbone_slot_6_out(100 downto 
            0)=>XLXI_51_wishbone_slot_6_out_openSignal(100 downto 0),
                wishbone_slot_8_out(100 downto 
            0)=>XLXI_51_wishbone_slot_8_out_openSignal(100 downto 0),
                wishbone_slot_9_out(100 downto 
            0)=>XLXI_51_wishbone_slot_9_out_openSignal(100 downto 0),
                wishbone_slot_10_out(100 downto 
            0)=>XLXI_51_wishbone_slot_10_out_openSignal(100 downto 0),
                wishbone_slot_11_out(100 downto 
            0)=>XLXI_51_wishbone_slot_11_out_openSignal(100 downto 0),
                wishbone_slot_12_out(100 downto 
            0)=>XLXI_51_wishbone_slot_12_out_openSignal(100 downto 0),
                wishbone_slot_13_out(100 downto 
            0)=>XLXI_51_wishbone_slot_13_out_openSignal(100 downto 0),
                wishbone_slot_14_out(100 downto 
            0)=>XLXI_51_wishbone_slot_14_out_openSignal(100 downto 0),
                clk_osc_32Mhz=>XLXN_481,
                clk_1Mhz=>open,
                clk_96Mhz=>open,
                ext_pins_out(100 downto 0)=>ext_pins_out(100 downto 0),
                gpio_bus_out(200 downto 0)=>XLXN_408(200 downto 0),
                wishbone_slot_video_out=>open,
                wishbone_slot_5_in(100 downto 0)=>XLXN_479(100 downto 0),
                wishbone_slot_6_in=>open,
                wishbone_slot_8_in=>open,
                wishbone_slot_9_in=>open,
                wishbone_slot_10_in=>open,
                wishbone_slot_11_in=>open,
                wishbone_slot_12_in=>open,
                wishbone_slot_13_in=>open,
                wishbone_slot_14_in=>open,
                ext_pins_inout(100 downto 0)=>ext_pins_inout(100 downto 0));
   
   XLXI_52 : BENCHY_sa_SumpBlaze_LogicAnalyzer8
      port map (clk_32Mhz=>XLXN_481,
                la0=>WING_CL2,
                la1=>WING_CL3,
                la2=>WING_CL4,
                la3=>WING_CL5,
                la4=>WING_AL0_DUMMY,
                la5=>WING_AL1_DUMMY,
                la6=>WING_AL2,
                la7=>XLXI_52_la7_openSignal,
                rx=>WING_CL1,
                tx=>WING_CL0);
   
end BEHAVIORAL;


