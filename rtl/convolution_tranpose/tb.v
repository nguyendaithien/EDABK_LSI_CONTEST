module tb() ;
  parameter DATA_WIDTH = 16;
  parameter WEIGHT_WIDTH = 8;
  parameter IFM_WIDTH = 8;
  parameter IFM_SIZE = 64;
  // Convolution 1
  parameter KERNEL_SIZE = 3;
  parameter STRIDE = 1;
  parameter PAD = 0;
  parameter RELU = 1;
  parameter CI = 3;
  parameter CO = 32;
	parameter OUT_FEATURE = 66*66*32; 


	reg clk1;
	reg clk2;
	reg rst_n;
  reg start_conv;
  wire ifm_read;
  wire wgt_read;
  wire out_valid;
  wire end_conv;
	wire [DATA_WIDTH-1:0] data_output;

	wire [IFM_WIDTH-1:0] ifm;
	wire [WEIGHT_WIDTH-1:0] wgt;

	always #5 clk1 = ~clk1;
	always @(clk1) begin
		clk2 = ~clk1;
	end
initial begin
		clk1 = 0;
    start_conv = 0;
		#5 rst_n = 1;
    #10 rst_n = 0;
    #10 rst_n = 1;
    #7  start_conv = 1;
    #10 start_conv = 0;
end


CONV #(
    .DATA_WIDTH(16), 
    .WEIGHT_WIDTH(8), 
    .IFM_WIDTH(8),  
    .IFM_SIZE(64), 
    .KERNEL_SIZE(KERNEL_SIZE),
    .STRIDE(1),
    .PAD(0),
    .RELU(1),
    .FIFO_SIZE((IFM_SIZE-1) + KERNEL_SIZE),
    .CI(3), 
    .CO(8)
) cov (
	.clk1       (clk1       ),
	.clk2       (clk2       ),
	.rst_n      (rst_n      ),
  .start_conv (start_conv ),
	.ifm        (ifm        ),
	.wgt        (wgt        ),
  .ifm_read   (ifm_read   ),
  .wgt_read   (wgt_read   ),
  .out_valid  (out_valid  ),
  .end_conv   (end_conv   ),
	.data_output(data_output)
	);
initial begin
	$dumpfile("CONV.VCD");
	$dumpvars(0,tb);
end	

  integer ofm_rtl;
  integer ofm_rtl_1;
  integer ow;
  integer ow_1;
  // Read ifm
  reg [IFM_WIDTH-1:0] ifm_in [0:CI*IFM_SIZE*IFM_SIZE-1];
  reg [WEIGHT_WIDTH-1:0] wgt_in [0:CO*CI*KERNEL_SIZE*KERNEL_SIZE-1];
  reg [31:0] ifm_cnt;
  reg ifm_read_reg;
initial begin
    $readmemb("ifm_bin_c3xh64xw64.txt", ifm_in);
end

always @(posedge clk2 or negedge rst_n)
  begin
    if (!rst_n)
    begin
      ifm_cnt       <= 0;
      ifm_read_reg  <= 0;
    end
    else
    begin
      ifm_read_reg <= ifm_read;
      if ((start_conv && !ifm_read) || ifm_cnt == CI*IFM_SIZE*IFM_SIZE)
        ifm_cnt   <= 0;
      else if (ifm_read)
        ifm_cnt   <= ifm_cnt + 1;
      else
        ifm_cnt   <= ifm_cnt;
    end
  end
  assign ifm = (ifm_read_reg == 1) ? ifm_in[ifm_cnt-1] : 0;

  // Read weight
  reg [31:0] wgt_cnt;
  reg wgt_read_reg;
  initial begin
    $readmemb("weight_bin_co8xci3xk3xk3.txt", wgt_in);
  end

  always @(posedge clk2 or negedge rst_n)
  begin
    if (!rst_n)
    begin
      wgt_cnt       <= 0;
      wgt_read_reg  <= 0;
    end
    else
    begin
      wgt_read_reg <= wgt_read;
      if (wgt_cnt == CO*CI*KERNEL_SIZE*KERNEL_SIZE)
        wgt_cnt   <= 0;
      else if (wgt_read || start_conv)
        wgt_cnt   <= wgt_cnt + 1;
      else
        wgt_cnt   <= wgt_cnt;
    end
  end

  assign wgt = (wgt_read_reg == 1) ? wgt_in[wgt_cnt-1] : 0;

  task read_output;
    input [DATA_WIDTH-1:0] data_output;
    input out_valid;
    reg signed [DATA_WIDTH-1:0] ofm [0:OUT_FEATURE-1];
    integer tow;

    begin
      if (ow < OUT_FEATURE)
      begin
        if (out_valid)
        begin
          ofm[ow] = data_output;
          ow = ow + 1;
        end
      end
      else
      begin
        for (tow = 0; tow < OUT_FEATURE; tow = tow + 1)
          $fwrite(ofm_rtl, "%b \n", ofm[tow]);
        $fclose(ofm_rtl);
        $finish();
      end
    end
  endtask

  initial begin
    ow = 0;
    ow_1 = 0;
    forever begin
      @(posedge clk1);
      read_output(data_output, out_valid);
    end
  end

initial begin
	#1000000 $finish;
end
	
endmodule
