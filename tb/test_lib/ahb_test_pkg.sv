package ahb_test_pkg;

    import uvm_pkg::*;
    import ahb_env_pkg::*;

    import ahb_seq_pkg::*;
    import ahb_agent_pkg::ahb_agent_config;
    import apb_agent_pkg::apb_agent_config;

    `include "def_tb.sv"
    `include "uvm_macros.svh"
    
    `include "ahb_base_test.sv"
    
    //Single Tests
    `include "single_write_read_test.sv"
    `include "single_cons_write_read_test.sv"
    `include "single_seq_write_read_test.sv"
    `include "single_overwrite_data_test.sv"
    `include "single_write_read_with_idle_test.sv"
    `include "AHB_APB_Transfer_Synchronization_Test.sv"
    
    //INCR4 Tests
    `include "INCR4_cons_write_read_test.sv"
    `include "INCR4_seq_write_read_test.sv"
    `include "INCR4_write_read_with_idle_test.sv"
    
    //INCR8 Tests
    `include "INCR8_cons_write_read_test.sv"
    `include "INCR8_seq_write_read_test.sv"
    `include "INCR8_write_read_with_idle_test.sv"
    
    //INCR16 Tests
    `include "INCR16_cons_write_read_test.sv"
    `include "INCR16_seq_write_read_test.sv"
    `include "INCR16_write_read_with_idle_test.sv"
    
    `include "user_define_pattern_test.sv"
    `include "random_pattern_test.sv"
    
endpackage
