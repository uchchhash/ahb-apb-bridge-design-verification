// user_define_pattern_test
class user_define_pattern_test extends ahb_base_test;
  
  `uvm_component_utils( user_define_pattern_test )
  
  //  ===============  Function New  ==============

    function new (string name = "user_define_pattern_test", uvm_component parent = null);

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
//  =========  user_define_pattern_test  ========
//  =============================================
        
        // user_defined_pattern, random_address_flag_or_num_of_pattern, transfer_pattern [$], addr_pattern [$], start_burst_range = IDLE_W, end_burst_range = I16_R
        // transfer_pattern [$] ==  {{ IDLE_W = 0, SIN_W = 1, I4_W = 2, I8_W = 3, I16_W = 4, SIN_R = 5, I4_R = 6, I8_R = 7, I16_R = 8;  }}
        
        
        phase.raise_objection(this);

            reset();
            
            udpt ( 1, 1, { I4_W, I4_R, I8_W, I8_W, I16_W, I16_W, SIN_R, I16_R } ); // user_def_pattern_or_random_pattern, random_address_flag, transfer_pattern, addr_pattern
            
            // random pattern 
            udpt ( 0, 10000 ); // user_def_pattern_or_random_pattern, random_address, transfer_pattern, addr_pattern
            
            
            ahb_apb_transfer_sync_wait_task();

        phase.drop_objection(this);

    endtask
  
endclass : user_define_pattern_test
