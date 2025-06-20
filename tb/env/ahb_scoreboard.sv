`uvm_analysis_imp_decl(_apb_mntr2scb)
`uvm_analysis_imp_decl(_ahb_mntr2scb)

class ahb_scoreboard extends uvm_scoreboard;

  //factory registration
    `uvm_component_utils(ahb_scoreboard)
    
  //Analysis ports
    uvm_analysis_imp_ahb_mntr2scb #(ahb_seq_item, ahb_scoreboard) ahb_mntr2scb;
    uvm_analysis_imp_apb_mntr2scb #(apb_seq_item, ahb_scoreboard) apb_mntr2scb;
  
  //Queues to store expected and captured items
    ahb_seq_item ahb_sync_q[$]; // sync_q // AHB Start
    apb_seq_item apb_sync_q[$]; // sync_q // APB Start
    
    ahb_seq_item ahb_read_data_q[$]; // sync_q //AHB END
    apb_seq_item apb_read_data_q[$]; // sync_q //APB END
    
  //To store received transactions
    ahb_seq_item ahb_rdata_cap_item; // AHB Read Data item
    apb_seq_item apb_rdata_cap_item; // APB Read Data item
    
    ahb_seq_item ahb_sync_item; // AHB sync item
    apb_seq_item apb_sync_item; // APB sync item
    
  //Store Exp Data
    bit [3:0][7:0] exp_data [int];
    
    int pass_count, fail_count, total_count;
    int sync_pass, sync_fail, sync_total;
      
//  ===============  Function New  ==============

    function new (string name = "ahb_scoreboard", uvm_component parent = null);

        super.new(name, parent);
        `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)
      
        ahb_mntr2scb = new("ahb_mntr2scb", this);
        apb_mntr2scb = new("apb_mntr2scb", this);
      
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

  
//  ==============  Run Phase  ==============
  
    task run_phase (uvm_phase phase);

        super.run_phase(phase);/
        `uvm_info(get_full_name(),"Inside Run Phase",UVM_DEBUG)
        
        forever begin
            ahb_apb_synchronization_task();
        end
        
    endtask : run_phase
    
    
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%  AHB APB Synchronization  %%%%%%%%%%%%%%%
    //  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    task ahb_apb_synchronization_task();
        
        
        wait( ahb_sync_q.size() > 0 && apb_sync_q.size() > 0);
        
        ahb_sync_item = ahb_sync_q.pop_front();
        apb_sync_item = apb_sync_q.pop_front();
        
        if ( apb_sync_item.paddr == ( ahb_sync_item.hsize == WORD ? ahb_sync_item.haddr[31:2] : ahb_sync_item.hsize == HALF_WORD ? ahb_sync_item.haddr[31:1] : ahb_sync_item.haddr ) ) begin : addr_compare
            //Address sync_Match
            if ( apb_sync_item.pwrite == ahb_sync_item.hwrite ) begin : write_signal_compare
                //Address sync_match & Write signal sync_match
                
                //Write
                if ( ahb_sync_item.hwrite == 1 ) begin : Write
                    //Data Compare
                    if ( apb_sync_item.pwdata == ahb_sync_item.hwdata ) begin : Wdata_Compare
                        //Address sync_match , Write signal sync_match & Wdata sync_match
                        `uvm_info ("AHB_APB_SYNC_PASS", $sformatf("[%0T] \t:: [Write Transfer] :: AHB_ADDR:%0h, \t APB_ADDR:%0h (ahb_equivalent : %0h), \t WRITE_DATA:%8h", $realtime, ahb_sync_item.haddr, apb_sync_item.paddr, ahb_sync_item.hsize == WORD ? {apb_sync_item.paddr[29:0],2'b00} : ahb_sync_item.hsize == HALF_WORD ? {apb_sync_item.paddr[30:0],1'b0} : apb_sync_item.paddr[31:0], ahb_sync_item.hwdata ), UVM_MEDIUM)
                        sync_pass = sync_pass + 1;
                    end
                    else begin : Wdata_Mismatch
                        //Address sync_match , Write signal sync_match & Wdata  sync_Mis_match
                        `uvm_error ("AHB_APB_SYNC_FAIL", $sformatf("[%0T] \t:: data mismatched :: [Write Transfer] :: AHB_ADDR:%0h, \t APB_ADDR:%0h (ahb_equivalent : %0h) \t EXP_WRITE_DATA:%8h, \t CAP_WRITE_DATA:%8h", $realtime, ahb_sync_item.haddr, apb_sync_item.paddr, ahb_sync_item.hsize == WORD ? {apb_sync_item.paddr[29:0],2'b00} : ahb_sync_item.hsize == HALF_WORD ? {apb_sync_item.paddr[30:0],1'b0} : apb_sync_item.paddr[31:0], ahb_sync_item.hwdata, apb_sync_item.pwdata ) )
                        sync_fail = sync_fail + 1;
                    end
                end : Write
                else begin : Read
                    //Address sync_match , Write signal sync_match
                    `uvm_info ("AHB_APB_SYNC_PASS", $sformatf("[%0T] \t:: [Read  Transfer] :: AHB_ADDR:%0h, \t APB_ADDR:%0h (ahb_equivalent : %0h) ", $realtime, ahb_sync_item.haddr, apb_sync_item.paddr, ahb_sync_item.hsize == WORD ? {apb_sync_item.paddr[29:0],2'b00} : ahb_sync_item.hsize == HALF_WORD ? {apb_sync_item.paddr[30:0],1'b0} : apb_sync_item.paddr[31:0] ), UVM_MEDIUM)
                    sync_pass = sync_pass + 1 ;

                    wait( apb_read_data_q.size() > 0 );
                    wait( ahb_read_data_q.size() > 0 );
                        

                    apb_rdata_cap_item = apb_read_data_q.pop_front();
                    ahb_rdata_cap_item = ahb_read_data_q.pop_front();
                        
                    if ( ahb_rdata_cap_item.hrdata == apb_rdata_cap_item.prdata ) begin : Rdata_Compare
                        //Address sync_match , Write signal sync_match & read data sync_match
                            
                        `uvm_info ("APB_AHB_Read_data_SYNC_PASS", $sformatf("[%0T] \t:: AHB_ADDR:%0h, \t APB_ADDR:%0h (ahb_equivalent : %0h), \t READ_DATA:%8h, \t ", $realtime, ahb_sync_item.haddr, apb_sync_item.paddr, ahb_sync_item.hsize == WORD ? {apb_sync_item.paddr[29:0],2'b00} : ahb_sync_item.hsize == HALF_WORD ? {apb_sync_item.paddr[30:0],1'b0} : apb_sync_item.paddr[31:0], ahb_sync_item.hrdata), UVM_MEDIUM)
                        sync_pass = sync_pass + 1;
                        data_compare ( ahb_rdata_cap_item );
                    end
                    else begin : Rdata_Mismatch
                        // Address sync_match , Write signal sync_match & read data sync_Mis_match
                        `uvm_error ("APB_AHB_Read_data_SYNC_FAIL", $sformatf("[%0T] \t:: data mismatched :: [Read Transfer] :: AHB_ADDR:%0h, \t APB_ADDR:%0h (ahb_equivalent : %0h) \t EXP_READ_DATA:%8h, \t CAP_READ_DATA:%8h", $realtime, ahb_sync_item.haddr, apb_sync_item.paddr, ahb_sync_item.hsize == WORD ? {apb_sync_item.paddr[29:0],2'b00} : ahb_sync_item.hsize == HALF_WORD ? {apb_sync_item.paddr[30:0],1'b0} : apb_sync_item.paddr[31:0], apb_sync_item.prdata, ahb_sync_item.hwdata ) )
                        sync_fail = sync_fail + 1;
                    end
                end : Read
            end : write_signal_compare
            else begin : write_signal_Mismatch
                //Address sync_match & write signal sync_Mis_match
                `uvm_error ("AHB_APB_SYNC_FAIL", $sformatf("[%0T] \t:: write signal mismatched :: AHB_ADDR:%0h, \t APB_ADDR:%0h (ahb_equivalent : %0h) \t Exp Transfer :%0s, \t Cap Transfer : %0s", $realtime, ahb_sync_item.haddr, apb_sync_item.paddr, ahb_sync_item.hsize == WORD ? {apb_sync_item.paddr[29:0],2'b00} : ahb_sync_item.hsize == HALF_WORD ? {apb_sync_item.paddr[30:0],1'b0} : apb_sync_item.paddr[31:0], (ahb_sync_item.hwrite ? "WRITE" : " READ"),(apb_sync_item.pwrite ? "WRITE" : " READ") ) )
                sync_fail = sync_fail + 1 ;
            end
        end : addr_compare
        else begin : addr_Mismatch
            //Address sync_Mis_Match
            `uvm_error ("AHB_APB_SYNC_FAIL", $sformatf("[%0T] \t:: Addr Mismatched :: Exp AHB ADDR:%0h (apb_equivalent : %0h), \t Cap APB ADDR : %0h(ahb_equivalent : %0h)", $realtime, ahb_sync_item.haddr, ahb_sync_item.hsize == WORD ? ahb_sync_item.haddr[31:2] : ahb_sync_item.hsize == HALF_WORD ? ahb_sync_item.haddr[31:1] : ahb_sync_item.haddr[31:0], apb_sync_item.paddr,  ahb_sync_item.hsize == WORD ? {apb_sync_item.paddr[29:0],2'b00} : ahb_sync_item.hsize == HALF_WORD ? {apb_sync_item.paddr[30:0],1'b0} : apb_sync_item.paddr[31:0] ) )
                
            sync_fail = sync_fail + 1;
        end
        
    endtask : ahb_apb_synchronization_task
    
    
//  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//  %%%%%%%%%%%%%%%%%%  Data Compare Task  %%%%%%%%%%%%%%%%%%
//  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function void data_compare ( ahb_seq_item ahb_cap_item );
	
	    if( ahb_cap_item.hrdata === exp_data[ahb_cap_item.haddr[31:2]] ) begin
	
		    `uvm_info ("PASS", $sformatf("ADDR:%0h	EXPECTED DATA:%8h,	CAPTURE DATA:%8h", ahb_cap_item.haddr, exp_data[ahb_cap_item.haddr[31:2]], ahb_cap_item.hrdata), UVM_LOW)
		    pass_count = pass_count + 1;
	    end
	    else begin
		    `uvm_error ("FAIL", $sformatf("ADDR:%0h	EXPECTED DATA:%8h,	CAPTURE DATA:%8h", ahb_cap_item.haddr, exp_data[ahb_cap_item.haddr[31:2]], ahb_cap_item.hrdata))
		    fail_count = fail_count + 1;
	    end
	
	    total_count = total_count+1;

    endfunction : data_compare
    

//  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//  %%%%%%%%%%%%%  AHB_mntr2scb write function  %%%%%%%%%%%%%
//  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function void write_ahb_mntr2scb (ahb_seq_item item);
        
        if ( item.hresetn == 0 ) begin
            exp_data.delete();
            ahb_sync_q.delete();
            `uvm_info("SCB", $sformatf("scb : [%0T] : reset ahb", $realtime),UVM_LOW)
            
        end
        else begin
            if ( item.hwrite ) begin // AHB Write Transfer
                
                ahb_sync_q.push_back(item);
                case (item.hsize)
                
                    WORD      : exp_data[item.haddr[31:2]] = item.hwdata;
                    
                    HALF_WORD : if ( item.haddr[31:1]%2 == 0 ) begin
                                    exp_data[item.haddr[31:2]][1:0] = item.hwdata[15:0];
                                end
                                else if ( item.haddr[31:1]%2 == 1 ) begin
                                    exp_data[item.haddr[31:2]][3:2] = item.hwdata[31:16];
                                end
                    
                    BYTE      : if ( item.haddr[31:0]%4 == 0 ) begin
                                    exp_data[item.haddr[31:2]][0] = item.hwdata[7:0];
                                end
                                else if ( item.haddr[31:0]%4 == 1 ) begin
                                    exp_data[item.haddr[31:2]][1] = item.hwdata[15:8];
                                end
                                else if ( item.haddr[31:0]%4 == 2 ) begin
                                    exp_data[item.haddr[31:2]][2] = item.hwdata[23:16];
                                end
                                else if ( item.haddr[31:0]%4 == 3 ) begin
                                    exp_data[item.haddr[31:2]][3] = item.hwdata[31:24];
                                end
                endcase
            end
            
            else begin // AHB Read Transfer
                if ( item.has_rdata == 0 ) begin // For Synchronization
                    ahb_sync_q.push_back(item);
                end
                else begin // For Rdata Compare
                    ahb_read_data_q.push_back(item);
                end
            end
        end

    endfunction
    
    
//  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//  %%%%%%%%%%%%%  APB_mntr2scb write function  %%%%%%%%%%%%%
//  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function void write_apb_mntr2scb (apb_seq_item item);
        
        if ( item.rst_n == 1 ) begin
            if ( item.pwrite == 1 ) begin // APB Write Transfer
                apb_sync_q.push_back(item);
            end
            else begin // APB Read Transfer
                if ( !item.has_rdata ) begin // For Synchronization
                    apb_sync_q.push_back(item);
                end
                else begin // For Rdata Compare
                    apb_read_data_q.push_back(item);
                end
            end
        end
        else begin
            apb_sync_q.delete();
            apb_read_data_q.delete();
        end
    endfunction : write_apb_mntr2scb
    
  
    function void report_phase(uvm_phase phase);
      
        $display("\n\t#####################################  Test Report  #####################################");

        $display("\t#\t\t\t\tTotal Test initiated :: %0d\t\t\t\t#", total_count);

        $display("\t#\t\t\t\t   Test Passed :: %0d\t\t\t\t\t#", pass_count);

        $display("\t#\t\t\t\t   Test failed :: %0d\t\t\t\t\t#", fail_count);

        $display("\t#########################################################################################");

      
        $display("\n\t###############################  Synchronization Report  ################################");

        $display("\t#\t\t\t\tTotal Test initiated :: %0d\t\t\t\t#", ( sync_pass + sync_fail ) );

        $display("\t#\t\t\t\t   Test Passed :: %0d\t\t\t\t\t#", sync_pass);

        $display("\t#\t\t\t\t   Test failed :: %0d\t\t\t\t\t#", sync_fail);

        $display("\t#########################################################################################");

    endfunction
  
endclass
