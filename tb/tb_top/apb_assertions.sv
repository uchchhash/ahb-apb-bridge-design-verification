//  ======  Sequence of Setup State  ======
    sequence setup_state;
         ( RST_N && PSEL && !PENABLE) ;
    endsequence

//  ======  Sequence of Enable State  ======
    sequence enable_state;
         ( RST_N && PSEL && PENABLE ) ;
    endsequence


//  ======  Write Property  ======
    property apb_write_state;
        @(negedge clk) (setup_state and PWRITE) |->##1  enable_state ##[1:$] $rose(PREADY);
    endproperty

//  ======  Read Property  ======     
    property apb_read_state;
        @(posedge clk) (setup_state and !PWRITE) |=>  enable_state ##[1:$] $rose(PREADY);
    endproperty


//  ======  Write Assertion  ======
    assert property(apb_write_state) //$info("write ok"); 
            else $info("write assertion failed");
            
//  ======  Read Assertion  ======            
    assert property(apb_read_state) //$info("read ok"); 
            else $info("read assertion failed");
