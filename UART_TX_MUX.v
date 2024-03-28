module UART_TX_MUX (
    input  wire [1 : 0] MUX_SEL,
    input  wire MUX_ser_data,
    input  wire MUX_par_bit, 
    output reg  MUX_OUT
);

// MUX Selection
localparam [1 : 0] Start_bit = 2'b00,
                   Stop_bit  = 2'b01,
                   Ser_data  = 2'b10,
                   Par_bit   = 2'b11;

// Check MUX Selecion
always @(*) begin
    case (MUX_SEL)
            Start_bit: MUX_OUT = 1'b0; 
            Stop_bit : MUX_OUT = 1'b1;
            Ser_data : MUX_OUT = MUX_ser_data;
            Par_bit  : MUX_OUT = MUX_par_bit;
            default  : MUX_OUT = 1'b1; 
        endcase
end

    
endmodule

