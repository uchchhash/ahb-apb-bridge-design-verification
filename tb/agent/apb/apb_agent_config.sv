class apb_agent_config extends uvm_object;
    
    `uvm_object_utils(apb_agent_config)
    
    int write_count;
    int  read_count;
    
    uvm_active_passive_enum is_active = UVM_PASSIVE;
    bit has_functional_coverage;
    
    function new(string name = "apb_agent_config");
    
        super.new(name);
        `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)
        
    endfunction
    
endclass

