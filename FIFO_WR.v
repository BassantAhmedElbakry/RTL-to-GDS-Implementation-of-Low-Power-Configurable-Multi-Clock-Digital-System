module FIFO_WR #(
    parameter P_WIDTH = 4
) (
    input  wire w_clk,
    input  wire w_rst_n,
    input  wire w_inc,
    input  wire [P_WIDTH - 1 : 0] wq2_r_ptr, 
    output reg  [P_WIDTH - 1 : 0] rq2_w_ptr,
    output wire [P_WIDTH - 1 : 0] w_addr,
    output reg  w_full
);

// Write Pointer
reg [P_WIDTH - 1 : 0] wr_Pointer;

// Condition of FIFO is full
always @(*) begin
    if( (rq2_w_ptr[P_WIDTH - 1] != wq2_r_ptr[P_WIDTH - 1]) && (rq2_w_ptr[P_WIDTH - 2] != wq2_r_ptr[P_WIDTH - 2]) && (rq2_w_ptr[1 : 0] == wq2_r_ptr[1 : 0]) ) begin
        w_full = 1'b1;
    end
    else begin
        w_full = 1'b0;
    end
end

// Write Address 
assign w_addr = wr_Pointer[P_WIDTH - 2 : 0];

// Increment the Pointer
always @(posedge w_clk or negedge w_rst_n) begin
    if(!w_rst_n) begin
        wr_Pointer <= 'b0;
    end
    else if(!w_full && w_inc) begin
        wr_Pointer <= wr_Pointer + 1'b1;
    end
end

// Gray coded 
always @(posedge w_clk or negedge w_rst_n) begin
    if(!w_rst_n) begin
        rq2_w_ptr <= 4'b0;
    end
    else begin
        case (wr_Pointer)
            4'b0000: rq2_w_ptr <= 4'b0000;
            4'b0001: rq2_w_ptr <= 4'b0001; 
            4'b0010: rq2_w_ptr <= 4'b0011;
            4'b0011: rq2_w_ptr <= 4'b0010;
            4'b0100: rq2_w_ptr <= 4'b0110;
            4'b0101: rq2_w_ptr <= 4'b0111;
            4'b0110: rq2_w_ptr <= 4'b0101;
            4'b0111: rq2_w_ptr <= 4'b0100;
            4'b1000: rq2_w_ptr <= 4'b1100;
            4'b1001: rq2_w_ptr <= 4'b1101;
            4'b1010: rq2_w_ptr <= 4'b1111;
            4'b1011: rq2_w_ptr <= 4'b1110;
            4'b1100: rq2_w_ptr <= 4'b1010;
            4'b1101: rq2_w_ptr <= 4'b1011;
            4'b1110: rq2_w_ptr <= 4'b1001;
            4'b1111: rq2_w_ptr <= 4'b1000;
            default: rq2_w_ptr <= 4'b0000;
        endcase 
    end
end

endmodule
