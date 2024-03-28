module UART_RX_stop_Check (
    input  wire stop_check_Enable,
    input  wire stop_Sampled_bit,
    output reg  stop_Error
);

always @(*) begin
    if(stop_check_Enable) begin
        stop_Error = !stop_Sampled_bit;
    end
    else begin
        stop_Error = 1'b0;
    end
end
    
endmodule

