`timescale 1ns / 1ps

module flusher

(   input        clock, reset,
    input [31:0] instruction,
    output       flush        );

    import global_types::*;

    logic6 opcode, funct;
    assign opcode = instruction[31:26];
    assign funct  = instruction[5:0];

    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin 
            flust <= 0;
        end
        else if (opcode == OPCODE_J || opcode == OPCODE_JAL) begin 
            flush <= 1;
        end
        else if (opcode == OPCODE_R && funct == FUNCT_JR) begin 
            flush <= 1;
        end
        else begin 
            flush <= 0;
        end
    end

endmodule