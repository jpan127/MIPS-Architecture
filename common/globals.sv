`ifndef GLOBALS_SV
`define GLOBALS_SV

// Converting between types: works for structs, or enum >> int, vice versa
// {>>{type2}} = type1

//// Global typedefs, enums, etc
package global_types;

    // Vectors
    typedef logic [1:0]  logic2;
    typedef logic [3:0]  logic4;
    typedef logic [4:0]  logic5;
    typedef logic [5:0]  logic6;
    typedef logic [7:0]  logic8;
    typedef logic [8:0]  logic9;
    typedef logic [9:0]  logic10;
    typedef logic [10:0] logic11;
    typedef logic [11:0] logic12;
    typedef logic [12:0] logic13;
    typedef logic [15:0] logic16;
    typedef logic [25:0] logic26;
    typedef logic [31:0] logic32;
    typedef logic [63:0] logic64;

    // Constants
    localparam logic32  ZERO32 = 'd0,
                        UNUSED = 'd0;

    localparam logic32  NOOP = 32'h60000019;

    localparam logic5   REG_ZERO = 'd0,
                        REG_1    = 'd1,
                        REG_2    = 'd2,
                        REG_3    = 'd3,
                        REG_4    = 'd4,
                        REG_5    = 'd5,
                        REG_6    = 'd6,
                        REG_7    = 'd7,
                        REG_8    = 'd8,
                        REG_9    = 'd9,
                        REG_10   = 'd10,
                        REG_11   = 'd11,
                        REG_12   = 'd12,
                        REG_13   = 'd13,
                        REG_14   = 'd14,
                        REG_15   = 'd15,
                        REG_16   = 'd16,
                        REG_17   = 'd17,
                        REG_18   = 'd18,
                        REG_19   = 'd19,
                        REG_20   = 'd20,
                        REG_21   = 'd21,
                        REG_22   = 'd22,
                        REG_23   = 'd23,
                        REG_24   = 'd24,
                        REG_25   = 'd25,
                        REG_26   = 'd26,
                        REG_27   = 'd27,
                        REG_28   = 'd28,
                        REG_29   = 'd29,
                        REG_SP   = 'd29,
                        REG_30   = 'd30,
                        REG_31   = 'd31,
                        REG_RA   = 'd31;

    // Instruction types
    typedef struct
    {
        logic [5:0] opcode;
        logic [4:0] rs;
        logic [4:0] rt;
        logic [15:0] immediate;
    } i_instruction_t;

    typedef struct
    {
        logic [5:0]  opcode;
        logic [25:0] address;
    } j_instruction_t;

    typedef struct
    {
        logic [5:0] opcode;
        logic [4:0] rs;
        logic [4:0] rt;
        logic [4:0] rd;
        logic [5:0] shamt;
        logic [5:0] funct;
    } r_instruction_t;

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                              Control Signal Enumerations                                  //
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // Control fields, dont_care are when the field does not matter because they are irrelevant to the instruction's path
    typedef enum logic
    {
        RF_WE_DONT_CARE = 1'bZ,
        RF_WE_ENABLE    = 1'b1,
        RF_WE_DISABLE   = 1'b0
    } rf_we_t;

    typedef enum logic [1:0]
    {
        SEL_WA_DONT_CARE    = 2'bZ,
        SEL_WA_WA0          = 2'b00,
        SEL_WA_WA1          = 2'b01,
        SEL_WA_31           = 2'b10,
        SEL_WA_00           = 2'b11
    } sel_wa_t;

    typedef enum logic
    {
        SEL_ALU_B_DONT_CARE = 1'bZ,
        SEL_ALU_B_DMEM_WD   = 1'b0,
        SEL_ALU_B_SIGN_IMM  = 1'b1
    } sel_alu_b_t;

    typedef enum logic [2:0]
    {
        SEL_RESULT_DONT_CARE = 3'bZ,
        SEL_RESULT_RD        = 3'b000,
        SEL_RESULT_ALU_OUT   = 3'b001,
        SEL_RESULT_PC_PLUS8  = 3'b010,
        SEL_RESULT_MFHI      = 3'b011,
        SEL_RESULT_MFLO      = 3'b100,
        SEL_RESULT_00        = 3'b111
    } sel_result_t;

    typedef enum logic [1:0]
    {
        SEL_PC_DONT_CARE = 2'bZ,
        SEL_PC_PC_PLUS4  = 2'b00,
        SEL_PC_BRANCH    = 2'b01,
        SEL_PC_JUMP      = 2'b10,
        SEL_PC_JR        = 2'b11
    } sel_pc_t;

    typedef enum logic
    {
        DMEM_WE_DONT_CARE   = 1'bZ,
        DMEM_WE_DISABLE     = 1'b0,
        DMEM_WE_ENABLE      = 1'b1
    } dmem_we_t;

    // Opcode for ALU decoder, not the actual ALU select signal
    typedef enum logic [1:0]
    {
        ALU_OP_DONT_CARE = 2'bZ,
        ALU_OP_ADDI      = 2'b00,
        ALU_OP_SUBI      = 2'b01,
        ALU_OP_R         = 2'b11     // Does not matter because R-Type instructions only look at funct
    } alu_op_t;

    // ALU control signals
    typedef enum logic [3:0]
    {
        // [TODO] Change these to be named similar to other enums
        DONT_CAREac = 4'dZ,
        ADDIac      = 4'd0,
        SUBIac      = 4'd1,
        ADDac       = 4'd2,
        SUBac       = 4'd3,
        ANDac       = 4'd4,
        ORac        = 4'd5,
        SLTac       = 4'd6,
        MULTUac     = 4'd7,
        DIVUac      = 4'd8,
        MFHIac      = 4'd9,
        MFLOac      = 4'd10,
        JRac        = 4'd11,
        NOPac       = 4'd12,
        SLLac       = 4'd13,
        SRLac       = 4'd14
    } alu_ctrl_t;

    typedef enum logic [5:0]
    {
        // ADD, ADDU, AND, NOR, OR, SLTU, SLL, SRL, SUBU, DIV, 
        // DIVU, MFHI, MFLO, MULT, MULTU, SRA, SLT, JR
        OPCODE_R        = 'h00,
        OPCODE_ADDI     = 'h08,
        OPCODE_ADDIU    = 'h09,
        OPCODE_ANDI     = 'h0C,
        OPCODE_BEQ      = 'h04,
        OPCODE_BNE      = 'h05,
        OPCODE_J        = 'h02,
        OPCODE_JAL      = 'h03,
        OPCODE_LBU      = 'h24,
        OPCODE_LHU      = 'h25,
        OPCODE_LL       = 'h30,
        OPCODE_LUI      = 'h0F,
        OPCODE_LW       = 'h23,
        OPCODE_ORI      = 'h0D,
        OPCODE_SLTI     = 'h0A,
        OPCODE_SLTIU    = 'h0B,
        OPCODE_SB       = 'h28,
        OPCODE_SC       = 'h38,
        OPCODE_SW       = 'h2b
    } opcode_t;

    typedef enum logic [5:0]
    {
        FUNCT_ADD       = 'h20,
        FUNCT_ADDU      = 'h21,
        FUNCT_AND       = 'h24,
        FUNCT_JR        = 'h08,
        FUNCT_NOP       = 'h00,
        FUNCT_NOR       = 'h27,
        FUNCT_OR        = 'h25,
        FUNCT_SLT       = 'h2A,
        FUNCT_SLTU      = 'h2b,
        // FUNCT_SLL       = 'h00,  // Maybe implement in the future
        FUNCT_SRL       = 'h02,
        FUNCT_SUB       = 'h22,
        FUNCT_SUBU      = 'h23,
        FUNCT_DIV       = 'h1A,
        FUNCT_DIVU      = 'h1B,
        FUNCT_MFHI      = 'h10,
        FUNCT_MFLO      = 'h12,
        FUNCT_MULT      = 'h18,
        FUNCT_MULTU     = 'h19,
        FUNCT_SRA       = 'h03
    } funct_t;

endpackage



//// For control unit
package control_signals;

    import global_types::*;

    // Control unit control struct (12 bits)
    typedef struct packed
    {
        rf_we_t      rf_we;         // 1 bit
        sel_wa_t     sel_wa;        // 2 bits
        sel_alu_b_t  sel_alu_b;     // 1 bit
        dmem_we_t    dmem_we;       // 1 bit
        sel_result_t sel_result;    // 3 bits
        sel_pc_t     sel_pc;        // 2 bits
        alu_op_t     alu_op;        // 2 bits
    } control_t;

    // Control unit control signals for each instruction
    // Instructions besides ADDI using ALU_OP_ADDI are not actually adding, they just don't care
    control_t
    // I-Type
    LWc     = '{ RF_WE_ENABLE,  SEL_WA_WA0, SEL_ALU_B_SIGN_IMM, DMEM_WE_DISABLE, SEL_RESULT_RD,        SEL_PC_PC_PLUS4, ALU_OP_ADDI }, 
    SWc     = '{ RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_SIGN_IMM, DMEM_WE_ENABLE,  SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, ALU_OP_ADDI }, 
    ADDIc   = '{ RF_WE_ENABLE,  SEL_WA_WA0, SEL_ALU_B_SIGN_IMM, DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, ALU_OP_ADDI },
    BEQc    = '{ RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,   SEL_PC_BRANCH,   ALU_OP_SUBI },
    BEQNc   = '{ RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, ALU_OP_SUBI },
    // J-Type
    // sel_pc should select jump but since it is being overridden before the control unit, then selecting jump would jump twice
    Jc      = '{ RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, ALU_OP_ADDI },
    JALc    = '{ RF_WE_ENABLE,  SEL_WA_31,  SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_PC_PLUS8,  SEL_PC_PC_PLUS4, ALU_OP_ADDI },
    // R-Type
    NOPc    = '{ RF_WE_DISABLE, SEL_WA_00,  SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_00,        SEL_PC_PC_PLUS4, ALU_OP_R    },    
    JRc     = '{ RF_WE_DISABLE, SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,   SEL_PC_JR,       ALU_OP_R    },    
    Rc      = '{ RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, ALU_OP_R    },
    ADDc    = '{ RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, ALU_OP_R    },
    ORc     = '{ RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, ALU_OP_R    },
    SLTc    = '{ RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, ALU_OP_R    },
    SUBc    = '{ RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,   SEL_PC_PC_PLUS4, ALU_OP_R    },
    DIVUc   = '{ RF_WE_DISABLE, SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_DONT_CARE, SEL_PC_PC_PLUS4, ALU_OP_R    },
    MFHIc   = '{ RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_MFHI,      SEL_PC_PC_PLUS4, ALU_OP_R    },
    MFLOc   = '{ RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_MFLO,      SEL_PC_PC_PLUS4, ALU_OP_R    },
    MULTUc  = '{ RF_WE_DISABLE, SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_DONT_CARE, SEL_PC_PC_PLUS4, ALU_OP_R    };

endpackage



//// Helper functions
package global_functions;

    // Adds 2 32-bit numbers
    function logic [31:0] add(input logic[31:0] a, b);
        add = a + b;
    endfunction

    // Shifts a number to the left by 2-bits
    function logic [31:0] shift_left_2(input logic[31:0] a);
        shift_left_2 = { a[29:0], 2'b00 };
    endfunction

    // Extend the sign 16-bits
    function logic [31:0] sign_extend(input logic[15:0] a);
        sign_extend = { { 16{a[15]} }, a[15:0] };
    endfunction

endpackage

`endif