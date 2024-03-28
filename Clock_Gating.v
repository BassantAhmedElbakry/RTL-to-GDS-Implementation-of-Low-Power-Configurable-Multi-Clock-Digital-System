
/////////////////////////////////////////////////////////////
/////////////////////// Clock Gating ////////////////////////
/////////////////////////////////////////////////////////////

module Clock_Gating (
    // I/O Ports
    input  wire CLK,
    input  wire Gate_EN,
    output wire GATED_CLK
);


// Internal Signl
reg     Latch_Out ;

// Latch (Level Sensitive Device)
always @(CLK or Gate_EN)
 begin
  // active low
  if(!CLK)      
   begin
    Latch_Out <= Gate_EN ;
   end
 end
 
 
// ANDING
assign  GATED_CLK = CLK && Latch_Out ;

/*



TLATNCAX12M U0_TLATNCAX12M (
.E(CLK_EN),
.CK(CLK),
.ECK(GATED_CLK)
);

*/




endmodule

