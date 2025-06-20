class ahb_agent extends uvm_agent;
    
    //factory registration
    `uvm_component_utils(ahb_agent)

    ahb_agent_config agent_cfg;
    ahb_drv drv;
    ahb_mntr mntr;
    ahb_seqr seqr;

//  ===============  Function New  ==============

    function new (string name = "ahb_agent", uvm_component parent = null);

        super.new(name, parent);
        `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)

    endfunction
    
//  ===============  Build Phase  ===============
  
    virtual function void build_phase (uvm_phase phase);

        super.build_phase(phase);
        `uvm_info(get_full_name(),"Inside Build Phase",UVM_DEBUG)

        // ~~~~ GET AHB agent config ~~~~
        if(!uvm_config_db #(ahb_agent_config) :: get(this, "", "ahb_agent_config", agent_cfg))
            `uvm_warning(get_full_name(),"Cannot get ahb agent config")

        if(agent_cfg.is_active == UVM_ACTIVE)
        begin
            // ~~~~ Create AHB Driver ~~~~
            drv = ahb_drv :: type_id :: create ("drv", this);
            // ~~~~ Create AHB Sequencer ~~~~
            seqr = ahb_seqr :: type_id :: create ("seqr", this);
        end
        
        // ~~~~ Create AHB Monitor ~~~~
        mntr = ahb_mntr :: type_id :: create ("mntr", this);

    endfunction : build_phase
    
//  ==============  Connect Phase  ==============
  
    virtual function void connect_phase (uvm_phase phase);

        super.connect_phase(phase);
        `uvm_info(get_full_name(),"Inside Connect Phase",UVM_DEBUG)
        
        // Conect the driver's TLM port with the sequencer's export so that 
        // The driver can accept the parameterized request object from the sequencer
        if(agent_cfg.is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end

    endfunction : connect_phase
  
  
endclass

