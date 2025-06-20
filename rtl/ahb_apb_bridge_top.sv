module ahb_apb_bridge_top  #(parameter DATA_WIDTH = 32,
                             parameter AHB_FIFO_DEPTH = 16,
                             parameter APB_FIFO_DEPTH = 2 )
                            (hclk, resetn, hsel, haddr, htrans, hwrite, 
                             hburst, hsize, hwdata, hready_o, hresp, hrdata,

                             pclk, psel, paddr, pwrite, pwdata, prdata, penable, pready 
                            );

    input  wire hclk;
    input  wire resetn;
    input  wire hsel;
    input  wire hwrite;
    input  wire [31:0] haddr;
    input  wire [1:0 ] htrans;
    input  wire [2:0 ] hburst;
    input  wire [2:0 ] hsize;
    input  wire [DATA_WIDTH -1 :0] hwdata;
    output wire hready_o;
    output wire hresp;
    output wire [DATA_WIDTH -1 :0] hrdata;

    input  wire pclk;
    output wire psel;
    output wire [31:0] paddr;
    output wire pwrite;
    output wire [DATA_WIDTH -1 :0] pwdata;
    input  wire [DATA_WIDTH -1 :0] prdata;
    output wire penable;
    input  wire pready;
  

    // Internal Signals //

    // CTRL FIFO
    wire ctrl_wen;
    wire ctrl_ren;
    wire [DATA_WIDTH -1 +9 :0] ctrl_flop;
    wire [DATA_WIDTH -1 +9 :0] ctrl_read;
    wire ctrl_full;
    wire ctrl_empty;
    
    wire [ $clog2(AHB_FIFO_DEPTH) : 0 ] ctrl_sp;

    
    // AHB DATA FIFO
    wire ahb_data_wen;
    wire ahb_data_ren;
    wire [DATA_WIDTH -1 :0] ahb_data_flop;
    wire [DATA_WIDTH -1 :0] ahb_data_read;
    wire ahb_data_full;
    wire ahb_data_empty;
    
    wire [ $clog2(AHB_FIFO_DEPTH) : 0 ] ahb_data_sp;

    
    // APB DATA FIFO
    wire apb_data_wen;
    wire apb_data_ren;
    wire [DATA_WIDTH -1 :0] prdata_flop;
    wire [DATA_WIDTH -1 :0] apb_data_read;
    wire apb_data_full;
    wire apb_data_empty;
    
    wire [ $clog2(APB_FIFO_DEPTH) : 0 ] apb_data_sp;
    
    
    ahb_fsm #(.DATA_WIDTH(DATA_WIDTH),
              .AHB_FIFO_DEPTH(AHB_FIFO_DEPTH))
         ahb (.hclk    ( hclk     ),
              .resetn  ( resetn   ),
              .hsel    ( hsel     ),
              .hwrite  ( hwrite   ),
              .haddr   ( haddr    ),
              .htrans  ( htrans   ),
              .hburst  ( hburst   ),
              .hsize   ( hsize    ),
              .hwdata  ( hwdata   ),
              .hready_o( hready_o ),
              .hresp   ( hresp    ),
              .hrdata  ( hrdata   ),

              .ctrl_wen       (ctrl_wen        ),
              .ahb_data_wen   (ahb_data_wen    ),
              .apb_data_ren   (apb_data_ren    ),

              .ctrl_full      ( ctrl_full      ),
              .ahb_data_full  ( ahb_data_full  ),
              .apb_data_empty ( apb_data_empty ),
             
              //fifo space
              .ctrl_sp        ( ctrl_sp        ),
              .ahb_data_sp    ( ahb_data_sp    ),
             
              //fifo_wdata
              .ctrl_flop      ( ctrl_flop      ),
              .ahb_data_flop  ( ahb_data_flop  ),
             
              //fifo_rdata
              .apb_data_read  ( apb_data_read  )
             );
                
                
    apb_fsm #(.DATA_WIDTH(DATA_WIDTH))
           apb (.pclk    ( pclk    ),
                .resetn  ( resetn  ),
                .psel    ( psel    ),
                .paddr   ( paddr   ),
                .pwrite  ( pwrite  ),
                .pwdata  ( pwdata  ),
                .prdata  ( prdata  ),
                .penable ( penable ),
                .pready  ( pready  ),

                .ctrl_ren       ( ctrl_ren       ),
                .ahb_data_ren   ( ahb_data_ren   ),
                .apb_data_wen   ( apb_data_wen   ),

                .apb_data_full  ( apb_data_full  ),
                .ctrl_empty     ( ctrl_empty     ),
                .ahb_data_empty ( ahb_data_empty ),

                //fifo_wdata
                .prdata_flop    ( prdata_flop    ),

                //fifo_rdata
                .ctrl_read      ( ctrl_read      ),
                .ahb_data_read  ( ahb_data_read  )
               );


    // Ctrl FIFO
    fifo_top #(.DATA_WIDTH(DATA_WIDTH + 9),
               .FIFO_DEPTH(AHB_FIFO_DEPTH))
         ctrl_fifo (.reset_n ( resetn     ),
                    .wclk    ( hclk       ),
                    .rclk    ( pclk       ),
                    .wen     ( ctrl_wen   ),
                    .ren     ( ctrl_ren   ),
                    .wdata   ( ctrl_flop  ),
                    .rdata   ( ctrl_read  ),
                    .w_full  ( ctrl_full  ),
                    .r_empty ( ctrl_empty ),
                    .fifo_sp ( ctrl_sp    )
                   );

    // AHB DATA FIFO
    fifo_top #(.DATA_WIDTH(DATA_WIDTH),
               .FIFO_DEPTH(AHB_FIFO_DEPTH))
          ahb_fifo (.reset_n ( resetn ),
                    .wclk    ( hclk   ),
                    .rclk    ( pclk   ),
                    .wen     ( ahb_data_wen   ),
                    .ren     ( ahb_data_ren   ),
                    .wdata   ( ahb_data_flop  ),
                    .rdata   ( ahb_data_read  ),
                    .w_full  ( ahb_data_full  ),
                    .r_empty ( ahb_data_empty ),
                    .fifo_sp ( ahb_data_sp )
                   );

    // APB DATA FIFO
    fifo_top #(.DATA_WIDTH(DATA_WIDTH),
               .FIFO_DEPTH(APB_FIFO_DEPTH))
          apb_fifo (.reset_n ( resetn ),
                    .wclk    ( pclk   ),
                    .rclk    ( hclk   ),
                    .wen     ( apb_data_wen   ),
                    .ren     ( apb_data_ren   ),
                    .wdata   ( prdata_flop    ),
                    .rdata   ( apb_data_read  ),
                    .w_full  ( apb_data_full  ),
                    .r_empty ( apb_data_empty ),

                    .fifo_sp ( apb_data_sp )
                   );

endmodule



