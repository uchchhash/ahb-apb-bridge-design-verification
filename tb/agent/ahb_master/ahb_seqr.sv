class ahb_seqr extends uvm_sequencer #(ahb_seq_item);
    
    //factory registration
    `uvm_component_utils(ahb_seqr)
      
//  ===============  Function New  ==============

    function new (string name = "ahb_seqr", uvm_component parent = null);

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
    
endclass

