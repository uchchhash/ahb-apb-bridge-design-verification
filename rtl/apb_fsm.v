module apb_fsm #(parameter DATA_WIDTH = 32)
                (pclk,
                 resetn,
                 psel,
                 paddr,
                 pwrite,
                 pwdata,
                 prdata,
                 penable,
                 pready,
                 //pstrb_o,//pstrb implementation
                 
                 ctrl_ren,
                 ahb_data_ren,
                 
                 apb_data_wen,
                 
                 apb_data_full,
                 
                 ctrl_empty,
                 ahb_data_empty,
                 
                 //wdata
                 prdata_flop,
                 
                 //rdata
                 ctrl_read,
                 ahb_data_read                
                 
                );

    `include "define.sv"
    
    input wire pclk;
    input wire resetn;
    output reg psel;
    output reg [31:0] paddr;
    output reg pwrite;
    output reg [DATA_WIDTH -1 :0] pwdata;
    input wire [DATA_WIDTH -1 :0] prdata;
    output reg penable;
    input wire pready;
    //output reg [3:0] pstrb_o;//pstrb implementation
    
    output reg ctrl_ren;
    output reg ahb_data_ren;

    output reg apb_data_wen;

    input wire apb_data_full;

    input wire ctrl_empty;
    input wire ahb_data_empty;

    //wdata
    output reg [DATA_WIDTH -1 :0] prdata_flop;

    //rdata
    input wire [40:0] ctrl_read;
    input wire [DATA_WIDTH -1 :0] ahb_data_read;
    
    
    reg [2:0] pstate, nstate;
    
    parameter [2:0] IDLE_STATE            = 3'b000, //0
                    SETUP_w_STATE         = 3'b001, //1
                    ENABLE_w_STATE        = 3'b010, //2
                    
                    SETUP_r_STATE         = 3'b011, //3
                    ENABLE_r_STATE        = 3'b100, //4
                    
                    PRDATA_VALID_STATE    = 3'b101; //5
                    
                    //READ_INCOMPLETE_STATE = 3'b110; //6
     
    
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%%%%%%  Pstrb  %%%%%%%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //pstrb implementation
    /*
      wire [3:0] pstrb;
      wire [31:0] rem4;
      wire [31:0] addr = ctrl_read[31:0];
      
      assign rem4  = addr % 4;
  
      assign  pstrb [3:0]  = ctrl_read [34:32] == WORD ? 4'b1111 : 
                 
                             ctrl_read [34:32] == HALF_WORD && rem4 ==0 ? 4'b0011 : 
                             ctrl_read [34:32] == HALF_WORD && rem4 ==2 ? 4'b1100 :
                  
                             ctrl_read [34:32] == BYTE && rem4 ==0 ? 4'b0001 :
                             ctrl_read [34:32] == BYTE && rem4 ==1 ? 4'b0010 :
                             ctrl_read [34:32] == BYTE && rem4 ==2 ? 4'b0100 :
                             ctrl_read [34:32] == BYTE && rem4 ==3 ? 4'b1000 :
                     
                             4'b0000; 
    
                     
                     // ctrl_ren [34:32] :: hsize
                     // ctrl_ren [31:0] :: haddr
    */
    
    
    always@(*) begin
        case(pstate)
        
            // ~~~~~~  0  ~~~~~~
            IDLE_STATE : begin
                         if (!ctrl_empty ) begin //  && (ctrl_read[39:38] == NSEQ || ctrl_read[39:38] == SEQ)
                         
                             if(ctrl_read[40]) begin // write transfer
                                 if (!ahb_data_empty)
                                     nstate = SETUP_w_STATE; //1
                                 else begin
                                     nstate = IDLE_STATE; //0
                                 end
                             end
                             else begin
                                 nstate = SETUP_r_STATE; //3
                             end
                         end
                         
                         else begin
                             nstate = IDLE_STATE; //0
                         end
                         
                         
            end
            // ~~~~~~  1  ~~~~~~
            SETUP_w_STATE : nstate = ENABLE_w_STATE; //2
            
            // ~~~~~~  2  ~~~~~~
            ENABLE_w_STATE : begin
                             if (!pready) begin
                                 nstate = ENABLE_w_STATE; //2
                             end
                             else begin
                                 if (!ctrl_empty ) begin //  && (ctrl_read[39:38] == NSEQ || ctrl_read[39:38] == SEQ)
                                     if(ctrl_read[40]) begin
                                         if (!ahb_data_empty)
                                             nstate = SETUP_w_STATE; //1
                                         else begin
                                             nstate = IDLE_STATE; //0
                                         end
                                     end
                                     else begin
                                         nstate = SETUP_r_STATE; //3
                                     end
                                 end
                                 
                                 else begin
                                     nstate = IDLE_STATE; //0
                                 end
                             end
                             
            end
            
            // ~~~~~~  3  ~~~~~~
            SETUP_r_STATE : nstate = ENABLE_r_STATE; //4
            
            // ~~~~~~  4  ~~~~~~
            ENABLE_r_STATE : begin
                             if (!pready) begin
                                 nstate = ENABLE_r_STATE; //4
                             end
                             else begin
                                 nstate = PRDATA_VALID_STATE; //5
                             end
            end
            
            
            
            // ~~~~~~  5  ~~~~~~
            PRDATA_VALID_STATE : begin
            
                                 nstate = IDLE_STATE; //0
                                 
                                 /*
                                 if (apb_data_full) begin
                                     nstate = READ_INCOMPLETE_STATE; //6
                                 end
                                 else begin
                                 */ 
                                     /*
                                     if (!ctrl_empty ) begin // && (ctrl_read[39:38] == NSEQ || ctrl_read[39:38] == SEQ)
                                         if(ctrl_read[40]) begin
                                             if (!ahb_data_empty)
                                                 nstate = SETUP_w_STATE; //1
                                             else begin
                                                 nstate = IDLE_STATE; //0
                                             end
                                         end
                                         else begin
                                             nstate = SETUP_r_STATE; //3
                                         end
                                     end
                                 
                                     else begin
                                         nstate = IDLE_STATE; //0
                                     end
                                     */
                                     
                                 //end
            end
            /*
            // ~~~~~~  6  ~~~~~~
            READ_INCOMPLETE_STATE : begin
                                    if (apb_data_full) begin
                                        nstate = READ_INCOMPLETE_STATE; //6
                                    end
                                    else begin
                                        if (!ctrl_empty ) begin // && (ctrl_read[39:38] == NSEQ || ctrl_read[39:38] == SEQ)
                                            if(ctrl_read[40]) begin
                                                if (!ahb_data_empty)
                                                    nstate = SETUP_w_STATE; //1
                                                else begin
                                                    nstate = IDLE_STATE; //0
                                                end
                                            end
                                            else begin
                                                nstate = SETUP_r_STATE; //3
                                            end
                                        end
                                 
                                        else begin
                                            nstate = IDLE_STATE; //0
                                        end
                                        
                                    end
            end
            */
        endcase
    end

    always @(posedge pclk or negedge resetn) begin : OL
        case (pstate)
            // ~~~~~~  0  ~~~~~~
            IDLE_STATE : begin
            
                psel         <= 1'b0  ;
                paddr        <= 32'b0 ;
                pwrite       <= 1'b0  ;
                pwdata       <= 32'b0 ;

                penable      <= 1'b0  ;

                ctrl_ren     <= 1'b0  ;
                ahb_data_ren <= 1'b0  ;
                apb_data_wen <= 1'b0  ;
                prdata_flop  <= 32'b0 ;

                //pstrb_o    <= 4'b0  ;//pstrb implementation
              
            end
            
            // ~~~~~~  1  ~~~~~~
            SETUP_w_STATE : begin

                psel         <= 1'b1  ;
                paddr        <= ctrl_read[31:2] ;
                pwrite       <= 1'b1  ;
                pwdata       <= ahb_data_read ;

                penable      <= 1'b0  ;

                ctrl_ren     <= 1'b1  ;
                ahb_data_ren <= 1'b1  ;
                apb_data_wen <= 1'b0  ;
                prdata_flop  <= 32'b0 ;

                //pstrb_o      <= pstrb  ;//pstrb implementation

            end
            
            // ~~~~~~  2  ~~~~~~
            ENABLE_w_STATE : begin
              
                penable      <= 1'b1  ;

                ctrl_ren     <= 1'b0  ;
                ahb_data_ren <= 1'b0  ;
                apb_data_wen <= 1'b0  ;
                prdata_flop  <= 32'b0 ;
              
            end
            
            // ~~~~~~  3  ~~~~~~
            SETUP_r_STATE : begin

                psel         <= 1'b1  ;
                paddr        <= ctrl_read[31:2] ;
                pwrite       <= 1'b0  ;

                penable      <= 1'b0  ;

                ctrl_ren     <= 1'b1  ;
                ahb_data_ren <= 1'b0  ;
                apb_data_wen <= 1'b0  ;
                prdata_flop  <= 32'b0 ;
                //pstrb_o      <= 4'b0  ;//pstrb implementation

            end
            
            // ~~~~~~  4  ~~~~~~
            ENABLE_r_STATE : begin
              
                penable      <= 1'b1  ;

                ctrl_ren     <= 1'b0  ;
                ahb_data_ren <= 1'b0  ;
                apb_data_wen <= 1'b0  ;
                prdata_flop  <= 32'b0 ;
              
            end
          
            // ~~~~~~  5  ~~~~~~
            PRDATA_VALID_STATE : begin

                psel         <= 1'b0   ;
                paddr        <= 32'b0  ;
                pwrite       <= 1'b0   ;
                pwdata       <= 32'b0  ;

                penable      <= 1'b0   ;

                ctrl_ren     <= 1'b0   ;
                ahb_data_ren <= 1'b0   ;
                apb_data_wen <= 1'b1   ;
                prdata_flop  <= prdata ;

            end
            /*
            // ~~~~~~  6  ~~~~~~
            READ_INCOMPLETE_STATE : begin

                psel         <= 1'b0   ;
                paddr        <= 32'b0  ;
                pwrite       <= 1'b0   ;
                pwdata       <= 32'b0  ;

                penable      <= 1'b0   ;

                ctrl_ren     <= 1'b0   ;
                ahb_data_ren <= 1'b0   ;
                apb_data_wen <= 1'b0   ;
                prdata_flop  <= prdata_flop ;

            end
            */
        endcase
    end
    
    always @(posedge pclk or negedge resetn)
    begin
        if (!resetn) begin
            pstate = IDLE_STATE;
        end
        else
            pstate = nstate;
    end



endmodule

