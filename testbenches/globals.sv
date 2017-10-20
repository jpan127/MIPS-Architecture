`ifndef GLOBALS_SV
`define GLOBALS_SV

// Converting between types: works for structs, or enum >> int, vice versa
// {>>{type2}} = type1

package global_types;

    // Vectors
    typedef logic [1:0] bit2;
    typedef logic [3:0] bit4;
    typedef logic [5:0] bit5;
    typedef logic [15:0] bit16;
    typedef logic [31:0] bit32;

    // Constants
    const localparam [4:0]  REG_RA   = 'd31;
    const localparam [4:0]  REG_ZERO = 'd0;
    const localparam [4:0]  REG_SP   = 'd29;
    const localparam [31:0] ZERO32   = 'd0;

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

    typedef enum logic [5:0]
    {
        OPCODE_R        = 'h00,
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


package testbench_globals;

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
        logic [11:0] vector;
        vector =
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
        sign_extend = { { 16{a[15]} }, a[14:0] };
    endfunction

endpackage


// CU <--> DP bus
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

    // Input to control_unit
    modport ExternalSignals
    (
        input   dmem_we
    );

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
    // Output to datapath
    modport StatusSignals
    (
        input   zero
    );

endinterface


`endif