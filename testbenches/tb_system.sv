`timescale 1ns / 1ps

// [MACRO] Wait an entire clock cycle
`define tick            #10;
`define half_tick       #5;
// [MACRO] Reset on, clock, reset off
`define reset_system    reset = 1; #10 reset = 0;

module tb_system;

    // DUT ports
    logic        clock, reset,      // Inputs
    logic [31:0] dmem_wd, alu_out;  // Outputs
    logic        dmem_we;
    logic [31:0] instruction;
    logic [31:0] pc;
    logic [9:0]  dmem_addr;
    logic [31:0] dmem_rd;

    // Testbench variables
    logic [4:0]  counter;
    localparam   max = 23;

    // DUT
    system DUT(.*);

    // Tasks
    task log;
        begin
            if (dmem_we) begin 
                $display("DMEM Write Data : %d", dmem_wd);
            end
            $display("ALU             : %d", alu_out);
            $display("IMEM[%d]        : %H", pc[11:2], instruction);
            $display("DMEM[%d] Read   : %d", dmem_addr, dmem_rd);
        end
    endtask

    // Initial state
    initial begin
        clock   = 0;
        counter = 0;
        `reset_system
    end

    // Generate #10 cycle clock
    always #5 clock = ~clock;

    // Increment counter every clock
    always_ff @(posedge clock) begin
        counter <= counter + 1;
        log;
    end

    // Stop every 23 cycles
    always_comb if (counter == max) $stop;

endmodule