parameter HIGH =    1'b1; 
parameter LOW =     1'b0;

// Read or write type 
parameter READ = 1'b0; 
parameter WRITE = 1'b1; 

//Htrans

parameter IDLE = 2'b00;
parameter BUSY = 2'b01;
parameter NSEQ = 2'b10;

parameter NONSEQ    =    2'h2;

parameter SEQ  = 2'b11;





//Hburst
parameter SINGLE = 3'b000;
parameter INCR   = 3'b001;
parameter WRAP4  = 3'b010;
parameter INCR4  = 3'b011;
parameter WRAP8  = 3'b100;
parameter INCR8  = 3'b101;
parameter WRAP16 = 3'b110;
parameter INCR16 = 3'b111;


//HSIZE
parameter BYTE           = 3'b000;
parameter HALF_WORD      = 3'b001;
parameter WORD           = 3'b010;
parameter SIZE_2_WORD    = 3'b011;
parameter SIZE_4_WORD    = 3'b100;
parameter SIZE_8_WORD    = 3'b101;
parameter SIZE_16_WORD   = 3'b110;
parameter SIZE_32_WORD   = 3'b111;


// Slave Responses 
parameter  OKAY      =    2'h0; 
parameter  ERROR     =    2'h1; 
parameter  RETRY     =    2'h2; 
parameter  SPLIT     =    2'h3; 

// Transfer Size 
parameter  BUS_8     =    3'h0; 
parameter  BUS_16    =    3'h1; 
parameter  BUS_32    =    3'h2; 
parameter  BUS_64    =    3'h3; 
parameter  BUS_128   =    3'h4; 
parameter  BUS_256   =    3'h5; 
parameter  BUS_512   =    3'h6; 
parameter  BUS_1024  =    3'h7;




// Transfer Pattern
parameter  IDLE_W    =    'h0; 
parameter  SIN_W     =    'h1;
parameter  I4_W      =    'h2;
parameter  I8_W      =    'h3;
parameter  I16_W     =    'h4;



parameter  SIN_R     =    'h5;
parameter  I4_R      =    'h6;
parameter  I8_R      =    'h7;
parameter  I16_R     =    'h8;



