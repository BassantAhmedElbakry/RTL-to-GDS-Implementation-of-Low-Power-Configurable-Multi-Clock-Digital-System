module FIFO_RD #(
    // Parameters
    parameter P_WIDTH = 4
)(
    // I/O Ports
    input  wire r_clk,
    input  wire r_rst_n,
    input  wire r_inc,
    input  wire [P_WIDTH - 1 : 0] rq2_w_ptr,
    output reg  [P_WIDTH - 1 : 0] wq2_r_ptr, 
    output wire [P_WIDTH - 1 : 0] r_addr,
    output reg  r_empty
);

// Read Pointer
reg [P_WIDTH - 1 : 0] rd_Pointer;

// Condition of FIFO is empty
always @(*) begin
    if(rq2_w_ptr == wq2_r_ptr) begin
        r_empty = 1'b1;
    end
    else begin
        r_empty = 1'b0;
    end
end

// Read Address 
assign r_addr = rd_Pointer[P_WIDTH - 2 : 0];

// Increment the Pointer
always @(posedge r_clk or negedge r_rst_n) begin
    if(!r_rst_n) begin
        rd_Pointer <= 'b0;
    end
    else if(!r_empty && r_inc) begin
        rd_Pointer <= rd_Pointer + 1'b1;
    end
end

// Gray coded 
always @(posedge r_clk or negedge r_rst_n) begin
    if(!r_rst_n) begin
        wq2_r_ptr <= 4'b0;
    end
    else begin
        case (rd_Pointer)
            4'b0000: wq2_r_ptr <= 4'b0000;
            4'b0001: wq2_r_ptr <= 4'b0001; 
            4'b0010: wq2_r_ptr <= 4'b0011;
            4'b0011: wq2_r_ptr <= 4'b0010;
            4'b0100: wq2_r_ptr <= 4'b0110;
            4'b0101: wq2_r_ptr <= 4'b0111;
            4'b0110: wq2_r_ptr <= 4'b0101;
            4'b0111: wq2_r_ptr <= 4'b0100;
            4'b1000: wq2_r_ptr <= 4'b1100;
            4'b1001: wq2_r_ptr <= 4'b1101;
            4'b1010: wq2_r_ptr <= 4'b1111;
            4'b1011: wq2_r_ptr <= 4'b1110;
            4'b1100: wq2_r_ptr <= 4'b1010;
            4'b1101: wq2_r_ptr <= 4'b1011;
            4'b1110: wq2_r_ptr <= 4'b1001;
            4'b1111: wq2_r_ptr <= 4'b1000;
            default: wq2_r_ptr <= 4'b0000;
        endcase 
    end
end
    
endmodule
