module SYS_CTRL #(
    // Parameters
    parameter ADDRESS       = 4,
    parameter BUS_WIDTH     = 8,
    parameter DATA_WIDTH    = 16,
    parameter ALU_FUN_WIDTH = 4 
) (
    // I/O Ports
    input  wire CLK,
    input  wire RST,
    input  wire [BUS_WIDTH - 1 : 0] sync_RX_Data,
    input  wire RX_enable_Pulse,
    input  wire S_FIFO_FULL,
    input  wire [DATA_WIDTH - 1 : 0] S_Rd_D,
    input  wire S_Rd_D_VLD,
    input  wire [DATA_WIDTH - 1 : 0] S_ALU_OUT,
    input  wire S_ALU_OUT_VLD,
    input  wire S_Par_En,
    input  wire S_str_glt,
    input  wire S_parity_Err,
    input  wire S_frame_Err,
    output reg  [DATA_WIDTH - 1 : 0] S_FIFO_WR_DATA,
    output reg  S_FIFO_WR_INC,
    output reg  S_WrEn,
    output reg  S_RdEn,
    output reg  [ADDRESS    - 1 : 0] S_Addr,
    output reg  [DATA_WIDTH - 1 : 0] S_Wr_D,
    output reg  S_Gate_EN,
    output reg  S_ALU_EN,
    output reg  [ALU_FUN_WIDTH - 1 : 0] S_ALU_FUNC,
    output reg  S_ClK_DIV_EN
);

// FSM States
localparam [4 : 0] IDLE           = 'b0000,
                   FRAME_0        = 'b0001,
                   WR_ADDR        = 'b0010,
                   WAIT_WR_ADDR   = 'b0011,
                   RD_ADDR        = 'b0100,
                   WAIT_RD_ADDR   = 'b0101,
                   OPERAND_A      = 'b0110,
                   WAIT_OPERAND_A = 'b0111,
                   ALU_FUNC       = 'b1000,
                   WAIT_ALU_FUNC  = 'b1001,
                   WR_DATA        = 'b1010,
                   WAIT_WR_DATA   = 'b1011,
                   SEND_DATA      = 'b1100,
                   DELAY_ADDR     = 'b1101,
                   SEND_RES       = 'b1110,
                   ALU_FUNC2      = 'b1111,
                   OPERAND_B      = 'b10000,
                   WAIT_OPERAND_B = 'b10001,
                   OPERAND_A_WR   = 'b10010,
                   OPERAND_B_WR   = 'b10011,
                   OP_A_DELAY     = 'b10100,
                   OP_B_DELAY     = 'b10101;

localparam [3 : 0] OP_A_ADDRESS = 'h0;
localparam [3 : 0] OP_B_ADDRESS = 'h1;

// Current state and next state
reg  [4 : 0] current_state, next_state;

// Recevied Frame 
reg [10 : 0] Frame;

// Counter
reg [3 : 0] counter;
reg count_done;
reg count_EN;

reg Address_Flag;
reg ALU_Fun_Flag;
reg OP_A_Flag, OP_B_Flag;

//reg [BUS_WIDTH - 1 : 0] A,B;


// Asynchronous reset
always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end 
end

// Next state Logic
always @(*) begin
    /****************** Initial Values ******************/ 

    /* Clock Divider is always on (clock divider enable = 1) */
    S_ClK_DIV_EN   = 1'b1;
    S_Gate_EN      = 1'b0;
    S_ALU_EN       = 1'b0;
    S_RdEn         = 1'b0;
    S_WrEn         = 1'b0;
    count_EN       = 1'b0;
    Address_Flag   = 1'b0;
    ALU_Fun_Flag   = 1'b0;
    S_FIFO_WR_INC  = 1'b0;
    S_FIFO_WR_DATA =  'b0; 
    OP_A_Flag      = 1'b0;
    OP_B_Flag      = 1'b0;   

    if(S_str_glt || S_parity_Err || S_frame_Err) begin
        next_state = IDLE;
    end
    else begin
        case (current_state)
        // IDLE State
            IDLE: begin
                if(RX_enable_Pulse) begin
                    next_state = FRAME_0;
                end
                else begin
                    next_state = IDLE;
                end
            end
            // Receive Frame_0
            FRAME_0: begin
                Frame = sync_RX_Data[7 : 0];
                if(Frame[7 : 0] == 'hAA) begin
                    if(RX_enable_Pulse) begin
                    next_state = WR_ADDR;
                   end
                   else begin
                    next_state = WAIT_WR_ADDR;
                   end
                    end
                else if(Frame[7 : 0] == 'hBB) begin
                    if(RX_enable_Pulse) begin
                    next_state = RD_ADDR;
                   end
                   else begin
                    next_state = WAIT_RD_ADDR;
                   end
                end
                else if(Frame[7 : 0] == 'hCC) begin
                    if(RX_enable_Pulse) begin
                    next_state = OPERAND_A;
                    end
                   else begin
                    next_state = WAIT_OPERAND_A;
                   end
                end
                else if(Frame[7 : 0] == 'hDD) begin
                    if(RX_enable_Pulse) begin
                    next_state = ALU_FUNC;
                   end
                   else begin
                    next_state = WAIT_ALU_FUNC;
                   end
                end
                else begin
                    next_state = IDLE;
                end
            end
            // Address for write
            WR_ADDR: begin
                Address_Flag = 1'b1;
                if(RX_enable_Pulse) begin
                    next_state = WR_DATA;
                end
                else begin
                    next_state = WAIT_WR_DATA;
                end
            end
            // Wait for start sending Frame which has the Address 
            WAIT_WR_ADDR: begin
                if(RX_enable_Pulse) begin
                  next_state = WR_ADDR;
                end
                else begin
                  next_state = WAIT_WR_ADDR;
                end
            end
            // Writing the Data
            WR_DATA: begin
                S_WrEn     = 1'b1;
                if(RX_enable_Pulse) begin
                    next_state = FRAME_0;
                end
                else begin
                    next_state = WR_DATA;
                end
            end
            // Waiting for start sending Frame which has the Data 
            WAIT_WR_DATA: begin
                if(RX_enable_Pulse) begin
                  next_state = WR_DATA;
                end
                else begin
                  next_state = WAIT_WR_DATA;
                end
            end
            // Address for Reading Data
            RD_ADDR: begin
                Address_Flag = 1'b1;
                next_state = DELAY_ADDR;
            end
            // Waiting for send Address to read it 
            WAIT_RD_ADDR: begin
                if(RX_enable_Pulse) begin
                  next_state = RD_ADDR;
                end
                else begin
                  next_state = WAIT_RD_ADDR;
                end
            end
            DELAY_ADDR: begin
                S_RdEn = 1'b1;
                next_state = SEND_DATA;
            end
            SEND_DATA: begin
                if(!S_FIFO_FULL) begin
                   S_FIFO_WR_DATA = S_Rd_D;
                    S_FIFO_WR_INC = 1'b1;
                    if(RX_enable_Pulse) begin
                        next_state = FRAME_0;
                    end
                    else begin
                        next_state = IDLE;
                    end 
                end
                else begin
                    next_state = SEND_DATA;
                end
            end
            ALU_FUNC: begin
                S_ALU_EN     = 1'b1;
                ALU_Fun_Flag = 1'b1;
                S_Gate_EN    = 1'b1;
                next_state   = ALU_FUNC2;
            end

            ALU_FUNC2: begin
                S_ALU_EN     = 1'b1;
                ALU_Fun_Flag = 1'b1;
                S_Gate_EN    = 1'b1;
                next_state   = SEND_RES;
            end

            WAIT_ALU_FUNC: begin
                if(RX_enable_Pulse) begin
                    next_state = ALU_FUNC;
                end
                else begin
                    next_state = WAIT_ALU_FUNC;
                end
            end
            SEND_RES: begin
                S_ALU_EN  = 1'b1;
                S_Gate_EN = 1'b1;
                ALU_Fun_Flag = 1'b1;
                if(!S_FIFO_FULL) begin
                   S_FIFO_WR_DATA = S_ALU_OUT;
                    S_FIFO_WR_INC = 1'b1;
                    if(RX_enable_Pulse) begin
                        next_state = FRAME_0;
                    end
                    else begin
                        next_state = IDLE;
                    end 
                end
                else begin
                    next_state = SEND_RES;
                end
            end
            OPERAND_A: begin
                OP_A_Flag    = 1'b1;
                next_state   = OP_A_DELAY; 
            end
            OP_A_DELAY: begin
                S_WrEn       = 1'b1;
                OP_A_Flag    = 1'b1;
                next_state   = OPERAND_A_WR; 
            end
            OPERAND_A_WR: begin
                S_WrEn       = 1'b1;
                OP_A_Flag    = 1'b1;
                if(RX_enable_Pulse) begin
                    next_state = OPERAND_B;
                end
                else begin
                    next_state = WAIT_OPERAND_B;
                end
            end
            WAIT_OPERAND_A: begin
                if(RX_enable_Pulse) begin
                    next_state = OPERAND_A;
                end
                else begin
                    next_state = WAIT_OPERAND_A;
                end
            end
            OPERAND_B: begin
                OP_B_Flag    = 1'b1; 
                next_state   = OP_B_DELAY;
            end
            OP_B_DELAY: begin
                S_WrEn       = 1'b1;
                OP_B_Flag    = 1'b1;
                next_state   = OPERAND_B_WR; 
            end
            OPERAND_B_WR: begin
                S_WrEn       = 1'b1;
                OP_B_Flag    = 1'b1; 
                if(RX_enable_Pulse) begin
                    next_state = ALU_FUNC;
                end
                else begin
                    next_state = WAIT_ALU_FUNC;
                end
            end
            WAIT_OPERAND_B: begin
                if(RX_enable_Pulse) begin
                    next_state = OPERAND_B;
                end
                else begin
                    next_state = WAIT_OPERAND_B;
                end
            end
        endcase
    end   
end

always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        S_Addr     <= 'b0;
        S_Wr_D     <= 'b0;
        S_ALU_FUNC <= 'b0;
    end
    else if(Address_Flag) begin
        S_Addr <= sync_RX_Data;
    end
    else if(S_WrEn && !OP_A_Flag && !OP_B_Flag) begin
        S_Wr_D <= sync_RX_Data;
    end
    else if(ALU_Fun_Flag) begin
        S_ALU_FUNC <= sync_RX_Data;
    end
    else if(OP_A_Flag && !S_WrEn) begin
        S_Addr <= OP_A_ADDRESS;
    end
    else if(OP_A_Flag && S_WrEn) begin
        S_Addr <= OP_A_ADDRESS;
        S_Wr_D <= sync_RX_Data; 
    end
    else if(OP_B_Flag && !S_WrEn) begin
        S_Addr <= OP_B_ADDRESS;
    end
    else if(OP_B_Flag && S_WrEn) begin
        S_Addr <= OP_B_ADDRESS;
        S_Wr_D <= sync_RX_Data; 
    end
end
    
endmodule
