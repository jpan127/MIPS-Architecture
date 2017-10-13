`ifndef GLOBALS_SV
`define GLOBALS_SV

package global_types;

    // Vectors
    typedef logic [1:0] bit2;
    typedef logic [3:0] bit4;
    typedef logic [5:0] bit5;
    typedef logic [15:0] bit16;
    typedef logic [31:0] bit32;

    // Instruction types
    typedef struct
    {
        reg [5:0] opcode;
        reg [4:0] rs;
        reg [4:0] rt;
        reg [15:0] immediate;
    } i_instruction_t;

    typedef struct
    {
        reg [5:0]  opcode;
        reg [25:0] address;
    } j_instruction_t;

    typedef struct
    {
        reg [5:0] opcode;
        reg [4:0] rs;
        reg [4:0] rt;
        reg [4:0] rd;
        reg [5:0] shamt;
        reg [5:0] funct;
    } r_instruction_t;

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
        ALU_OP_ADDI         = 2'b00,
        ALU_OP_SUBI         = 2'b01,
        ALU_OP_DONT_CARE    = 2'b11
    } alu_op_t;

    // ALU control signals
    typedef enum logic [3:0]
    {
        DONT_CAREac = 4'dZ,
        ADDIac  = 4'd0,
        SUBIac  = 4'd1,
        ADDac   = 4'd2,
        SUBac   = 4'd3,
        ANDac   = 4'd4,
        ORac    = 4'd5,
        SLTac   = 4'd6,
        MULTUac = 4'd7,
        DIVUac  = 4'd8,
        MFHIac  = 4'd9,
        MFLOac  = 4'd10,
        JRac    = 4'd11
    } alu_ctrl_t;

    // Control signal for tb_datapath
    typedef struct
    {
        logic       rf_we;
        logic [1:0] sel_wa;
        logic       sel_alu_b;
        logic [1:0] sel_result;
        logic [1:0] sel_pc;
        logic [3:0] alu_ctrl;
    } testbench_ctrl_t;

    typedef enum logic [7:0]
    {
        OPCODE_R        = 8'h00,
        // OPCODE_ADD      = 8'h00,
        // OPCODE_ADDU     = 8'h00,
        // OPCODE_AND      = 8'h00,
        // OPCODE_NOR      = 8'h00,
        // OPCODE_OR       = 8'h00,
        // OPCODE_SLTU     = 8'h00,
        // OPCODE_SLL      = 8'h00,
        // OPCODE_SRL      = 8'h00,
        // OPCODE_SUB      = 8'h00,
        // OPCODE_SUBU     = 8'h00,
        // OPCODE_DIV      = 8'h00,
        // OPCODE_DIVU     = 8'h00,
        // OPCODE_MFHI     = 8'h00,
        // OPCODE_MFLO     = 8'h00,
        // OPCODE_MULT     = 8'h00,
        // OPCODE_MULTU    = 8'h00,
        // OPCODE_SRA      = 8'h00,
        // OPCODE_SLT      = 8'h00,
        // OPCODE_JR       = 8'h00,
        OPCODE_ADDI     = 8'h08,
        OPCODE_ADDIU    = 8'h09,
        OPCODE_ANDI     = 8'h0C,
        OPCODE_BEQ      = 8'h04,
        OPCODE_BNE      = 8'h05,
        OPCODE_J        = 8'h02,
        OPCODE_JAL      = 8'h03,
        OPCODE_LBU      = 8'h24,
        OPCODE_LHU      = 8'h25,
        OPCODE_LL       = 8'h30,
        OPCODE_LUI      = 8'h0F,
        OPCODE_LW       = 8'h23,
        OPCODE_ORI      = 8'h0D,
        OPCODE_SLTI     = 8'h0A,
        OPCODE_SLTIU    = 8'h0B,
        OPCODE_SB       = 8'h28,
        OPCODE_SC       = 8'h38,
        OPCODE_SW       = 8'h2b
    } opcode_t;

    typedef enum logic [7:0]
    {
        FUNCT_ADD       = 8'h20,
        FUNCT_ADDU      = 8'h21,
        FUNCT_AND       = 8'h24,
        FUNCT_JR        = 8'h08,
        FUNCT_NOR       = 8'h27,
        FUNCT_OR        = 8'h25,
        FUNCT_SLT       = 8'h2A,
        FUNCT_SLTU      = 8'h2b,
        FUNCT_SLL       = 8'h00,
        FUNCT_SRL       = 8'h02,
        FUNCT_SUB       = 8'h22,
        FUNCT_SUBU      = 8'h23,
        FUNCT_DIV       = 8'h1A,
        FUNCT_DIVU      = 8'h1B,
        FUNCT_MFHI      = 8'h10,
        FUNCT_MFLO      = 8'h12,
        FUNCT_MULT      = 8'h18,
        FUNCT_MULTU     = 8'h19,
        FUNCT_SRA       = 8'h03
    } funct_t;

endpackage


package testbench_helpers;

    import global_types::*;

    // Constructor for i_instruction_t
    function i_instruction_t create_i_instruction(input [5:0] opcode, [4:0] rs, [4:0] rt, [15:0] immediate);
        automatic i_instruction_t i = '{ opcode, rs, rt, immediate };
        return i;
    endfunction

    // Constructor for j_instruction_t
    function j_instruction_t create_j_instruction(input [5:0] opcode, [25:0] address);
        automatic j_instruction_t j = '{ opcode, address };
        return j;
    endfunction

    // Constructor for r_instruction_t
    function r_instruction_t create_r_instruction(input [5:0] opcode, [4:0] rs, [4:0] rt, [4:0] rd, [5:0] shamt, [5:0] funct);
        automatic r_instruction_t r = '{ opcode, rs, rt, rd, shamt, funct };
        return r;
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

    // Converts testbench_control_t into a 12-bit vector
    function logic [11:0] decode_testbench_ctrl(input testbench_control_t c);
        logic [11:0] vector =
        {
            logic '(c.rf_we),
            logic '(c.sel_wa),
            logic '(c.sel_alu_b),
            logic '(c.sel_result),
            logic '(c.sel_pc),
            logic '(c.alu_ctrl)
        };
        return vector;
    endfunction

    // All the controls to test
    testbench_control_t
    tb_LWc   = '{RF_WE_ENABLE,  SEL_WA_WA0, SEL_ALU_B_DMEM_WD,  SEL_RESULT_RD,      SEL_PC_PC_PLUS4, DONT_CAREac},
    tb_SWc   = '{RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_SIGN_IMM, SEL_RESULT_ALU_OUT, SEL_PC_PC_PLUS4, DONT_CAREac},
    tb_ADDIc = '{RF_WE_ENABLE,  SEL_WA_WA0, SEL_ALU_B_SIGN_IMM, SEL_RESULT_ALU_OUT, SEL_PC_PC_PLUS4, ADDIac};

endpackage

//// For control unit
package control_signals;

    import global_types::*;

    // Control unit control struct
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
    LWc     = '{RF_WE_ENABLE,  SEL_WA_WA0, SEL_ALU_B_SIGN_IMM, DMEM_WE_DISABLE, SEL_RESULT_RD,      SEL_PC_PC_PLUS4, ALU_OP_ADDI},
    SWc     = '{RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_SIGN_IMM, DMEM_WE_ENABLE,  SEL_RESULT_ALU_OUT, SEL_PC_PC_PLUS4, ALU_OP_ADDI},
    ADDIc   = '{RF_WE_ENABLE,  SEL_WA_WA0, SEL_ALU_B_SIGN_IMM, DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT, SEL_PC_PC_PLUS4, ALU_OP_ADDI},
    Jc      = '{RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT, SEL_PC_JUMP,     ALU_OP_ADDI},
    JALc    = '{RF_WE_ENABLE,  SEL_WA_31,  SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_PC_PLUS4,SEL_PC_JUMP,     ALU_OP_ADDI},
    BEQYc   = '{RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT, SEL_PC_BRANCH,   ALU_OP_SUBI},
    BEQNc   = '{RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT, SEL_PC_PC_PLUS4, ALU_OP_SUBI},
    // R-Type
    JRc     = '{RF_WE_DISABLE, SEL_WA_WA0, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT, SEL_PC_RESULT,   ALU_OP_DONT_CARE},
    Rc      = '{RF_WE_ENABLE,  SEL_WA_WA1, SEL_ALU_B_DMEM_WD,  DMEM_WE_DISABLE, SEL_RESULT_ALU_OUT, SEL_PC_PC_PLUS4, ALU_OP_DONT_CARE};

    // Convert control_t into a 11-bit vector
    function logic [10:0] decode_control(input control_t c);
        logic [10:0] vector =
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

// CU <--> DP bus
interface ControlBus;

    import global_types::*;

    dmem_we_t       dmem_we;
    sel_alu_b_t     sel_alu_b;
    rf_we_t         rf_we;
    sel_pc_t        sel_pc;
    sel_result_t    sel_result;
    sel_wa_t        sel_wa;
    alu_ctrl_t      alu_ctrl;

    modport ControlSignals
    (
        output  dmem_we,
                sel_alu_b,
                rf_we,
                sel_pc,
                sel_result,
                sel_wa,
                alu_ctrl
    );

    logic zero;

    modport StatusSignals
    (
        input   zero
    );

endinterface


`endif