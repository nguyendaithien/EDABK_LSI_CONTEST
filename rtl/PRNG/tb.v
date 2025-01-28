module tb ();
	reg clk, rst_n;
	reg start;
	reg re_start;
	wire out_valid;
	wire [31:0] data_out;
	wire end_random;


PRNG #(.DATA_WIDTH(32)) dut (
	.clk(clk),
	.rst_n(rst_n),
	.start(start),
	.re_start(re_start),
	.out_valid(out_valid),
	.data_out(data_out),
	.end_random(end_random)
);

initial begin
	$dumpfile("PRNG.VCD");
	$dumpvars(0,tb);
end
integer i;
reg [31:0] state [623:0];
//always @(posedge out_valid ) begin
//	for(i = 0; i < 624 ; i = i+ 1) begin
//		state[i] = dut.state_vector[i];
//		$display(" state vector %d: %h ", i, state[i]);
//	end
//end	

always #5 clk = !clk;
initial begin
	#0 rst_n  = 1;
			clk   = 0;
	re_start = 0;
	#10 rst_n = 0;
	#10 rst_n = 1;
	#40 start = 1;
	#20 start = 0;
	#13500 re_start = 1;
	#20 re_start = 0;

end
initial begin
	#100000 $finish;
end
always @(posedge out_valid) begin
	if(out_valid) begin
		$display("the random number generated in the range [0:1] is %f" , (dut.y10)/($itor(32'hFFFFFFFF)));
	end
end
endmodule
