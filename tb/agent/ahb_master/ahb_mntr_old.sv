
class ahb_mntr extends uvm_monitor;
  
    //factory registration
    `uvm_component_utils(ahb_mntr)
    
    `include "define.sv"
  
//  ===============  Virtual Interface  ==============  
    virtual ahb_interface ahb_vif;
    
    ahb_seq_item data_item;
  
    semaphore sema;
  
    int Remainder;

    uvm_analysis_port #(ahb_seq_item) mntr_analysis_port;
  
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
      
        if(!uvm_config_db #(virtual ahb_interface) :: get(this, "", "ahb_intf", ahb_vif))
            `uvm_fatal(get_full_name(),"Cannont Get Virtual Interface")
        
        sema = new(1);

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
            transfer_pipeline();
        join_none
        
    endtask : run_phase
  
    
    
    task reset_capture();
    
        forever begin
            ahb_seq_item reset_item;
            reset_item = ahb_seq_item :: type_id :: create ("reset_item");
        
            @(ahb_vif.HRESETN);
        
            if ( !ahb_vif.HRESETN ) begin
                reset_item.hresetn = ahb_vif.HRESETN ;
                //`uvm_info("ahb_mntr", $sformatf("[%.3T] :: reset value (exp : 0) :: %0d", $realtime, ahb_vif.HRESETN), UVM_LOW)
                mntr_analysis_port.write(reset_item);
            end
            /*
            else begin
                `uvm_info("ahb_mntr", $sformatf("[%.3T] :: reset value (exp : 1) :: %0d", $realtime, ahb_vif.HRESETN), UVM_LOW)
            end
            */
       end
        
    endtask
    
    
    
    task transfer_pipeline();
    
        forever begin
            ahb_seq_item item;
            item = ahb_seq_item :: type_id :: create ("item");
      
            fork
                Address_Phase(item);
                Data_Phase(item);
            join_any
        end

    endtask : transfer_pipeline
  
  // ===================================
  // =========  Address Phase  =========
  // ===================================
  
    task Address_Phase(ahb_seq_item item);
    
        sema.get(1);
        wait(ahb_vif.HSEL && ahb_vif.HRESETN);
        
        @(posedge ahb_vif.clk);

        if( ahb_vif.HRESETN && ahb_vif.HSEL ) begin
          
            //if(ahb_vif.HTRANS == IDLE) begin
                
                item.hresetn = ahb_vif.HRESETN ;
                item.hsel    = ahb_vif.HSEL    ;

                item.hwrite  = ahb_vif.HWRITE  ;

                item.hburst  = ahb_vif.HBURST  ;
                item.htrans  = ahb_vif.HTRANS  ;

                item.hsize   = ahb_vif.HSIZE   ;
                item.haddr   = ahb_vif.HADDR   ;
                
            //end 
            //else if(ahb_vif.HTRANS != IDLE) begin
            /*    
                item.hresetn = ahb_vif.HRESETN  ;
                item.hsel    = ahb_vif.HSEL     ;

                item.hwrite  = ahb_vif.HWRITE   ;

                item.hburst  = ahb_vif.HBURST   ;
                item.htrans  = ahb_vif.HTRANS   ;

                item.hsize   = ahb_vif.HSIZE    ;
                item.haddr   = ahb_vif.HADDR    ;
            */    
            //end
            
        end
            
        sema.put(1);
        
    endtask : Address_Phase
  
  
  //  ====================================
  //  ===========  DATA Phase  ===========
  //  ====================================
  
    task Data_Phase(ahb_seq_item item);

        sema.get(1);
        $cast(data_item, item.clone());
        
        if (data_item.htrans == IDLE) begin
            sema.put(1);
        end
        
        //else if (data_item.hwrite && data_item.htrans != IDLE ) begin
        else begin
        else if (data_item.hwrite && data_item.htrans != IDLE ) begin
            wait(ahb_vif.HREADY);
            sema.put(1);
        //end
        
        @(posedge ahb_vif.clk);
        
        //if ( data_item.htrans != IDLE ) begin
            if(!data_item.hwrite) begin
                
                if ( !data_item.hwrite ) begin
                    data_item.hready = 0; // always should zero. or force zero
                    mntr_analysis_port.write(data_item);
                end
                
                
                if(ahb_vif.HREADY) begin
                    sema.put(1);
                end
            
                else if(!ahb_vif.HREADY) begin
                    wait(ahb_vif.HREADY);
                    sema.put(1);
                    @(posedge ahb_vif.clk);
                end
                
                data_item.hready = 1; // always should HIGH. or force ONE
                
                Remainder = data_item.haddr % 32'h4;
                
                if (data_item.hsize == BUS_8) begin
                    case (Remainder)
                        'h0 : data_item.hrdata = ahb_vif.HRDATA[0+:8];
                        'h1 : data_item.hrdata = ahb_vif.HRDATA[8+:8];
                        'h2 : data_item.hrdata = ahb_vif.HRDATA[16+:8];
                        'h3 : data_item.hrdata = ahb_vif.HRDATA[24+:8];
                    endcase
                end 
                else if (data_item.hsize == BUS_16) begin
                    case (Remainder)
                        'h0 : data_item.hrdata = ahb_vif.HRDATA[0+:16];
                        'h1 : data_item.hrdata = ahb_vif.HRDATA[0+:16];
                        'h2 : data_item.hrdata = ahb_vif.HRDATA[16+:16];
                        'h3 : data_item.hrdata = ahb_vif.HRDATA[16+:16];
                    endcase
                end
                else if (data_item.hsize == BUS_32)
                    data_item.hrdata = ahb_vif.HRDATA[0+:32];
            end
            else begin // hwrite 
                data_item.hwdata = ahb_vif.HWDATA;
            end
            
            mntr_analysis_port.write(data_item);
        end
    endtask : Data_Phase
      
endclass

