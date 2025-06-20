class apb_driver extends uvm_driver #(apb_seq_item);
  
    `uvm_component_utils(apb_driver)
  
// ==========  Virtual Interface  ==========
    virtual apb_interface apb_vif;

    apb_agent_config apb_agent_cfg;
  
//  ==============  Function New  ===============

    function new(string name = "apb_driver", uvm_component parent = null);

        super.new(name, parent);
        `uvm_info(get_full_name(), "Inside Constructor Function", UVM_DEBUG )

    endfunction : new

//  ===============  Build Phase  ===============
  
    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        `uvm_info(get_full_name(),"Inside Build Phase",UVM_DEBUG)

        //  ==========  Get APB Interface  ==========  //
        if(!uvm_config_db #(virtual apb_interface)::get(this, "", "apb_intf", apb_vif))
            `uvm_fatal("get_full_name()", "Cannot Get APB virtual interface" )

        //  ==========  Get APB Agent Config  ==========  //
        if(!uvm_config_db #( apb_agent_config )::get(this, "", "apb_agent_cfg", apb_agent_cfg))
            `uvm_error(get_full_name(),"Cannot get APB Agent Config")

    endfunction : build_phase
  
//  ==============  Connect Phase  ==============
  
    virtual function void connect_phase (uvm_phase phase);

        super.connect_phase(phase);
        `uvm_info(get_full_name(),"Inside Connect Phase",UVM_DEBUG)

    endfunction : connect_phase

//  ================  Run Phase  ================
  
    virtual task run_phase(uvm_phase phase);

        super.run_phase(phase);
        `uvm_info(get_full_name(),"Inside Run Phase",UVM_DEBUG)

        forever begin
            
            apb_seq_item item;
            `uvm_info(get_full_name(), "Wait for item from Sequencer", UVM_DEBUG)
            
            seq_item_port.get_next_item ( item );

            if(!item.rst_n) // Reset
                reset();

            else if(item.pwrite)  // Write
                write(item);

            else if(!item.pwrite) // Read
                read(item);   

            seq_item_port.item_done(item);
            
        end
        
    endtask : run_phase
  
//  ===================  Reset Driver Task Start  ===================
    task reset();

        apb_vif.RST_N     <= 1'b1;
        @(posedge apb_vif.clk);

        apb_vif.RST_N     <= 1'b0;

        apb_vif.PWRITE    <= 1'b0;
        apb_vif.PSEL      <= 1'b0;
        apb_vif.PENABLE   <= 1'b0;
        apb_vif.PADDR     <= 32'b0;
        apb_vif.PWDATA    <= 32'b0;

        @(posedge apb_vif.clk);
        apb_vif.RST_N     <= 1'b1;

    endtask
//  ====================  Reset Driver Task END  ====================
  
  
//  =====================  APB Write Task START  ====================
    task write( apb_seq_item item );
      
        apb_vif.RST_N     <= 1'b1;

        apb_vif.PWRITE    <= 1'b1;
        apb_vif.PSEL      <= 1'b1;
        apb_vif.PENABLE   <= 1'b0;

        apb_vif.PADDR     <= item.paddr;
        apb_vif.PWDATA    <= item.pwdata;

        @(posedge apb_vif.clk);

        apb_vif.PENABLE   <= 1'b1;
        wait(apb_vif.PREADY);
        @(posedge apb_vif.clk);

        apb_vif.PSEL      <= 1'b0;
        apb_vif.PENABLE   <= 1'b0;
      
    endtask : write
  
//  ======================  APB Write Task END  =====================

  
//  =====================  APB Read Task START  =====================
    task read( apb_seq_item item );       
        
        apb_vif.RST_N     <= 1'b1;

        apb_vif.PWRITE    <= 1'b0;
        apb_vif.PSEL      <= 1'b1;
        apb_vif.PENABLE   <= 1'b0;

        apb_vif.PADDR     <= item.paddr;

        @(posedge apb_vif.clk);

        apb_vif.PENABLE   <= 1'b1;
        wait(apb_vif.PREADY);

        @(posedge apb_vif.clk);

        apb_vif.PSEL      <= 1'b0;
        apb_vif.PENABLE   <= 1'b0;
      
    endtask : read
  
//  ======================  APB Read Task END  ====================== 
  
  
endclass : apb_driver
