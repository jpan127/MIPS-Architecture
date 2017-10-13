`timescale 1ns / 1ps

module tb_datapath;

    import testbench_helpers::*;

    // DUT Ports
    reg         clock, reset, sel_alu_b, rf_we;
    reg  [1:0]  sel_pc, sel_result, sel_wa;
    reg  [3:0]  alu_ctrl;
    reg  [31:0] instruction, rd;
    wire [31:0] pc, alu_out, dmem_wd;
    wire        zero;

    // Testbench Variables
    integer i;

    // Control signal
    reg  [11:0] ctrl;
    always @* begin
        {
            rf_we,          // 1 bit
            sel_wa,         // 2 bits
            sel_alu_b,      // 1 bit
            sel_result,     // 2 bits
            sel_pc,         // 2 bits
            alu_ctrl        // 4 bits
        } = ctrl;
    end

    // Instructions To Test
    localparam LW_0XFF_INTO_REG10 = { 6'h23, 5'd0, 5'd10, 16'hFF };
    localparam SW_REG10_INTO_0XFF = { 6'h2b, 5'd0, 5'd10, 16'hFF };

    // DUT
    datapath DUT(.*);

    // Initial State
    initial begin 
        clock       = 0;
        reset       = 1;
        sel_alu_b   = 0;
        rf_we       = 0;
        sel_pc      = 0;
        sel_result  = 0;
        sel_wa      = 0;
        alu_ctrl    = 0;
        instruction = 0;
        rd          = 0;
        ctrl        = 0;
        i           = 0;
        #10 reset   = 0;
    end

    // Generate #10 period clock
    initial begin forever #5 clock = ~clock; end

    // // Mock instruction functions
    // function void execute_lw(input instr);
    //     instruction = instr;
    //     ctrl        = testbench_lw_ctrl; 
    // endfunction
    // function void execute_sw(input instr);
    //     instruction = instr;
    //     ctrl        = testbench_sw_ctrl; 
    // endfunction
    // function void execute_addi(input immediate);

    // endfunction

    // // Tasks to test mock instructions are working
    // task test_sw_and_lw(input sw_instr, lw_instr);
    //     // Store a constant value 0 first, then load it back to check
    //     execute_lw(sw_instr);
    //     #10;
    //     execute_sw(lw_instr);
    //     #10;
    // endtask

    // Testbench
    initial begin
        $display("///////////////////////////////////////////////////////////////////////");

        // Wait for reset to go low
        #10;

        test_sw_and_lw(LW_0XFF_INTO_REG10, SW_REG10_INTO_0XFF);

        $display("///////////////////////////////////////////////////////////////////////");
        $stop;
    end
    
endmodule
