//  ======  Sequence of Address Phase  ======
    sequence address_phase;
         ( HRESETN && HSEL && (HTRANS == 2'b10 || HTRANS==2'b11 ) ) ;
    endsequence
    
//  ======  Sequence of Data Phase  ======
    sequence data_phase;
         ( HRESETN && HSEL ) ;
    endsequence
    
//  ======  Write Property  ======
    property ahb_write_state;
        @(posedge clk) (address_phase and HWRITE) |->##[1:$] (data_phase and HREADY);
    endproperty
    
//  ======  Read Property  ======
    property ahb_read_state;
        @(posedge clk) (address_phase and !HWRITE) |->##[1:$] (data_phase and HREADY);
    endproperty

//  ======  Write Assertion  ======
    assert property(ahb_write_state) $info("ahb write assertion ok"); 
            else $info("ahb write assertion failed");

//  ======  Read Assertion  ======            
    assert property(ahb_read_state) $info("ahb read assertion ok"); 
            else $info("ahb read assertion failed");
