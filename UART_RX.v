module UART_RX #(
    parameter DATA_WIDTH = 8
)(
    input   wire CLK,RST,
    input   wire PAR_EN, PAR_TYP,
    input   wire RX_IN,
    input   wire [5 : 0] Prescale,
    output  wire [DATA_WIDTH - 1 : 0] P_DATA,
    output  wire DATA_VALID,
    output  wire Start_GLT,
    output  wire Parity_Error,
    output  wire Frame_Error
    
);

/********Internal Connections********/

// Internal Connection of data_sampling 
wire sampled_bit;

// Internal Connection of edge_bit_counter 
wire edge_done;

// Internal Connections between FSM & parity_Check
wire par_chk_en;

// Internal Connections between FSM & start_Check
wire strt_chk_en;

// Internal Connections between FSM & stop_Check
wire stp_chk_en;

// Internal Connections between FSM & deserializer
wire deser_en;

// Internal Connections between FSM & data_sampling
wire dat_samp_en;

// Internal Connections between edge_bit_counter & data_sampling
wire [4 : 0] edge_cnt;

// Internal Connections between edge_bit_counter & FSM
wire enable;
wire [3 : 0] bit_cnt;

UART_RX_parity_Check #(.DATA_WIDTH_PARITY(DATA_WIDTH)) U0 (
    .parity_type(PAR_TYP),
    .parity_Sampled_bit(sampled_bit),
    .parity_P_Data(P_DATA),
    .parity_check_Enable(par_chk_en),
    .parity_Error(Parity_Error)
);

UART_RX_start_Check U1(
    .start_check_Enable(strt_chk_en),
    .start_Sampled_bit(sampled_bit),
    .start_Glitch(Start_GLT)
);

UART_RX_stop_Check U2(
    .stop_check_Enable(stp_chk_en),
    .stop_Sampled_bit(sampled_bit),
    .stop_Error(Frame_Error)
);

UART_RX_deserializer #(.DATA_WIDTH_DESERIALIZER(DATA_WIDTH)) U3(
    .clk(CLK),
    .rst(RST),
    .deserializer_Enable(deser_en),
    .deserializer_Sampled_bit(sampled_bit),
    .deserializer_edge_done(edge_done),
    .deserializer_P_DATA(P_DATA)
);

UART_RX_data_sampling U4(
    .clk(CLK),
    .rst(RST),
    .sampling_Prescale(Prescale),
    .sampling_RX_IN(RX_IN),
    .data_sampling_Enable(dat_samp_en),
    .sampling_Edge_count(edge_cnt),
    .sampled_BIT(sampled_bit)
);

UART_RX_edge_bit_counter U5(
    .clk(CLK),
    .rst(RST),
    .counter_Enable(enable),
    .counter_par_en(PAR_EN),
    .counter_Prescale(Prescale),
    .done_edge(edge_done),
    .bit_count(bit_cnt),
    .edge_count(edge_cnt)
);

UART_RX_FSM #(.DATA_WIDTH_FSM(DATA_WIDTH)) U6(
    .clk(CLK),
    .rst(RST),
    .FSM_RX_IN(RX_IN),
    .FSM_par_err(Parity_Error),
    .FSM_start_glitch(Start_GLT),
    .FSM_stop_err(Frame_Error),
    .FSM_bit_count(bit_cnt),
    .FSM_edge_done(edge_done),
    .FSM_edge_count(edge_cnt),
    .FSM_Prescale(Prescale),
    .FSM_PAR_EN(PAR_EN),
    .FSM_par_chk_en(par_chk_en),
    .FSM_start_chk_en(strt_chk_en),
    .FSM_stop_chk_en(stp_chk_en),
    .FSM_edge_bit_counter_en(enable),
    .FSM_data_sample_en(dat_samp_en),
    .FSM_deser_en(deser_en),
    .FSM_data_valid(DATA_VALID)
);

endmodule

