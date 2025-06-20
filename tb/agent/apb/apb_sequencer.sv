class apb_sequencer extends uvm_sequencer #(apb_seq_item);
  
    `uvm_component_utils(apb_sequencer)
      
//  ===============  Function New  ==============

    function new (string name = "apb_sequencer", uvm_component parent = null);

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
  
    virtual task run_phase (uvm_phase phase);

        super.run_phase(phase);
        `uvm_info(get_full_name(),"Inside Connect Phase",UVM_DEBUG)

    endtask : run_phase
  
endclass : apb_sequencer
