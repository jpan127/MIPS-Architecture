`timescale 1ns / 1ps

module fetch_reg

(   input    clock, reset,
    FetchBus fetch_bus     );

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            fetch_bus.w_pc <= 0;
        end else begin
            fetch_bus.w_pc <= fetch_bus.f_pc;
        end
    end

endmodule

module decode_reg

(   input       clock, reset,
    DecodeBus   decode_bus    );

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

module execute_reg

(   input       clock, reset,
    // ControlBus.ControlSignals   control_signals,
    // ControlBus.ExternalSignals  control_external,
    ExecuteBus  execute_bus    );

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            execute_bus.e_rd0       <= 0;
            execute_bus.e_rd1       <= 0;
            execute_bus.e_ra1       <= 0;
            execute_bus.e_wa0       <= 0;
            execute_bus.e_wa1       <= 0;
            execute_bus.e_sign_imm  <= 0;
            execute_bus.e_pc_plus4  <= 0;
        end else begin
            execute_bus.e_rd0       <= execute_bus.d_rd0;
            execute_bus.e_rd1       <= execute_bus.d_rd1;
            execute_bus.e_ra1       <= execute_bus.d_ra1;
            execute_bus.e_wa0       <= execute_bus.d_wa0;
            execute_bus.e_wa1       <= execute_bus.d_wa1;
            execute_bus.e_sign_imm  <= execute_bus.d_sign_imm;
            execute_bus.e_pc_plus4  <= execute_bus.d_pc_plus4;
        end
    end

    // always_ff @(posedge clock or posedge reset) begin
    //     if (reset) begin
    //         execute_bus.d_control_bus_control   <= 0;
    //         execute_bus.d_control_bus_external  <= 0;
    //     end else begin
    //         execute_bus.d_control_bus_control   <= 0;
    //         execute_bus.d_control_bus_external  <= 0;
    //     end
    // end

endmodule

module memory_reg

(   input       clock, reset,
    MemoryBus   memory_bus    );

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            // memory_bus.e_rd0       <= 0;
            // memory_bus.e_rd1       <= 0;
            // memory_bus.e_ra1       <= 0;
            // memory_bus.e_wa0       <= 0;
            // memory_bus.e_wa1       <= 0;
            // memory_bus.e_sign_imm  <= 0;
            // memory_bus.e_pc_plus4  <= 0;
        end else begin
            // memory_bus.e_rd0       <= d_rd0;
            // memory_bus.e_rd1       <= d_rd1;
            // memory_bus.e_ra1       <= d_ra1;
            // memory_bus.e_wa0       <= d_wa0;
            // memory_bus.e_wa1       <= d_wa1;
            // memory_bus.e_sign_imm  <= d_sign_imm;
            // memory_bus.e_pc_plus4  <= d_pc_plus4;
        end
    end

endmodule