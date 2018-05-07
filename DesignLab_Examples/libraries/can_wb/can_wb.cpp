/*

 can_wb - Summarize your library here.

 Describe your library here.

 License: GNU General Public License V3

 (C) Copyright (Your Name Here)
 
 For more help on how to make an Arduino style library:
 http://arduino.cc/en/Hacking/LibraryTutorial

 */

#include "Arduino.h"
#include "can_wb.h"

#define REG_CAN_VERSION           0x00
#define REG_CAN_STATUS            0x01
#define REG_CAN_CONFIG            0x02
#define REG_CAN_SAMPLE_RATE       0x03
#define REG_CAN_RX_ID_FILTER      0x04
#define REG_CAN_RX_ID_FILTER_MASK 0x05

#define REG_CAN_TX_ID             0x06
#define REG_CAN_TX_DLC            0x07
#define REG_CAN_TX_DATA0          0x08
#define REG_CAN_TX_DATA1          0x09
#define REG_CAN_TX_VALID          0x0A

#define REG_CAN_RX_ID             0x0b
#define REG_CAN_RX_DLC            0x0c
#define REG_CAN_RX_DATA0          0x0d
#define REG_CAN_RX_DATA1          0x0e
#define REG_CAN_RX_DRR            0x0f


can_wb::can_wb()
{

}

void can_wb::setup(unsigned int wishboneSlot)
{
	this->wishboneSlot = wishboneSlot;
}

unsigned int can_wb::get_version()
{
  return REGISTER(IO_SLOT(wishboneSlot),REG_CAN_VERSION);
}

unsigned int can_wb::get_val(unsigned int address){
   return REGISTER(IO_SLOT(wishboneSlot),address);
}
unsigned int can_wb::get_config()
{
  return REGISTER(IO_SLOT(wishboneSlot),REG_CAN_CONFIG);
}

void can_wb::set_config(unsigned int config)
{
  REGISTER(IO_SLOT(wishboneSlot),REG_CAN_CONFIG) = config;
}

void can_wb::set_sample_rate(unsigned int rate){
  REGISTER(IO_SLOT(wishboneSlot),REG_CAN_SAMPLE_RATE) = rate;
};

unsigned int can_wb::get_sample_rate(){
    	return REGISTER(IO_SLOT(wishboneSlot),REG_CAN_SAMPLE_RATE);
}

void can_wb::set_tx_id(unsigned int id){
  REGISTER(IO_SLOT(wishboneSlot),REG_CAN_TX_ID) = id;
};

void can_wb::set_tx_dlc(unsigned int length){
  REGISTER(IO_SLOT(wishboneSlot),REG_CAN_TX_DLC) = length	;
};

void can_wb::set_tx_data(unsigned char *data,unsigned int length){        
	//REGISTER(IO_SLOT(wishboneSlot),REG_CAN_TX_DATA0) = (data[3] << 24) | (data[2] << 16) | (data[1] << 8) | data[0];
        //REGISTER(IO_SLOT(wishboneSlot),REG_CAN_TX_DATA0) = (data[0] << 24) | (data[1] << 16) | (data[2] << 8) | data[3];
        REGISTER(IO_SLOT(wishboneSlot),REG_CAN_TX_DATA0) = ((unsigned int *)data)[0];
        REGISTER(IO_SLOT(wishboneSlot),REG_CAN_TX_DATA1) = ((unsigned int *)data)[1];
        //REGISTER(IO_SLOT(wishboneSlot),REG_CAN_TX_DATA1) = (data[7] << 24) | (data[6] << 16) | (data[5] << 8) | data[4];
};

void can_wb::get_tx_data(unsigned char *data,unsigned int length){
   	((unsigned int *)data)[0] = REGISTER(IO_SLOT(wishboneSlot),REG_CAN_TX_DATA0) ;
	((unsigned int *)data)[1] = REGISTER(IO_SLOT(wishboneSlot),REG_CAN_TX_DATA1) ;
}

void can_wb::set_tx_valid(){
	REGISTER(IO_SLOT(wishboneSlot),REG_CAN_TX_VALID) = 0x01;
};

unsigned int can_wb::get_status(){
	return REGISTER(IO_SLOT(wishboneSlot),REG_CAN_STATUS);
};

unsigned int can_wb::get_rx_id(){
  	return REGISTER(IO_SLOT(wishboneSlot),REG_CAN_RX_ID);

}
unsigned int can_wb::get_rx_dlc(){
	return REGISTER(IO_SLOT(wishboneSlot),REG_CAN_RX_DLC);
}
void can_wb::get_rx_data(unsigned char *data,unsigned int length){
 	((unsigned int *)data)[0] = REGISTER(IO_SLOT(wishboneSlot),REG_CAN_RX_DATA0) ;
	((unsigned int *)data)[1] = REGISTER(IO_SLOT(wishboneSlot),REG_CAN_RX_DATA1) ;
}

void can_wb::set_rx_drr(){
  REGISTER(IO_SLOT(wishboneSlot),REG_CAN_RX_DRR) =0x01;
}
