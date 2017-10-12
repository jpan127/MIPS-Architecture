
package globals;

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

    // Constructor for i_instruction_t
    function i_instruction_t create_i_instruction(input [5:0] opcode, [4:0] rs, [4:0] rt, [15:0] immediate);
        i_instruction_t i = `{ opcode, rs, rt, immediate };
        return i;
    endfunction

    // Constructor for j_instruction_t
    function j_instruction_t create_j_instruction(input [5:0] opcode, [25:0] address);
        j_instruction_t j = `{ opcode, address };
        return j;
    endfunction

    // Constructor for r_instruction_t
    function r_instruction_t create_r_instruction(input [5:0] opcode, [4:0] rs, [4:0] rt, [4:0] rd, [5:0] shamt, [5:0] funct);
        r_instruction_t r = `{ opcode, rs, rt, rd, shamt, funct };
        return r;
    endfunction

    typedef enum
    {
        RF_WE_ENABLE    = 1'b1,
        RF_WE_DISABLE   = 1'b0
    } rf_we_t;

    typedef enum
    {
        SEL_WA_WA0  = 2'b00,
        SEL_WA_WA1  = 2'b01,
        SEL_WA_31   = 2'b10,
        SEL_WA_00   = 2'b11    
    } sel_wa_t;

    typedef enum
    {
        SEL_ALU_B_DMEM_WD   = 1'b0,
        SEL_ALU_B_SIGN_IMM  = 1'b1
    } sel_alu_b_t;

    typedef enum
    {
        SEL_RESULT_RD       = 2'b00,
        SEL_RESULT_ALU_OUT  = 2'b01,
        SEL_RESULT_PC_PLUS4 = 2'b10,
        SEL_RESULT_00       = 2'b11
    } sel_result_t;

    typedef enum
    {
        SEL_PC_PC_PLUS4 = 2'b00,
        SEL_PC_BRANCH   = 2'b01,
        SEL_PC_JUMP     = 2'b10,
        SEL_PC_RESULT   = 2'b11
    } sel_pc_t;

    // ALU control signals
    typedef enum
    {
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
    } alu_control_t;

    // Control signal for tb_datapath
    typedef struct
    {
        logic       rf_we,
        logic [1:0] sel_wa,
        logic       sel_alu_b,
        logic [1:0] sel_result,
        logic [1:0] sel_pc,
        logic [3:0] alu_ctrl
    } testbench_ctrl_t;

    // Creates a control vector signal out of the inputs
    function testbench_ctrl_t create_testbench_ctrl();
        input     rf_we,
            [1:0] sel_wa, sel_alu_b, sel_result, sel_pc,
            [3:0] alu_ctrl;
        testbench_ctrl_t ctrl = '{ rf_we, sel_wa, sel_alu_b, sel_result, sel_pc, alu_ctrl };
        return ctrl;
    endfunction

    logic [11:0] LWc = create_testbench_ctrl(RF_WE_ENABLE, 
                                            SEL_WA_WA0, 
                                            SEL_ALU_B_DMEM_WD, 
                                            SEL_RESULT_RD, 
                                            SEL_PC_PC_PLUS4, 
                                            ADDIac);
    logic [11:0] SWc = create_testbench_ctrl(RF_WE_DISABLE, 
                                            SEL_WA_WA0, 
                                            SEL_ALU_B_SIGN_IMM, 
                                            SEL_RESULT_ALU_OUT, 
                                            SEL_PC_PC_PLUS4, 
                                            ADDIac);

    typedef enum
    {
        OPCODE_ADD      = 0x00,
        OPCODE_ADDI     = 0x08,
        OPCODE_ADDIU    = 0x09,
        OPCODE_ADDU     = 0x00,
        OPCODE_AND      = 0x00,
        OPCODE_ANDI     = 0x0C,
        OPCODE_BEQ      = 0x04,
        OPCODE_BNE      = 0x05,
        OPCODE_J        = 0x02,
        OPCODE_JAL      = 0x03,
        OPCODE_JR       = 0x08,
        OPCODE_LBU      = 0x24,
        OPCODE_LHU      = 0x25,
        OPCODE_LL       = 0x30,
        OPCODE_LUI      = 0x0F,
        OPCODE_LW       = 0x23,
        OPCODE_NOR      = 0x00,
        OPCODE_OR       = 0x00,
        OPCODE_ORI      = 0x0D,
        OPCODE_SLT      = 0x00,
        OPCODE_SLTI     = 0x0A,
        OPCODE_SLTIU    = 0x0B,
        OPCODE_SLTU     = 0x00,
        OPCODE_SLL      = 0x00,
        OPCODE_SRL      = 0x00,
        OPCODE_SB       = 0x28,
        OPCODE_SC       = 0x38,
        OPCODE_SW       = 0x25,
        OPCODE_SUB      = 0x00,
        OPCODE_SUBU     = 0x00,
        OPCODE_DIV      = 0x00,
        OPCODE_DIVU     = 0x00,
        OPCODE_MFHI     = 0x00,
        OPCODE_MFLO     = 0x00,
        OPCODE_MULT     = 0x00,
        OPCODE_MULTU    = 0x00,
        OPCODE_SRA      = 0x00
    } opcode_t;

    typedef enum
    {
        FUNCT_ADD       = 0x20,
        FUNCT_ADDU      = 0x21,
        FUNCT_AND       = 0x24,
        FUNCT_JR        = 0x08,
        FUNCT_NOR       = 0x27,
        FUNCT_OR        = 0x25,
        FUNCT_SLT       = 0x2A,
        FUNCT_SLTU      = 0x25,
        FUNCT_SLL       = 0x00,
        FUNCT_SRL       = 0x02,
        FUNCT_SUB       = 0x22,
        FUNCT_SUBU      = 0x23,
        FUNCT_DIV       = 0x1A,
        FUNCT_DIVU      = 0x1B,
        FUNCT_MFHI      = 0x10,
        FUNCT_MFLO      = 0x12,
        FUNCT_MULT      = 0x18,
        FUNCT_MULTU     = 0x19,
        FUNCT_SRA       = 0x03
    } funct_t;

endpackage