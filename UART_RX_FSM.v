module UART_RX_FSM #(
    parameter DATA_WIDTH_FSM = 8 
) (
    input  wire clk, rst,
    input  wire FSM_RX_IN,
    input  wire FSM_par_err,
    input  wire FSM_start_glitch,
    input  wire FSM_stop_err,
    input  wire [3 : 0] FSM_bit_count,
    input  wire [4 : 0] FSM_edge_count,
    input  wire [5 : 0] FSM_Prescale,
    input  wire FSM_edge_done,
    input  wire FSM_PAR_EN,
    output reg  FSM_par_chk_en,
    output reg  FSM_start_chk_en,
    output reg  FSM_stop_chk_en,
    output reg  FSM_edge_bit_counter_en,
    output reg  FSM_data_sample_en,
    output reg  FSM_deser_en,
    output reg  FSM_data_valid
);

// FSM States
localparam [2 : 0] IDLE   = 3'b000,
                   START  = 3'b001,
                   DATA   = 3'b010,
                   PARITY = 3'b011,
                   STOP   = 3'b100;

// Current state and next state
reg  [2 : 0] current_state, next_state;

reg str_glitch;
reg str_glt_en;

reg stp_err_en;
reg stp_error;

reg Error_En;
reg error;

// To handle if we send 2 frames without gap one with parity and the other without parity
reg par_en;

// Asynchronous reset
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end 
end

always @(*) begin
    
    //Initial Values
    FSM_par_chk_en           = 1'b0;
    FSM_start_chk_en         = 1'b0;
    FSM_stop_chk_en          = 1'b0;
    FSM_edge_bit_counter_en  = 1'b0;
    FSM_data_sample_en       = 1'b0;
    FSM_deser_en             = 1'b0;
    FSM_data_valid           = 1'b0;
    stp_err_en               = 1'b0;
    str_glt_en               = 1'b0;

    case (current_state)
        // IDLE State
        IDLE: begin
            FSM_par_chk_en           = 1'b0;
            FSM_start_chk_en         = 1'b0;
            FSM_stop_chk_en          = 1'b0;
            FSM_edge_bit_counter_en  = 1'b0;
            FSM_data_sample_en       = 1'b0;
            FSM_deser_en             = 1'b0;
            Error_En                 = 1'b0;            

            if(!FSM_RX_IN) begin
                next_state = START;
            end
            else begin
                next_state = IDLE;
            end
        end 

        // Start State
        START: begin
           FSM_edge_bit_counter_en  = 1'b1;
           FSM_data_sample_en       = 1'b1;
           FSM_deser_en             = 1'b1;
           Error_En                 = 1'b0; 
           str_glt_en               = 1'b1;

            if(FSM_edge_done && FSM_bit_count == 'b0) begin
                if(str_glitch) begin
                   next_state = IDLE; 
                end
                else begin
                    next_state = DATA;  
                end  
            end

            else if(FSM_edge_count == ((FSM_Prescale >> 1) + 1'b1)) begin
                FSM_start_chk_en = 1'b1;
                next_state = START;
                 
            end
            else begin
                next_state = START; 
            end
        end

        // Data State
        DATA: begin
            FSM_edge_bit_counter_en  = 1'b1;
            FSM_data_sample_en       = 1'b1;
            FSM_deser_en             = 1'b1;
            Error_En                 = 1'b0; 

            if(FSM_bit_count == 'b1000 && FSM_edge_done) begin
                if(FSM_PAR_EN) begin
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
            FSM_edge_bit_counter_en  = 1'b1;
            FSM_data_sample_en       = 1'b1;

            if(error) begin
                Error_En = 1'b1;
            end
            else begin
                Error_En = 1'b0;
            end  

            if(FSM_bit_count == 'b1001 && FSM_edge_done) begin
                next_state = STOP;  
            end

            else if(FSM_edge_count == ((FSM_Prescale >> 1) + 1'b1)) begin
                FSM_par_chk_en           = 1'b1;
                if(FSM_par_err) begin
                    Error_En = 1'b1;
                end else begin
                    Error_En = 1'b0;
                end
                next_state = PARITY;
                 
            end
            else begin
                next_state = PARITY; 
            end

        end

        // Stop State
        STOP: begin
            FSM_edge_bit_counter_en  = 1'b1;
            FSM_data_sample_en       = 1'b1;
            stp_err_en               = 1'b1;

            if(error) begin
                Error_En = 1'b1;
            end
            else begin
                Error_En = 1'b0;
            end

            if((par_en && FSM_bit_count == 'b1010 && FSM_edge_done) || (!par_en && FSM_bit_count == 'b1001 && FSM_edge_done)) begin
                // To handle sending 2 frames without GAP
                if(((stp_error || error) && FSM_RX_IN )) begin
                   next_state = IDLE; 
                end
                else if(((stp_error || error) && !FSM_RX_IN )) begin
                    next_state = START;
                end
                else begin
                    FSM_data_valid = 1'b1;
                    // To handle sending 2 frames without GAP
                    if(!FSM_RX_IN) begin         
                        next_state = START;
                    end
                    else begin
                        next_state = IDLE;
                    end   
                end  
            end

            else if(FSM_edge_count == ((FSM_Prescale >> 1) + 1'b1)) begin
                FSM_stop_chk_en = 1'b1;
                next_state      = STOP;
                 
            end
            else begin
                next_state = STOP; 
            end
        end

        // Default State
        default: begin
            next_state = IDLE;
            Error_En   = 1'b0;
        end 
    endcase
end

// To handle case of parity error and stop error together
always @(negedge clk or negedge rst) begin
    if (!rst) begin
        error <= 1'b0;
    end
    else if(Error_En) begin
        error <= 1'b1;
    end
    else begin
        error <= 1'b0;
    end
end

// Check on start Glitch
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        str_glitch <= 1'b0;
    end
    else if(str_glt_en) begin
        if(FSM_start_glitch) begin
           str_glitch <= 1'b1; 
        end
    end
    else begin
        str_glitch <= 1'b0;
    end
end

// To handle if we send 2 frames without gap one with parity and the other without parity
always @(posedge clk or negedge rst) begin
    if(!rst) begin
       par_en <= 1'b0; 
    end
    else if(FSM_PAR_EN) begin
        par_en <= 1'b1;
        end
    else begin
        par_en <= 1'b0;
    end  
end

// Check on stop Error
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        stp_error <= 1'b0;
    end
    else if(stp_err_en) begin
        if(FSM_stop_err) begin
           stp_error <= 1'b1; 
        end
    end
    else begin
        stp_error <= 1'b0;
    end
end

    
endmodule

