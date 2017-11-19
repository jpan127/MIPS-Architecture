`timescale 1ns / 1ps

module fetch_reg

    // Packages
    import pipeline_pkg::FetchBus;

(   input    clock, reset, flush,
    FetchBus fetch_bus     );

    // Datapath Signals
    always_ff @(posedge clock or posedge reset) begin
        if (reset || flush) begin
            fetch_bus.f_pc <= 0;
        end else begin
            fetch_bus.f_pc <= fetch_bus.w_pc;
        end
    end

endmodule

module decode_reg

    // Packages
    import pipeline_pkg::DecodeBus;

(   input       clock, reset, flush,
    DecodeBus   decode_bus    );

    // Datapath Signals
    always_ff @(posedge clock or posedge reset) begin
        if (reset || flush) begin
            decode_bus.d_instruction <= 0;
            decode_bus.d_pc_plus4    <= 0;
        end else begin
            decode_bus.d_instruction <= decode_bus.f_instruction;
            decode_bus.d_pc_plus4    <= decode_bus.f_pc_plus4;
        end
    end

endmodule

module execute_reg

    // Packages
    import pipeline_pkg::ExecuteBus;
    import global_types::*;

(   input       clock, reset, flush,
    ExecuteBus  execute_bus    );

    // Datapath Signals
    always_ff @(posedge clock or posedge reset) begin
        if (reset || flush) begin
            execute_bus.e_rd0         <= 0;
            execute_bus.e_rd1         <= 0;
            execute_bus.e_wa0         <= 0;
            execute_bus.e_wa1         <= 0;
            execute_bus.e_sign_imm    <= 0;
            execute_bus.e_pc_plus4    <= 0;
        end else begin
            execute_bus.e_rd0         <= execute_bus.d_rd0;
            execute_bus.e_rd1         <= execute_bus.d_rd1;
            execute_bus.e_wa0         <= execute_bus.d_wa0;
            execute_bus.e_wa1         <= execute_bus.d_wa1;
            execute_bus.e_sign_imm    <= execute_bus.d_sign_imm;
            execute_bus.e_pc_plus4    <= execute_bus.d_pc_plus4;
        end
    end

    // Control Signals
    always_ff @(posedge clock or posedge reset) begin
        if (reset || flush) begin
            execute_bus.e_alu_ctrl      <= alu_ctrl_t'(0);
            execute_bus.e_rf_we         <= rf_we_t'(0);
            execute_bus.e_sel_alu_b     <= sel_alu_b_t'(0);
            execute_bus.e_sel_pc        <= sel_pc_t'(0);
            execute_bus.e_sel_result    <= sel_result_t'(0);
            execute_bus.e_sel_wa        <= sel_wa_t'(0);
            execute_bus.e_dmem_we       <= dmem_we_t'(0);
        end else begin
            execute_bus.e_alu_ctrl      <= execute_bus.d_alu_ctrl;
            execute_bus.e_rf_we         <= execute_bus.d_rf_we;
            execute_bus.e_sel_alu_b     <= execute_bus.d_sel_alu_b;
            execute_bus.e_sel_pc        <= execute_bus.d_sel_pc;
            execute_bus.e_sel_result    <= execute_bus.d_sel_result;
            execute_bus.e_sel_wa        <= execute_bus.d_sel_wa;
            execute_bus.e_dmem_we       <= execute_bus.d_dmem_we;
        end
    end

endmodule

module memory_reg

    // Packages
    import pipeline_pkg::MemoryBus;
    import global_types::*;

(   input       clock, reset, flush,
    MemoryBus   memory_bus    );

    // Datapath Signals
    always_ff @(posedge clock or posedge reset) begin
        if (reset || flush) begin
            memory_bus.m_alu_out       <= 0;
            memory_bus.m_dmem_wd       <= 0;
            memory_bus.m_rf_wa         <= 0;
            memory_bus.m_pc_plus4      <= 0;
        end else begin
            memory_bus.m_alu_out       <= memory_bus.e_alu_out;
            memory_bus.m_dmem_wd       <= memory_bus.e_dmem_wd;
            memory_bus.m_rf_wa         <= memory_bus.e_rf_wa;
            memory_bus.m_pc_plus4      <= memory_bus.e_pc_plus4;
        end
    end

    // Control Signals
    always_ff @(posedge clock or posedge reset) begin
        if (reset || flush) begin
            memory_bus.m_rf_we         <= rf_we_t'(0);
            memory_bus.m_sel_pc        <= sel_pc_t'(0);
            memory_bus.m_sel_result    <= sel_result_t'(0);
            memory_bus.m_dmem_we       <= dmem_we_t'(0);
        end else begin
            memory_bus.m_rf_we         <= memory_bus.e_rf_we;
            memory_bus.m_sel_pc        <= memory_bus.e_sel_pc;
            memory_bus.m_sel_result    <= memory_bus.e_sel_result;
            memory_bus.m_dmem_we       <= memory_bus.e_dmem_we;
        end
    end

    // Status Signals
    always_ff @(posedge clock or posedge reset) begin 
        if (reset || flush) begin 
            memory_bus.m_zero          <= 0;
        end
        else begin 
            memory_bus.m_zero          <= memory_bus.e_zero;
        end
    end

endmodule

module writeback_reg

    // Packages
    import pipeline_pkg::WritebackBus;
    import global_types::*;

(   input           clock, reset, flush,
    WritebackBus    writeback_bus    );

    // Datapath Signals
    always_ff @(posedge clock or posedge reset) begin
        if (reset || flush) begin
            writeback_bus.w_dmem_rd     <= 0;
            writeback_bus.w_alu_out     <= 0;
            writeback_bus.w_rf_wa       <= 0;
            writeback_bus.w_pc_plus4    <= 0;
        end else begin
            writeback_bus.w_dmem_rd     <= writeback_bus.m_dmem_rd;
            writeback_bus.w_alu_out     <= writeback_bus.m_alu_out;
            writeback_bus.w_rf_wa       <= writeback_bus.m_rf_wa;
            writeback_bus.w_pc_plus4    <= writeback_bus.m_pc_plus4;
        end
    end

    // Control Signals
    always_ff @(posedge clock or posedge reset) begin
        if (reset || flush) begin
            writeback_bus.w_rf_we         <= rf_we_t'(0);
            writeback_bus.w_sel_result    <= sel_result_t'(0);
        end else begin
            writeback_bus.w_rf_we         <= writeback_bus.m_rf_we;
            writeback_bus.w_sel_result    <= writeback_bus.m_sel_result;
        end
    end

endmodule