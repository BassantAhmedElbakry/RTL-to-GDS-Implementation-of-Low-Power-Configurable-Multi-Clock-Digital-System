module PULSE_GEN (
    // I/O Ports
    input  wire CLK, RST,
    input  wire i_signal,
    output wire o_signal
);

// Internal Signals
reg First_FF;
reg Second_FF;

// Active Low Asynchronous Reset
always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        First_FF  <= 1'b0;
        Second_FF <= 1'b0;
    end
    else begin
       First_FF  <=  i_signal;
       Second_FF <=  First_FF;
    end
end

// Pulse Generator
assign o_signal = First_FF && !Second_FF;
    
endmodule
