`timescale 1 ns/10 ps
module tb;
parameter DATA_WIDTH = 16;
parameter IFM_WIDTH = 16;
parameter WGT_WIDTH = 16;
parameter IFM_SIZE  = 100;
parameter IFM_LEN   = 10000;
parameter WGT_LEN   = 20000;
parameter TILING_SIZE = 8;
parameter KERNEL_SIZE = 8000;

parameter DATA_WIDTH_1   = 16;
parameter IFM_WIDTH_1   = 16;
parameter WGT_WIDTH_1   = 16;
parameter IFM_SIZE_1    = 30;
parameter IFM_LEN_1     = 30;
parameter WGT_LEN_1     = 100;
parameter TILING_SIZE_1 = 8;
parameter KERNEL_SIZE_1 = 80;



reg clk1, clk2;
reg rst_n;
reg input_valid;

wire ifm_read;
wire wgt_read;
wire ifm_read_1;
wire wgt_read_1;

reg [IFM_WIDTH-1:0] ifm_r;
wire [64-1:0] wgt;
wire [64-1:0] wgt_1;
wire [IFM_WIDTH-1:0] ifm;
reg  [8*WGT_WIDTH-1:0] wgt_r;
reg  [8*WGT_WIDTH-1:0] wgt_r_1;
wire [DATA_WIDTH-1:0] ofm;    
wire [DATA_WIDTH-1:0] ofm_final;    
wire valid_data;
wire valid_data_final;
wire [15:0] data_fifo_0;
assign data_fifo_0 = fully_1.ifm_buffer.fifo_data[0];
wire [15:0] data_fifo_8;
assign data_fifo_8 = fully_1.ifm_buffer.fifo_data[8];

	initial begin
		$dumpfile("CONV_ACC.vcd");
		$dumpvars(0,tb);
	end

TOP #(.DATA_WIDTH(DATA_WIDTH), .IFM_WIDTH(IFM_WIDTH), .WGT_WIDTH(WGT_WIDTH), .IFM_SIZE(IFM_SIZE), .TILING_SIZE(TILING_SIZE), .KERNEL_SIZE(KERNEL_SIZE)) fully_0 (
		 .clk1(clk1)        
    ,.clk2(clk2)
    ,.rst_n(rst_n)   
    ,.ifm(ifm)
    ,.valid_ifm(input_valid)
    ,.wgt(wgt)
    ,.ofm(ofm)  
	  ,.ifm_read(ifm_read)
	  ,.wgt_read(wgt_read)
		,.valid_data(valid_data)
	);

TOP #(.DATA_WIDTH(DATA_WIDTH_1), .IFM_WIDTH(IFM_WIDTH_1), .WGT_WIDTH(WGT_WIDTH_1), .IFM_SIZE(IFM_SIZE_1), .TILING_SIZE(TILING_SIZE_1), .KERNEL_SIZE(KERNEL_SIZE_1)) fully_1 ( 
		 .clk1(clk1)        
    ,.clk2(clk2)
    ,.rst_n(rst_n)   
    ,.ifm(ofm)
    ,.valid_ifm(valid_data)
    ,.wgt(wgt_1)
    ,.ofm(ofm_final)  
	  ,.ifm_read(ifm_read_1)
	  ,.wgt_read(wgt_read_1)
		,.valid_data(valid_data_final)
		);

initial begin
	$dumpfile ("XCELIUM.vcd");
	$dumpvars(0,tb);
end
integer file;
integer file_1;

reg [DATA_WIDTH-1:0] ofm_buffer [0:7];
reg [DATA_WIDTH-1:0] ofm_buffer_1 [0:7];
integer ofm_index = 0;
integer ofm_index_1 = 0;
	reg [15:0] ifm_in [0:IFM_LEN-1];
	reg [7:0] wgt_in [0:WGT_LEN-1];
	reg [7:0] wgt_in_1 [0:WGT_LEN-1];
	reg [31:0] wgt_cnt;
	reg [31:0] wgt_cnt_1;
	reg [31:0] ifm_cnt;
always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
        ofm_index <= 0;
    end else begin
        if (valid_data) begin
            ofm_buffer[ofm_index] <= ofm;
            ofm_index <= ofm_index + 1;
            if (ofm_index == 7) begin
                // Open the file if not already opened
                if (file == 0) begin
                    file = $fopen("output.txt", "w");
                    if (file == 0) begin
                        $display("Error: Could not open file for writing");
                        $finish;
                    end
                end

                // Write data to the file
                $fwrite(file, "%d %d %d %d %d %d %d %d\n",
                        ofm_buffer[0], ofm_buffer[1], ofm_buffer[2], ofm_buffer[3],
                        ofm_buffer[4], ofm_buffer[5], ofm_buffer[6], ofm_buffer[7]);

                ofm_index <= 0;
            end
        end
    end
end
always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
        ofm_index_1 <= 0;
    end else begin
        if (valid_data_final) begin
            ofm_buffer_1[ofm_index_1] <= ofm_final;
            ofm_index_1 <= ofm_index_1 + 1;
            if (ofm_index_1 == 7) begin
                // Open the file if not already opened
                if (file_1 == 0) begin
                    file_1 = $fopen("output_1.txt", "w");
                    if (file_1 == 0) begin
                        $display("Error: Could not open file for writing");
                        $finish;
                    end
                end

                // Write data to the file
                $fwrite(file_1, "%d %d %d %d %d %d %d %d\n",
                        ofm_buffer_1[0], ofm_buffer_1[1], ofm_buffer_1[2], ofm_buffer_1[3],
                        ofm_buffer_1[4], ofm_buffer_1[5], ofm_buffer_1[6], ofm_buffer_1[7]);

                ofm_index_1 <= 0;
            end
        end
    end
end

initial begin
    file_1 = 0; // Initialize file descriptor
end

// Close the file at the end of simulation
initial begin
    file = 0; // Initialize file descriptor
end

// Ensure the file is closed at the end of the simulation
initial begin
    if (file != 0) begin
        $fclose(file);
    end
end


  initial begin
      $readmemb("../script/weight.txt", wgt_in);
  end 
  initial begin
      $readmemb("../script/weight_2.txt", wgt_in_1);
  end 
  initial begin
      $readmemb("../script/ifm.txt", ifm_in);
  end 
  always @(*) begin
      if (!rst_n) begin
          wgt_r = 0;
      end else if (wgt_read) begin
          wgt_r[7:0]   = wgt_in[wgt_cnt+0];
          wgt_r[15:8]  = wgt_in[wgt_cnt+1];
          wgt_r[23:16] = wgt_in[wgt_cnt+2];
          wgt_r[31:24] = wgt_in[wgt_cnt+3];
          wgt_r[39:32] = wgt_in[wgt_cnt+4];
          wgt_r[47:40] = wgt_in[wgt_cnt+5];
          wgt_r[55:48] = wgt_in[wgt_cnt+6];
          wgt_r[63:56] = wgt_in[wgt_cnt+7];
      end else
          wgt_r = 0;
  end 
    always @(posedge clk1 or negedge rst_n) begin
        if (!rst_n)
            wgt_cnt <= 0;
        else if (wgt_cnt == WGT_LEN && !wgt_read)
            wgt_cnt <= 0;
        else if (wgt_read)
           // ifm_cnt <= ifm_cnt + 8;
            wgt_cnt <= wgt_cnt + 8;

        else
            wgt_cnt <= wgt_cnt;
    end
    assign wgt = wgt_r;

  always @(*) begin
      if (!rst_n) begin
          wgt_r_1 = 0;
      end else if (wgt_read_1) begin
          wgt_r_1[7:0]   = wgt_in_1[wgt_cnt_1+0];
          wgt_r_1[15:8]  = wgt_in_1[wgt_cnt_1+1];
          wgt_r_1[23:16] = wgt_in_1[wgt_cnt_1+2];
          wgt_r_1[31:24] = wgt_in_1[wgt_cnt_1+3];
          wgt_r_1[39:32] = wgt_in_1[wgt_cnt_1+4];
          wgt_r_1[47:40] = wgt_in_1[wgt_cnt_1+5];
          wgt_r_1[55:48] = wgt_in_1[wgt_cnt_1+6];
          wgt_r_1[63:56] = wgt_in_1[wgt_cnt_1+7];
      end else
          wgt_r_1 = 0;
  end 
    always @(posedge clk1 or negedge rst_n) begin
        if (!rst_n)
            wgt_cnt_1 <= 0;
        else if (wgt_cnt_1 == WGT_LEN && !wgt_read_1)
            wgt_cnt_1 <= 0;
        else if (wgt_read_1)
           // ifm_cnt <= ifm_cnt + 8;
            wgt_cnt_1 <= wgt_cnt_1 + 8;

        else
            wgt_cnt_1 <= wgt_cnt_1;
    end
    assign wgt_1 = wgt_r_1;



    always @(*) begin
        if (!rst_n) begin
            ifm_r = 0;
        end else if (input_valid) begin
            ifm_r   = ifm_in[ifm_cnt];
        end else
            ifm_r = 0;
    end 
		assign ifm = ifm_r;
    always @(posedge clk1 or negedge rst_n) begin
			if(!rst_n)
				ifm_cnt <= 0;
      else if (ifm_cnt == IFM_LEN && !ifm_read)
				ifm_cnt <= 0;
			else if (input_valid)
				ifm_cnt <= ifm_cnt + 1;
			else 
				ifm_cnt <= ifm_cnt;
		end

		always #5 clk1 = !clk1; 
		always #5 clk2 = !clk1; 

		initial begin
			rst_n = 0;
			clk1 = 0;
			clk2 = 0;
			input_valid = 0;

#10   rst_n = 1;
#5
			input_valid = 1;

#510   
			input_valid = 0;
#100   
			input_valid = 1;
#3000   
			input_valid = 0;
#10   
			input_valid = 1;
#10000   
			input_valid = 1;


		end
initial #100000 $finish;

			














endmodule
