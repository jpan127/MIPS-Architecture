`timescale 1ns / 1ps

module flusher

(   input        clock, reset,
    input [31:0] instruction,
    output logic f_flush, d_flush, e_flush, m_flush, w_flush );

    import global_types::*;

    logic6 opcode, funct;
    assign opcode = instruction[31:26];
    assign funct  = instruction[5:0];

    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin 
            f_flush <= 0;
            d_flush <= 0;
            e_flush <= 0;
            m_flush <= 0;
            w_flush <= 0;
        end
        // Jump or Jump And Link
        else if (opcode == OPCODE_J || opcode == OPCODE_JAL) begin 
            // f_flush <= 1;
        end
        // Jump Register
        else if (opcode == OPCODE_R && funct == FUNCT_JR) begin 
            // f_flush <= 1;
        end
        else begin 
            f_flush <= 0;
            d_flush <= 0;
            e_flush <= 0;
            m_flush <= 0;
            w_flush <= 0;
        end
    end

endmodule