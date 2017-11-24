`ifndef PIPELINE_PKG_SV
`define PIPELINE_PKG_SV

package pipeline_pkg;

    // Packages
    import global_types::*;

    // Pipeline : Fetch
    typedef struct
    {
        // Inputs
        logic32 w_pc;
        // Outputs
        logic32 f_pc;  
    } FetchBus;

    // Pipeline : Decode
    typedef struct
    {
        // Inputs
        logic32 f_instruction;
        logic32 f_pc_plus4;
        // Outputs
        logic32 d_instruction;
        logic32 d_pc_plus4;
    } DecodeBus;

    // Pipeline : Execute
    typedef struct
    {
        // Inputs
        logic32       d_rd0;
        logic32       d_rd1;
        logic5        d_wa0;
        logic5        d_wa1;
        logic32       d_sign_imm;
        logic32       d_pc_plus4;
        // Outputs
        logic32       e_rd0;
        logic32       e_rd1;
        logic5        e_wa0;
        logic5        e_wa1;
        logic32       e_sign_imm;
        logic32       e_pc_plus4;
        // Control Inputs
        alu_ctrl_t    d_alu_ctrl;
        rf_we_t       d_rf_we;
        sel_alu_b_t   d_sel_alu_b;
        sel_result_t  d_sel_result;
        sel_wa_t      d_sel_wa;
        dmem_we_t     d_dmem_we;
        // Control Outputs
        alu_ctrl_t    e_alu_ctrl;
        rf_we_t       e_rf_we;
        sel_alu_b_t   e_sel_alu_b;
        sel_result_t  e_sel_result;
        sel_wa_t      e_sel_wa;
        dmem_we_t     e_dmem_we;
    } ExecuteBus;

    // Pipeline : Memory
    typedef struct
    {
        // Inputs
        logic32       e_alu_out;
        logic32       e_dmem_wd;
        logic5        e_rf_wa;
        logic32       e_pc_plus4;
        // Outputs
        logic32       m_alu_out;
        logic32       m_dmem_wd;
        logic5        m_rf_wa;
        logic32       m_pc_plus4;
        // Control Inputs
        rf_we_t       e_rf_we;
        sel_result_t  e_sel_result;
        dmem_we_t     e_dmem_we;
        // Control Outputs
        rf_we_t       m_rf_we;
        sel_result_t  m_sel_result;
        dmem_we_t     m_dmem_we;
        // Status Inputs
        logic         e_zero;
        // Status Outputs
        logic         m_zero;
    } MemoryBus;

    // Pipeline : Writeback
    typedef struct
    {
        // Inputs
        logic32       m_dmem_rd;
        logic32       m_alu_out;
        logic5        m_rf_wa;
        logic32       m_pc_plus4;
        // Outputs
        logic32       w_dmem_rd;
        logic32       w_alu_out;
        logic5        w_rf_wa;
        logic32       w_pc_plus4;
        // Control Inputs
        rf_we_t       m_rf_we;
        sel_result_t  m_sel_result;
        // Control Outputs
        rf_we_t       w_rf_we;
        sel_result_t  w_sel_result;
    } WritebackBus;

endpackage : pipeline_pkg

`endif