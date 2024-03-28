module FIFO_memory #(
    // Parameters
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 8, 
    parameter P_WIDTH = 4 
)(
    // I/O Ports
    input  wire w_clk,
    input  wire w_rst_n,
    input  wire w_inc,
    input  wire w_full,
    input  wire [DATA_WIDTH - 1 : 0] w_data,
    input  wire [P_WIDTH    - 1 : 0] w_addr,
    input  wire [P_WIDTH    - 1 : 0] r_addr,
    output reg  [DATA_WIDTH - 1 : 0] r_data 
);

// FIFO Memory
reg [DATA_WIDTH - 1 : 0] memory [DEPTH - 1 : 0];

// Integer i --> for loop
integer i;

// Writing the Data
always @(posedge w_clk or negedge w_rst_n) begin
    if(!w_rst_n) begin
        for(i = 0 ; i < DEPTH ; i = i + 1) begin
            memory[i] <= 'b0;
        end
    end
    // Check that the FIFO is not Full
    else if(!w_full && w_inc) begin
        memory[w_addr] <= w_data;
    end
end

// Reading the Data
always @(*) begin
    r_data = memory[r_addr];
end

endmodule
