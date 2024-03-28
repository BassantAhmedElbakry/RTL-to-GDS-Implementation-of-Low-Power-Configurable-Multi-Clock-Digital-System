module Data_Synchronizer #(
    parameter NUM_STAGES = 2,
    parameter BUS_WIDTH  = 8
) (
    input  wire CLK, RST,
    input  wire bus_enable,
    input  wire [BUS_WIDTH - 1 : 0] unsync_bus,
    output reg  [BUS_WIDTH - 1 : 0]   sync_bus,
    output reg  enable_pulse
);

// Internal signals
reg  Pulse_Gen_FF_OUT;
wire Pulse_Gen_OUT;
wire [BUS_WIDTH  - 1 : 0] sync_bus_comp;
reg  [NUM_STAGES - 1 : 0] internal_DATA;


// Synchronize multiple bits 
always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        internal_DATA  <= 'b0;
    end
    else begin
        internal_DATA  <= {internal_DATA[NUM_STAGES - 2 : 0] ,bus_enable};
    end 
end

// Pulse Gen FF Output  
always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        Pulse_Gen_FF_OUT     <= 1'b0;
    end
    else begin
        Pulse_Gen_FF_OUT     <= internal_DATA[NUM_STAGES - 1];
    end 
end

// Pulse Gen
assign Pulse_Gen_OUT = internal_DATA[NUM_STAGES - 1] && !Pulse_Gen_FF_OUT;

// MUX
assign sync_bus_comp = Pulse_Gen_OUT ? unsync_bus : sync_bus ; 

// Sync bus
always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        sync_bus     <= 'b0;
    end
    else begin
        sync_bus     <= sync_bus_comp;
    end 
end

// Enable pulse 
always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        enable_pulse     <= 1'b0;
    end
    else begin
        enable_pulse     <= Pulse_Gen_OUT;
    end 
end
    
endmodule


