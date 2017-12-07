`timescale 1ns / 1ps

`define tick1       #10;
`define tick_half   #5;
`define tick5       #50;

// Reset on, clock, reset off
`define reset_system    reset = 1; #10 reset = 0;

module tb_hazards;

    // Packages
    import testbench_globals::*;
    import global_types::*;

    // DUT ports
    // Inputs
    logic6 d_rs, d_rt, e_rs, e_rt;                // Register operands
    logic6 m_rf_wa, w_rf_wa;                      // RF write register 1-2 stages ahead
    logic  m_rf_we, w_rf_we;                      // RF write enable 1-2 stages ahead
    logic3 w_sel_result;                          // Mux result select control signal
    // Outputs
    logic2 sel_forward_alu_a, sel_forward_alu_b;  // Mux forward select control signals
    logic  f_stall, d_stall, e_flush;             // Stall/Freeze control signals


    // Device Under Testing
    hazard_controller DUT(.*);

    // Initial state
    initial begin 
        d_rs         = 0;
        d_rt         = 0;
        e_rs         = 0;
        e_rt         = 0;
        m_rf_wa      = 0;
        w_rf_wa      = 0;
        m_rf_we      = 0;
        w_rf_we      = 0;
        w_sel_result = 0;
    end

    // Asserts two values are equal, returns 1 for yes, 0 for no
    function logic assert_equal;
        input logic32 expected;
        input logic32 actual;
        input string  name;
        begin 
            assert(expected == actual)
            begin
                return 1;
            end
            else
            begin
                $error("[%s] FAILED EQUAL Expected: %d Actual: %d", name, expected, actual);
                return 0;
            end
        end
    endfunction

    // Testbench
    initial begin
        $display("///////////////////////////////////////////////////////////////////////");

        for (int i=0; i<4; i++) begin 
            w_sel_result = i;
            for (int j=0; j<64; j++) begin 
                d_rs = j;
                for (int k=0; k<64; k++) begin 
                    d_rt = k;
                    for (int l=0; l<64; l++) begin 
                        e_rs = l;
                        for (int m=0; m<64; m++) begin 
                            e_rt = m;
                            #1;
                            if ( ((d_rs == e_rt) | (d_rt == e_rt)) & w_sel_result == SEL_RESULT_RD ) begin 
                                assert_equal(1'b1, e_flush, "e_flush");
                                assert_equal(1'b1, f_stall, "f_stall");
                                assert_equal(1'b1, d_stall, "d_stall");
                            end
                        end
                    end
                end
            end
        end

        $display("///////////////////////////////////////////////////////////////////////");
        $stop;
    end

endmodule