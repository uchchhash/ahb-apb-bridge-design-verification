class ahb_env extends uvm_env;
  
    //factory registration
    `uvm_component_utils(ahb_env)

    ahb_env_config env_cfg;
    ahb_scoreboard scb;
    ahb_agent ahb_agnt;
    apb_agent apb_agnt;
    
//  ===============  Function New  ==============
  
    function new (string name = "ahb_env", uvm_component parent = null);

        super.new(name, parent);
        `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)

    endfunction
    
//  ===============  Build Phase  ===============
  
    virtual function void build_phase (uvm_phase phase);

        super.build_phase(phase);
        `uvm_info(get_full_name(),"Inside Build Phase",UVM_DEBUG)

        // ~~~~ GET Env config ~~~~
        if(!uvm_config_db #(ahb_env_config) ::get(this, "" , "test2env", env_cfg))
            `uvm_warning(get_full_name(),"Cannot get env config")
        
        // ~~~~ Create Scoreboard ~~~~
        if(env_cfg.has_scoreboard)
            scb = ahb_scoreboard :: type_id :: create ("scb",this);
        
        
        // ~~~~ Create AHB Agent ~~~~
        ahb_agnt = ahb_agent :: type_id :: create ("ahb_agnt",this);
        // ~~~~ SET AHB agent config ~~~~
        uvm_config_db #(ahb_agent_config) ::set(this, "*", "ahb_agent_config", env_cfg.ahb_agent_cfg);

        
        // ~~~~ Create APB Agent ~~~~
        apb_agnt = apb_agent :: type_id :: create ("apb_agnt",this);
        // ~~~~ SET APB agent config ~~~~
        uvm_config_db #(apb_agent_config) ::set(this, "*", "apb_agent_config", env_cfg.apb_agent_cfg);

    endfunction : build_phase
    
//  ==============  Connect Phase  ==============
  
    virtual function void connect_phase (uvm_phase phase);

        super.connect_phase(phase);
        `uvm_info(get_full_name(),"Inside Connect Phase",UVM_DEBUG)
        
        // Connect the analysis port of the scoreboard with the monitor so that
    	// the scoreboard gets data whenever monitor broadcasts the data.
        if(env_cfg.has_scoreboard) begin
            ahb_agnt.mntr.mntr_analysis_port.connect (scb.ahb_mntr2scb);
            apb_agnt.mntr.mntr_analysis_port.connect (scb.apb_mntr2scb);
        end

    endfunction : connect_phase
  
endclass

