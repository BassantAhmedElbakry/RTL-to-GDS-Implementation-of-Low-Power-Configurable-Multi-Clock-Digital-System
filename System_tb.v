// Scale my time to nano second
`timescale 1ns/100ps

module System_tb #(
    parameter FIFO_DATA_WIDTH_TB = 16,
    parameter ALU_FUN_WIDTH_TB = 4,
    parameter DATA_WIDTH_TB = 16,
    parameter ADDRESS_TB    = 4
) ();

parameter REF_CLK_PERIOD  = 10,
          UART_CLK_PERIOD = 271.26736111; 

integer i ;   

// DUT Signals
reg  REF_CLK_tb;
reg  UART_CLK_tb;
reg  RST_tb;
reg  UART_RX_IN_tb;
wire UART_TX_OUT_tb;
wire UART_str_GLT_tb;
wire UART_parity_Error_tb;
wire UART_framing_Error_tb;

// DUT Instantiation
System #(
    .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH_TB),
    .ALU_FUN_WIDTH(ALU_FUN_WIDTH_TB),
    .DATA_WIDTH(DATA_WIDTH_TB),
    .ADDRESS(ADDRESS_TB)
) DUT (
    .REF_CLK(REF_CLK_tb),
    .UART_CLK(UART_CLK_tb),
    .RST(RST_tb),
    .UART_RX_IN(UART_RX_IN_tb),
    .UART_TX_OUT(UART_TX_OUT_tb),
    .UART_str_GLT(UART_str_GLT_tb),
    .UART_parity_Error(UART_parity_Error_tb),
    .UART_framing_Error(UART_framing_Error_tb)
);

// Ref Clock Generator --> 50M Hz     --> Tperiod = 20 nano seconds
always #(REF_CLK_PERIOD/2) REF_CLK_tb = ~REF_CLK_tb;

// UART Clock Generator --> 3.6864M Hz --> Tperiod = 271.26736111 nano seconds
always #(UART_CLK_PERIOD/2) UART_CLK_tb = ~UART_CLK_tb;

// Initial Block
initial begin
    
    // Save Waveform
    $dumpfile("System.vcd");
    $dumpvars;

    // Initialization
    Initialize();

    // Reset
    Reset();

        /******************************************************************** TESTS ********************************************************************/

                                                    /******************** First Command Test ********************/
    /*** Write at address 0x05 ***/
    Fisrt_Command_EA_ED('h05,'hFF);

    // Check
    if(DUT.U11.RegFile[5] == 'hFF) begin
        $display("FIRST COMMAND IS PASSED :) ");
    end
    else begin
        $display("FIRST COMMAND IS FAILED :( ");
    end

                                                /******************** Second Command Test ********************/
    
    // 0000_0101 contains UART_Config = b001000_01
    Second_Command_Odd('h02);
    
    // Check
    if(DUT.U0.UART_RD_DATA == 'b001000_01) begin
        $display("SECOND COMMAND IS PASSED :) ");
    end
    else begin
        $display("SECOND COMMAND IS FAILED :( ");
    end

                                                    /******************** Third Command Test ********************/

    // Send: A, B, ALU_Func
    // A = 0x0F = 1111 & B = 0x05 = 0101 & ALU_FUNC = 0x01 = 0001 --> SUB
    Third_Command_E_E_O('h0F,'h05,'h01);
    
    // Check
    if(DUT.U0.UART_RD_DATA == 'b1010) begin
        $display("THIRD COMMAND IS PASSED :) ");
    end
    else begin
        $display("THIRD COMMAND IS FAILED :( ");
    end

                                                /******************** Fourth Command Test ********************/
    /*** Write at address 0x00 && 0x01 to access Operand A and Operand B Values ***/

    // A_Operand --> Addrress A is 0x00
    // Data = 0000_0110
    Fisrt_Command_EA_ED('h00,'h06);

    // B_Operand --> Addrress B is 0x01
    // Data = 0000_0100
    Fisrt_Command_OA_OD('h01,'h04);

    // ALU_FUNC = 0000 --> ADD
    Fourth_Command_Even('b0000);

    // Check --> ADD A + B = 6 + 4 = 10
    if(DUT.U0.UART_RD_DATA == 'b0000_1010) begin
        $display("FOURTH COMMAND 0 IS PASSED :) ");
    end
    else begin
        $display("FOURTH COMMAND 0 IS FAILED :( ");
    end

    // ALU_FUNC = 0001 --> SUB
    Fourth_Command_Odd('b0001);

    // Check --> SUB A - B = 6 - 4 = 2
    if(DUT.U0.UART_RD_DATA == 'b0000_0010) begin
        $display("FOURTH COMMAND 1 IS PASSED :) ");
    end
    else begin
        $display("FOURTH COMMAND 1 IS FAILED :( ");
    end

    // ALU_FUNC = 0100 --> AND
    Fourth_Command_Odd('b0100);

    // Check --> AND A & B = 110 & 100 = 100
    if(DUT.U0.UART_RD_DATA == 'b0000_0100) begin
        $display("FOURTH COMMAND 2 IS PASSED :) ");
    end
    else begin
        $display("FOURTH COMMAND 2 IS FAILED :( ");
    end

    // ALU_FUNC = 1011 --> CMP
    Fourth_Command_Odd('b1011);

    // Check --> CMP A > B = 6 > 4 = 2
    if(DUT.U0.UART_RD_DATA == 'b0000_0010) begin
        $display("FOURTH COMMAND 3 IS PASSED :) ");
    end
    else begin
        $display("FOURTH COMMAND 3 IS FAILED :( ");
    end


    $stop;

end

/********************************** TASKS **********************************/

// Initialize task
task Initialize;
    begin
        REF_CLK_tb        = 1'b0; 
        UART_CLK_tb       = 1'b0;
        UART_RX_IN_tb     = 1'b1;
    end
endtask

// Reset task
task Reset;
    begin
        RST_tb = 1'b0;
        #(REF_CLK_PERIOD);
        RST_tb = 1'b1;
    end
endtask

task send_Frame_Even_PRT;
input [7 : 0] Frame;
    begin
        // Start Bit
       UART_RX_IN_tb     = 1'b0;
       #(8*UART_CLK_PERIOD);

       // Data
       for(i = 0 ; i < 8 ; i = i + 1) begin
        UART_RX_IN_tb     = Frame[i];
        #(8*UART_CLK_PERIOD);
       end

       // Parity Bit
       UART_RX_IN_tb     = 1'b0;
       #(8*UART_CLK_PERIOD);

       // Stop Bit
       UART_RX_IN_tb     = 1'b1;
       #(8*UART_CLK_PERIOD);

    end
endtask

task send_Frame_Odd_PRT;
input [7 : 0] Frame;
    begin
        // Start Bit
       UART_RX_IN_tb     = 1'b0;
       #(8*UART_CLK_PERIOD);

       // Data
       for(i = 0 ; i < 8 ; i = i + 1) begin
        UART_RX_IN_tb     = Frame[i];
        #(8*UART_CLK_PERIOD);
       end

       // Parity Bit
       UART_RX_IN_tb     = 1'b1;
       #(8*UART_CLK_PERIOD);

       // Stop Bit
       UART_RX_IN_tb     = 1'b1;
       #(8*UART_CLK_PERIOD);

    end
endtask

task Fisrt_Command_EA_ED;
input [7 : 0] Fisrt_Command_Address;
input [7 : 0] Fisrt_Command_Data;
begin
    // Write CMD
    send_Frame_Even_PRT('hAA);
    #(8*UART_CLK_PERIOD);
    
    // The Address
    send_Frame_Even_PRT(Fisrt_Command_Address); 
    #(8*UART_CLK_PERIOD);

    // The Data
    send_Frame_Even_PRT(Fisrt_Command_Data); 
    #(32*UART_CLK_PERIOD);

end
endtask

task Fisrt_Command_EA_OD;
input [7 : 0] Fisrt_Command_Address;
input [7 : 0] Fisrt_Command_Data;
begin
    // Write CMD
    send_Frame_Even_PRT('hAA);
    #(8*UART_CLK_PERIOD);
    
    // The Address
    send_Frame_Even_PRT(Fisrt_Command_Address); 
    #(8*UART_CLK_PERIOD);

    // The Data
    send_Frame_Odd_PRT(Fisrt_Command_Data); 
    #(32*UART_CLK_PERIOD);

end
endtask

task Fisrt_Command_OA_ED;
input [7 : 0] Fisrt_Command_Address;
input [7 : 0] Fisrt_Command_Data;
begin
    // Write CMD
    send_Frame_Even_PRT('hAA);
    #(8*UART_CLK_PERIOD);
    
    // The Address
    send_Frame_Odd_PRT(Fisrt_Command_Address); 
    #(8*UART_CLK_PERIOD);

    // The Data
    send_Frame_Even_PRT(Fisrt_Command_Data); 
    #(32*UART_CLK_PERIOD);

end
endtask

task Fisrt_Command_OA_OD;
input [7 : 0] Fisrt_Command_Address;
input [7 : 0] Fisrt_Command_Data;
begin
    // Write CMD
    send_Frame_Even_PRT('hAA);
    #(8*UART_CLK_PERIOD);
    
    // The Address
    send_Frame_Odd_PRT(Fisrt_Command_Address); 
    #(8*UART_CLK_PERIOD);

    // The Data
    send_Frame_Odd_PRT(Fisrt_Command_Data); 
    #(32*UART_CLK_PERIOD);

end
endtask

task Fourth_Command_Even;
input [3 : 0] ALU_Func;
begin
    // ALU Operation command with No operand
    send_Frame_Even_PRT('hDD);  // 1101_1101
    #(8*UART_CLK_PERIOD);
    
    // ALU FUNC 
    send_Frame_Even_PRT(ALU_Func);
    #(32*UART_CLK_PERIOD);
    #(32*UART_CLK_PERIOD);
    #(32*UART_CLK_PERIOD);
end
endtask

task Fourth_Command_Odd;
input [3 : 0] ALU_Func;
begin
    // ALU Operation command with No operand
    send_Frame_Even_PRT('hDD);  // 1101_1101
    #(8*UART_CLK_PERIOD);
    
    // ALU FUNC 
    send_Frame_Odd_PRT(ALU_Func);
    #(32*UART_CLK_PERIOD);
    #(32*UART_CLK_PERIOD);
    #(32*UART_CLK_PERIOD);
end
endtask

task Second_Command_Even;
input [3 : 0] Second_Command_Address;
begin
    send_Frame_Even_PRT('hBB);  // 1011_1011
    #(8*UART_CLK_PERIOD);
    
    // Address 
    send_Frame_Even_PRT(Second_Command_Address);
    #(32*UART_CLK_PERIOD);
    #(32*UART_CLK_PERIOD);
end
endtask

task Second_Command_Odd;
input [3 : 0] Second_Command_Address;
begin
    send_Frame_Even_PRT('hBB);  // 1011_1011
    #(8*UART_CLK_PERIOD);
    
    // Address 
    send_Frame_Odd_PRT(Second_Command_Address);
    #(32*UART_CLK_PERIOD);
    #(32*UART_CLK_PERIOD);
end
endtask

task Third_Command_E_E_E;
input [7 : 0] OP_A;
input [7 : 0] OP_B;
input [7 : 0] ALU_FUNCTION;
begin
    // ALU Operation command with operand 
    send_Frame_Even_PRT('hCC); // 1100_1100
    #(8*UART_CLK_PERIOD);
    #(8*UART_CLK_PERIOD);

    // Frame contains A
    send_Frame_Even_PRT(OP_A); // 0000_1111 --> 15
    #(8*UART_CLK_PERIOD);
    #(8*UART_CLK_PERIOD);
    #(8*UART_CLK_PERIOD);

    // Frame contains B
    send_Frame_Even_PRT(OP_B); // 0000_0101 --> 5
    #(8*UART_CLK_PERIOD);
    #(8*UART_CLK_PERIOD);
    #(8*UART_CLK_PERIOD);

    // ALU FUNC 
    send_Frame_Even_PRT(ALU_FUNCTION);
    #(32*UART_CLK_PERIOD);
    #(32*UART_CLK_PERIOD);

end
endtask

task Third_Command_E_E_O;
input [7 : 0] OP_A;
input [7 : 0] OP_B;
input [7 : 0] ALU_FUNCTION;
begin
    // ALU Operation command with operand 
    send_Frame_Even_PRT('hCC); // 1100_1100
    #(8*UART_CLK_PERIOD);
    #(8*UART_CLK_PERIOD);

    // Frame contains A
    send_Frame_Even_PRT(OP_A); // 0000_1111 --> 15
    #(8*UART_CLK_PERIOD);
    #(8*UART_CLK_PERIOD);
    #(8*UART_CLK_PERIOD);

    // Frame contains B
    send_Frame_Even_PRT(OP_B); // 0000_0101 --> 5
    #(8*UART_CLK_PERIOD);
    #(8*UART_CLK_PERIOD);
    #(8*UART_CLK_PERIOD);

    // ALU FUNC 
    send_Frame_Odd_PRT(ALU_FUNCTION);
    #(32*UART_CLK_PERIOD);
    #(32*UART_CLK_PERIOD);

end
endtask

endmodule