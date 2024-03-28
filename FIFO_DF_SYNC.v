module FIFO_DF_SYNC #(
    // Parameters
    parameter NUM_STAGES = 2,
    parameter BUS_WIDTH = 4
)(
    // I/O Ports
    input  wire CLK, RST,
    input  wire [BUS_WIDTH - 1 : 0] ASYNC,
    output reg  [BUS_WIDTH - 1 : 0]  SYNC
);

// Internal signal
integer i;
reg [NUM_STAGES - 1 : 0] internal_BIT [BUS_WIDTH - 1 : 0];

// Synchronize asynchronous signals to avoid CDC issues
always @(posedge CLK or negedge RST) begin
    // Active Low Asynchronous Reset
    if(!RST) begin
        for (i = 0 ; i < BUS_WIDTH ; i = i + 1) begin
            internal_BIT[i] <= 'b0;
        end   
    end
    else begin
        for(i = 0 ; i < BUS_WIDTH ; i = i + 1) begin
           internal_BIT[i] <= {internal_BIT[i][NUM_STAGES - 2 : 0],ASYNC[i]}; 
        end 
    end
end

// The OutPut
always @(*) begin
    for(i = 0 ; i < BUS_WIDTH ; i = i + 1) begin
        SYNC[i] = internal_BIT[i][NUM_STAGES - 1];
    end
end

endmodule


