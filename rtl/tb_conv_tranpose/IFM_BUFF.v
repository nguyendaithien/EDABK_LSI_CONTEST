module IFM_BUFF #(parameter DATA_WIDTH = 8) (
		input clk
	 ,input rst_n
	 ,input set_ifm
	 ,input  [DATA_WIDTH-1:0] ifm_in
	 ,output reg [DATA_WIDTH-1:0] ifm_out
	 );

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			ifm_out <= 0;
		end
		else if(set_ifm) begin
			ifm_out <= ifm_in;
		end
  end
endmodule
