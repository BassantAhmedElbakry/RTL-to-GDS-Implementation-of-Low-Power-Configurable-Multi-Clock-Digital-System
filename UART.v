module UART #(
    parameter UART_CONFIG = 8,
    parameter DATA_WIDTH = 8
)(
    input  wire UART_RX_CLK,
    input  wire UART_TX_CLK,
    input  wire UART_RST,
    input  wire [UART_CONFIG - 1 : 0] UART_Config,
    input  wire UART_RX_IN,
    input  wire UART_F_EMPTY,
    input  wire [DATA_WIDTH - 1 : 0] UART_RD_DATA,
    output wire UART_Busy,
    output wire UART_TX_OUT,
    output wire UART_DATA_VALID,
    output wire [DATA_WIDTH - 1 : 0] UART_P_DATA,
    output wire UART_str_glt,
    output wire UART_frm_Error,
    output wire UART_prt_Error
);

UART_TX #(.DATA_WIDTH_TOP(DATA_WIDTH)) U0 (
    .CLK(UART_TX_CLK),
    .RST(UART_RST),
    .PAR_EN(UART_Config[0]),
    .PAR_TYP(UART_Config[1]),
    .TX_OUT(UART_TX_OUT),
    .Busy(UART_Busy),
    .P_DATA(UART_RD_DATA),
    .DATA_VALID(UART_F_EMPTY) 
);

UART_RX #(.DATA_WIDTH(DATA_WIDTH)) U1 (
    .CLK(UART_RX_CLK),
    .RST(UART_RST),
    .PAR_EN(UART_Config[0]),
    .PAR_TYP(UART_Config[1]),
    .Prescale(UART_Config[UART_CONFIG - 1 : 2]),
    .RX_IN(UART_RX_IN),
    .DATA_VALID(UART_DATA_VALID),
    .P_DATA(UART_P_DATA),
    .Start_GLT(UART_str_glt),
    .Parity_Error(UART_prt_Error),
    .Frame_Error(UART_frm_Error)
);
    
endmodule
