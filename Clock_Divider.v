module ClkDiv #(
    // Parameters
    parameter WIDTH = 8
)(
    // I/O Ports
    input  wire i_clk_ref,
    input  wire i_rst_n ,
    input  wire i_clk_en,
    input  wire [WIDTH - 1 : 0] i_div_ratio,
    output wire o_div_clk
);

// Internal Signals
wire odd;
wire [WIDTH - 2 : 0] half;
wire ClK_DIV_EN;
reg  flag;
reg  [WIDTH - 1 : 0] counter;
reg div_clk;

always @(posedge i_clk_ref or negedge i_rst_n) begin
    //IF RST --> Active Low Asynchronous Reset
    if(!i_rst_n) begin
      div_clk      <= 1'b0;
      counter      <=  'b0;
      flag         <= 1'b0;
    end
    // IF EN
    else if(ClK_DIV_EN) begin
      // IF Div Ratio is even
      if(counter == half && !odd) begin
        // Toggle the clock
        div_clk   <= ~div_clk;
        counter   <=  'b0; 
      end

      // IF Div Ratio is odd
      else if(odd && (counter == half && !flag) || (counter == (half + 1'b1) && flag)) begin
        // Toggle the clock
        div_clk   <= ~div_clk;
        counter   <=  'b0;
        flag      <= !flag;
      end

      else begin
        // Increment the counter
        counter <= counter + 1'b1;
      end
    end
end

// Check Div Ratio is ODD or EVEN ?
assign odd  = (i_div_ratio[0]);
// Get the half of Div Ratio
assign half = ( (i_div_ratio >> 1) - 1);
// Check Div Ratio not equals Zero or One before enable the clock divider
assign ClK_DIV_EN = (i_clk_en && ( i_div_ratio != 1'b0) && ( i_div_ratio != 1'b1));
// IF clock divider is disabled --> generated clock is the reference clock    
assign o_div_clk = ClK_DIV_EN ? div_clk : i_clk_ref;


endmodule


