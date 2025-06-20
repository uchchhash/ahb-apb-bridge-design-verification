module fifo_top #(parameter DATA_WIDTH = 73, parameter FIFO_DEPTH = 16 )
                 (reset_n,
                  wclk,
                  rclk,
                  wen,
                  ren,
                  wdata,
                  rdata,
                  w_full,
                  r_empty,

                  fifo_sp
                 );
    
    // Input Output Signals
    input wire reset_n;    
    input wire wclk;
    input wire rclk;
    
    input wire wen;
    input wire ren;
    
    input  wire [DATA_WIDTH -1 :0] wdata;
    output wire [DATA_WIDTH -1 :0] rdata;
    
    output wire w_full;
    output wire r_empty;
    
    output wire [ $clog2(FIFO_DEPTH) :0] fifo_sp;
    
    
    // Internal Signals
    reg [$clog2(FIFO_DEPTH):0] wptr;
    reg [$clog2(FIFO_DEPTH):0] rptr;
    
    reg [$clog2(FIFO_DEPTH):0] meta_w2r;
    reg [$clog2(FIFO_DEPTH):0] meta_r2w;
    
    reg [$clog2(FIFO_DEPTH):0] wq2_rptr;
    reg [$clog2(FIFO_DEPTH):0] rq2_wptr;
    
    wire [($clog2(FIFO_DEPTH) -1):0] waddr;
    wire [($clog2(FIFO_DEPTH) -1):0] raddr;
    
    reg [DATA_WIDTH - 1:0] mem [0:FIFO_DEPTH - 1];
    
    
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%%  Generate wptr  %%%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ///*
    always @(posedge wclk or negedge reset_n) begin
        if (!reset_n) begin
            wptr <= 0;
        end

        else begin
            if (wen && !w_full) begin
                wptr <= wptr + 1'b1;
            end
            
            else begin
                wptr <= wptr;
            end
        end
    end
    //*/
    
    
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%%  Generate rptr  %%%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    always @(posedge rclk or negedge reset_n) begin
        if (!reset_n) begin
            rptr  <= 0;
        end

        else begin
            if (ren && !r_empty) begin
                rptr <= rptr + 1'b1;
            end

            else begin
                rptr <= rptr;
            end
        end
    end
    
    
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%  Synchronizer_w2r  %%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%% Generate  rq2_wptr %%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    always @(posedge rclk or negedge reset_n) begin
        if (!reset_n) begin
            meta_w2r <= 0;
            rq2_wptr <= 0;
        end
        
        else begin
            meta_w2r <= wptr;
            rq2_wptr <= meta_w2r;
        end
        
    end
    
    
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%  Synchronizer_r2w  %%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%% Generate  wq2_rptr %%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    always @(posedge wclk or negedge reset_n) begin
        if (!reset_n) begin
            meta_r2w <= 0;
            wq2_rptr <= 0;
        end
        
        else begin
            meta_r2w <= rptr;
            wq2_rptr <= meta_r2w;
        end
    end
    
    
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%  Generate w_full  %%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    //  ^^^^^^^^^^^^^^^^^  update (3-3-23)  ^^^^^^^^^^^^^^^^^
    
    assign w_full = ({~wptr[$clog2(FIFO_DEPTH)], wptr[($clog2(FIFO_DEPTH) -1):0]} == wq2_rptr && reset_n);
    
    //  +.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+
    
    
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%  Generate r_empty  %%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    //  ^^^^^^^^^^^^^^^^^  update (3-3-23)  ^^^^^^^^^^^^^^^^^
    
    assign r_empty = (rq2_wptr == rptr  | ~reset_n);
    
    //  +.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+
    
    
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%%%%%  fifo_sp  %%%%%%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    //  ^^^^^^^^^^^^^^^^^  update (21-3-23)  ^^^^^^^^^^^^^^^^^
    
    function int abs(input int a); // Absolute value
        abs = a<0? -a : a;   
    endfunction
    
    assign fifo_sp = ~reset_n? FIFO_DEPTH: abs(FIFO_DEPTH-abs(wptr-wq2_rptr));
    
    //  +.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+.+
    
    
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%%%  FIFO Memory  %%%%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    assign waddr = wptr[($clog2(FIFO_DEPTH) -1):0];
    assign raddr = rptr[($clog2(FIFO_DEPTH) -1):0];
    
    assign rdata = mem[raddr];
    
    //  $$$$$$$$$$  Write WDATA into FIFO  $$$$$$$$$$
    always @(posedge wclk) begin
    
        if (wen & !w_full) begin
            mem[waddr] <= wdata;
        end
        
        else begin
            mem[waddr] <= mem[waddr];
        end
    
    end

endmodule

