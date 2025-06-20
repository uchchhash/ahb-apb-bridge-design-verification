class ahb_read_sequence extends ahb_base_sequence;
  
    //factory registration
    `uvm_object_utils(ahb_read_sequence)
  
//  ===============  Function New  ==============

    function new(string name = "ahb_read_sequence");
        super.new(name);
        `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)
    endfunction
  
//  ===============  Body Task  ==============
  
    virtual task body();
    
    //  =======================  Initialization  =======================
        Number_Bytes = number_bytes(hsize);
        Burst_Length = burst_length(hburst);
        Wrap_Boundary = wrap_boundary(haddr, Number_Bytes, Burst_Length );
        Address_N = addr_n(Number_Bytes, Burst_Length, Wrap_Boundary);
    //  ================================================================
    
        if( hburst == INCR ) begin
            Burst_Length = burst_length_INCR;
            $display("burst_length_INCR = %0d",burst_length_INCR);
        end
        
        for(int i = 0; i< Burst_Length; i=i+1 ) //How many Burst
        begin

            // NON-Sequential  &  Sequential  Control
              htrans = i == 0 ? NONSEQ : SEQ ;

            // WRAP Address Control
            if( hburst == WRAP4 || hburst == WRAP8 || hburst == WRAP16 ) // WRAP4, WRAP8, WRAP16 Transfer
                if (haddr == Address_N )
                    haddr = Wrap_Boundary;

            // Read Sequence
            if(!hwrite)  
                Read_Sequence();

            //Burst ADDRESS     
            if ( hburst != SINGLE )
                haddr   += Number_Bytes;
        end
    endtask
  
    task Read_Sequence();
    
        `uvm_do_with(ahb_item, {
                     ahb_item.hresetn == HIGH;
                     ahb_item.hwrite  == LOW;

                     ahb_item.hburst == local :: hburst;
                     ahb_item.htrans == local :: htrans;

                     ahb_item.hsize  == local :: hsize;
          
                     ahb_item.haddr  == local :: haddr;
                   })
    endtask
    
  
endclass

