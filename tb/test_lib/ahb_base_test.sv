class ahb_base_test extends uvm_test;
    
    //factory registration
    `uvm_component_utils(ahb_base_test)
    
    ahb_env env;
    ahb_env_config env_cfg;
    ahb_agent_config ahb_agent_cfg;
    apb_agent_config apb_agent_cfg;
    
//  ===============  Function New  ==============
    
    function new (string name = "ahb_base_test", uvm_component parent = null);
    
        super.new(name, parent);
        `uvm_info(get_full_name(),"Inside Constructor Function",UVM_DEBUG)
    
    endfunction
    
//  ===============  Build Phase  ===============
    
    virtual function void build_phase (uvm_phase phase);
    
        super.build_phase(phase);
        `uvm_info(get_full_name(),"Inside Build Phase",UVM_DEBUG)
        
        //Env Config
        env_cfg = ahb_env_config :: type_id :: create ("env_cfg");
        env_cfg.has_scoreboard = 1;
        
        //AHB Agent Config
        ahb_agent_cfg = ahb_agent_config :: type_id :: create ("ahb_agent_cfg");
        ahb_agent_cfg.is_active = UVM_ACTIVE;
        ahb_agent_cfg.has_functional_coverage = 0;
        
        //APB Agent Config
        apb_agent_cfg = apb_agent_config :: type_id :: create ("apb_agent_cfg");
        apb_agent_cfg.is_active = UVM_PASSIVE;
        apb_agent_cfg.has_functional_coverage = 0;


        env_cfg.ahb_agent_cfg = this.ahb_agent_cfg;
        env_cfg.apb_agent_cfg = this.apb_agent_cfg;
        
        //Environment create
        env = ahb_env :: type_id :: create ("env", this);
        
        // ~~~~ SET Env config ~~~~
        uvm_config_db #(ahb_env_config) :: set(this, "env", "test2env", env_cfg );
                

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
      
    endtask

  
//  ===============  Reset Task  ================
    task reset();

        ahb_reset_sequence reset_seq;
        reset_seq = ahb_reset_sequence :: type_id :: create ("reset_seq");

        reset_seq.start (env.ahb_agnt.seqr);

    endtask  


//  ===============  Write Task  ================
    task write(bit [2:0]  hburst     = SINGLE, 
               bit [2:0]  hsize      = BUS_8, 
               bit [31:0] start_addr = 0,
               bit [31:0] end_addr   = start_addr,
               bit [31:0] hwdata     = 0,
               bit        rand_flag  = 1,
               bit [1:0]  htrans     = NONSEQ,
               int INCR_Burst_Length = 0
              );
              
        int data_width = (hsize == BUS_8)? 1 : (hsize == BUS_16)? 2 : 4;
        int burst_size = hburst == SINGLE ? 1 : hburst == INCR4 ? 4 : hburst == INCR8 ? 8 : hburst == INCR16 ? 16 : 1;
        
        for ( bit [31:0] addr = start_addr; addr <= end_addr;  addr = (addr + (data_width * burst_size) )  ) begin
        
            ahb_write_sequence w_seq;
            w_seq = ahb_write_sequence :: type_id :: create ("write_seq");

            w_seq.hwrite = HIGH;
            w_seq.hburst = hburst;
            w_seq.haddr  = addr;
            w_seq.hsize  = hsize;
            w_seq.htrans = htrans;
      
      
            w_seq.haddr  = addr;
      
            if (!rand_flag )
                w_seq.hwdata = hwdata;
      
            w_seq.Random_Flag = rand_flag;

            w_seq.burst_length_INCR = INCR_Burst_Length;

            w_seq.start (env.ahb_agnt.seqr);
        end

    endtask


//  ===============  Read Task  =================
    task read(bit [2:0]  hburst     = SINGLE,
              bit [2:0]  hsize      = BUS_8, 
              bit [31:0] start_addr = 0,
              bit [31:0] end_addr   = start_addr,
              int INCR_Burst_Length = 0
             );

        int data_width = (hsize == BUS_8)? 1 : (hsize == BUS_16)? 2 : 4;
        int burst_size = hburst == SINGLE ? 1 : hburst == INCR4 ? 4 : hburst == INCR8 ? 8 : hburst == INCR16 ? 16 : 1;
        
        //for ( bit [31:0] addr = start_addr; addr <= end_addr;  addr = (addr + (hsize==0?1: hsize==1?2: 4 ))  ) begin
        for ( bit [31:0] addr = start_addr; addr <= end_addr;  addr = (addr + (data_width * burst_size) )  ) begin
        
            ahb_read_sequence r_seq;
            r_seq = ahb_read_sequence :: type_id :: create ("read_seq");

            r_seq.hwrite = LOW;
            r_seq.hburst = hburst;

            r_seq.hsize  = hsize;

            r_seq.haddr  = addr;
      
            r_seq.burst_length_INCR = INCR_Burst_Length;

            r_seq.start (env.ahb_agnt.seqr);
            
        end
        
    endtask

    
//  =======  Sequential Write Read Task  ========
    task seq_write_read(bit [2:0]  hburst     = SINGLE, 
                        bit [2:0]  hsize      = BUS_8, 
                        bit [31:0] start_addr = 0,
                        bit [31:0] end_addr   = start_addr,
                        bit [31:0] hwdata     = 0,
                        bit        rand_flag  = 1,
                        int INCR_Burst_Length = 0
                       );
                       
        int data_width = (hsize == BUS_8)? 1 : (hsize == BUS_16)? 2 : 4;
        int burst_size = hburst == SINGLE ? 1 : hburst == INCR4 ? 4 : hburst == INCR8 ? 8 : hburst == INCR16 ? 16 : 1;
        
        for ( bit [31:0] addr = start_addr; addr <= end_addr;  addr = (addr + (data_width * burst_size) )  ) begin
        
            write(hburst, hsize, addr, addr, hwdata, rand_flag);
            read (hburst, hsize, addr, addr, INCR_Burst_Length);
            
        end
        
    endtask

//  =============================================    
//  ========  User Define Pattern Task  =========
//  =============================================
    task udpt ( bit user_defined_pattern               = 1,
                int random_addr_flag_or_num_of_pattern = 1,
                bit [3:0] transfer_pattern [$]         = {},
                bit [31:0] addr_pattern [$]            = {},
                
                bit [3:0] pattern_constrain [$]        = {0,1,2,3,4,5,6,7,8}  // transfer_pattern [$] ==  {{ IDLE_W = 0, SIN_W = 1, I4_W = 2, I8_W = 3, I16_W = 4, SIN_R = 5, I4_R = 6, I8_R = 7, I16_R = 8;  }}
              );
        
        if ( user_defined_pattern ) begin
            foreach( transfer_pattern[i] ) begin
                case (transfer_pattern[i] )
                
                    SIN_W : begin
                                write( SINGLE, BUS_32, random_addr_flag_or_num_of_pattern? $urandom_range(0, 1023):addr_pattern[i] ); // Burst Operation, data_size, Start_ADDR
                            end
                    SIN_R : begin
                                read ( SINGLE, BUS_32, random_addr_flag_or_num_of_pattern? $urandom_range(0, 1023):addr_pattern[i] ); // Burst Operation, data_size, Start_ADDR
                            end
                    
                    I4_W : begin
                                write( INCR4, BUS_32, random_addr_flag_or_num_of_pattern? $urandom_range(0, 1011):addr_pattern[i] ); // Burst Operation, data_size, Start_ADDR
                            end
                    I4_R : begin
                                read ( INCR4, BUS_32, random_addr_flag_or_num_of_pattern? $urandom_range(0, 1011):addr_pattern[i] ); // Burst Operation, data_size, Start_ADDR
                            end
                    
                    I8_W : begin
                                write( INCR8, BUS_32, random_addr_flag_or_num_of_pattern? $urandom_range(0, 995):addr_pattern[i] ); // Burst Operation, data_size, Start_ADDR
                            end
                    I8_R : begin
                                read ( INCR8, BUS_32, random_addr_flag_or_num_of_pattern? $urandom_range(0, 995):addr_pattern[i] ); // Burst Operation, data_size, Start_ADDR
                            end
                    
                    I16_W : begin
                                write( INCR16, BUS_32, random_addr_flag_or_num_of_pattern? $urandom_range(0, 963):addr_pattern[i] ); // Burst Operation, data_size, Start_ADDR
                            end
                    I16_R : begin
                                read ( INCR16, BUS_32, random_addr_flag_or_num_of_pattern? $urandom_range(0, 963):addr_pattern[i] ); // Burst Operation, data_size, Start_ADDR
                            end
                            
                    IDLE_W : begin
                                write( SINGLE, , , , , , IDLE ); // Burst Operation, data_size, Start_ADDR, End_ADDR, WDATA, Random_Flag, htrans
                            end
                endcase
            end
        end
        
        else begin
            int rand_pattern;
            $display ("[base_test] :: [%0T] :: random_addr_flag_or_num_of_pattern : %0d", $realtime, random_addr_flag_or_num_of_pattern);
        
            for (int i = 1; i<=random_addr_flag_or_num_of_pattern; i++) begin
                
                rand_pattern = pattern_constrain [$urandom_range( 0,(pattern_constrain.size()-1) ) ];
                
                
                //`uvm_info("base_test :: User Define Pattern Task", $sformatf("Random pattern number : %0d, \t rand_pattern :: %0s", i, rand_pattern == 0 ? "IDLE_W" : rand_pattern == 1 ? "SIN_W" : rand_pattern == 2 ? "I4_W" : rand_pattern == 3 ? "I8_W" : rand_pattern == 4 ? "I16_W" : rand_pattern == 5 ? "SIN_R" : rand_pattern == 6 ? "I4_R" : rand_pattern == 7 ? "I8_R" : rand_pattern == 8 ? "I16_R" : "nothing"), UVM_NONE)
                            
                case (rand_pattern )
                
                    SIN_W : begin
                                write( SINGLE, BUS_32, $urandom_range(0, 1023) ); // Burst Operation, data_size, Start_ADDR
                            end
                    SIN_R : begin
                                read ( SINGLE, BUS_32, $urandom_range(0, 1023) ); // Burst Operation, data_size, Start_ADDR
                            end
                    
                    I4_W : begin
                                write( INCR4, BUS_32, $urandom_range(0, 1011) ); // Burst Operation, data_size, Start_ADDR
                            end
                    I4_R : begin
                                read ( INCR4, BUS_32, $urandom_range(0, 1011) ); // Burst Operation, data_size, Start_ADDR
                            end
                    
                    I8_W : begin
                                write( INCR8, BUS_32, $urandom_range(0, 995) ); // Burst Operation, data_size, Start_ADDR
                            end
                    I8_R : begin
                                read ( INCR8, BUS_32, $urandom_range(0, 995) ); // Burst Operation, data_size, Start_ADDR
                            end
                    
                    I16_W : begin
                                write( INCR16, BUS_32, $urandom_range(0, 963) ); // Burst Operation, data_size, Start_ADDR
                            end
                    I16_R : begin
                                read ( INCR16, BUS_32, $urandom_range(0, 963) ); // Burst Operation, data_size, Start_ADDR
                            end
                            
                    IDLE_W : begin
                                write( SINGLE, , , , , , IDLE ); // Burst Operation, data_size, Start_ADDR, End_ADDR, WDATA, Random_Flag, htrans
                            end
                endcase
            end
        end
        
    endtask : udpt
    
    task ahb_apb_transfer_sync_wait_task ();
    
        wait ( env_cfg.ahb_agent_cfg.write_count == env_cfg.apb_agent_cfg.write_count );
        
        wait ( env_cfg.ahb_agent_cfg.read_count == env_cfg.apb_agent_cfg.read_count );
        
        `uvm_info("base_test", $sformatf("Write_Transfer_count : AHB, APB :: %0d : %0d \tRead_Transfer_count  : AHB, APB  :: %0d : %0d", env_cfg.ahb_agent_cfg.write_count, env_cfg.apb_agent_cfg.write_count, env_cfg.ahb_agent_cfg.read_count, env_cfg.apb_agent_cfg.read_count), UVM_NONE)
        
    endtask
endclass : ahb_base_test

