
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

    // Control signal literal decoding / macros for easier understanding and universal syncing
    localparam  RF_WE_ENABLE        = 1'b1,
                RF_WE_DISABLE       = 1'b0,
                SEL_WA_WA0          = 2'b00,
                SEL_WA_WA1          = 2'b01,
                SEL_WA_31           = 2'b10,
                SEL_WA_00           = 2'b11,
                SEL_ALU_B_DMEM_WD   = 1'b0,
                SEL_ALU_B_SIGN_IMM  = 1'b1,
                SEL_RESULT_RD       = 2'b00,
                SEL_RESULT_ALU_OUT  = 2'b01,
                SEL_RESULT_PC_PLUS4 = 2'b10,
                SEL_RESULT_00       = 2'b11,
                SEL_PC_PC_PLUS4     = 2'b00,
                SEL_PC_BRANCH       = 2'b01,
                SEL_PC_JUMP         = 2'b10,
                SEL_PC_RESULT       = 2'b11;

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

    localparam  LWc = {RF_WE_ENABLE,    SEL_WA_WA0, SEL_ALU_B_DMEM_WD,  SEL_RESULT_RD,      SEL_PC_PC_PLUS4, ADDIac},
                SWc = {RF_WE_DISABLE,   SEL_WA_WA0, SEL_ALU_B_SIGN_IMM, SEL_RESULT_ALU_OUT, SEL_PC_PC_PLUS4, ADDIac};

    // Instructions To Test
    localparam LW_0XFF_INTO_REG10 = { 6'h23, 5'd0, 5'd10, 16'hFF };
    localparam SW_REG10_INTO_0XFF = { 6'h2b, 5'd0, 5'd10, 16'hFF };

endpackage