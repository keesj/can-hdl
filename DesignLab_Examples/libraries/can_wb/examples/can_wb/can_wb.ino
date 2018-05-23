#include <can_wb.h>

/*
 Gadget Factory
 Template to make your own Schematic Symbol and Community Core Library for the Papilio FPGA and DesignLab

 To use this sketch do the following steps:
  1) 
  
 Tools for generating your own libraries:
 

 Tutorials:
   http://learn.gadgetfactory.net
   http://gadgetfactory.net/learn/2013/10/29/papilio-schematic-library-getting-started/
  

 created 2014
 by Jack Gassett
 http://www.gadgetfactory.net
 
 This example code is in the public domain.
 */

#include "can_wb.h"


#define circuit can_wb

can_wb can_wb;
 
void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  can_wb.setup(5);   
  
  can_wb.set_sample_rate(1920);
  can_wb.set_config(0x01);
}

unsigned int id_counter =0;
void loop() {

  id_counter ++;
  if (id_counter > 0x7ff){
    id_counter =0;
  }
  Serial.print("CAN SAMPLE RATE ");
  Serial.print(can_wb.get_sample_rate());
  Serial.print(" CAN CONFIG ");
  Serial.print(can_wb.get_config());


  unsigned char data[8] = {'h','e','l','l','o','c','a','n'};
  
  can_wb.set_tx_id(id_counter << 21);
  can_wb.set_tx_dlc(8); 
  can_wb.set_tx_data(data,8);
  
  can_wb.set_rx_drr(); 
  can_wb.set_tx_valid(); 

  unsigned long value;
  int count=0;
  while( ((value = can_wb.get_status()) & 0x2) == 2 ){
    delay(100);
    count++;
    if (count > 10) {
      break;
    }
  }
    
  count=0;
  while( ((value = can_wb.get_status()) & 0x1) == 1 ){
    delay(100);
    count++;
    if (count > 10) {
      break;
    }
  }
  
  Serial.print(" STATUS ");
  Serial.print(can_wb.get_status());
  Serial.print(" ID ");
  Serial.print(can_wb.get_rx_id(),HEX);
  Serial.print(" DLC ");

  Serial.print(can_wb.get_rx_dlc());
  
  unsigned char data_out[9];
  memset(data_out,0,9);
  can_wb.get_rx_data(data_out,8);
  data_out[can_wb.get_rx_dlc()] =0x00;
  Serial.print(" DATA =");
  for (unsigned int g =0 ; g < can_wb.get_rx_dlc(); g++){
    Serial.print(data_out[g],HEX);
  }
  Serial.println();
}
