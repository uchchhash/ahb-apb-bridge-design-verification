class ahb_env_config extends uvm_object;
  
    `uvm_object_utils(ahb_env_config)

    bit has_scoreboard;
    
    ahb_agent_config ahb_agent_cfg;
    apb_agent_config apb_agent_cfg;
      
//  ===============  Function New  ==============

    function new (string name = "ahb_env_config");
      
        super.new(name);
        `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)
      
    endfunction
  
endclass

