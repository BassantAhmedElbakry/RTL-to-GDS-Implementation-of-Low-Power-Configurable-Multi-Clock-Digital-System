module UART_RX_data_sampling(
    input  wire clk,rst,
    input  wire [5 : 0] sampling_Prescale,
    input  wire sampling_RX_IN,
    input  wire data_sampling_Enable,
    input  wire [4 : 0] sampling_Edge_count,
    output reg  sampled_BIT
);

reg  [2 : 0] samples;
wire [3 : 0] half;

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        samples     <=  'b0;
    end
    else if(data_sampling_Enable) begin
        if(sampling_Edge_count ==  (half - 1'b1)) begin
           samples[0] <= sampling_RX_IN;
        end
        else if(sampling_Edge_count == half) begin
            samples[1] <= sampling_RX_IN;
        end
        else if(sampling_Edge_count ==  (half + 1'b1)) begin
            samples[2] <= sampling_RX_IN;
        end
    end
    else begin
        samples <= 'b0;
    end
end

assign half = (sampling_Prescale >> 1) - 1'b1; // IF:1000 --> 0100-0001 = 111

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        sampled_BIT <= 1'b1;
    end
    else if (data_sampling_Enable) begin
        case (samples)
            3'b000:  sampled_BIT <= 1'b0; 
            3'b001:  sampled_BIT <= 1'b0; 
            3'b010:  sampled_BIT <= 1'b0; 
            3'b011:  sampled_BIT <= 1'b1; 
            3'b100:  sampled_BIT <= 1'b0; 
            3'b101:  sampled_BIT <= 1'b1; 
            3'b110:  sampled_BIT <= 1'b1; 
            3'b111:  sampled_BIT <= 1'b1; 
            default: sampled_BIT <= 1'b0;
        endcase
    end
    else begin
        sampled_BIT <= 1'b1;
    end
end

endmodule

