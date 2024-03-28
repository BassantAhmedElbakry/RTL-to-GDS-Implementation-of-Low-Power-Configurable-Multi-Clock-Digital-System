module UART_TX_FSM #(
    parameter DATA_WIDTH_FSM = 8 
) (
    input  wire clk, rst,
    input  wire FSM_DATA_VALID,
    input  wire FSM_ser_done,
    input  wire FSM_Par_en,
    output reg  FSM_ser_en,
    output reg  [1 : 0] FSM_mux_sel,
    output reg  FSM_Busy,
    // Flag to Avoid input new data when sending frame
    output reg  flag    
);

// FSM States
localparam [2 : 0] IDLE   = 3'b000,
                   START  = 3'b001,
                   DATA   = 3'b010,
                   PARITY = 3'b011,
                   STOP   = 3'b100;

// MUX Selection
localparam [1 : 0] Start_bit = 2'b00,
                   Stop_bit  = 2'b01,
                   Ser_data  = 2'b10,
                   Par_bit   = 2'b11;

// Current state and next state
reg  [2 : 0] current_state, next_state;

// Asynchronous reset
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end 
end

// next state logic and output
always @(*) begin

    // Initial Values
    FSM_Busy       = 1'b0;
    FSM_ser_en     = 1'b0;
    flag           = 1'b0;
    FSM_mux_sel    = Stop_bit;

    case (current_state)
        // IDLE State
        IDLE: begin
            FSM_Busy    = 1'b0;
            FSM_ser_en  = 1'b0;
            flag        = 1'b1;
            FSM_mux_sel = Stop_bit;
            if (FSM_DATA_VALID && flag) begin
                next_state = START;
            end
            else begin
                next_state = IDLE;
            end
        end

        // Start State
        START: begin
            FSM_mux_sel = Start_bit;
            FSM_ser_en  = 1'b1; 
            FSM_Busy    = 1'b1;
            flag        = 1'b0;
            next_state  = DATA;
        end

        // Data State
        DATA: begin
            FSM_ser_en     = 1'b1;
            FSM_mux_sel    = Ser_data;
            FSM_Busy       = 1'b1;
            flag           = 1'b0;
            if (FSM_ser_done) begin
               if(FSM_Par_en) begin
                next_state = PARITY;
            end
            else begin
                next_state = STOP;
            end  
            end
            else begin
                next_state = DATA;
            end            
        end

        // Parity State
        PARITY: begin
            FSM_ser_en     = 1'b0;
            FSM_mux_sel    = Par_bit;
            FSM_Busy       = 1'b1;
            next_state     = STOP; 
            flag           = 1'b0; 
        end

        // Stop State
        STOP: begin
            FSM_ser_en     = 1'b0;
            FSM_mux_sel    = Stop_bit;
            FSM_Busy       = 1'b1;
            flag           = 1'b1;
            next_state     = IDLE;
            /*if (FSM_DATA_VALID) begin
                next_state = START;
            end
            else begin
                next_state = IDLE;
            end*/
        end

        // Default State
        default: begin
            next_state = IDLE;
        end
    endcase
    
end

endmodule

