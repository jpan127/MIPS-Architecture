`ifndef TESTBENCH_GLOBALS_SV
`define TESTBENCH_GLOBALS_SV

//// Functions and typedefs / structs for datapath testing
package testbench_globals;

    // Packages
    import global_types::*;

    // Returns an I-Type instruction
    function logic32 set_instruction_i(input logic6 opcode, logic5 rs, logic5 rt, logic16 imm);
        return { opcode, rs, rt, imm };
    endfunction

    // Returns an J-Type instruction
    function logic32 set_instruction_j(input logic6 opcode, logic [25:0] address);
        return { opcode, address };
    endfunction

    // Returns an R-Type instruction
    function logic32 set_instruction_r(input logic6 opcode, logic5 rs, logic5 rt, logic5 rd, logic5 shamt, logic6 funct);
        return { opcode, rs, rt, rd, shamt, funct };
    endfunction

    // Testbench control struct
    typedef struct packed
    {
        rf_we_t      rf_we;
        sel_wa_t     sel_wa;
        sel_alu_b_t  sel_alu_b;
        sel_result_t sel_result;
        sel_pc_t     sel_pc;
        alu_ctrl_t   alu_ctrl;
    } testbench_control_t;

    // All the controls to test
    testbench_control_t
    // I-Type
    TB_LWc     = '{ RF_WE_ENABLE,  SEL_WA_WA0, SEL_ALU_B_SIGN_IMM, SEL_RESULT_RD,        SEL_PC_PC_PLUS4, ADDac       },
    TB_SWc     = '{ RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_SIGN_IMM, SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, ADDac       },
    TB_ADDIc   = '{ RF_WE_ENABLE,  SEL_WA_WA0, SEL_ALU_B_SIGN_IMM, SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, ADDIac      },
    TB_BEQc    = '{ RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_DMEM_WD,  SEL_RESULT_ALU_OUT,   SEL_PC_BRANCH,   SUBac       },
    TB_BEQNc   = '{ RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_DMEM_WD,  SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, SUBac       },
    // J-Type
    TB_Jc      = '{ RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_DMEM_WD,  SEL_RESULT_ALU_OUT,   SEL_PC_JUMP,     DONT_CAREac },
    TB_JALc    = '{ RF_WE_ENABLE,  SEL_WA_31,  SEL_ALU_B_DMEM_WD,  SEL_RESULT_PC_PLUS8,  SEL_PC_JUMP,     DONT_CAREac },
    // R-Type
    TB_JRc     = '{ RF_WE_DISABLE, SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  SEL_RESULT_ALU_OUT,   SEL_PC_JR,       JRac        },
    TB_Rc      = '{ RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, DONT_CAREac },
    TB_ADDc    = '{ RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, ADDac       },
    TB_ANDc    = '{ RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, ANDac       },
    TB_ORc     = '{ RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, ORac        },
    TB_SLTc    = '{ RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, SLTac       },
    TB_SUBc    = '{ RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, SUBac       },
    TB_DIVUc   = '{ RF_WE_DISABLE, SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  SEL_RESULT_DONT_CARE, SEL_PC_PC_PLUS4, DIVUac      },
    TB_MFHIc   = '{ RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, MFHIac      },
    TB_MFLOc   = '{ RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, MFLOac      },
    TB_MULTUc  = '{ RF_WE_DISABLE, SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  SEL_RESULT_DONT_CARE, SEL_PC_PC_PLUS4, MULTUac     };

endpackage

`endif