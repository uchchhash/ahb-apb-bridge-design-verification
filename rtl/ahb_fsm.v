module ahb_fsm #(parameter DATA_WIDTH = 32, parameter AHB_FIFO_DEPTH = 16)
                
                (hclk, resetn, hsel, hwrite, haddr, 
                 htrans, hburst, hsize, hwdata, hready_o, hresp, hrdata,
                 
                 //wen//ren
                 ctrl_wen, ahb_data_wen,
                 apb_data_ren,
                 
                 //fifo_status
                 ctrl_full, ahb_data_full,
                 apb_data_empty,
                 
                 //fifo_space
                 ctrl_sp, ahb_data_sp,
                 
                 //fifo_wdata
                 ctrl_pipe, ahb_data_pipe,
                 
                 //fifo_rdata
                 apb_data_read
                );

    input wire hclk;
    input wire resetn;
    input wire hsel;
    input wire hwrite;
    input wire [31:0] haddr;
    input wire [1:0] htrans;
    input wire [2:0] hburst;
    input wire [2:0] hsize;
    input wire [DATA_WIDTH -1 :0] hwdata;
    
    output wire hready_o;
    output reg  hresp;
    output reg  [DATA_WIDTH -1 :0] hrdata;
    
    `include "define.sv"
    
    //Internal Signals
    
    output reg ctrl_wen;
    output reg ahb_data_wen;
    output reg apb_data_ren;
    
    input wire ctrl_full;
    input wire ahb_data_full;
    input wire apb_data_empty;
    
    //fifo space
    input wire [ $clog2(AHB_FIFO_DEPTH) :0] ctrl_sp;
    input wire [ $clog2(AHB_FIFO_DEPTH) :0] ahb_data_sp;
    
    //fifo_wdata
    output reg [40:0] ctrl_pipe;
    output reg [DATA_WIDTH -1 :0] ahb_data_pipe;
    
    //fifo_rdata
    input wire [DATA_WIDTH -1 :0] apb_data_read;
    
    reg [4:0] burst_count;
    wire Single_Addr_valid;
    wire BURST_Addr_valid;
    
    reg a_d_w;
    reg nseq_wait;
    wire [4:0] Initial_burst_count;
    
    reg  [3:0] pstate, nstate;
    
    //FSM States
    parameter [3:0] IDLE_STATE            = 4'b0000,
                    
                    //Write states
                    TRX_w_ad_STATE        = 4'b0001,
                    TRX_wait_w_ad_STATE   = 4'b0010,
                    TRX_w_data_STATE      = 4'b0011,
                    
                    //Read states
                    TRX_r_ad_STATE        = 4'b0100,
                    TRX_wait_r_ad_STATE   = 4'b0101,
                    
                    READ_valid_STATE      = 4'b0110,
                    READ_wait_valid_STATE = 4'b0111,
                    
                    //Nseq_wait state
                    NSEQ_wait_STATE       = 4'b1000;


    assign hready_o = (resetn && pstate == TRX_w_ad_STATE   && !ctrl_full )
                   || (resetn && pstate == TRX_w_ad_STATE   && hsel && !hwrite )
                   || (resetn && pstate == READ_valid_STATE && hsel)
                   || (resetn && pstate == IDLE_STATE       && hsel) ;
    
    
    assign Single_Addr_valid = resetn && hsel  && htrans == NSEQ && hburst == SINGLE ;
    
    assign BURST_Addr_valid  = resetn && hsel  && ( htrans == NSEQ || htrans == SEQ ) 
                                               &&   hburst != SINGLE && hburst != INCR ;
    
    //Initial_burst_count
    assign Initial_burst_count =  (hburst == INCR4  ? 4  :
                                   hburst == INCR8  ? 8  :
                                   hburst == INCR16 ? 16 :
                                   hburst == SINGLE ? 1  :
                                   hburst == WRAP4  ? 4  :
                                   hburst == WRAP8  ? 8  :
                                   hburst == WRAP16 ? 16 : 0 ) * (htrans == NSEQ ) * resetn * hsel ;


    always@(*)
        begin : NSL
            case(pstate)
                IDLE_STATE : begin //    ~~~~  ST 0  ~~~~
                             if (!Single_Addr_valid && !BURST_Addr_valid) begin
                                 nstate = IDLE_STATE; //0
                             end
                             
                             else begin
                                 if (hwrite) begin // Write Transfer
                                     if (ctrl_sp >= Initial_burst_count) begin
                                         nstate = TRX_w_ad_STATE; //1
                                     end
                                     else begin
                                         nstate = TRX_wait_w_ad_STATE; //2
                                     end
                                 end
                                 else begin // Read Transfer
                                     if (!ctrl_full) begin
                                         nstate = TRX_r_ad_STATE; //4
                                     end
                                     else begin
                                         nstate = TRX_wait_r_ad_STATE; //5
                                     end
                                 end
                             end
                end
                 
                TRX_w_ad_STATE : begin //    ~~~~  ST 1  ~~~~
                                 if (!Single_Addr_valid && !BURST_Addr_valid) begin
                                     nstate = TRX_w_data_STATE; //3
                                 end

                                 else begin
                                     if ( nseq_wait ) begin
                                         nstate = TRX_w_ad_STATE; //1
                                     end
                                    
                                     else begin
                                         if (htrans == SEQ ) begin
                                             nstate = TRX_w_ad_STATE; //1
                                         end
                                         else begin
                                             nstate = NSEQ_wait_STATE; //8
                                         end
                                     end
                                 end
                end
                
                TRX_wait_w_ad_STATE : begin //    ~~~~  ST 2  ~~~~
                                      if (ctrl_sp >= Initial_burst_count) begin
                                          nstate = TRX_w_ad_STATE; //1
                                      end
                                      else begin
                                          nstate = TRX_wait_w_ad_STATE; //2
                                      end
                end
                
                TRX_w_data_STATE : begin //    ~~~~  ST 3  ~~~~
                                   if (!Single_Addr_valid && !BURST_Addr_valid) begin
                                       nstate = IDLE_STATE; //0
                                   end
                                   else begin
                                       nstate = NSEQ_wait_STATE; //8
                                   end
                end
                
                TRX_r_ad_STATE : begin //    ~~~~  ST 4  ~~~~
                                 nstate = READ_wait_valid_STATE; //7
                end
                
                TRX_wait_r_ad_STATE : begin //    ~~~~  ST 5  ~~~~
                                      if ( !ctrl_full ) begin
                                          nstate = TRX_r_ad_STATE; //4
                                      end
                                      else begin
                                          nstate = TRX_wait_r_ad_STATE; //5
                                      end
                end
                
                READ_valid_STATE : begin //    ~~~~  ST 6  ~~~~
                                   if (!Single_Addr_valid && !BURST_Addr_valid) begin
                                       nstate = IDLE_STATE; //0
                                   end
                                   else begin
                                       if ( htrans == SEQ && !hwrite ) begin
                                           nstate = TRX_r_ad_STATE; //4
                                       end
                                       else begin
                                           nstate = NSEQ_wait_STATE; //8
                                       end
                                   end
                end
                
                READ_wait_valid_STATE : begin //    ~~~~  ST 7  ~~~~
                                        if (apb_data_empty) begin
                                            nstate = READ_wait_valid_STATE; //7
                                        end
                                        else begin
                                            nstate = READ_valid_STATE; //6
                                        end
                end
                
                NSEQ_wait_STATE : begin //    ~~~~  ST 8  ~~~~
                                  if ( nseq_wait ) begin
                                      if (hwrite) begin //Write_Transfer
                                          if (ctrl_sp >= Initial_burst_count) begin
                                              nstate = TRX_w_ad_STATE; //1
                                          end
                                          else begin
                                              nstate = TRX_wait_w_ad_STATE; //2
                                          end
                                      end
                                      else begin //Read_Transfer
                                          if (!ctrl_full && apb_data_empty) begin
                                              nstate = TRX_r_ad_STATE; //4
                                          end
                                          else begin
                                              nstate = TRX_wait_r_ad_STATE; //5
                                          end
                                      end
                                  end
                                  else begin
                                      nstate = NSEQ_wait_STATE; //8
                                  end
                end
            endcase
        end
      
            
            
    always @(posedge hclk or negedge resetn)
        begin : OL
            case (pstate)
                
            IDLE_STATE : begin //    ~~~~  ST 0  ~~~~
                hresp    <= 1'b0;
                hrdata   <= 32'hFACE_CAFE;

                burst_count <= 1'b0;
                ctrl_wen      <= 1'b0  ;
                ahb_data_wen  <= 1'b0  ;
                apb_data_ren  <= 1'b0  ;

                ctrl_pipe     <= 1'b0  ;
                ahb_data_pipe <= 32'b0 ;

                a_d_w         <= 1'b0  ;
                nseq_wait     <= 1;
            end

            TRX_w_ad_STATE : begin //    ~~~~  ST 1  ~~~~
                
                burst_count   <= ( htrans == NSEQ ) ? Initial_burst_count : burst_count-1;
                ctrl_wen      <= ( htrans == SEQ  ) ?  1 : ( htrans == NSEQ ) ? 1 : 0;
                ahb_data_wen  <= a_d_w ;
                apb_data_ren  <= 1'b0 ;
                
                ctrl_pipe     <= { hwrite, htrans, hburst, hsize, haddr } ;
                ahb_data_pipe <= a_d_w ? hwdata : ahb_data_pipe ;
                
                a_d_w         <= 1'b1  ;
                nseq_wait     <= 0;
            end

            TRX_wait_w_ad_STATE : begin //    ~~~~  ST 2  ~~~~

                burst_count <= burst_count;
                ctrl_wen      <= 1'b0 ;
                ahb_data_wen  <= a_d_w ;
                apb_data_ren  <= 1'b0 ;

                ctrl_pipe     <= ctrl_pipe ;
                ahb_data_pipe <= a_d_w ? hwdata : ahb_data_pipe ;

                a_d_w         <= 1'b0  ;
                nseq_wait     <= 0;
            end

            TRX_w_data_STATE : begin //    ~~~~  ST 3  ~~~~

                burst_count <= burst_count - 1;
                ctrl_wen      <= 1'b0 ;
                ahb_data_wen  <= a_d_w ;
                apb_data_ren  <= 1'b0 ;

                ctrl_pipe     <= ctrl_pipe ;
                ahb_data_pipe <= a_d_w ? hwdata : ahb_data_pipe ;
                
                a_d_w         <= 1'b0  ;
                nseq_wait     <= 0;
            end

            TRX_r_ad_STATE : begin //    ~~~~  ST 4  ~~~~

                burst_count <= htrans == NSEQ ? Initial_burst_count : htrans == SEQ ? burst_count-1 : burst_count ;
                ctrl_wen      <= 1 ;
                ahb_data_wen  <= a_d_w ;
                apb_data_ren  <= 0 ;

                ctrl_pipe     <= { hwrite, htrans, hburst, hsize, haddr } ;
                ahb_data_pipe <= a_d_w ? hwdata : ahb_data_pipe ;
                
                a_d_w         <= 1'b0  ;
                nseq_wait     <= 0;
            end

            TRX_wait_r_ad_STATE : begin //    ~~~~  ST 5  ~~~~

                burst_count <= burst_count ;
                ctrl_wen      <= 0 ;
                ahb_data_wen  <= a_d_w ;
                apb_data_ren  <= 0 ;

                ctrl_pipe     <= ctrl_pipe ;
                ahb_data_pipe <= a_d_w ? hwdata : ahb_data_pipe ;

                a_d_w         <= 1'b0  ;
                nseq_wait     <= 1;
            end

            READ_valid_STATE : begin //    ~~~~  ST 6  ~~~~

                hrdata   <= apb_data_read ;

                burst_count <= burst_count ;
                ctrl_wen      <= 0 ;
                ahb_data_wen  <= a_d_w ;
                apb_data_ren  <= 1 ;

                ctrl_pipe <= { hwrite, htrans, hburst, hsize, haddr };
                ahb_data_pipe <= a_d_w ? hwdata : ahb_data_pipe ;

                a_d_w         <= 1'b0  ;    
            end

            READ_wait_valid_STATE : begin //    ~~~~  ST 7  ~~~~

                burst_count <= burst_count ;
                ctrl_wen      <= 0 ;
                ahb_data_wen  <= a_d_w ;
                apb_data_ren  <= 0 ;

                ctrl_pipe     <= ctrl_pipe ;
                ahb_data_pipe <= a_d_w ? hwdata : ahb_data_pipe ;
                ahb_data_pipe <= ahb_data_pipe ;

                a_d_w         <= 1'b0  ;
            end

            NSEQ_wait_STATE : begin //    ~~~~  ST 8  ~~~~

                burst_count <= ( htrans == NSEQ ) ? Initial_burst_count : burst_count-1;  
                ctrl_wen      <= 1'b0 ;
                ahb_data_wen  <= a_d_w ;
                apb_data_ren  <= 1'b0 ;
                
                ctrl_pipe     <= ctrl_pipe ;
                ahb_data_pipe <= a_d_w ? hwdata : ahb_data_pipe ;

                a_d_w         <= 1'b0  ;
                nseq_wait     <= a_d_w ? nseq_wait : 1 ;
            end
            endcase
        end
    
    always @(posedge hclk or negedge resetn)
    begin
        if (!resetn) begin
            pstate = IDLE_STATE;
        end
        
        else
            pstate = nstate;
    end

endmodule

