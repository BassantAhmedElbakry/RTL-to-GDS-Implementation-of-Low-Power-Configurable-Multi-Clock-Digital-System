module UART_TX_parity_Calc #(
    parameter DATA_WIDTH_PARITY = 8
) (
    input  wire clk,rst,
    input  wire Par_data_valid,
    input  wire Par_en,
    input  wire Par_type,
    input  wire [DATA_WIDTH_PARITY - 1 : 0] Par_P_Data,
    input  wire flag_par, // Flag to Avoid input new data when sending frame
    output reg  Par_BIT
);

integer i;
reg [3 : 0] XOR_DATA ;
reg [DATA_WIDTH_PARITY - 1 : 0] parity_DATA; 

always @(posedge clk or negedge rst) begin
    if (!rst) begin
      parity_DATA <= 'b0;
    end
    else begin
      if(Par_data_valid && flag_par) begin
        parity_DATA <= Par_P_Data;
      end
    end  
end

always @(*) begin
    if (Par_en) begin
       /* Check parity: IF XOR DATA = 0 then number is even 
                      : IF XOR DATA = 1 then number is odd */
       XOR_DATA = ^Par_P_Data;
       
        // Calc Odd Parity  
        if ( Par_type && !XOR_DATA ) begin
            Par_BIT    = 1'b1;
        end 
        // Calc Even Parity 
        else if ( !Par_type && XOR_DATA) begin
            Par_BIT    = 1'b1;
            end
        else begin
            Par_BIT    = 1'b0;
        end
    end
    else begin
        XOR_DATA   = 'b0;
        Par_BIT    = 1'b0;
    end

end


endmodule

