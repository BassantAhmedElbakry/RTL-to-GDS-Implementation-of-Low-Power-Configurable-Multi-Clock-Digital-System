module UART_RX_deserializer #(
    parameter DATA_WIDTH_DESERIALIZER = 8
) (
    input clk,rst,
    input  wire deserializer_Enable,
    input  wire deserializer_edge_done,
    input  wire deserializer_Sampled_bit,
    output reg  [DATA_WIDTH_DESERIALIZER - 1 : 0] deserializer_P_DATA
);

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        deserializer_P_DATA <= 'b0;
    end
    else if(deserializer_Enable && deserializer_edge_done) begin
        // Shifting
        deserializer_P_DATA <=  {deserializer_Sampled_bit,deserializer_P_DATA[DATA_WIDTH_DESERIALIZER - 1 : 1]};
        /*
        IF Data = 0111_1011
        P_DATA  = 0000_0000; --> Initial
        P_DATA  = 1000_0000;
        P_DATA  = 1100_0000;
        P_DATA  = 0110_0000;
        P_DATA  = 1011_0000;
        P_DATA  = 1101_1000;
        P_DATA  = 1110_1100;
        P_DATA  = 1111_0110;
        P_DATA  = 0111_1011;
        */
    end
end
    
endmodule

