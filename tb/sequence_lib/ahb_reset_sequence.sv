class ahb_reset_sequence extends ahb_base_sequence;

    //factory registration
    `uvm_object_utils(ahb_reset_sequence)
  
//  ===============  Function New  ==============

    function new(string name = "ahb_reset_sequence");
        super.new(name);
        `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)
    endfunction
  
//  ===============  Body Task  ==============
  
    virtual task body();

        `uvm_do_with(ahb_item, { ahb_item.hresetn == 1'b0; })

    endtask
  
endclass

