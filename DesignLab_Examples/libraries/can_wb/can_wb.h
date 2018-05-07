/*

 can_wb - Summarize your library here.

 Describe your library here.

 License: GNU General Public License V3

 (C) Copyright (Your Name Here)
 
 For more help on how to make an Arduino style library:
 http://arduino.cc/en/Hacking/LibraryTutorial

 */

#ifndef __can_wb_H__
#define __can_wb_H__

#include <inttypes.h> 
#include <zpuino-types.h>
#include <zpuino.h>
#include "Arduino.h"

#define CAN_CONFIG_LOOPBACK (1 << 0)
#define CAN_CONFIG_CLK_SYNC (1 << 1)

#define CAN_CONFIG_DEFAULT (CAN_CONFIG_CLK_SYNC)

#define CAN_STATUS_RX_BUSY            (1 << 0)
#define CAN_STATUS_TX_BUSY            (1 << 1)
#define CAN_STATUS_RX_CRC_ERROR       (1 << 2)
#define CAN_STATUS_RX_DATA_READY      (1 << 3)
#define CAN_STATUS_TX_LOST_ARBIRATION (1 << 4)

class can_wb
{
  public:
    can_wb();
    void setup(unsigned int wishboneSlot);
    
    unsigned int get_val(unsigned int address);
    unsigned int get_version();
    unsigned int get_config();
    void set_config(unsigned int config);
    
    void set_sample_rate(unsigned int rate);
    unsigned int get_sample_rate();
    void set_tx_id(unsigned int id);
    void set_tx_dlc(unsigned int length);
    void set_tx_data(unsigned char *data,unsigned int length);
    void get_tx_data(unsigned char *data,unsigned int length);
    void set_tx_valid();
    
    unsigned int get_rx_id();
    unsigned int get_rx_dlc();
    void get_rx_data(unsigned char *data,unsigned int length);
    void set_rx_drr();
    
    unsigned int get_status();
    /*
        void set_rx_id_filter(unsigned long id);
    void set_rx_id_filter_mask(unsigned long mask);

    */
  private:
    int wishboneSlot;
};

#endif
