module UART_RX_parity_Check #(
    parameter DATA_WIDTH_PARITY = 8
) (
    input  wire parity_type,
    input  wire parity_Sampled_bit,
    input  wire [DATA_WIDTH_PARITY - 1 : 0] parity_P_Data,
    input  wire parity_check_Enable,
    output reg  parity_Error
);

// Calculated parity bit
reg Par_BIT;

// Local parameters for case statment
localparam EVEN = 1'b0,
           ODD  = 1'b1;

always @(*) begin
   if(parity_check_Enable) begin
    /* Check parity: IF XOR DATA = 0 then number is even 
                   : IF XOR DATA = 1 then number is odd */
    case (parity_type)
        // Calc Even parity
        EVEN: Par_BIT =  ^parity_P_Data;
        // Calc Odd parity
        ODD:  Par_BIT = ~^parity_P_Data; 
        default: Par_BIT = 1'b0;
    endcase 

    /* IF it's the same parity bit --> parity_Error = 0
                               else -->  parity_Error = 1 */ 
    parity_Error = parity_Sampled_bit ^ Par_BIT;

   end
   else begin
        Par_BIT      = 1'b0;
        parity_Error = 1'b0;
   end 
end

endmodule

