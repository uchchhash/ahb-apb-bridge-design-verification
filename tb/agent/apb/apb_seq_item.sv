class apb_seq_item extends uvm_sequence_item;

    rand logic rst_n;
    rand logic pwrite;
    rand logic psel;
    rand logic penable;
    rand logic [31:0] paddr;
    rand logic [31:0] pwdata;
    logic [31:0] prdata;
    logic pready;
    logic has_rdata;

    //   to use the uvm_object methods 
    //   ( copy, compare, pack, unpack, record, print, and etc

    `uvm_object_utils_begin(apb_seq_item)

        `uvm_field_int( rst_n,     UVM_ALL_ON)
        `uvm_field_int( pwrite,    UVM_ALL_ON)
        `uvm_field_int( psel,      UVM_ALL_ON)
        `uvm_field_int( penable,   UVM_ALL_ON)
        `uvm_field_int( paddr,     UVM_ALL_ON)
        `uvm_field_int( pwdata,    UVM_ALL_ON)
        `uvm_field_int( prdata,    UVM_ALL_ON)
        `uvm_field_int( pready,    UVM_ALL_ON)
        `uvm_field_int( has_rdata, UVM_ALL_ON)

    `uvm_object_utils_end


//  ===============  Function New  ==============

    function new(string name = "apb_seq_item");
        super.new(name);
        `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)
    endfunction
  
endclass

