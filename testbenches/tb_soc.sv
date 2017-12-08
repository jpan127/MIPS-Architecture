`timescale 1ns / 1ps

`define tick1       #10;
`define tick_half   #5;
`define tick5       #50;

// Reset on, clock, reset off
`define reset_system    reset = 1; #10 reset = 0;

module tb_soc;

    // Packages
    import global_types::*;

    // DUT ports
    logic     clock, reset;      // Inputs
    logic [5:0] gpio_in;
    logic32   dmem_wd, alu_out;  // Outputs
    logic     dmem_we;
    logic32   instruction, pc;
    logic16   gpio_out;
    logic5    rf_ra2;
    logic32   rf_rd2;
    integer   n;

    // Testbench variables
    logic16   counter;
    logic [1:0] stop;
    logic32   correct;
    logic16   actual [1:0];
    logic [3:0] state;

    // DUT
    soc DUT(.*);

    // [TASK] Assert values are equal
    task assert_equal;
        input logic [31:0] expected;
        input logic [31:0] actual;
        input string       name;
        begin 
            if (expected == actual)
                $display("[%s] SUCCESS", name);
            else
                $error("[%s] FAILED Expected: %h Actual: %h", name, expected[7:0], actual[7:0]);
        end
    endtask

    function calc_factorial(input logic4 n, output logic32 ret);
        begin 
            ret = 1;
            for (logic[31:0] i=2; i<(n+1); i++) begin 
                ret *= i;
            end
            return ret;
        end
    endfunction : calc_factorial

    // Initial state
    initial begin
        $display("///////////////////////////////////////////////////////////////////////");
        clock   = 0;
        { actual[1], actual[0] } = 0;
        `reset_system
    end

    // Generate #10 cycle clock
    always #5 clock = ~clock;

    // Testbench
    initial begin 

        #10;

        for (n=0; n<12; n++) begin 

            gpio_in = n;

            // Wait until last instruction
            do #10; while (instruction != 32'h08000000);

            // Get correct result
            #30 calc_factorial(n, correct);

            actual[0] = gpio_out;
            gpio_in[5:4] = 2'b01;

            #1 actual[1] = gpio_out;

            if ({actual[1], actual[0]} != correct) begin 
                $display("[%t] GPIO OUT %d FAILED, CORRECT: %d, ACTUAL: %d", $realtime(), n, correct, {actual[1], actual[0]});
            end
            else begin 
                $display("[%t] GPIO OUT %d SUCCESS", $realtime(), n);
            end

        end

        $display("///////////////////////////////////////////////////////////////////////");
        $stop;
    end

endmodule