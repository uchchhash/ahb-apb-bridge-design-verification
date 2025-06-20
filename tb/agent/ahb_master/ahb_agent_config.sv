class ahb_agent_config extends uvm_object;
  
    `uvm_object_utils(ahb_agent_config)

    uvm_active_passive_enum is_active = UVM_PASSIVE;
    bit has_functional_coverage;
    
    int write_count ;
    int  read_count ;
      
//  ===============  Function New  ==============

    function new(string name = "ahb_agent_config");
        
        super.new(name);
        `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)
        
    endfunction
  
endclass

