// single_write_read_with_idle_test
class single_write_read_with_idle_test extends ahb_base_test;
  
  `uvm_component_utils( single_write_read_with_idle_test )
  
  //  ===============  Function New  ==============

    function new (string name = "single_write_read_with_idle_test", uvm_component parent = null);

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
//  ===========  Single Data Transfer  ==========
//  =============================================
      

        phase.raise_objection(this);

            reset();
          
            /* IDLE  */ repeat(5)write( SINGLE, , , , , , IDLE ); // Burst Operation, data_size, Start_ADDR, End_ADDR, WDATA, Random_Flag, htrans
            
            /* write */ write( SINGLE, BUS_32, 32'h04 ); // Burst Operation, data_size, Start_ADDR, End_ADDR, WDATA, Random_Flag
            
            /* IDLE  */ repeat(5)write( SINGLE, , , , , , IDLE ); // Burst Operation, data_size, Start_ADDR, End_ADDR, WDATA, Random_Flag, htrans
            
            /* read  */ read ( SINGLE, BUS_32, 32'h04); // Burst Operation, data_size, Start_ADDR, End_ADDR
            
            /* IDLE  */ repeat(5)write( SINGLE, , , , , , IDLE ); // Burst Operation, data_size, Start_ADDR, End_ADDR, WDATA, Random_Flag, htrans
            
            
            repeat(frequency_multiplier*52) begin // 52
                @(negedge ahb_vif.clk);
            end

        phase.drop_objection(this);

    endtask
  
endclass : single_write_read_with_idle_test
