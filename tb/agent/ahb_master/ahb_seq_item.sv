class ahb_seq_item extends uvm_sequence_item;
    
    rand logic        hresetn;
    rand logic        hsel;
    rand logic [31:0] haddr;
    rand logic [1:0]  htrans;
    rand logic        hwrite;
    rand logic [2:0]  hburst;
    rand logic [2:0]  hsize;
    rand logic [31:0] hwdata;
    logic             hready;
    logic [1:0]       hresp;
    logic [31:0]      hrdata;
    logic             has_rdata;
    
    `uvm_object_utils_begin(ahb_seq_item)
      
        `uvm_field_int( hresetn,   UVM_ALL_ON)
        `uvm_field_int( hsel,      UVM_ALL_ON)
        `uvm_field_int( haddr,     UVM_ALL_ON)
        `uvm_field_int( htrans,    UVM_ALL_ON)
        `uvm_field_int( hwrite,    UVM_ALL_ON)
        `uvm_field_int( hburst,    UVM_ALL_ON)
        `uvm_field_int( hsize,     UVM_ALL_ON)
        `uvm_field_int( hwdata,    UVM_ALL_ON)
        `uvm_field_int( hready,    UVM_ALL_ON)
        `uvm_field_int( hresp,     UVM_ALL_ON)
        `uvm_field_int( hrdata,    UVM_ALL_ON)
        `uvm_field_int( has_rdata, UVM_ALL_ON)
        
    `uvm_object_utils_end
      
//  ===============  Function New  ==============

    function new (string name = "ahb_seq_item");
        super.new(name);
        `uvm_info(get_full_name(),"Inside Constructor Function", UVM_DEBUG)
    endfunction
  
endclass

