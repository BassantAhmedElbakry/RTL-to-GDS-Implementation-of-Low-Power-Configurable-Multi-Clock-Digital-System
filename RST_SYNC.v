module RST_SYNC #(
    // Parameters
    parameter  NUM_STAGES = 2
) (
    // I/O Ports
    input  wire CLK, RST,
    output wire SYNC_RST
);

// Internal signal
reg [NUM_STAGES - 1 : 0] internal_RST;

// Synchronize the de-assertion of the asynchronous reset with respect to the clock domain
always @(posedge CLK or negedge RST) begin
    // Active Low Asynchronous Reset
    if(!RST) begin
        internal_RST <= 'b0;
    end
    else begin
        /*
         * NUM_STAGES = 2
         * Fisrt CLK:
         * internal_RST[0] = 1
         * internal_RST[1] = 0 --> SYNC_RST = 0
         * Second CLK:
         * internal_RST[0] = 1
         * internal_RST[1] = 1 --> SYNC_RST = 1
         */
        internal_RST <= {internal_RST[NUM_STAGES - 2 : 0] , 1'b1};
    end
end

// SYNC_RST = The last bit of internal_RST
assign SYNC_RST = internal_RST[NUM_STAGES - 1];
    
endmodule


