module UART_TX_serializer #(
    parameter DATA_WIDTH = 8
) (
    input  wire clk, rst,
    input  wire [DATA_WIDTH - 1 : 0] ser_P_DATA,
    input  wire ser_EN,
    output reg  ser_DONE,
    output reg  ser_DATA
);

reg [3 : 0] count;

// Take the parallel data and Out it serial bit by bit
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        ser_DATA <= 1'b0;
        count    <= 0;
    end
     else if (ser_EN) begin
      if (count == 'b1000) begin
        count    <= 0;
      end 
      else begin
        ser_DATA <= ser_P_DATA[count];
        count    <= count + 1'b1;
      end
    end
    else begin
      count    <= 0;
    end
end

// Access ser_Done value
always @(*) begin
  if (count == 'b1000) begin
        ser_DONE = 1'b1;
      end 
      else begin
        ser_DONE = 1'b0;
    end
end
    
endmodule


