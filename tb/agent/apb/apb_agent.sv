class apb_agent extends uvm_agent;
  
    `uvm_component_utils(apb_agent)

    apb_agent_config agnt_cfg;
    apb_driver driver;
    apb_monitor mntr;
    apb_sequencer seqr;
    
//  =========  Function New  =========
    function new(string name = "apb_agent", uvm_component parent = null);
    
        super.new(name, parent);
        `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)
    
    endfunction : new

  
//  =========  Build Phase  ==========
    virtual function void build_phase ( uvm_phase phase );
      
        super.build_phase(phase);
        `uvm_info(get_full_name(),"Inside Build Phase",UVM_DEBUG)
        
      // ~~~~ GET APB Agent Config ~~~~
        if(!uvm_config_db #(apb_agent_config) ::get(this, "", "apb_agent_config", agnt_cfg))
            `uvm_error(get_full_name(), "Cannot Get APB Agent cfg");
        
        if(agnt_cfg.is_active == UVM_ACTIVE) begin
            // ~~~~ Create APB Driver ~~~~
            driver = apb_driver :: type_id :: create ("driver", this);
            // ~~~~ Create APB Sequencer ~~~~
            seqr = apb_sequencer :: type_id :: create ("seqr", this);
        end
            
        // ~~~~ Create Monitor ~~~~
        mntr = apb_monitor :: type_id :: create ("mntr", this);
      
    endfunction : build_phase
  
  
//  =========  Connect Phase  ==========
    virtual function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);
        `uvm_info(get_full_name(),"Inside Connect Phase",UVM_DEBUG)
        
        if(agnt_cfg.is_active == UVM_ACTIVE) begin
            driver.seq_item_port.connect(seqr.seq_item_export);
        end
                    
    endfunction : connect_phase
  
endclass

