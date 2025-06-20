module apb_fsm #(parameter DATA_WIDTH = 32)
                (pclk, resetn, psel, paddr, pwrite, pwdata, prdata, penable, pready,
                 
                 //fifo_wen//ren
                 ctrl_ren,
                 ahb_data_ren,
                 apb_data_wen,
                 
                 //fifo_status
                 apb_data_full,
                 ctrl_empty,
                 ahb_data_empty,
                 
                 //fifo_wdata
                 prdata_flop,
                 
                 //fifo_rdata
                 ctrl_read, ahb_data_read                
                 
                );


    input  pclk;
    input  resetn;
    
    output logic       psel;
    output logic       pwrite;
    output logic [31:0]             paddr;
    output logic [DATA_WIDTH -1 :0] pwdata;
    input        [DATA_WIDTH -1 :0] prdata;
    output logic                    penable;
    input                           pready;
    
    output logic ctrl_ren;
    output logic ahb_data_ren;
    output logic apb_data_wen;

    input apb_data_full;
    input ctrl_empty;
    input ahb_data_empty;

    //fifo_wdata
    output logic [DATA_WIDTH -1 :0] prdata_flop;

    //fifo_rdata
    input [40:0] ctrl_read;
    input [DATA_WIDTH -1 :0] ahb_data_read;
    
    
    logic [2:0] pstate, nstate;
    
    parameter [2:0] IDLE_STATE            = 3'b000,
                    SETUP_w_STATE         = 3'b001,
                    ENABLE_w_STATE        = 3'b010,
                    
                    SETUP_r_STATE         = 3'b011,
                    ENABLE_r_STATE        = 3'b100,
                    
                    PRDATA_VALID_STATE    = 3'b101;
    
    
    always@(*) begin
        case(pstate)
            IDLE_STATE : begin //    ~~~~  ST 0  ~~~~
                         if (!ctrl_empty ) begin
                             if(ctrl_read[40]) begin // Write Transfer
                                 if (!ahb_data_empty)
                                     nstate = SETUP_w_STATE; //1
                                 else begin
                                     nstate = IDLE_STATE; //0
                                 end
                             end
                             else begin  // Read Transfer
                                 nstate = SETUP_r_STATE; //3
                             end
                         end
                         else begin
                             nstate = IDLE_STATE; //0
                         end
            end
            
            SETUP_w_STATE : begin //    ~~~~  ST 1  ~~~~
                nstate = ENABLE_w_STATE; //2
            end
            
            ENABLE_w_STATE : begin //    ~~~~  ST 2  ~~~~
                             if (!pready) begin
                                 nstate = ENABLE_w_STATE; //2
                             end
                             else begin
                                 if (!ctrl_empty ) begin
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
            
            SETUP_r_STATE : begin //    ~~~~  ST 3  ~~~~
                nstate = ENABLE_r_STATE; //4
            end
            
            ENABLE_r_STATE : begin //    ~~~~  ST 4  ~~~~
                             if (!pready) begin
                                 nstate = ENABLE_r_STATE; //4
                             end
                             else begin
                                 nstate = PRDATA_VALID_STATE; //5
                             end
            end
            
            PRDATA_VALID_STATE : begin //    ~~~~  ST 5  ~~~~
                                 nstate = IDLE_STATE; //0
            end
        endcase
    end

    always @(posedge pclk or negedge resetn) begin
        case (pstate)
            
            IDLE_STATE : begin //    ~~~~  ST 0  ~~~~
            
                psel         <= 1'b0  ;
                paddr        <= 32'b0 ;
                pwrite       <= 1'b0  ;
                pwdata       <= 32'b0 ;

                penable      <= 1'b0  ;

                ctrl_ren     <= 1'b0  ;
                ahb_data_ren <= 1'b0  ;
                apb_data_wen <= 1'b0  ;
                prdata_flop  <= 32'b0 ;

            end
            
            SETUP_w_STATE : begin //    ~~~~  ST 1  ~~~~

                psel         <= 1'b1  ;
                paddr        <= ctrl_read[31:2] ;
                pwrite       <= 1'b1  ;
                pwdata       <= ahb_data_read ;

                penable      <= 1'b0  ;

                ctrl_ren     <= 1'b1  ;
                ahb_data_ren <= 1'b1  ;
                apb_data_wen <= 1'b0  ;
                prdata_flop  <= 32'b0 ;

            end
            
            ENABLE_w_STATE : begin //    ~~~~  ST 2  ~~~~
              
                penable      <= 1'b1  ;

                ctrl_ren     <= 1'b0  ;
                ahb_data_ren <= 1'b0  ;
                apb_data_wen <= 1'b0  ;
                prdata_flop  <= 32'b0 ;
              
            end
            
            SETUP_r_STATE : begin //    ~~~~  ST 3  ~~~~

                psel         <= 1'b1  ;
                paddr        <= ctrl_read[31:2] ;
                pwrite       <= 1'b0  ;

                penable      <= 1'b0  ;

                ctrl_ren     <= 1'b1  ;
                ahb_data_ren <= 1'b0  ;
                apb_data_wen <= 1'b0  ;
                prdata_flop  <= 32'b0 ;

            end
            
            ENABLE_r_STATE : begin //    ~~~~  ST 4  ~~~~
              
                penable      <= 1'b1  ;

                ctrl_ren     <= 1'b0  ;
                ahb_data_ren <= 1'b0  ;
                apb_data_wen <= 1'b0  ;
                prdata_flop  <= 32'b0 ;
              
            end
          
            PRDATA_VALID_STATE : begin //    ~~~~  ST 5  ~~~~

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

