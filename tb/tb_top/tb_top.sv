`timescale 1ns/1ps
import uvm_pkg::*;
import ahb_test_pkg::*;
module tb_top();
    
    // Clock Generation
    bit hclk = $urandom_range(0,1);
    bit pclk = $urandom_range(0,1);
    
    real ahb_frequency = `AHB_frequency; // macro AHB_frequency is received from command line
    real apb_frequency = `APB_frequency; // macro APB_frequency is received from command line
    
    initial forever #( 500/ahb_frequency ) hclk = ~hclk; // frequency in Mhz
    initial forever #( 500/apb_frequency ) pclk = ~pclk; // frequency in Mhz
    
    // Interface Instance
    ahb_interface ahb_intf (hclk);
    apb_interface apb_intf (pclk);
    
    assign apb_intf.RST_N = ahb_intf.HRESETN ;
    
    // DUT Connection
    ahb_apb_bridge_top #(.DATA_WIDTH(32), .AHB_FIFO_DEPTH(16), .APB_FIFO_DEPTH(2))
                    DUT (.hclk   ( ahb_intf.clk    ),
                         .resetn ( ahb_intf.HRESETN),
                         .hsel   ( ahb_intf.HSEL   ),
                         .haddr  ( ahb_intf.HADDR  ),
                         .htrans ( ahb_intf.HTRANS ),
                         .hwrite ( ahb_intf.HWRITE ),
                         .hburst ( ahb_intf.HBURST ),
                         .hsize  ( ahb_intf.HSIZE  ),
                         .hwdata ( ahb_intf.HWDATA ),
                         .hready_o ( ahb_intf.HREADY ),
                         .hresp  ( ahb_intf.HRESP  ),
                         .hrdata ( ahb_intf.HRDATA ),

                         .pclk   ( apb_intf.clk    ),
                         .psel   ( apb_intf.PSEL   ),
                         .paddr  ( apb_intf.PADDR  ),
                         .pwrite ( apb_intf.PWRITE ),
                         .pwdata ( apb_intf.PWDATA ),
                         .prdata ( apb_intf.PRDATA ),
                         .penable( apb_intf.PENABLE),
                         .pready ( apb_intf.PREADY )
                        );


    apb_slave #(.addrWidth(32) )
           apb (.pclk   ( apb_intf.clk     ),
                .rst_n  ( ahb_intf.HRESETN ),
                .paddr  ( apb_intf.PADDR   ),
                .pwrite ( apb_intf.PWRITE  ),
                .psel   ( apb_intf.PSEL    ),
                .penable( apb_intf.PENABLE ),
                .pwdata ( apb_intf.PWDATA  ),
                .prdata ( apb_intf.PRDATA  ),
                .pready ( apb_intf.PREADY  )
               );
    
    initial begin
    
        /*
        // $value$plusarg method
        if (!$value$plusargs("AHB_frequency=%d", ahb_frequency))
            if (!$value$plusargs("APB_frequency=%d", apb_frequency))begin
                ahb_frequency = 400; // Default AHB_frequency in Mhz
                apb_frequency = 100; // Default APB_frequency in Mhz
            end
            else begin
                ahb_frequency = 400; // Default AHB_frequency in Mhz
            end
        else begin
            if (!$value$plusargs("APB_frequency=%d", apb_frequency))begin
                apb_frequency = 100; // Default APB_frequency in Mhz
            end
        end
        */
        
        // AHB APB Frequency 
        `uvm_info("tb_top", $sformatf( "[%0T] ::\t Received Macro AHB_frequency in Mhz = %0f, \t ahb_time_period :: in nano_sec = %.3f ns"
                                                                                ,$realtime, ahb_frequency, (1e3/ahb_frequency) ), UVM_NONE)
                                                                                
        `uvm_info("tb_top", $sformatf( "[%0T] ::\t Received Macro APB_frequency in Mhz = %0f, \t apb_time_period :: in nano_sec = %.3f ns"
                                                                                ,$realtime, apb_frequency, (1e3/apb_frequency) ), UVM_NONE)
    end
    
    initial begin
        
        // ~~~~ SET virtual AHB Interface ~~~~
        uvm_config_db #(virtual ahb_interface) ::set(null,"*","ahb_intf",ahb_intf);
        // ~~~~ SET virtual APB Interface ~~~~
        uvm_config_db #(virtual apb_interface) ::set(null,"*","apb_intf",apb_intf);
        
        run_test();
    
    end

endmodule

