class apb_monitor extends uvm_monitor;
  
    //factory registration
    `uvm_component_utils(apb_monitor)

//  =======  Virtual Interface =======
    virtual apb_interface apb_vif;
    
    apb_agent_config agnt_cfg;
    bit valid_apb_transfer;
    
    uvm_analysis_port #(apb_seq_item) mntr_analysis_port;

//  =========  Function New  =========
    function new(string name = "apb_monitor", uvm_component parent = null);

        super.new(name, parent);
        `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)

    endfunction : new
  
    
//  =========  Build Phase  ==========
    virtual function void build_phase ( uvm_phase phase );
      
        super.build_phase(phase);
        `uvm_info(get_full_name(),"Inside Build Phase",UVM_DEBUG)
        
        mntr_analysis_port = new("mntr_analysis_port", this);
        
        // ~~~~ GET virtual APB Interface ~~~~
        if(!uvm_config_db#(virtual apb_interface) :: get(this, "", "apb_intf", apb_vif))
            `uvm_error("get_full_name()", "Cannot Get virtual interface" )
        else
            `uvm_info(get_full_name(),"Got vif",UVM_DEBUG)
        
        // ~~~~ GET APB Agent Config ~~~~
        if(!uvm_config_db #(apb_agent_config) ::get(this, "", "apb_agent_config", agnt_cfg))
            `uvm_error(get_full_name(), "Cannot Get APB Agent cfg");
        
    endfunction : build_phase
  
  
//  =========  Connect Phase  ==========
    
    virtual function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);
        `uvm_info(get_full_name(),"Inside Connect Phase",UVM_DEBUG)

    endfunction : connect_phase
    
    
//  =========  Run Phase  ==========
    virtual task run_phase(uvm_phase phase);

        super.run_phase(phase);
        `uvm_info(get_full_name(),"Inside Run Phase",UVM_DEBUG)
        
        fork
            reset_capture();
            transfer_capture();
        join_none
        
    endtask : run_phase
    
    task reset_capture();
        
        forever begin
            apb_seq_item reset_item;
            reset_item = apb_seq_item :: type_id :: create ("reset_item");
            
            @(apb_vif.RST_N);
            
            if ( apb_vif.RST_N == 0 ) begin
                reset_item.rst_n = apb_vif.RST_N ;
                
                agnt_cfg.write_count = 0; // Write Transfer Counter
                agnt_cfg.read_count  = 0; // Read  Transfer Counter
                mntr_analysis_port.write(reset_item);
            end
        end
        
    endtask : reset_capture
    
    
    task transfer_capture();
        
        apb_seq_item apb_item;
        
        forever begin
            fork
                begin : transfer_capture_block
                    @(posedge apb_vif.clk);
            
                    if ( (apb_vif.PSEL && !apb_vif.PENABLE && apb_vif.RST_N) === 1 ) begin
                        apb_item = apb_seq_item :: type_id :: create ("apb_item");
                        
                        //Setup phase // Capture Addr 
                        apb_item.rst_n   =  apb_vif.RST_N   ;
                        apb_item.psel    =  apb_vif.PSEL    ;
                        
                        apb_item.pwrite  =  apb_vif.PWRITE  ;
                        apb_item.penable =  apb_vif.PENABLE ;
                        
                        apb_item.paddr   =  apb_vif.PADDR   ;
                        
                        //Enable Phase
                        @(posedge apb_vif.clk);
                        
                        if ( apb_item.pwrite == 1 ) begin  // Write transfer capture
                        
                            while ( (apb_vif.PENABLE && apb_vif.PREADY)!==1 ) begin
                                @(posedge apb_vif.clk);
                            end
                            
                            apb_item.pwdata  =  apb_vif.PWDATA  ;
                            // send to scb // after capturing write data
                            mntr_analysis_port.write( apb_item );
                            
                            // Write Transfer Counter
                            agnt_cfg.write_count = agnt_cfg.write_count + 1; 
                        end
                        
                        else begin // read transfer capture
                        
                            apb_item.has_rdata = 0;
                            // send Read Transfer Address to scb for Synchronization
                            mntr_analysis_port.write( apb_item );
                            
                            while ( (apb_vif.PENABLE && apb_vif.PREADY)!==1 ) begin
                                @(posedge apb_vif.clk);
                            end
                            
                            apb_item.has_rdata = 1;
                            apb_item.prdata  =  apb_vif.PRDATA  ;
                            // send to scb // after capturing read data
                            mntr_analysis_port.write( apb_item );
                              
                            // Read Transfer Counter
                            agnt_cfg.read_count = agnt_cfg.read_count + 1; 
                            
                        end
                    end
                end : transfer_capture_block
                
                begin
                    @(apb_vif.RST_N==0);
                    disable transfer_capture_block;
                end
            join_any
        end
    endtask : transfer_capture
    
endclass
   
