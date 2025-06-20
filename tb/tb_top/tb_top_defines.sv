import uvm_pkg::*;
import ahb_test_pkg::*;

`timescale 1ns/1ps

/*
`ifndef AHB_frequency
    `define AHB_frequency 400
`endif

`ifndef APB_frequency
    `define APB_frequency 100
`endif
*/

//`include "def_tb.sv"
module tb_top();
    
    // Clock Generation
    bit hclk = $urandom_range(0,1);
    bit pclk = $urandom_range(0,1);
    
    //`define AHB 400
    //`define APB 100

    `ifdef AHB_frequency
        //`undef AHB
        `define AHB `AHB_frequency
    `else
        `define AHB 400
    `endif

    `ifdef APB_frequency
        //`undef APB
        `define APB `APB_frequency
    `else
        `define APB 100
    `endif
    
    //`include "def_tb.sv"
    
    /*
    `ifndef AHB_frequency
        `define AHB 400
    `endif
    
    `ifdef AHB_frequency
        `define AHB `AHB_frequency
    `endif

    `ifndef APB_frequency
        `define APB 100
    `endif
    
    `ifdef APB_frequency
        `define APB `APB_frequency
    `endif
    */
    
    //real ahb_frequency = `AHB;
    //real apb_frequency = `APB;
    
    
    //real ahb_frequency = $itor(`AHB);
    //real apb_frequency = $itor(`APB);
    
    real ahb_frequency = $itor(`AHB);
    real apb_frequency = $itor(`APB);
    
    //ahb_frequency = $itor(`AHB);
    //apb_frequency = $itor(`APB);
    
    /*
        `define APB APB_frequency
        real apb_frequency = `APB;
    `endif
    */
    //*/
 
    /*
    `ifdef AHB_frequency
        real ahb_frequency= `AHB_frequency;

    `endif
      
    `ifdef APB_frequency
        real apb_frequency= `APB_frequency;

    `endif
    */
  //real apb_frequency = 0;  

    
    /*
    real ahb_frequency;
    real apb_frequency;
    
    //initial forever #(2.5) hclk = ~hclk;
    //initial forever #(5.5) pclk = ~pclk;
    
    initial forever #( (500/ahb_frequency) ) hclk = ~hclk; // frequency in Mhz
    initial forever #( (500/apb_frequency) ) pclk = ~pclk; // frequency in Mhz
    */
    /*
    initial forever #( (500/`AHB_frequency) ) hclk = ~hclk; // frequency in Mhz
    initial forever #( (500/`APB_frequency) ) pclk = ~pclk; // frequency in Mhz
    */
    
    initial forever #( 500/ahb_frequency ) hclk = ~hclk; // frequency in Mhz
    initial forever #( 500/apb_frequency ) pclk = ~pclk; // frequency in Mhz
    
    
    // Interface Instance
    ahb_interface ahb_intf (hclk);
    apb_interface apb_intf (pclk);
    
    assign apb_intf.RST_N = ahb_intf.HRESETN ;
    
    // DUT Connection
    ahb_apb_bridge_top #(.DATA_WIDTH(32), .AHB_FIFO_DEPTH(16), .APB_FIFO_DEPTH(2))
                    DUT (
                        .hclk   ( ahb_intf.clk    ),
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
                         //.pstrb_o( apb_intf.PSTRB  ),//pstrb implementation
                        .pready ( apb_intf.PREADY )
                        
                        );
                          
    apb_slave apb (.pclk   ( apb_intf.clk     ),
                   .rst_n  ( ahb_intf.HRESETN ),
                   .paddr  ( apb_intf.PADDR   ),
                   .pwrite ( apb_intf.PWRITE  ),
                   .psel   ( apb_intf.PSEL    ),
                   .penable( apb_intf.PENABLE ),
                   .pwdata ( apb_intf.PWDATA  ),
                   .prdata ( apb_intf.PRDATA  ),
                   //.pstrb  ( apb_intf.PSTRB   ), //pstrb implementation
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
                ahb_frequency = (apb_frequency*2); // assume AHB_frequency, 2x of APB in Mhz
            end
        else begin
            if (!$value$plusargs("APB_frequency=%d", apb_frequency))begin
                apb_frequency = (ahb_frequency/2); // assume APB_frequency, half of AHB in Mhz
            end
        end
        */
        /*
        
        `uvm_info("tb_top", $sformatf( "[%0T] ::\t Received AHB_frequency in Mhz = %0f, \t ahb_time_period :: in nano_sec = %.3f ns",$realtime, ahb_frequency, (1e3/ahb_frequency) ), UVM_LOW)
        `uvm_info("tb_top", $sformatf( "[%0T] ::\t Received APB_frequency in Mhz = %0f, \t apb_time_period :: in nano_sec = %.3f ns",$realtime, apb_frequency, (1e3/apb_frequency) ), UVM_LOW)
        */
        
        // define macro
        `uvm_info("tb_top", $sformatf( "[%0T] ::\t Received Macro AHB_frequency in Mhz = %0f, \t ahb_time_period :: in nano_sec = %.3f ns",$realtime, ahb_frequency, (1e3/ahb_frequency) ), UVM_LOW)
        `uvm_info("tb_top", $sformatf( "[%0T] ::\t Received Macro APB_frequency in Mhz = %0f, \t apb_time_period :: in nano_sec = %.3f ns",$realtime, apb_frequency, (1e3/apb_frequency) ), UVM_LOW)
        
        
    end
    
    initial begin
  
        uvm_config_db #(virtual ahb_interface) ::set(null,"*","ahb_intf",ahb_intf);
        uvm_config_db #(virtual apb_interface) ::set(null,"*","apb_intf",apb_intf);
        
        //uvm_config_db #(real) ::set(null,"*","ahb_frequency",ahb_frequency);
        //uvm_config_db #(real) ::set(null,"*","apb_frequency",apb_frequency);
    
        run_test();
    
    end


endmodule

