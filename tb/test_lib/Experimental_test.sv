// Experimental_test
class Experimental_test extends ahb_base_test;
  
  `uvm_component_utils( Experimental_test )
  
  int repeat_var;
  int i;
  
  //  ===============  Function New  ==============

    function new (string name = "Experimental_test", uvm_component parent = null);

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
//  ============  Experimental_test  ============
//  =============================================
      
      // user_defined_pattern, random_address_flag_or_num_of_pattern, transfer_pattern [$], addr_pattern [$], start_burst_range = IDLE_W, end_burst_range = I16_R
      // transfer_pattern [$] ==  {{ IDLE_W = 0, SIN_W = 1, I4_W = 2, I8_W = 3, I16_W = 4, SIN_R = 5, I4_R = 6, I8_R = 7, I16_R = 8;  }}

  
        phase.raise_objection(this);

        reset();
        
        udpt(1, 0, {2}, {'h10}); // pattern constrain
        
        
        udpt(1, 0, {6}, {'h10}); // pattern constrain
        
        
        //reset();
        
        //udpt(1, 0, {2,2}, {'h50, 'h70}); // pattern constrain
        
        ///*
        i = 0;
        repeat_var = 100;
        //repeat_var = 2;
        repeat( repeat_var)
            begin
                i = i+1;
                $display("Repeat No : %0d", i);
                reset();
                
                udpt(0, 5); // pattern constrain
                //udpt(0, 2); // pattern constrain
            
            end
        
        udpt(0, 1000); // pattern constrain
        
        //*/    
            //*/
        
        
        
        #2;
        ahb_apb_transfer_sync_wait_task();
        
        `uvm_info("base_test", $sformatf("Write_Transfer_count : AHB, APB :: %0d : %0d \tRead_Transfer_count  : AHB, APB  :: %0d : %0d", env_cfg.ahb_agent_cfg.write_count, env_cfg.apb_agent_cfg.write_count, env_cfg.ahb_agent_cfg.read_count, env_cfg.apb_agent_cfg.read_count), UVM_LOW)
        
        phase.drop_objection(this);

    endtask
  
endclass : Experimental_test
