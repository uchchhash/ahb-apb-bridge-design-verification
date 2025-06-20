interface ahb_interface (input bit clk);
 
    logic        HRESETN;
    logic        HSEL;
    logic [31:0] HADDR;
    logic [1:0]  HTRANS;
    logic        HWRITE;
    logic [2:0]  HBURST;
    logic [2:0]  HSIZE;
    logic [31:0] HWDATA;
    logic        HREADY;
    logic        HRESP;
    logic [31:0] HRDATA;

endinterface

