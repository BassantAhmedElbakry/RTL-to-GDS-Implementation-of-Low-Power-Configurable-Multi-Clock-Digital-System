module System #(
    parameter FIFO_DATA_WIDTH = 16,
    parameter ALU_FUN_WIDTH = 4,
    parameter DATA_WIDTH = 16,
    parameter ADDRESS    = 4
) (
    input  wire REF_CLK,
    input  wire UART_CLK,
    input  wire RST,
    input  wire UART_RX_IN,
    output wire UART_TX_OUT,
    output wire UART_str_GLT,
    output wire UART_parity_Error,
    output wire UART_framing_Error
);

/******************* Internal connections *******************/

// Clock Divider & System Control
wire clock_Didvider_EN;

// UART & Clock Divider
wire RX_CLK, TX_CLK;
wire [DATA_WIDTH - 1 : 0] UART_Configurations;

// Clock Divider for UART_TX & Register File
wire [DATA_WIDTH - 1 : 0] Div_Ratio;

// Clock Divider for UART_RX & Clock Divider MUX 
wire [7 : 0] Div_Ratio_RX;

// RST_SYNC
wire Reset_Sync_1, Reset_Sync_2;

// UART & FIFO
wire FIFO_Empty;
wire [DATA_WIDTH - 1 : 0] Read_Data;

// System Control & FIFO
wire FIFO_FULL;
wire Write_INC;
wire [FIFO_DATA_WIDTH - 1 : 0] Write_DATA;

// Data Synchronizer & UART
wire [7 : 0] Parallel_Data;
wire Parallel_Data_VLD;

// Data Synchronizer & System Control
wire [7 : 0] Parallel_Data_SYNC;
wire EN_Pulse;

// Pulse Generator
wire Busy_Signal;
wire Read_INC;

// System Control & Clock Gating
wire Clock_Gating_EN;

// Clock Gating & ALU
wire ALU_Clock;

// System Control & ALU
wire ALU_Enable;
wire ALU_Output_VLD;
wire [ALU_FUN_WIDTH  - 1 : 0] ALU_Function;
wire [DATA_WIDTH     - 1 : 0] ALU_Output;

// ALU & Register File
wire [FIFO_DATA_WIDTH - 1 : 0] Op_A, Op_B;

// System Control & Register File
wire Read_Data_VLD;
wire Write_EN, Read_EN;
wire [ADDRESS - 1 : 0] RegFile_Address;
wire [FIFO_DATA_WIDTH - 1 : 0] Write_DATA_RegFile, Read_DATA_RegFile;

// UART 
UART U0 (
    .UART_RX_CLK(RX_CLK),
    .UART_TX_CLK(TX_CLK),
    .UART_RST(Reset_Sync_2),
    .UART_Config(UART_Configurations[7 : 0]),
    .UART_RX_IN(UART_RX_IN),
    .UART_F_EMPTY(!FIFO_Empty),
    .UART_RD_DATA(Read_Data[7 : 0]),
    .UART_Busy(Busy_Signal),
    .UART_TX_OUT(UART_TX_OUT),
    .UART_DATA_VALID(Parallel_Data_VLD),
    .UART_P_DATA(Parallel_Data),
    .UART_str_glt(UART_str_GLT),
    .UART_frm_Error(UART_framing_Error),
    .UART_prt_Error(UART_parity_Error)
);

// Clock Divider For UART_RX
ClkDiv U1 (
    .i_clk_ref(UART_CLK),
    .i_rst_n(Reset_Sync_2),
    .i_clk_en(clock_Didvider_EN),
    .i_div_ratio(Div_Ratio_RX),
    .o_div_clk(RX_CLK)
);

// Clock Divider For UART_TX
ClkDiv U2 (
    .i_clk_ref(UART_CLK),
    .i_rst_n(Reset_Sync_2),
    .i_clk_en(clock_Didvider_EN),
    .i_div_ratio(Div_Ratio[7 : 0]),
    .o_div_clk(TX_CLK)
);

// Clock Divider MUX
ClkDiv_MUX U3 (
    .MUX_Prescale(UART_Configurations[7 : 2]),
    .MUX_OUT(Div_Ratio_RX)
);

// Reset Sync 2
RST_SYNC U4 (
    .CLK(UART_CLK),
    .RST(RST),
    .SYNC_RST(Reset_Sync_2)
);

// Reset Sync 1
RST_SYNC U5 (
    .CLK(REF_CLK),
    .RST(RST),
    .SYNC_RST(Reset_Sync_1)
);

// FIFO
ASYC_FIFO U6 (
    .W_CLK(REF_CLK),
    .R_CLK(TX_CLK),
    .W_RST(Reset_Sync_1),
    .R_RST(Reset_Sync_2),
    .W_INC(Write_INC),
    .R_INC(Read_INC),
    .WR_DATA(Write_DATA),
    .RD_DATA(Read_Data),
    .FULL(FIFO_FULL),
    .EMPTY(FIFO_Empty)
);

// System control
SYS_CTRL U7 (
    .CLK(REF_CLK),
    .RST(Reset_Sync_1),
    .sync_RX_Data(Parallel_Data_SYNC),
    .RX_enable_Pulse(EN_Pulse),
    .S_FIFO_FULL(FIFO_FULL),
    .S_Rd_D(Read_DATA_RegFile),
    .S_Rd_D_VLD(Read_Data_VLD),
    .S_ALU_OUT(ALU_Output),
    .S_ALU_OUT_VLD(ALU_Output_VLD),
    .S_Par_En(UART_Configurations[0]),
    .S_str_glt(UART_str_GLT),
    .S_parity_Err(UART_parity_Error),
    .S_frame_Err(UART_framing_Error),
    .S_FIFO_WR_DATA(Write_DATA),
    .S_FIFO_WR_INC(Write_INC),
    .S_WrEn(Write_EN),
    .S_RdEn(Read_EN),
    .S_Addr(RegFile_Address),
    .S_Wr_D(Write_DATA_RegFile),
    .S_Gate_EN(Clock_Gating_EN),
    .S_ALU_EN(ALU_Enable),
    .S_ALU_FUNC(ALU_Function),
    .S_ClK_DIV_EN(clock_Didvider_EN)
);

// Data Synchronizer
Data_Synchronizer U8 (
    .CLK(REF_CLK),
    .RST(Reset_Sync_1),
    .bus_enable(Parallel_Data_VLD),
    .unsync_bus(Parallel_Data),
    .sync_bus(Parallel_Data_SYNC),
    .enable_pulse(EN_Pulse)
);

// Pulse Generator
PULSE_GEN U9 (
    .CLK(TX_CLK),
    .RST(Reset_Sync_2),
    .i_signal(Busy_Signal),
    .o_signal(Read_INC)
);

// ALU
ALU U10 (
    .CLK(ALU_Clock),
    .RST(Reset_Sync_1),
    .ALU_EN(ALU_Enable),
    .A(Op_A[7 : 0]),
    .B(Op_B[7 : 0]),
    .ALU_FUN(ALU_Function),
    .ALU_OUT(ALU_Output),
    .OUT_Valid(ALU_Output_VLD)
); 

// Register File
Reg_File U11 (
    .clk(REF_CLK),
    .rst(Reset_Sync_1),
    .RdEn(Read_EN),
    .WrEn(Write_EN),
    .Address(RegFile_Address),
    .WrData(Write_DATA_RegFile),
    .RdData(Read_DATA_RegFile),
    .REG0(Op_A),
    .REG1(Op_B),
    .REG2(UART_Configurations),
    .REG3(Div_Ratio),
    .RD_D_Vld(Read_Data_VLD)
);

// Clock Gating
Clock_Gating U12 (
    .CLK(REF_CLK),
    .Gate_EN(Clock_Gating_EN),
    .GATED_CLK(ALU_Clock)
);

    
endmodule
