module ASYC_FIFO #(
    // Parameters
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 8, 
    parameter P_WIDTH = 4 
)(
    // I/O Ports
    input  wire W_CLK,
    input  wire W_RST,
    input  wire W_INC,
    input  wire R_CLK,
    input  wire R_RST,
    input  wire R_INC,
    input  wire [DATA_WIDTH - 1 : 0] WR_DATA,
    output wire [DATA_WIDTH - 1 : 0] RD_DATA,
    output wire FULL,
    output wire EMPTY
);
 // Parameters
localparam BIT_SYNC_NUM_STAGES = 2 ;

// Internal Connection between memory & FIFO_WR
wire [P_WIDTH - 1 : 0] W_addr;

// Internal Connection between memory & FIFO_RD
wire [P_WIDTH - 1 : 0] R_addr;

// Internal Connection between FIFO_WR & FIFO_RD
wire [P_WIDTH - 1 : 0] wptr, rprt;
wire [P_WIDTH - 1 : 0] wq2_r_ptr, rq2_w_ptr;

FIFO_memory #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH), .P_WIDTH(P_WIDTH)) U0 (
    .w_clk(W_CLK),
    .w_rst_n(W_RST),
    .w_inc(W_INC),
    .w_full(FULL),
    .w_data(WR_DATA),
    .w_addr(W_addr),
    .r_addr(R_addr),
    .r_data(RD_DATA)
);

FIFO_RD #(.P_WIDTH(P_WIDTH)) U1 (
    .r_clk(R_CLK),
    .r_rst_n(R_RST),
    .r_inc(R_INC),
    .rq2_w_ptr(rq2_w_ptr),
    .r_addr(R_addr),
    .wq2_r_ptr(rprt),
    .r_empty(EMPTY)
);

FIFO_WR #(.P_WIDTH(P_WIDTH)) U2 (
    .w_clk(W_CLK),
    .w_rst_n(W_RST),
    .w_inc(W_INC),
    .wq2_r_ptr(wq2_r_ptr),
    .w_addr(W_addr),
    .rq2_w_ptr(wptr),
    .w_full(FULL)
);

FIFO_DF_SYNC #(.NUM_STAGES(BIT_SYNC_NUM_STAGES), .BUS_WIDTH(P_WIDTH)) sync_r2w (
    .CLK(W_CLK),
    .RST(W_RST),
    .ASYNC(rprt),
    .SYNC(wq2_r_ptr)
);

FIFO_DF_SYNC #(.NUM_STAGES(BIT_SYNC_NUM_STAGES), .BUS_WIDTH(P_WIDTH)) sync_w2r (
    .CLK(R_CLK),
    .RST(R_RST),
    .ASYNC(wptr),
    .SYNC(rq2_w_ptr)
);
    
endmodule
