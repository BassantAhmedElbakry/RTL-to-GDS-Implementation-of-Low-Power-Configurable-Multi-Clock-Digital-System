module ClkDiv_MUX #(
    // Parameters
    parameter PRESCALE = 6,
              OUT = 8
) (
    // I/O Ports 
    input  wire [PRESCALE - 1 : 0] MUX_Prescale,
    output reg  [OUT      - 1 : 0] MUX_OUT
);


/*
 * IF Prescale = 32 --> UART_CLK Divided by 1
 * IF Prescale = 16 --> UART_CLK Divided by 2
 * IF Prescale = 8  --> UART_CLK Divided by 4  
 */
always @(*) begin
    case (MUX_Prescale)
        1000  : MUX_OUT = 4;
        10000 : MUX_OUT = 2;
        100000: MUX_OUT = 1;
        // Default Case
        default: MUX_OUT = 1;
    endcase
end
    
endmodule
