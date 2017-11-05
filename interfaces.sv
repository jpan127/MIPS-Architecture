
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