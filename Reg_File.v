module Reg_File #( 
    // Parameters
    parameter ADDRESS = 4,
    parameter DEPTH   = 8 ,
    parameter WIDTH   = 16

) ( 
    // I/O Ports
    input  wire clk, rst,
    input  wire RdEn, WrEn, 
    input  wire [ADDRESS - 1 : 0] Address,
    input  wire [WIDTH   - 1 : 0] WrData,
    output reg  [WIDTH   - 1 : 0] RdData,
    output wire [WIDTH   - 1 : 0] REG0,
    output wire [WIDTH   - 1 : 0] REG1,
    output wire [WIDTH   - 1 : 0] REG2,
    output wire [WIDTH   - 1 : 0] REG3,
    output reg  RD_D_Vld
);

/* 
 * Reg_File 8*16 --> 2D array
 * 8 Registers each one is 16 bits width
 */ 
reg [WIDTH - 1 : 0] RegFile [DEPTH - 1 : 0]; 
integer i;

// Active Low Asynchronous Reset
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        RD_D_Vld <= 1'b0;
        RdData   <=  'b0;
        // Reset all the Register file except address 0x2 & 0x3 as they are contain UART_Config & Division Ratio 
        for (i = 0 ; i < 8 ; i = i + 1 ) begin
            /* 
             * Address 0x2 contains UART_Config:
             * Bit[0] = Parity Enable --> Default Enable = 1
             * Bit[1] = Parity Type   --> Default Even   = 0
             * Bits[7 : 2] = Prescale --> Default = 32
             */ 
            if (i == 2) begin 
                RegFile[i] <= 'b001000_01; 
            end
            // Address 0x3 contains Division Ratio --> Default = 32
            else if (i == 3) begin
                RegFile[i] <= 'b0010_0000;
            end
            else begin
               RegFile[i] <= 'b0; 
            end
              
        end
    end
    // Write Operation is done only when WrEn is high
    else if(WrEn && !RdEn) begin
        RegFile[Address] <= WrData;
    end
    // Read Operation is done only when RdEn is high
    else if(RdEn && !WrEn) begin
        RdData   <= RegFile[Address];
        RD_D_Vld <= 1'b1;
    end 
    else begin
        RD_D_Vld <= 1'b0;
    end         
end

assign REG0 = RegFile['b000] ;
assign REG1 = RegFile['b001] ;
assign REG2 = RegFile['b010] ;
assign REG3 = RegFile['b011] ;
   
endmodule

