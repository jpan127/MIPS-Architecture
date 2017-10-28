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
    typedef logic [10:0] logic11;
    typedef logic [15:0] logic16;
    typedef logic [25:0] logic26;
    typedef logic [31:0] logic32;

    // Constants
    localparam logic32  ZERO32 = 'd0,
                        UNUSED = 'd0;

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

    typedef enum logic [1:0]
    {
        SEL_RESULT_DONT_CARE = 2'bZ,
        SEL_RESULT_RD        = 2'b00,
        SEL_RESULT_ALU_OUT   = 2'b01,
        SEL_RESULT_PC_PLUS4  = 2'b10,
        SEL_RESULT_00        = 2'b11
    } sel_result_t;

    typedef enum logic [1:0]
    {
        SEL_PC_DONT_CARE = 2'bZ,
        SEL_PC_PC_PLUS4  = 2'b00,
        SEL_PC_BRANCH    = 2'b01,
        SEL_PC_JUMP      = 2'b10,
        SEL_PC_RESULT    = 2'b11
    } sel_pc_t;

    typedef enum logic
    {
        DMEM_WE_DONT_CARE   = 1'bZ,
        DMEM_WE_DISABLE     = 1'b0,
        DMEM_WE_ENABLE      = 1'b1
    } dmem_we_t;

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
        JRac        = 4'd11
    } alu_ctrl_t;

    typedef enum logic [5:0]
    {
        // OPCODE_ADD      = 6'h00,
        // OPCODE_ADDU     = 6'h00,
        // OPCODE_AND      = 6'h00,
        // OPCODE_NOR      = 6'h00,
        // OPCODE_OR       = 6'h00,
        // OPCODE_SLTU     = 6'h00,
        // OPCODE_SLL      = 6'h00,
        // OPCODE_SRL      = 6'h00,
        // OPCODE_SUB      = 6'h00,
        // OPCODE_SUBU     = 6'h00,
        // OPCODE_DIV      = 6'h00,
        // OPCODE_DIVU     = 6'h00,
        // OPCODE_MFHI     = 6'h00,
        // OPCODE_MFLO     = 6'h00,
        // OPCODE_MULT     = 6'h00,
        // OPCODE_MULTU    = 6'h00,
        // OPCODE_SRA      = 6'h00,
        // OPCODE_SLT      = 6'h00,
        // OPCODE_JR       = 6'h00,
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
        FUNCT_NOR       = 'h27,
        FUNCT_OR        = 'h25,
        FUNCT_SLT       = 'h2A,
        FUNCT_SLTU      = 'h2b,
        FUNCT_SLL       = 'h00,
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

    // Control unit control struct (11 bits)
    typedef struct packed
    {
        rf_we_t      rf_we;    
        sel_wa_t     sel_wa;    
        sel_alu_b_t  sel_alu_b;
        dmem_we_t    dmem_we;  
        sel_result_t sel_result;
        sel_pc_t     sel_pc;    
        alu_op_t     alu_op;    
    } control_t;

    // Control unit control signals for each instruction
    control_t
    // I-Type
    LWc     = '{RF_WE_ENABLE,  SEL_WA_WA0, SEL_ALU_B_SIGN_IMM, DMEM_WE_DISABLE, SEL_RESULT_RD,          SEL_PC_PC_PLUS4,   ALU_OP_ADDI},
    SWc     = '{RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_SIGN_IMM, DMEM_WE_ENABLE,  SEL_RESULT_ALU_OUT,     SEL_PC_PC_PLUS4,   ALU_OP_ADDI},
    ADDIc   = '{RF_WE_ENABLE,  SEL_WA_WA0, SEL_ALU_B_SIGN_IMM, DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,     SEL_PC_PC_PLUS4,   ALU_OP_ADDI},
    Jc      = '{RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,     SEL_PC_JUMP,       ALU_OP_ADDI},
    JALc    = '{RF_WE_ENABLE,  SEL_WA_31,  SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_PC_PLUS4,    SEL_PC_JUMP,       ALU_OP_ADDI},
    BEQc    = '{RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,     SEL_PC_BRANCH,     ALU_OP_SUBI},
    BEQNc   = '{RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,     SEL_PC_PC_PLUS4,   ALU_OP_SUBI},
    // R-Type
    JRc     = '{RF_WE_DISABLE, SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,     SEL_PC_RESULT,     ALU_OP_R},
    Rc      = '{RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,     SEL_PC_PC_PLUS4,   ALU_OP_R},
    ADDc    = '{RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,     SEL_PC_PC_PLUS4,   ALU_OP_R},
    ORc     = '{RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,     SEL_PC_PC_PLUS4,   ALU_OP_R},
    SLTc    = '{RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,     SEL_PC_PC_PLUS4,   ALU_OP_R},
    SUBc    = '{RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,     SEL_PC_PC_PLUS4,   ALU_OP_R},
    DIVUc   = '{RF_WE_DISABLE, SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_DONT_CARE,   SEL_PC_PC_PLUS4,   ALU_OP_R},
    MFHIc   = '{RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,     SEL_PC_PC_PLUS4,   ALU_OP_R},
    MFLOc   = '{RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT,     SEL_PC_PC_PLUS4,   ALU_OP_R},
    MULTUc  = '{RF_WE_DISABLE, SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_DONT_CARE,   SEL_PC_PC_PLUS4,   ALU_OP_R};

    // Convert control_t into a 11-bit vector
    function logic [10:0] decode_control(input control_t c);
        logic [10:0] vector;
        vector =
        {
            // Static cast uses parentheses
            logic '( c.rf_we ),
            logic '( c.sel_wa ),
            logic '( c.sel_alu_b ),
            logic '( c.dmem_we ),
            logic '( c.sel_result ),
            logic '( c.sel_pc ),
            logic '( c.alu_op )
        };
        return vector;
    endfunction

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



//// CU <--> DP bus
interface ControlBus;

    import global_types::*;

    alu_ctrl_t      alu_ctrl;
    rf_we_t         rf_we;
    sel_alu_b_t     sel_alu_b;
    sel_pc_t        sel_pc;
    sel_result_t    sel_result;
    sel_wa_t        sel_wa;
    dmem_we_t       dmem_we;
    logic           zero;

    // Output from control_unit
    // Input to datapath
    modport ControlSignals
    (
        inout   alu_ctrl,
                rf_we,
                sel_alu_b,
                sel_pc,
                sel_result,
                sel_wa
    );

    // Input to control_unit
    modport ExternalSignals
    (
        inout   dmem_we
    );

    // Input to control_unit
    // Output to datapath
    modport StatusSignals
    (
        inout   zero
    );

endinterface


`endif