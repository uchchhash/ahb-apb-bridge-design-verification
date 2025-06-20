// INCR8_seq_write_read_test
class INCR8_seq_write_read_test extends ahb_base_test;
    
    //factory registration
    `uvm_component_utils(INCR8_seq_write_read_test)
    
    //  ===============  Function New  ==============

    function new (string name = "INCR8_seq_write_read_test", uvm_component parent = null);

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
//  ===========  INCR8  Data Transfer  ==========
//  =============================================
    
        phase.raise_objection(this);
            
            reset();
            
            /* write-read  */ seq_write_read( INCR8, BUS_32, 32'h00, 32'h20 ); // Burst Operation, data_size, Start_ADDR, End_ADDR
            
            repeat(frequency_multiplier*52) begin // 52
                @(negedge ahb_vif.clk);
            end
        
        phase.drop_objection(this);

    endtask
  
endclass : INCR8_seq_write_read_test

