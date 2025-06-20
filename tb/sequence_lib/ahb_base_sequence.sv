class ahb_base_sequence extends uvm_sequence #(ahb_seq_item);
    
    //factory registration
    `uvm_object_utils(ahb_base_sequence)
    
    ahb_seq_item ahb_item;
    
    bit        hwrite;
    
    bit [1:0]  htrans;
    bit [2:0]  hburst;
    
    int burst_length_INCR;
    
    bit [2:0]  hsize;
    bit [31:0] haddr;
    
    bit [31:0] hwdata;
    
    bit Random_Flag;
     
    int Burst_Length;
    bit [31:0] Wrap_Boundary;
    bit [31:0] Address_N ;
    bit [15:0] Number_Bytes;
    
    
//  ===============  Function New  ==============
    
    function new(string name = "ahb_base_sequence");
        super.new(name);
      `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)
    endfunction

    
//  ===============  Body Task  ==============
    
    virtual task body();
      
    endtask
    
endclass

//  ==========  Number of Byte  ==========
    function bit[15:0] number_bytes(bit [2:0] size);
             if ( size == BYTE) return 1;
        else if ( size == HALF_WORD) return 2;
        else if ( size == WORD) return 4;
    endfunction
    
    //  ===========  Burst Length  ===========
    function int burst_length(bit [2:0] hburst);
    
             if ( hburst == SINGLE) return 1;
        else if ( hburst == INCR)  return 1;
        else if ( hburst == WRAP4) return 4;
        else if ( hburst == INCR4) return 4;
        else if ( hburst == WRAP8) return 8;
        else if ( hburst == INCR8) return 8;
        else if ( hburst == WRAP16) return 16;
        else if ( hburst == INCR16) return 16;
    
    endfunction
    
    //  ==========  Wrap Boundary  ===========
    function bit[31:0] wrap_boundary(bit [31:0] haddr, int Number_Bytes, int Burst_Length );
      
        return ((haddr)/(Number_Bytes*Burst_Length))*(Number_Bytes*Burst_Length);
    endfunction
    
    //  =============  Address_N  =============
    function bit[31:0] addr_n( int Number_Bytes, int Burst_Length , [31:0] wrap_boundary);
      
      return (wrap_boundary + Number_Bytes * Burst_Length);
    endfunction
    

