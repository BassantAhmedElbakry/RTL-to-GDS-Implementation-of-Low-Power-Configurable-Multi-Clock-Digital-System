module UART_RX_start_Check (
    input  wire start_check_Enable,
    input  wire start_Sampled_bit,     
    output reg  start_Glitch
);

always @(*) begin
    if(start_check_Enable) begin
        start_Glitch <= start_Sampled_bit;
    end
    else begin
        start_Glitch <= 1'b0;
    end
end
    
endmodule

