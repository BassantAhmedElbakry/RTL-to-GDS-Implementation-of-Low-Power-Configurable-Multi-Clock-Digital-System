module UART_TX #(
    parameter DATA_WIDTH_TOP = 8
) (
    input   CLK, RST,
    input   DATA_VALID,
    input   [DATA_WIDTH_TOP - 1 : 0] P_DATA,
    input   PAR_EN, PAR_TYP,
    output  TX_OUT, Busy
);

/********Internal Connections********/

// Internal connection between serializer and FSM
wire ser_en, ser_done;

// Internal connection between FSM and MUX
wire [1 : 0] mux_sel;

// Internal connection between parity_Calc and MUX
wire par_bit;

// Internal connection between serializer and MUX
wire ser_data;

// Internal connection between FSM and parity_Calc
wire flag_top;

UART_TX_serializer #(.DATA_WIDTH(DATA_WIDTH_TOP)) U0 (
    .clk(CLK),
    .rst(RST),
    .ser_P_DATA(P_DATA),
    .ser_DONE  (ser_done),
    .ser_EN    (ser_en),
    .ser_DATA  (ser_data)
);

UART_TX_FSM #(.DATA_WIDTH_FSM(DATA_WIDTH_TOP)) U1 (
    .clk(CLK),
    .rst(RST),    
    .FSM_DATA_VALID(DATA_VALID),
    .FSM_ser_done  (ser_done),
    .FSM_ser_en    (ser_en),
    .FSM_Par_en    (PAR_EN),
    .FSM_mux_sel   (mux_sel),
    .FSM_Busy      (Busy),
    .flag          (flag_top)
);

UART_TX_parity_Calc #(.DATA_WIDTH_PARITY(DATA_WIDTH_TOP)) U2 (
    .clk(CLK),
    .rst(RST),
    .Par_data_valid(DATA_VALID),
    .Par_en        (PAR_EN),
    .Par_type      (PAR_TYP),
    .Par_P_Data    (P_DATA),
    .Par_BIT       (par_bit),
    .flag_par      (flag_top)
);

UART_TX_MUX U3 (
    .MUX_SEL(mux_sel),
    .MUX_ser_data (ser_data),
    .MUX_par_bit(par_bit),
    .MUX_OUT(TX_OUT)

);
    
endmodule

