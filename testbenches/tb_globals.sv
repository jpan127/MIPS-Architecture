`timescale 1ns / 1ps

module tb_globals;

    import global_types::*;
    import control_signals::*;

    // Data types
    ControlBus cb();
    control_t load_word;
    i_instruction_t i;
    j_instruction_t j;
    r_instruction_t r;

    logic num;

    initial begin

        // Test ControlBus
        cb.dmem_we      = DMEM_WE_DISABLE;
        cb.sel_alu_b    = SEL_ALU_B_DMEM_WD;
        cb.rf_we        = RF_WE_DISABLE;
        cb.sel_pc       = SEL_PC_PC_PLUS4;
        cb.sel_wa       = SEL_WA_WA0;
        cb.sel_result   = SEL_RESULT_RD;
        cb.alu_ctrl     = ADDIac;

        #10;

        assert(cb.dmem_we    == DMEM_WE_DISABLE)    else $error("cb.dmem_we incorrect: %s\n",    cb.dmem_we.name());
        assert(cb.sel_alu_b  == SEL_ALU_B_DMEM_WD)  else $error("cb.sel_alu_b incorrect: %s\n",  cb.sel_alu_b.name());
        assert(cb.rf_we      == RF_WE_DISABLE)      else $error("cb.rf_we incorrect: %s\n",      cb.rf_we.name());
        assert(cb.sel_pc     == SEL_PC_PC_PLUS4)    else $error("cb.sel_pc incorrect: %s\n",     cb.sel_pc.name());
        assert(cb.sel_wa     == SEL_WA_WA0)         else $error("cb.sel_wa incorrect: %s\n",     cb.sel_wa.name());
        assert(cb.sel_result == SEL_RESULT_RD)      else $error("cb.sel_result incorrect: %s\n", cb.sel_result.name());
        assert(cb.alu_ctrl   == ADDIac)             else $error("cb.alu_ctrl incorrect: %s\n",   cb.alu_ctrl.name());

        // Test instructions
        load_word = '{  RF_WE_ENABLE,  
                        SEL_WA_WA0, 
                        SEL_ALU_B_SIGN_IMM, 
                        DMEM_WE_DISABLE, 
                        SEL_RESULT_RD, 
                        SEL_PC_JUMP, 
                        ALU_OP_ADDI };

        #10;

        assert(load_word.rf_we      == RF_WE_ENABLE)       
            else $error("load_word.rf_we incorrect: %s\n",       load_word.rf_we.name());
        assert(load_word.sel_wa     == SEL_WA_WA0)         
            else $error("load_word.sel_wa incorrect: %s\n",      load_word.sel_wa.name());
        assert(load_word.sel_alu_b  == SEL_ALU_B_SIGN_IMM) 
            else $error("load_word.sel_alu_b incorrect: %s\n",   load_word.sel_alu_b.name());
        assert(load_word.dmem_we    == DMEM_WE_DISABLE)    
            else $error("load_word.dmem_we incorrect: %s\n",     load_word.dmem_we.name());
        assert(load_word.sel_result == SEL_RESULT_RD)      
            else $error("load_word.sel_result incorrect: %s\n",  load_word.sel_result.name());
        assert(load_word.sel_pc     == SEL_PC_JUMP)    
            else $error("load_word.sel_pc incorrect: %s\n",      load_word.sel_pc.name());
        assert(load_word.alu_op     == ALU_OP_ADDI)        
            else $error("load_word.alu_op incorrect: %s\n",      load_word.alu_op.name());

        assert(decode_control(load_word) == 80)
            else $error("decode_control function not converting to number correctly: %i\n", decode_control(load_word));

        i.opcode    = 6'd63;
        i.rs        = 5'd27;
        i.rt        = 5'd11;
        i.immediate = 16'b1111_1111_1111_1111;

        #10;

        // Convert i type to j type
        {>>{j}} = i;
        assert(j.opcode  == 6'd63) 
            else $error("Converting from i struct to j struct incorrect: %i", j.opcode);
        assert(j.address == {i.rs, i.rt, i.immediate}) 
            else $error("Converting from i struct j struct address incorrect: %i", j.address);

        // Convert from enum to int
        {>>{num}} = load_word.rf_we;
        assert(num == 1)
            else $error("Converting from enum to int should be 1: %i", num);

        $display("Testbench SUCCESS");

    end

endmodule