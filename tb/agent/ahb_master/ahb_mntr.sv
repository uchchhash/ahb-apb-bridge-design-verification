class ahb_mntr extends uvm_monitor;
    
    //factory registration
    `uvm_component_utils(ahb_mntr)
    
//  ===============  Virtual Interface  ==============  
    virtual ahb_interface ahb_vif;
    
    uvm_analysis_port #(ahb_seq_item) mntr_analysis_port;
    
    ahb_agent_config agent_cfg;
    
    semaphore pipe_line_sema;
    
//  ===============  Function New  ==============

    function new (string name = "ahb_mntr", uvm_component parent = null);

        super.new(name, parent);
        `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)

    endfunction
    
    
//  ===============  Build Phase  ===============
  
    virtual function void build_phase (uvm_phase phase);

        super.build_phase(phase);
        `uvm_info(get_full_name(),"Inside Build Phase",UVM_DEBUG)
      
        mntr_analysis_port = new("mntr_analysis_port", this);
        
        // ~~~~ GET virtual AHB Interface ~~~~
        if(!uvm_config_db #(virtual ahb_interface) :: get(this, "", "ahb_intf", ahb_vif))
            `uvm_fatal(get_full_name(),"Cannont Get Virtual Interface")
        
        //Initialized a semaphore object with initial value of 1
        pipe_line_sema = new(1);
        
        // ~~~~ GET AHB Agent Config ~~~~
        if(!uvm_config_db #(ahb_agent_config) :: get(this, "", "ahb_agent_config", agent_cfg))
            `uvm_warning(get_full_name(),"Cannot get ahb agent config")

    endfunction : build_phase
    
    
//  ==============  Connect Phase  ==============
  
    virtual function void connect_phase (uvm_phase phase);

        super.connect_phase(phase);
        `uvm_info(get_full_name(),"Inside Connect Phase",UVM_DEBUG)
        
    endfunction : connect_phase
  
  
//  =========  Run Phase  ==========
    virtual task run_phase(uvm_phase phase);

        super.run_phase(phase);
        `uvm_info(get_full_name(),"Inside Run Phase",UVM_DEBUG)
        
        fork
            reset_capture();
            fork
                pipeline_monitor_task();
                pipeline_monitor_task();
            join
        join_none
        
    endtask : run_phase
    
    
    task reset_capture();
    
        forever begin
            ahb_seq_item reset_item;
            reset_item = ahb_seq_item :: type_id :: create ("reset_item");
        
            @(ahb_vif.HRESETN);
        
            if ( ahb_vif.HRESETN == 0 ) begin
                reset_item.hresetn = ahb_vif.HRESETN ;
                
                agent_cfg.write_count = 0; // Write Transfer Counter
                agent_cfg.read_count  = 0; // Read  Transfer Counter
                
                mntr_analysis_port.write(reset_item);
            end
       end
        
    endtask
    
    
    task pipeline_monitor_task();
        
        ahb_seq_item item;
        
        forever begin
        
            pipe_line_sema.get(1);
            
            item = ahb_seq_item :: type_id :: create ("item");
            
            @(posedge ahb_vif.clk);
            while ( (ahb_vif.HSEL && ahb_vif.HRESETN ) !==1  ) begin
                @(posedge ahb_vif.clk);
            end
            
            // Capture Control Signals in Address phase
            item.hresetn = ahb_vif.HRESETN ;
            item.hsel    = ahb_vif.HSEL    ;
            item.hwrite  = ahb_vif.HWRITE  ;
            item.hburst  = ahb_vif.HBURST  ;
            item.htrans  = ahb_vif.HTRANS  ;
            item.hsize   = ahb_vif.HSIZE   ;
            item.haddr   = ahb_vif.HADDR   ;
            
            if (item.htrans == IDLE) begin //IDLE
                pipe_line_sema.put(1);
            end
            
            else begin // Not IDLE
                if (item.hwrite) begin // write
                    
                    @(negedge ahb_vif.clk);
                    
                    while (ahb_vif.HREADY == 0) begin
                        @(negedge ahb_vif.clk);
                    end
                    
                    pipe_line_sema.put(1);
                    @(posedge ahb_vif.clk);
                    
                    // Capture Write Data
                    item.hwdata = ahb_vif.HWDATA;
                    
                    mntr_analysis_port.write(item); // send to scb // after capturing write data
                    agent_cfg.write_count = agent_cfg.write_count + 1; // Write Transfer Counter
                    
                end
                else begin // read
                    @(posedge ahb_vif.clk);
                    
                    item.has_rdata = 0;
                    
                    // Capture Read Transfer Address Phase
                    // send to scb for Synchronization
                    mntr_analysis_port.write(item);

                    
                    wait(ahb_vif.HREADY);
                    pipe_line_sema.put(1);
                    
                    @(posedge ahb_vif.clk);
                    
                    // Capture Read Data
                    item.hrdata = ahb_vif.HRDATA;
                    
                    item.has_rdata = 1;
                    
                    mntr_analysis_port.write(item);  // send to scb // after capturing read data
                    agent_cfg.read_count = agent_cfg.read_count + 1; // Read Transfer Counter
                    
                end
            end
        end
    endtask : pipeline_monitor_task

endclass

