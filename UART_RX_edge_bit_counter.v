module UART_RX_edge_bit_counter(
    input  wire clk,rst,
    input  wire counter_Enable,
    input  wire counter_par_en,
    input  wire [5 : 0] counter_Prescale,
    output reg  done_edge,
    output reg  [3 : 0] bit_count,
    output reg  [4 : 0] edge_count
);

// To handle if we send 2 frames without gap one with parity and the other without parity
reg par_en;

// Count edges
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        edge_count <= 1'b0;
    end
    else if(counter_Enable) begin
        if(done_edge) begin
            edge_count <= 'b0;
        end 
        else begin
            edge_count <= edge_count + 1'b1;
        end
    end
end

// Check if edge count is done or not
always @(*) begin
    if(edge_count == (counter_Prescale - 1'b1)) begin
        done_edge = 1'b1;
    end
    else begin
        done_edge = 1'b0;
    end
end

// Count bits
always @(posedge clk or negedge rst) begin
    if(!rst) begin
       bit_count  <= 'b0; 
    end
    else if(counter_Enable) begin
        if(done_edge) begin
            if( (bit_count == 'b1010 && par_en) || (bit_count == 'b1001 && !par_en) ) begin
                bit_count <= 'b0;
            end
            else begin
                bit_count <= bit_count + 1'b1;
            end
        end
    end
    else begin
        bit_count <= 'b0;
    end
end

// To handle if we send 2 frames without gap one with parity and the other without parity
always @(posedge clk or negedge rst) begin
    if(!rst) begin
       par_en <= 1'b0; 
    end
    else if(counter_par_en) begin
        par_en <= 1'b1;
        end
    else begin
        par_en <= 1'b0;
    end
end
    
endmodule

