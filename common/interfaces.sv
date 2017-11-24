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
    logic           branch;
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
        input  branch,
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
        output branch,
        input  zero,
        output dmem_we
    );

endinterface

/// Debug bus
interface DebugBus;

    import global_types::*;

    logic5  rf_ra;
    logic32 rf_rd;

endinterface

`endif