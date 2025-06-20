/*
                      -----------
  //pstrb[3:0]   ===>|           |, pstrb implementation
    paddr[31:0]  ===>|           |
    pwdata[31:0] ===>|           |
    pwrite       --->|           |===> prdata[31:0] 
    psel         --->| APB SLAVE |
    penable      --->|           |---> pready
    pclk         --->|           |
    rst_n        --->|           |
                      -----------
*/
module apb_slave
#(
    parameter addrWidth = 32,
    parameter dataWidth = 32
)
(
    input wire                 pclk,
    input wire                 rst_n,
    input wire [addrWidth-1:0] paddr,
    input wire                 pwrite,
    input wire                 psel,
    input wire                 penable,
    input wire [dataWidth-1:0] pwdata,
    output reg [dataWidth-1:0] prdata,
    //~~Modified~~//
    //input                  [3:0] pstrb, pstrb implementation
    output reg                 pready
    
);
    //~~Modified~~//
    integer i;
    parameter memSize = 256;
    reg [dataWidth-1:0] mem [0 : memSize-1];
    
    //logic [1:0] apb_st;
    //~~Modified~~//
    reg [1:0] apb_st;
    
    //const logic [1:0] SETUP = 0;
    //const logic [1:0] W_ENABLE = 1;
    //const logic [1:0] R_ENABLE = 2;
    
    parameter [1:0] SETUP = 0,
                    W_ENABLE = 1,
                    R_ENABLE = 2;
    
    // SETUP -> ENABLE
    always @(negedge rst_n or posedge pclk) begin
        if (rst_n == 0) begin
            
            apb_st <= 0;
            prdata <= 32'hFEDC_BA98;
            pready <= 0;
            //~~Modified~~//
            // Initialize memory array
            /*
            for (i=0; i<memSize; i =i+1) begin
                mem[i] <= 32'h0000_0000;
            end
            */
            
            mem [0:memSize-1] <= '{default:0};
            
            
            
        end   
        else begin
            case (apb_st)
                SETUP    :  begin
                                // clear the prdata
                                prdata <= 32'hFEDC_BA98;
                                pready <= 0;
    
                                // Move to ENABLE when the psel is asserted
                                if (psel && !penable) begin
                                    if (pwrite) begin
                                        apb_st <= W_ENABLE;
                                    end
                                    else begin
                                        apb_st <= R_ENABLE;
                                    end
                                end
                            end
    
                W_ENABLE :  begin
                                // write pwdata to memory
                                if (psel && penable && pwrite) begin
                                    //~~Modified~~// ~~ pstrb implementation
                                    /*
                                    if (pstrb[0])
                                        mem[paddr][7:0]   <= pwdata[7:0];
                                    if (pstrb[1])
                                        mem[paddr][15:8]  <= pwdata[15:8];
                                    if (pstrb[2])
                                        mem[paddr][23:16] <= pwdata[23:16];
                                    if (pstrb[3])
                                        mem[paddr][31:24] <= pwdata[31:24];
                                    */
                                    
                                    //Original
                                    mem[paddr] <= pwdata;
                                    
                                    pready <= 1;
                                end
    
                                // return to SETUP
                                apb_st <= SETUP;
                            end
    
                R_ENABLE :  begin
                                // read prdata from memory
                                if (psel && penable && !pwrite) begin
                                    prdata <= mem[paddr];
                                    pready <= 1;
                                end
    
                                // return to SETUP
                                apb_st <= SETUP;
                            end
            endcase
        end
    end 
endmodule


