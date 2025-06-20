/*
                      -----------
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
    input                        pclk,
    input                        rst_n,
    input        [addrWidth-1:0] paddr,
    input                        pwrite,
    input                        psel,
    input                        penable,
    input        [dataWidth-1:0] pwdata,
    output logic [dataWidth-1:0] prdata,
    output logic                 pready
    
);

    parameter memSize = 256;
    reg [dataWidth-1:0] mem [0 : memSize-1];
    
    logic [1:0] apb_st;
    
    const logic [1:0] SETUP = 0;
    const logic [1:0] W_ENABLE = 1;
    const logic [1:0] R_ENABLE = 2;
    
    
    // SETUP -> ENABLE
    always @(negedge rst_n or posedge pclk) begin
        if (rst_n == 0) begin
            apb_st <= 0;
            prdata <= 32'hFEDC_BA98;
            pready <= 0;
            //Modified
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
                                    mem[paddr] <= pwdata;
                                    pready     <= 1;
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




