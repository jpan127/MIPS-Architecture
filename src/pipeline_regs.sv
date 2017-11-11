`timescale 1ns / 1ps

module fetch_reg

    // Packages
    import pipeline_pkg::FetchBus;

(   input    clock, reset,
    FetchBus fetch_bus     );

    // Datapath Signals
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            fetch_bus.f_pc <= 0;
        end else begin
            fetch_bus.f_pc <= fetch_bus.w_pc;
        end
    end

endmodule

module decode_reg

    // Packages
    import pipeline_pkg::DecodeBus;

(   input       clock, reset,
    DecodeBus   decode_bus    );

    // Datapath Signals
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            decode_bus.d_instruction <= 0;
            decode_bus.d_pc_plus4    <= 0;
        end else begin
            decode_bus.d_instruction <= decode_bus.f_instruction;
            decode_bus.d_pc_plus4    <= decode_bus.f_pc_plus4;
        end
    end

endmodule

// module execute_reg

//     // Packages
//     import pipeline_pkg::ExecuteBus;

// (   input       clock, reset,
//     ExecuteBus  execute_bus    );

//     // Datapath Signals
//     always_ff @(posedge clock or posedge reset) begin
//         if (reset) begin
//             execute_bus.e_rd0       <= 0;
//             execute_bus.e_rd1       <= 0;
//             execute_bus.e_ra1       <= 0;
//             execute_bus.e_wa0       <= 0;
//             execute_bus.e_wa1       <= 0;
//             execute_bus.e_sign_imm  <= 0;
//             execute_bus.e_pc_plus4  <= 0;
//         end else begin
//             execute_bus.e_rd0       <= execute_bus.d_rd0;
//             execute_bus.e_rd1       <= execute_bus.d_rd1;
//             execute_bus.e_ra1       <= execute_bus.d_ra1;
//             execute_bus.e_wa0       <= execute_bus.d_wa0;
//             execute_bus.e_wa1       <= execute_bus.d_wa1;
//             execute_bus.e_sign_imm  <= execute_bus.d_sign_imm;
//             execute_bus.e_pc_plus4  <= execute_bus.d_pc_plus4;
//         end
//     end

//     // Control Signals
//     always_ff @(posedge clock or posedge reset) begin
//         if (reset) begin
//             execute_bus.e_alu_ctrl      <= 0;
//             execute_bus.e_rf_we         <= 0;
//             execute_bus.e_sel_alu_b     <= 0;
//             execute_bus.e_sel_pc        <= 0;
//             execute_bus.e_sel_result    <= 0;
//             execute_bus.e_sel_wa        <= 0;
//             execute_bus.e_dmem_we       <= 0;
//         end else begin
//             execute_bus.e_alu_ctrl      <= execute_bus.d_alu_ctrl;
//             execute_bus.e_rf_we         <= execute_bus.d_rf_we;
//             execute_bus.e_sel_alu_b     <= execute_bus.d_sel_alu_b;
//             execute_bus.e_sel_pc        <= execute_bus.d_sel_pc;
//             execute_bus.e_sel_result    <= execute_bus.d_sel_result;
//             execute_bus.e_sel_wa        <= execute_bus.d_sel_wa;
//             execute_bus.e_dmem_we       <= execute_bus.d_dmem_we;
//         end
//     end

// endmodule

// module memory_reg

//     // Packages
//     import pipeline_pkg::MemoryBus;

// (   input       clock, reset,
//     MemoryBus   memory_bus    );

//     // Datapath Signals
//     always_ff @(posedge clock or posedge reset) begin
//         if (reset) begin
//             memory_bus.m_alu_out       <= 0;
//             memory_bus.m_dmem_wd       <= 0;
//             memory_bus.m_rf_wa         <= 0;
//             memory_bus.m_pc_branch     <= 0;
//         end else begin
//             memory_bus.m_alu_out       <= memory_bus.e_alu_out;
//             memory_bus.m_dmem_wd       <= memory_bus.e_dmem_wd;
//             memory_bus.m_rf_wa         <= memory_bus.e_rf_wa;
//             memory_bus.m_pc_branch     <= memory_bus.e_pc_branch;
//         end
//     end

//     // Control Signals
//     always_ff @(posedge clock or posedge reset) begin
//         if (reset) begin
//             memory_bus.m_rf_we         <= 0;
//             memory_bus.m_sel_pc        <= 0;
//             memory_bus.m_sel_result    <= 0;
//             memory_bus.m_dmem_we       <= 0;
//         end else begin
//             memory_bus.m_rf_we         <= memory_bus.e_rf_we;
//             memory_bus.m_sel_pc        <= memory_bus.e_sel_pc;
//             memory_bus.m_sel_result    <= memory_bus.e_sel_result;
//             memory_bus.m_dmem_we       <= memory_bus.e_dmem_we;
//         end
//     end

//     // Status Signals
//     always_ff @(posedge clock or posedge reset) begin 
//         if (reset) begin 
//             memory_bus.m_zero          <= 0;
//         end
//         else begin 
//             memory_bus.m_zero          <= memory_bus.e_zero;
//         end
//     end

// endmodule

// module writeback_reg

//     // Packages
//     import pipeline_pkg::WritebackBus;

// (   input           clock, reset,
//     WritebackBus    writeback_bus    );

//     // Datapath Signals
//     always_ff @(posedge clock or posedge reset) begin
//         if (reset) begin
//             writeback_bus.w_dmem_rd     <= 0;
//             writeback_bus.w_alu_out     <= 0;
//             writeback_bus.w_rf_wa       <= 0;
//         end else begin
//             writeback_bus.w_dmem_rd     <= writeback_bus.m_dmem_rd;
//             writeback_bus.w_alu_out     <= writeback_bus.m_alu_out;
//             writeback_bus.w_rf_wa       <= writeback_bus.m_rf_wa;
//         end
//     end

//     // Control Signals
//     always_ff @(posedge clock or posedge reset) begin
//         if (reset) begin
//             writeback_bus.w_rf_we         <= 0;
//             writeback_bus.w_sel_result    <= 0;
//         end else begin
//             writeback_bus.w_rf_we         <= writeback_bus.m_rf_we;
//             writeback_bus.w_sel_result    <= writeback_bus.m_sel_result;
//         end
//     end

// endmodule