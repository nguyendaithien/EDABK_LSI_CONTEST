module PE #(parameter DATA_WIDTH = 16, WGT_WIDTH = 8, IFM_WIDTH = 8, PSUM_WIDTH = 16, POOLING = 0)(
    clk,
    rst_n,
    set_reg,
		ifm,
		wgt,
		psum_in,
		psum_out
		);

	input clk    ;  
	input rst_n  ;
	input set_reg;
	input  signed [IFM_WIDTH-1:0   ] ifm      ;
	input  signed [WGT_WIDTH-1:0] wgt      ;
	input  signed [PSUM_WIDTH-1:0  ] psum_in  ;
	output signed [PSUM_WIDTH-1:0  ] psum_out ;
	
	reg  signed [PSUM_WIDTH-1:0] psum         ;
	wire signed	[PSUM_WIDTH-1:0] product			;

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
      psum <= 0;
    else 
    begin
      if (set_reg)
      begin
          psum <= psum_wire;
      end
      else
        psum <= psum;
    end
  end
	wire [PSUM_WIDTH-1:0] psum_wire;
	assign psum_wire = ifm*wgt + psum_in;

	assign psum_out = psum;
endmodule
