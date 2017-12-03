`timescale 1ns / 1ps

module staller

(   input        reset,
    input [4:0]  d_rs, e_rt, d_rt,
    input [1:0]  w_sel_result,
    output logic f_stall, d_stall, e_flush );

    import global_types::*;

    // If decode rs / rt is the same as rt at execute stage,
    // If also instruction is LW,
    // Then stall/freeze FETCH and DECODE then flush EXECUTE 
    always_comb begin 
        if ((!reset) && ((d_rs == e_rt) | (d_rt == e_rt)) && (w_sel_result == SEL_RESULT_RD)) begin 
            { f_stall, d_stall, e_flush } = 3'b111;
        end
        else begin 
            { f_stall, d_stall, e_flush } = 3'b000;
        end
    end

endmodule

module forwarder

(   input        [4:0] e_rs, e_rt,
    input        [4:0] m_rf_wa, w_rf_wa,
    input              m_rf_we, w_rf_we,
    output logic [1:0] forward_alu_a, forward_alu_b );

    // Forward for ALU port a
    always_comb begin
        // If execute rs is the same as the write address 1 stage ahead,
        // If 1 stage ahead is writing to RF
        // Forward data from m_alu_out to alu_a
        if ( (e_rs != 0) & (e_rs == m_rf_wa) & (m_rf_we) ) begin 
            forward_alu_a = 2'b10;
        end
        // If execute rs is the same as the write address 2 stages ahead,
        // If 2 stages ahead is writing to RF
        // Forward data from result to alu_a
        else if ( (e_rs != 0) & (e_rs == w_rf_wa) & (w_rf_we) ) begin 
            forward_alu_a = 2'b01;
        end
        // Don't forward, pass e_rd0 to alu_a
        else begin 
            forward_alu_a = 2'b00;
        end
    end

    // Forward for ALU port b
    always_comb begin 
        // If execute rt is the same as the write address 1 stage ahead,
        // If 1 stage ahead is writing to RF
        // Forward data from m_alu_out to alu_b
        if ( (e_rt != 0) & (e_rt == m_rf_wa) & (m_rf_we) ) begin 
            forward_alu_b = 2'b10;
        end
        // If execute rt is the same as the write address 2 stages ahead,
        // If 2 stages ahead is writing to RF
        // Forward data from result to alu_b
        else if ( (e_rt != 0) & (e_rt == w_rf_wa) & (w_rf_we) ) begin 
            forward_alu_b = 2'b01;
        end
        // Don't forward, pass e_rd1 to alu_b
        else begin 
            forward_alu_b = 2'b00;
        end
    end

endmodule

module hazard_controller

(   input        reset,                                 // Just so does not trigger on reset
    input  [4:0] d_rs, d_rt, e_rs, e_rt,                // Register operands
    input  [4:0] m_rf_wa, w_rf_wa,                      // RF write register 1-2 stages ahead
    input        m_rf_we, w_rf_we,                      // RF write enable 1-2 stages ahead
    input  [1:0] w_sel_result,                          // Mux result select control signal
    output [1:0] sel_forward_alu_a, sel_forward_alu_b,  // Mux forward select control signals
    output       f_stall, d_stall, e_flush    );        // Stall/Freeze control signals

    staller STALL_CONTROLLER
    (
        .d_rs          (d_rs),
        .e_rt          (e_rt),
        .d_rt          (d_rt),
        .w_sel_result  (w_sel_result),
        .f_stall       (f_stall),
        .d_stall       (d_stall),
        .e_flush       (e_flush)
    );

    forwarder FORWARD_CONTROLLER
    (
        .e_rs          (e_rs),
        .e_rt          (e_rt),
        .m_rf_wa       (m_rf_wa),
        .w_rf_wa       (w_rf_wa),
        .m_rf_we       (m_rf_we),
        .w_rf_we       (w_rf_we),
        .forward_alu_a (sel_forward_alu_a),
        .forward_alu_b (sel_forward_alu_b)
    );

endmodule