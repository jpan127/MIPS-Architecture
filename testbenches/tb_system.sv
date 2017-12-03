`timescale 1ns / 1ps

`define tick1       #10;
`define tick_half   #5;
`define tick5       #50;

// Reset on, clock, reset off
`define reset_system    reset = 1; #10 reset = 0;

module tb_system;

    // Packages
    import global_types::*;

    // DUT ports
    logic     clock, reset;      // Inputs
    logic32   dmem_wd, alu_out;  // Outputs
    logic     dmem_we;
    logic32   instruction;

    // Testbench variables
    logic16    counter;

    // DUT
    system_debug DUT(.*);

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

    // Initial state
    initial begin
        $display("///////////////////////////////////////////////////////////////////////");
        clock = 0;
        `reset_system
    end

    // Generate #10 cycle clock
    always #5 clock = ~clock;

    // Increment counter every clock
    always_ff @(posedge clock, posedge reset) begin

        // Reset
        if (reset) begin
            counter <= 0;
        end

        // No reset
        else begin

            // Stop simulation after program ends
            if (instruction == 32'h0800001F) begin
                assert_equal(32'h18, DUT.MIPS.DP.RF.rf[REG_2], "ALU FINAL RESULT");
                $display("Total Instructions: %d", counter);
                $display("///////////////////////////////////////////////////////////////////////");
                $stop;
            end

            // Program has not ended
            else begin 
                // Increment Counter
                counter <= counter + 1;

                // Check dmem write data only when write enable is on
                if (dmem_we) begin 
                    // Check each case when it should be writing data to dmem
                    case (alu_out[9:0]) 
                        10'h1FC: assert_equal(32'h4,  dmem_wd, "DMEM_WD 1" );
                        10'h1F8: assert_equal(32'hC,  dmem_wd, "DMEM_WD 2" );   // Assembler says 0x8 but we use JAL = PC + 8
                        10'h1F4: assert_equal(32'h3,  dmem_wd, "DMEM_WD 3" );
                        10'h1F0: assert_equal(32'h58, dmem_wd, "DMEM_WD 4" );
                        10'h1EC: assert_equal(32'h2,  dmem_wd, "DMEM_WD 5" );
                        10'h1E8: assert_equal(32'h58, dmem_wd, "DMEM_WD 6" );
                        10'h1E4: assert_equal(32'h1,  dmem_wd, "DMEM_WD 7" );
                        10'h1E0: assert_equal(32'h58, dmem_wd, "DMEM_WD 8" );
                    endcase
                end
            end
        end
    end

endmodule