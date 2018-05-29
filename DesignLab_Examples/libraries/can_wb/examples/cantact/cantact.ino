#include <can_wb.h>

/*
 * based on ... 
 https://github.com/linklayer/pyvit/blob/master/pyvit/hw/cantact.py (in turn based on the documentation found here)
 http://www.can232.com/docs/canusb_manual.pdf \o/
 */

#include "can_wb.h"

#define circuit can_wb

can_wb can_wb;

#define MAX_MSG_SIZE 64

#define FIFO_SIZE 3

//#define DEBUG 1

struct can_frame{
  unsigned int iii;
  unsigned int dlc;
  unsigned int rtr;
  unsigned char  data[8];
} can_frame;

struct can_fifo {
  unsigned int size;
  unsigned int index;
  unsigned int count ;
  struct can_frame frames[FIFO_SIZE];
} can_fifo;

struct can_fifo send_buffer;
struct can_fifo receive_buffer;

void can_fifo_init(struct can_fifo *cff){
  cff->size  =FIFO_SIZE;
  cff->index =0;
  cff->count =0;
  for (int x =0 ; x < 3 ; x++){
    cff->frames[x].iii = 0;
    cff->frames[x].dlc = 0;
    cff->frames[x].rtr = 0;
    memset(cff->frames[x].data,0,8);
  }
};

int can_fifo_add(
  struct can_fifo *cff,
  unsigned long iii,
  unsigned long rtr,
  unsigned long dlc,
  unsigned char *data)
{
  if (cff->count ==cff->size){
    return -1; //fifo full
  }

  //cff->index points to the next item hence we can "fill it"
  struct can_frame * fr = &cff->frames[cff->index];
  fr->iii = iii;
  fr->rtr = rtr;
  fr->dlc = dlc;

  memset(fr->data,0,8);
  memcpy(fr->data,data,dlc);

  //determine next index to fill and increase count
  cff->index = (cff->index +1 ) % cff->size;
  cff->count++;
  return 0;
};

unsigned char ser_buf[MAX_MSG_SIZE];
unsigned int ser_buf_idx =0; 
int char_read;


void clean_buf(){
  ser_buf_idx =0;
  memset(ser_buf,0,MAX_MSG_SIZE);
}

void setup() {
  Serial.begin(115200);
  can_wb.setup(5);
  can_wb.set_config(0);
  clean_buf();
  can_fifo_init(&send_buffer);
  can_fifo_init(&receive_buffer);
}


void send_error(char *text=NULL){
#ifdef DEBUG
    Serial.print("DE:");
    if (text){
     Serial.print(text);
     Serial.write('\r');
   }
#endif
   Serial.write('\b');
}

int speed_table[9] = 
{
  10000,//  10 Kbit
  20000,//  20 Kbit
  50000,//  50 Kbit
  100000,// 100 Kbit
  125000,// 125 Kbit
  250000,// 250 Kbit
  500000,// 500 Kbit
  800000,// 800 Kbit
 1000000//    1 Mbit
};

int cmd_V(){
  Serial.print("V1337\r");
  return 0;
}

int cmd_N(){
  Serial.print("N1111\r");
  return 0;
}

int cmd_S(){
  if (ser_buf_idx != 3){
    send_error("S paramemter missing");
    return -1;
  }
  if (ser_buf[1] < '0' || ser_buf[1] > '8'){
    send_error("S invalid parameter value betweeb 0 and 8 inclusive expected");
    return -1;
  }

  int speed_index = ser_buf[1]- '0';
  //lookup speed  
  unsigned long speed = speed_table[speed_index];
  //we only need one for now..
  can_wb.set_sample_rate(1908);
  //TODO SET sample rate here
#ifdef DEBUG
  Serial.print("DS:OK: Speed=");
  Serial.print(speed);
  Serial.write('\r');
#endif
  Serial.write('\r');

  return 0;
}

int is_hex(char x){
  if (x >='0' && x <= '9'){
    return 1;
  }
  if(x >= 'A' &&  x<= 'F') {
    return 1;
  }
  if (x >= 'a' && x <= 'f') {
    return 1;
  }
  return 0;
}

unsigned long hex2long(unsigned char *input,int len){
  if (len > 9){
    Serial.print("Dhex:WARNING.. invalid conversion\r");
  }
  char data[10];
  memcpy(data,input,len);
  data[len+1] = '\0';
  return strtol(data,NULL,16);
}

int cmd_O(){
  if (ser_buf_idx != 2){
    send_error("E No paraneters expected");
    return -1;
  }
  can_wb.set_rx_drr(); //allow to get an initial message
#ifdef DEBUG
  Serial.print("D:O OK: Open channel\r");
#endif
  return 0;
}

int cmd_C(){
  if (ser_buf_idx != 2){
    send_error("C:No paraneters expected");
    return -1;
  }
  Serial.print("D:OK: Close channel\r");
  return 0;
}

int cmd_F(){// Status
  if (ser_buf_idx != 2){
    send_error("F:No paraneters expected");
    return -1;
  }

  unsigned long status = can_wb.get_status();
  //yea all is fine no problems

  Serial.print("F00\r");
  return 0;
}

int cmd_t(){//tiiildd...

  unsigned char data[8];
  memset(data,0,8);
  if (ser_buf_idx < 6){//"tiiid\r" minimum
    send_error("t: paramemter missing");
    return -1;
  }

  if (ser_buf[4] < '0' || ser_buf[4] > '8'){
    send_error("t: invalid size parameter");
    return -1;
  }

  unsigned int dlc = ser_buf[4] - '0';
  if (dlc * 2 + 6 != ser_buf_idx){
    send_error("t: size mismatch between dlc value and values given");
#ifdef DEBUG
    Serial.write("D: DLC ");
    Serial.write(String(dlc,HEX));
    Serial.write(" Buff size ");
    Serial.write(String(ser_buf_idx,HEX));
    Serial.write(" Buff ");
    Serial.write(ser_buf,ser_buf_idx-1);
    Serial.write('\r');
#endif
    return -1;
  }

  if (! (is_hex(ser_buf[1]) && is_hex(ser_buf[2]) && is_hex(ser_buf[3]))){
    send_error("t: iii are not hex");
    return -1;
  }

  unsigned long int id = hex2long(&ser_buf[1],3);

  if (id > 0x7ff){
    send_error("ID should be smaller than 0x7ff");
    return -1;
  }

  for (int x = 0 ; x < dlc ; x++){
    if ( ! (is_hex(ser_buf[2 * x + 5]) && is_hex(ser_buf[2 * x + 6]))){
      send_error("t: data not hex formatted");
      return -1;
    }
    data[x] = hex2long(&ser_buf[2 * x + 5],2);
  }
  if (can_fifo_add(&send_buffer,id,0/*rtr*/,dlc,data) ==0){
#ifdef DEBUG
    Serial.print("D:OK: transmit\r");
#endif
  } else {
    send_error("t: send buffer full???");
    return -1;
  }
  return 0;
}


int cmd_inval(){
  send_error("Invalid command sent");
  return -1;
}

void get_from_serial(){
  int serial_count =0 ;
  //try reading from serial but do not overdo it.
  while(Serial.available() && serial_count < 16 ){
    serial_count++;
    char_read = Serial.read();
    
    if (char_read == -1){
      //we need to clear the buffer/ start over again hence.. 
      send_error("READ : EOF");
      clean_buf();
      break;
    }
    
    if ( ser_buf_idx < MAX_MSG_SIZE ){//63 is still fine no problem
      ser_buf[ser_buf_idx] = (char)char_read;
      ser_buf_idx++;
      
      int retval =0;
      if ( (char)char_read == '\r'){//all command end with a newline            
        switch(ser_buf[0]){

          case 'V': retval = cmd_V(); break;// version
          case 'N': retval = cmd_N(); break;// serial number            
          case 'S': retval = cmd_S(); break;// speed
          case 'O': retval = cmd_O(); break;// opwn channel
          case 'C': retval = cmd_O(); break;// close channel
          case 't': retval = cmd_t(); break;// transmit 11 bit can message
          case 'F': retval = cmd_F(); break;// status
          default: retval = cmd_inval(); break;                
          }
        ser_buf_idx = 0;
        memset(ser_buf,0,MAX_MSG_SIZE);
        break; // out of the while loop so we only handle a single command at the time
      }
    }
  }
}

void send_to_can(){
  if (send_buffer.count >0){
    //send one message
    if( (can_wb.get_status() & CAN_STATUS_TX_BUSY) == 0){//in idle mode


        //given fifo index, count and size determine... top item in the fifo
        //the start of the fifo = fifo_index - count (but modulo)

        //modulo -1
        send_buffer.index = (send_buffer.index + send_buffer.size -1) % send_buffer.size;
        send_buffer.count--;
        struct can_frame * fr = &send_buffer.frames[send_buffer.index];
        can_wb.set_tx_id(fr->iii << 21);
        can_wb.set_tx_dlc(fr->dlc); 
        can_wb.set_tx_data(fr->data,8);
        can_wb.set_tx_valid(); //starts sending the packet
#ifdef DEBUG
        Serial.print("D: APP->CAN SEND ID 0x");
        Serial.print(fr->iii << 21 | ((fr->rtr >0)?0x1:0x0),HEX);
        Serial.print(" DLC ");
        Serial.print(fr->dlc);
        Serial.write('\r');
#endif        

    }
  }  
}

void get_from_can(){
  if (receive_buffer.count ==receive_buffer.size){
    return ; //fifo full
  }
  if (can_wb.get_status() & CAN_STATUS_RX_BUSY == CAN_STATUS_RX_BUSY){
    return ;//busy
  }
  if( (can_wb.get_status() &CAN_STATUS_RX_CRC_ERROR) == CAN_STATUS_RX_CRC_ERROR){


//    Serial.print("D: RX CRC ERROR, reseting\r");

    //Still read data to see what is going on
    unsigned char data[8];
    memset(data,0,8);
    can_wb.get_rx_data(data,can_wb.get_rx_dlc());


  //  can_fifo_add(&receive_buffer,can_wb.get_rx_id() >> 21,0,can_wb.get_rx_dlc(),data);

    can_wb.set_rx_drr();
  }
  if( (can_wb.get_status() &CAN_STATUS_RX_DATA_READY) == CAN_STATUS_RX_DATA_READY){ // some data is ready!
#ifdef DEBUG
    Serial.print("D: Added message status=");
    Serial.print(can_wb.get_status(),HEX);
    Serial.print(" COUNT=");
    Serial.print(receive_buffer.count);
    Serial.print("\r");
#endif
    unsigned char data[8];
    memset(data,0,8);
    can_wb.get_rx_data(data,can_wb.get_rx_dlc());
    can_fifo_add(&receive_buffer,can_wb.get_rx_id() >> 21,0,can_wb.get_rx_dlc(),data);
    // ready for the next packet
     can_wb.set_rx_drr();
     
  }
}

unsigned char nibble2char(unsigned char nibble){
  nibble &= 0x0f; //only take the lower value
  if (nibble < 0xa){
    return '0' + nibble;
  }
  return 'a' - 0xa + nibble;
}

void send_to_serial(){
  if (receive_buffer.count  == 0 ){
    return;
  }

  //modulo -1
  receive_buffer.index = (receive_buffer.index + receive_buffer.size -1) % receive_buffer.size;
  receive_buffer.count--;

  struct can_frame * fr = &receive_buffer.frames[receive_buffer.index];
  unsigned char data[21]  ; //tiii0011223344556677
  memset(data,0,21);


  unsigned long id = fr->iii ;
  data[0] = 't';
  data[1] = nibble2char(id >> 8);
  data[2] = nibble2char(id >> 4);
  data[3] = nibble2char(id);
  data[4] = nibble2char(fr->dlc);
  for (int x =0 ; x < fr->dlc ; x++ ){
      data[5 + (x * 2)] = nibble2char(fr->data[x] >> 4);
      data[5 + 1 + (x * 2)] =  nibble2char(fr->data[x]);
  }
#ifdef DEBUG
      Serial.print("D: APP->SER count=");
      Serial.print(receive_buffer.count,HEX);
      Serial.print(" ID=");
      Serial.print(fr->iii,HEX);
      Serial.print(" DLC=");
      Serial.print(fr->dlc,HEX);      
      Serial.print(" DATA ");
        Serial.write(data,5 + (fr->dlc *2) );
      Serial.write('\r');
#endif  
  Serial.write(data,5 + (fr->dlc *2) );
  Serial.print('\r');
}

void loop() {  
  get_from_can();
  send_to_serial();
  get_from_serial();
  send_to_can();
  delay(10);
}
