// INCR4_write_read_with_idle_test
class INCR4_write_read_with_idle_test extends ahb_base_test;
    
    //factory registration
    `uvm_component_utils(INCR4_write_read_with_idle_test)
    
    //  ===============  Function New  ==============

    function new (string name = "INCR4_write_read_with_idle_test", uvm_component parent = null);

        super.new(name, parent);
        `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)

    endfunction
    
//  ===============  Build Phase  ===============
    
    virtual function void build_phase (uvm_phase phase);

        super.build_phase(phase);
        `uvm_info(get_full_name(),"Inside Build Phase",UVM_DEBUG)

    endfunction : build_phase
    
//  ==============  Connect Phase  ==============
    
    virtual function void connect_phase (uvm_phase phase);

        super.connect_phase(phase);
        `uvm_info(get_full_name(),"Inside Connect Phase",UVM_DEBUG)
      
    endfunction : connect_phase

//  ================  Run Phase  ================
    
    virtual task run_phase(uvm_phase phase);

        super.run_phase(phase);
        `uvm_info(get_full_name(),"Inside Run Phase",UVM_DEBUG)
      
      
//  =============================================
//  ===========  INCR4  Data Transfer  ==========
//  =============================================
    
    // Burst Operation = hburst = 00 = Single Transfer
    // Size of data = hsize = 010 = Word = BUS_32
        
        phase.raise_objection(this);
            
            reset();
            
            /* IDLE  */ repeat(5)write( SINGLE, , , , , , IDLE ); // Burst Operation, data_size, Start_ADDR, End_ADDR, WDATA, Random_Flag, htrans
            
            /* write */ write( INCR4, BUS_32, 32'h00 ); // Burst Operation, data_size, Start_ADDR, End_ADDR, WDATA, Random_Flag
            
            /* IDLE  */ repeat(5)write( SINGLE, , , , , , IDLE ); // Burst Operation, data_size, Start_ADDR, End_ADDR, WDATA, Random_Flag, htrans
            
            /* read  */ read ( INCR4, BUS_32, 32'h00 ); // Burst Operation, data_size, Start_ADDR, End_ADDR
            
            /* IDLE  */ repeat(5)write( SINGLE, , , , , , IDLE ); // Burst Operation, data_size, Start_ADDR, End_ADDR, WDATA, Random_Flag, htrans
            
            
            repeat(100) begin
                @(negedge ahb_vif.clk);
            end
        
        phase.drop_objection(this);

    endtask
  
endclass : INCR4_write_read_with_idle_test

