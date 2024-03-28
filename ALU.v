module ALU #(
    // Parameters
    parameter OPER_WIDTH = 8,
              OUT_WIDTH  = OPER_WIDTH * 2,
              ALU_FUN_WIDTH = 4
)(
    // I/O Ports
    input  wire CLK, RST,
    input  wire ALU_EN,
    input  wire [OPER_WIDTH    - 1 : 0] A, B, 
    input  wire [ALU_FUN_WIDTH - 1 : 0] ALU_FUN,
    output reg  [OUT_WIDTH     - 1 : 0] ALU_OUT,
    output reg  OUT_Valid
);

  // Internal Signals
  reg [OUT_WIDTH - 1 : 0] ALU_COMP_OUT;
  reg OUT_Valid_COMP;

  // Active Low Asynchronous Reset
  always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        ALU_OUT <= 'b0;
        OUT_Valid <= 1'b0;
    end
    else if (ALU_EN) begin
        ALU_OUT   <= ALU_COMP_OUT;
        OUT_Valid <= OUT_Valid_COMP;
    end  
  end

  always @(*) begin
    // Initial values
    ALU_COMP_OUT   = 'b0;
    OUT_Valid_COMP = 1'b0;

    // IF ALU is Enable
    if(ALU_EN) begin

        // OUT_Valid is HIGH
        OUT_Valid_COMP = 1'b1;

        // Choose the Operation
        case (ALU_FUN)
            // Addition operator
            4'b0000: begin
                ALU_COMP_OUT = A + B;
            end
            // Subtractor operator 
            4'b0001: begin
                ALU_COMP_OUT = A - B;
            end
            // Multiplication operator
            4'b0010: begin
                ALU_COMP_OUT = A * B;
            end
            // Division operator
            4'b0011: begin
                ALU_COMP_OUT = A / B;
            end
            // Logic AND 
            4'b0100: begin
                ALU_COMP_OUT = A & B;
            end
            // Logic OR
            4'b0101: begin
                ALU_COMP_OUT = A | B;
            end
            // Logic NAND 
            4'b0110:begin
                ALU_COMP_OUT = ~(A & B);
            end
            // Logic NOR  
            4'b0111: begin
                ALU_COMP_OUT = ~(A | B);
            end 
            // Logic XOR
            4'b1000: begin
                ALU_COMP_OUT = A ^ B;
            end 
            // Logic XNOR
            4'b1001: begin
                ALU_COMP_OUT = (A ~^ B);
            end 
            // Comparison --> Equal
            4'b1010: begin
                ALU_COMP_OUT = (A == B) ? 'b1  : 'b0;
            end
            // Comparison --> Greater than
            4'b1011: begin
                ALU_COMP_OUT = (A > B) ? 'b10  : 'b0;
            end
            // Comparison --> Smaller than
            4'b1100: begin
                ALU_COMP_OUT = (A < B) ? 'b11  : 'b0;
            end
            // Shift Right
            4'b1101: begin
                ALU_COMP_OUT = (A >> 1);
            end
            // Shift Left
            4'b1110: begin
                ALU_COMP_OUT = (A << 1); 
            end
            // Default case
            default: begin 
            // ALU_OUT = 0 & OUT_Valid = 0
                ALU_COMP_OUT   =  'b0;   
            end 
        endcase
    end

    // IF ALU is Disable
    else begin
        // OUT_Valid is LOW
        OUT_Valid_COMP = 1'b0;
    end  
  end

endmodule

