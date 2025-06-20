interface apb_interface (input bit clk);

    logic        RST_N;
    logic [31:0] PADDR;
    logic        PWRITE;
    logic        PSEL;
    logic        PENABLE;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic        PREADY;
    
endinterface

