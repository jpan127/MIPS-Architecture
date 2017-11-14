`ifndef INTERFACES_SV
`define INTERFACES_SV

/// CU <--> DP bus
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

    modport Receiver
    (
        input  alu_ctrl,
        input  rf_we,
        input  sel_alu_b,
        input  sel_pc,
        input  sel_result,
        input  sel_wa,
        input  dmem_we,
        output zero
    );

    modport Sender
    (
        output alu_ctrl,
        output rf_we,
        output sel_alu_b,
        output sel_pc,
        output sel_result,
        output sel_wa,
        input  zero,
        output dmem_we
    );

endinterface

/// Debug bus
interface DebugBus;

    import global_types::*;

    logic5  rf_ra;
    logic32 rf_rd;

    modport InputBus
    (
        inout rf_ra
    );

    modport OutputBus
    (
        inout rf_rd
    );

endinterface

// /// Pipeline : Fetch
// interface FetchBus;

//     // Packages
//     import global_types::logic32;

//     // Writeback : Inputs
//     logic32 w_pc;

//     // Fetch : Outputs
//     logic32 f_pc;

// endinterface

// /// Pipeline : Decode
// interface DecodeBus;

//     // Packages
//     import global_types::*;

//     // Fetch : Inputs
//     logic32 f_instruction;
//     logic32 f_pc_plus4;

//     // modport InputBus (input f_instruction, input f_pc_plus4);

//     // Decode : Outputs
//     logic32 d_instruction;
//     logic32 d_pc_plus4;

//     // modport OutputBus (output d_instruction, output d_pc_plus4);

// endinterface

// /// Pipeline : Execute
// interface ExecuteBus;

//     // Packages
//     import global_types::*;

//     // Decode : Inputs
//     logic32 d_rd0;
//     logic32 d_rd1;
//     logic5  d_ra1;
//     logic5  d_wa0;
//     logic5  d_wa1;
//     logic32 d_sign_imm;
//     logic32 d_pc_plus4;

//     modport DecodeInput
//     (
//         input d_rd0,
//         input d_rd1,
//         input d_ra1,
//         input d_wa0,
//         input d_wa1,
//         input d_sign_imm,
//         input d_pc_plus4
//     );

//     // Execute : Outputs
//     logic32 e_rd0;
//     logic32 e_rd1;
//     logic5  e_ra1;
//     logic5  e_wa0;
//     logic5  e_wa1;
//     logic32 e_sign_imm;
//     logic32 e_pc_plus4;

//     modport ExecuteOutput
//     (
//         output e_rd0,
//         output e_rd1,
//         output e_ra1,
//         output e_wa0,
//         output e_wa1,
//         output e_sign_imm,
//         output e_pc_plus4
//     );

//     // // Control : Inputs
//     // ControlBus.ControlSignals  d_control_bus_control;
//     // ControlBus.ExternalSignals d_control_bus_external;

//     // modport ControlInput
//     // (
//     //     input d_control_bus_control,
//     //     input d_control_bus_external
//     // );

//     // // Control : Outputs
//     // ControlBus.ControlSignals  e_control_bus_control;
//     // ControlBus.ExternalSignals e_control_bus_external;

//     // modport ControlOutput
//     // (
//     //     output e_control_bus_control,
//     //     output e_control_bus_external
//     // );

// endinterface

// /// Pipeline : Memory
// interface MemoryBus;

//     // Packages
//     import global_types::*;

//     // Inputs
//     logic32 e_alu_out;
//     logic   e_zero;
//     logic32 e_dmem_wd;
//     logic5  e_rf_wa;
//     logic32 e_pc_branch;

//     modport ExecuteInput
//     (
//         input e_alu_out,
//         input e_zero,
//         input e_dmem_wd,
//         input e_rf_wa,
//         input e_pc_branch
//     );

//     // Outputs
//     logic32 m_alu_out;
//     logic   m_zero;
//     logic32 m_dmem_wd;
//     logic5  m_rf_wa;
//     logic32 m_pc_branch;

//     modport MemoryOutput
//     (
//         output m_alu_out,
//         output m_zero,
//         output m_dmem_wd,
//         output m_rf_wa,
//         output m_pc_branch
//     );

//     // Control : Inputs
//     ControlBus.ControlSignals  e_control_bus_control;
//     ControlBus.ExternalSignals e_control_bus_external;
//     ControlBus.StatusSignals   e_control_bus_status;

//     modport ControlInput
//     (
//         input e_control_bus_control,
//         input e_control_bus_external,
//         input e_control_bus_status
//     );

//     // Control : Outputs
//     ControlBus.ControlSignals  m_control_bus_control;
//     ControlBus.ExternalSignals m_control_bus_external;
//     ControlBus.StatusSignals   m_control_bus_status;

//     modport ControlOutput
//     (
//         output m_control_bus_control,
//         output m_control_bus_external,
//         output m_control_bus_status
//     );

// endinterface

// /// Pipeline : Writeback
// interface WritebackBus;

//     // Packages
//     import global_types::*;

//     // Inputs
//     logic32 m_dmem_rd;
//     logic32 m_alu_out;
//     logic5  m_rf_wa;

//     modport MemoryInput
//     (
//         input m_dmem_rd,
//         input m_alu_out,
//         input m_rf_wa
//     );

//     // Outputs
//     logic32 w_dmem_rd;
//     logic32 w_alu_out;
//     logic5  w_rf_wa;

//     modport WritebackOutput
//     (
//         output w_dmem_rd,
//         output w_alu_out,
//         output w_rf_wa
//     );

//     // Control : Inputs
//     ControlBus.ControlSignals  m_control_bus_control;
//     ControlBus.ExternalSignals m_control_bus_external;
//     ControlBus.StatusSignals   m_control_bus_status;

//     modport ControlInput
//     (
//         input m_control_bus_control,
//         input m_control_bus_external,
//         input m_control_bus_status
//     );

//     // Control : Outputs
//     ControlBus.ControlSignals  w_control_bus_control;
//     ControlBus.ExternalSignals w_control_bus_external;

//     modport ControlOutput
//     (
//         input w_control_bus_control,
//         input w_control_bus_external
//     );

// endinterface

`endif