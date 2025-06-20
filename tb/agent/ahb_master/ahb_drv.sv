class ahb_drv extends uvm_driver #(ahb_seq_item);
    
    //factory registration
    `uvm_component_utils(ahb_drv)
    
//  ===============  Virtual Interface  ==============  
    virtual ahb_interface ahb_vif;
    
    semaphore pipe_line_sema;
//  ===============  Function New  ==============

    function new (string name = "ahb_drv", uvm_component parent = null);

        super.new(name, parent);
        `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)

    endfunction
    
//  ===============  Build Phase  ===============

    virtual function void build_phase (uvm_phase phase);

        super.build_phase(phase);
        `uvm_info(get_full_name(),"Inside Build Phase",UVM_DEBUG)
        
        // ~~~~ GET virtual AHB Interface ~~~~
        if(!uvm_config_db #(virtual ahb_interface) :: get(this, "", "ahb_intf", ahb_vif))
            `uvm_fatal(get_full_name(),"Cannont Get Virtual Interface")
        else
            `uvm_info(get_full_name(),"Get Virtual Interface", UVM_DEBUG)
        
        //Initialized a semaphore object with initial value of 1
        pipe_line_sema = new(1);

    endfunction : build_phase
    
//  ==============  Connect Phase  ==============
    
    virtual function void connect_phase (uvm_phase phase);

        super.connect_phase(phase);
        `uvm_info(get_full_name(),"Inside Connect Phase",UVM_DEBUG)

    endfunction : connect_phase

//  ==============  Run Phase  ==============

    virtual task run_phase (uvm_phase phase);

        super.run_phase(phase);
        `uvm_info(get_full_name(),"Inside Connect Phase",UVM_DEBUG)
        
        fork
            pipeline_driver_task();
            pipeline_driver_task();
        join

    endtask : run_phase
    
    
    task reset_drive();
        
        ahb_vif.HRESETN <= HIGH;
        @(negedge ahb_vif.clk);
      
        ahb_vif.HRESETN <= LOW;
        ahb_vif.HSEL    <= LOW;
        ahb_vif.HWRITE  <= LOW;
        ahb_vif.HBURST  <= SINGLE;
        ahb_vif.HTRANS  <= IDLE;
        ahb_vif.HSIZE   <= 3'b0;
      
        ahb_vif.HADDR   <= 32'b0;
        ahb_vif.HWDATA  <= 32'b0;
        @(negedge ahb_vif.clk);
      
        ahb_vif.HRESETN <= HIGH;

    endtask
    
    
    task pipeline_driver_task();
        
        ahb_seq_item item;
        
        forever begin
        
            pipe_line_sema.get(1);
            
            `uvm_info(get_full_name(),"wait for item from sequencer", UVM_DEBUG)

            seq_item_port.get_next_item( item );
            
            if(!item.hresetn) begin // Reset
                reset_drive();
                pipe_line_sema.put(1);
            end
            else begin // Not Reset
                if(item.htrans == IDLE) begin
                    ahb_vif.HRESETN   <= item.hresetn;
                    
                    ahb_vif.HTRANS    <= IDLE;
                    ahb_vif.HSEL      <= HIGH;
                    
                    //all zero  !!!!!!!!!!!!!!
                    ahb_vif.HWRITE    <= LOW;
                    ahb_vif.HBURST    <= SINGLE;
                    ahb_vif.HSIZE     <= BYTE;

                    ahb_vif.HADDR     <= 32'h0;
                end
                
                if (item.htrans != IDLE) begin
                    ahb_vif.HRESETN   <= item.hresetn;
                    ahb_vif.HSEL      <= HIGH;
                    ahb_vif.HWRITE    <= item.hwrite;
                    ahb_vif.HBURST    <= item.hburst;
                    ahb_vif.HTRANS    <= item.htrans;
                    ahb_vif.HSIZE     <= item.hsize;

                    ahb_vif.HADDR     <= item.haddr;
                end
                
                @(negedge ahb_vif.clk);
                
                if (item.htrans == IDLE) begin
                    ahb_vif.HSEL      <= LOW;
                    pipe_line_sema.put(1);
                end
                else begin // Not IDLE
                
                    while(ahb_vif.HREADY == 0)
                        @(negedge ahb_vif.clk);
                    
                    ahb_vif.HTRANS    <= IDLE;
                    ahb_vif.HSEL      <= LOW;

                    //all zero  !!!!!!!!!!!!!!
                    ahb_vif.HWRITE    <= LOW;
                    ahb_vif.HBURST    <= SINGLE;
                    ahb_vif.HSIZE     <= BYTE;

                    ahb_vif.HADDR     <= 32'h0;
                    
                    pipe_line_sema.put(1);
                    
                    if (item.hwrite) begin
                        ahb_vif.HWDATA <= item.hwdata; 
                    end
                    else begin
                        ahb_vif.HTRANS <= IDLE;
                    end
                end
            end
        
        seq_item_port.item_done();    
                
        end
    endtask : pipeline_driver_task
    
endclass

