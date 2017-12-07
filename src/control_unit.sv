`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                          MIPS Control Unit                                              //
//                                          Author: Jonathan Pan                                           //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

module control_unit 

    import global_types::*;
    import control_signals::*;

(   input [5:0]         opcode, funct,
    input               branch,
    ControlBus.Sender   control_bus     );

    // Control signal sets alu_op which then defines alu control, split I-Type vs R-Type
    logic2  alu_op;
    logic12 ctrl;

    // Fail when undefined opcode
    localparam CTRL_UNDEFINED = 12'bX;

    ///////////////////////////////////////////////////////////////////////////////////////////////

    assign
    {
        control_bus.rf_we,          // 1 bit
        control_bus.sel_wa,         // 2 bits
        control_bus.sel_alu_b,      // 1 bit
        control_bus.dmem_we,        // 1 bit
        control_bus.sel_result,     // 3 bits
        control_bus.sel_pc,         // 2 bits
        alu_op                      // 2 bits
    } = ctrl;

    // Decodes opcode to set ctrl signals
    always_comb begin : MAIN_DECODER
        case (opcode)
            // I-TYPE
            OPCODE_LW:       ctrl = LWc;
            OPCODE_SW:       ctrl = SWc;
            OPCODE_BEQ:      ctrl = (branch) ? BEQc : BEQNc;
            OPCODE_ADDI:     ctrl = ADDIc;
            // J-TYPE
            OPCODE_J:        ctrl = Jc;
            OPCODE_JAL:      ctrl = JALc;
            // R-TYPE
            OPCODE_R:       
            case (funct)
                FUNCT_JR:    ctrl = JRc;
                FUNCT_MULTU: ctrl = MULTUc;
                FUNCT_MFHI:  ctrl = MFHIc;
                FUNCT_MFLO:  ctrl = MFLOc;
                FUNCT_DIVU:  ctrl = DIVUc;
                default:     ctrl = Rc;
            endcase
            // Undefined instructions
            default:         ctrl = CTRL_UNDEFINED;
        endcase
    end

    // Ctrl signals sets alu_op which this decodes to set alu_ctrl
    always_comb begin : ALU_DECODER
        case (alu_op)
            // I-TYPE
            2'b00:               control_bus.alu_ctrl = ADDIac;
            2'b01:               control_bus.alu_ctrl = SUBIac;
            // R-TYPE
            default: 
                case (funct)
                    FUNCT_ADD:   control_bus.alu_ctrl = ADDac;
                    FUNCT_AND:   control_bus.alu_ctrl = ANDac;
                    FUNCT_DIVU:  control_bus.alu_ctrl = DIVUac;
                    FUNCT_JR:    control_bus.alu_ctrl = JRac;
                    FUNCT_MFHI:  control_bus.alu_ctrl = MFHIac;
                    FUNCT_MFLO:  control_bus.alu_ctrl = MFLOac;
                    FUNCT_MULTU: control_bus.alu_ctrl = MULTUac;
                    FUNCT_NOP:   control_bus.alu_ctrl = NOPac;
                    FUNCT_OR:    control_bus.alu_ctrl = ORac;
                    FUNCT_SLT:   control_bus.alu_ctrl = SLTac;
                    FUNCT_SRL:   control_bus.alu_ctrl = SRLac;
                    FUNCT_SUB:   control_bus.alu_ctrl = SUBac;
                    default:     control_bus.alu_ctrl = DONT_CAREac;
                endcase
        endcase
    end

endmodule