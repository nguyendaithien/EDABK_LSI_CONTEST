module tb() ;
  parameter DATA_WIDTH = 16;
  parameter WEIGHT_WIDTH = 8;
  parameter IFM_WIDTH = 8;
  parameter IFM_SIZE = 1992;

  parameter KERNEL_SIZE = 512;
  parameter RELU = 1;
	parameter OUT_FEATURE = KERNEL_SIZE; 

	parameter TOTAL_ELEMENTS = KERNEL_SIZE;
  parameter WAIT = 3'b011;


	reg clk1;
	reg clk2;
	reg rst_n;
  reg valid_ifm;
  wire ifm_read;
  wire wgt_read;
  wire out_valid;
  wire end_compute;


	wire [IFM_WIDTH-1:0] ifm;
	wire [WEIGHT_WIDTH*WEIGHT_WIDTH-1:0] wgt;
	wire [DATA_WIDTH-1:0] ofm;

	always #5 clk1 = ~clk1;
	always @(clk1) begin
		clk2 = ~clk1;
	end
initial begin
		clk1 = 0;
		#5     rst_n = 1;
    #10    rst_n = 0;
    #10    rst_n = 1;
	  #20    valid_ifm = 1;
	  #19920 valid_ifm = 0;
end
FC #(.DATA_WIDTH(DATA_WIDTH), .IFM_WIDTH(IFM_WIDTH), .WGT_WIDTH(WEIGHT_WIDTH), .IFM_SIZE(IFM_SIZE), .KERNEL_SIZE(KERNEL_SIZE), .TILING_SIZE(8), .RELU(1))  fully_connected (
	 .clk1         (clk1      )      
	,.clk2         (clk2      )
	,.rst_n        (rst_n     )
	,.ifm          (ifm       ) 
	,.valid_ifm    (valid_ifm )
	,.wgt          (wgt       ) 
	,.ofm          (ofm       )       
	,.valid_data   (valid_data)
	,.ifm_read     (ifm_read  )
	,.wgt_read     (wgt_read  )
	,.end_compute  (end_compute)
);

initial begin
	$dumpfile("FC.VCD");
	$dumpvars(0,tb);
end	

  integer ofm_rtl;
  integer ow;
  reg [IFM_WIDTH-1:0] ifm_in [0:IFM_SIZE-1];
  reg [WEIGHT_WIDTH*WEIGHT_WIDTH-1:0] wgt_in [0:KERNEL_SIZE*(IFM_SIZE/8)-1];

  reg [31:0] ifm_cnt;
  reg ifm_read_reg;
	reg [DATA_WIDTH-1:0] ofm_out [KERNEL_SIZE:0];
	reg [DATA_WIDTH-1:0] ofm_golden [KERNEL_SIZE-1:0];
    integer sample_index; // Vị trí của giá trị đang được xử lý
    integer file, i, error_count;
initial begin
  $readmemb("../script/ifm_bin_1992.txt", ifm_in);
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
      if ((!ifm_read) || ifm_cnt == IFM_SIZE)
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
    $readmemb("../script/weight_bin_512x1992.txt", wgt_in);
  end

  always @(posedge clk1 or negedge rst_n)
  begin
    if (!rst_n)
    begin
      wgt_cnt       <= 0;
      wgt_read_reg  <= 0;
    end
    else
    begin
      wgt_read_reg <= wgt_read;
      if (wgt_cnt == KERNEL_SIZE*(IFM_SIZE/8))
        wgt_cnt   <= 0;
      else if (wgt_read)
        wgt_cnt   <= wgt_cnt + 1;
      else
        wgt_cnt   <= wgt_cnt;
    end
  end

reg [10:0] counter_output;
always @(posedge fully_connected.set_output or negedge rst_n) begin
	if(!rst_n) begin
		counter_output <= 0;
	end else begin
		counter_output <= counter_output + 1;
	end
end
always @(posedge clk1) begin
	if(fully_connected.controller.current_state == WAIT) begin
		$display( "COMPUTING TILING %d " , fully_connected.controller.counter_tiling);
	end
end


  assign wgt = (wgt_read_reg == 1) ? wgt_in[wgt_cnt-1] : 0;

  task read_output;
    input [DATA_WIDTH-1:0] data_output;
    input out_valid;
  //  reg signed [DATA_WIDTH-1:0] ofm [0:TOTAL_ELEMENTS-1];
    integer tow;

    begin
      if (ow <= OUT_FEATURE)
      begin
        if (out_valid)
        begin
          ofm_out[ow] = data_output;
          ow = ow + 1;
        end
      end
      else
      begin
        for (tow = 0; tow < OUT_FEATURE; tow = tow + 1)
          $fwrite(ofm_rtl, "%b \n", ofm_out[tow]);
          $fclose(ofm_rtl);
          $finish();
      end
    end
  endtask

initial begin
	$readmemb("../script/ofm_bin_512.txt",ofm_golden);
end
  initial begin
    ow = 0;
    forever begin
      @(posedge clk2);
      read_output(ofm, valid_data);
    end
  end
// COMPARE 2 MATRIX
task compare;
	integer  i;
	begin
		for(i = 0; i < TOTAL_ELEMENTS ; i = i + 1) begin
	//		$display (" matrix ofm RTL : %d", ofm_out[i]);
	//		$display (" matrix golden : %d", ofm_golden[i]);
			if(ofm_golden[i] != ofm_out[i]) begin
				$display("NO PASS in %d", i);
			$display (" matrix ofm RTL : %d", ofm[i]);
			$display (" matrix golden : %d", ofm_golden[i]);
				disable compare;
			end
		end
		$display("\n");
		$display("██████╗  █████╗ ███████╗███████╗    ████████╗███████╗███████╗████████╗");
		$display("██╔══██╗██╔══██╗██╔════╝██╔════╝    ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝");
		$display("██████╔╝███████║███████╗███████╗       ██║   █████╗  ███████    ██║   ");
		$display("██╔═══╝ ██╔══██║╚════██║╚════██║       ██║   ██╔══╝       ██    ██║   ");
		$display("██║     ██║  ██║███████║███████║       ██║   ███████╗███████╗   ██║   ");
		$display("╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝       ╚═╝   ╚══════╝╚══════╝   ╚═╝   ");
	end
endtask

always @(posedge end_compute) begin
	if(end_compute) begin
		compare();
//		for(i = 0 ; i < TOTAL_ELEMENTS/100; i= i + 1) begin
//			$display(" ofm %d :  %d " , i , ofm_golden[i]); 
//		end
	end
end

initial begin
	#2000000 $finish;
	$display (" counter output : %d ", counter_output);
end

endmodule






