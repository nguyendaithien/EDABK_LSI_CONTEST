module CONV #(
  parameter 
    DATA_WIDTH = 48, 
    WEIGHT_WIDTH = 16, 
    IFM_WIDTH = 16,  
    IFM_SIZE = 64, 
    KERNEL_SIZE = 5,
    STRIDE = 1,
    PAD = 2,
    RELU = 1,
    FIFO_SIZE = (IFM_SIZE-1)*STRIDE-2*PAD+KERNEL_SIZE,
    CI = 3, 
    CO = 8
)(
	input clk1,
	input clk2,
	input rst_n,
  input start_conv,
	input [IFM_WIDTH-1:0] ifm,
	input [WEIGHT_WIDTH-1:0] wgt,
  output ifm_read,
  output wgt_read,
  output out_valid,
  output end_conv,
	output[DATA_WIDTH-1:0] data_output
	);

  localparam ADD_WIDTH = $clog2((IFM_SIZE-1)*STRIDE-2*PAD+KERNEL_SIZE)+1;

	wire [DATA_WIDTH-1:0] row_sum [KERNEL_SIZE-1:0];

  
	// out of each PE
	wire [DATA_WIDTH-1:0] psum_00, psum_01, psum_02, psum_03;   
	wire [DATA_WIDTH-1:0] psum_10, psum_11, psum_12, psum_13;   
	wire [DATA_WIDTH-1:0] psum_20, psum_21, psum_22, psum_23;   
// out of FIFO
	wire [DATA_WIDTH-1:0] out_fifo_0; 
	wire [DATA_WIDTH-1:0] out_fifo_1; 
	wire [DATA_WIDTH-1:0] out_fifo_2; 
	wire [DATA_WIDTH-1:0] out_buffer; 

	assign psum_00 = 0;
	assign psum_10 = 0;
	assign psum_20 = 0;

  wire rd_clr;
  wire wr_clr;
  wire re_buffer;
  wire set_ifm;
  wire set_reg;
  wire [DATA_WIDTH-1:0] psum_buffer;
  wire [KERNEL_SIZE-1:0] wr_en;
  wire [KERNEL_SIZE-1:0] rd_en;
  wire [DATA_WIDTH-1:0] data_output_temp;
	wire [IFM_WIDTH-1:0] ifm_wire;
  wire [KERNEL_SIZE*KERNEL_SIZE-1:0] set_wgt;

	wire [WEIGHT_WIDTH-1:0] wgt_wire [KERNEL_SIZE*KERNEL_SIZE-1:0];
	wire [DATA_WIDTH-1:0] psum [KERNEL_SIZE-1:0][KERNEL_SIZE+1:0];

	reg [DATA_WIDTH-1:0] data_in_fifo_1;
	reg [DATA_WIDTH-1:0] data_in_fifo_2;

	always @(posedge clk2 or negedge rst_n) begin
		if(!rst_n) begin
			data_in_fifo_1 <= 0;
			data_in_fifo_2 <= 0;
		end else begin
			data_in_fifo_1 <= out_fifo_0 + psum_13;
			data_in_fifo_2 <= out_fifo_1 + psum_23;
		end
	end
	
	      PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .IFM_WIDTH(IFM_WIDTH), .POOLING(0)) pe00 (
	      	. clk      ( clk1                              )
	      	,.rst_n    ( rst_n                             )
	      	,.set_reg  ( set_reg                           )
	      	,.ifm      ( ifm_wire                          )
	      	,.wgt      ( wgt_wire[8] )
	      	,.psum_in  ( psum_00                )
	      	,.psum_out ( psum_01              )
	      	 );
	      PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .IFM_WIDTH(IFM_WIDTH), .POOLING(0)) pe01 (
	      	. clk      ( clk1                              )
	      	,.rst_n    ( rst_n                             )
	      	,.set_reg  ( set_reg                           )
	      	,.ifm      ( ifm_wire                          )
	      	,.wgt      ( wgt_wire[7] )
	      	,.psum_in  ( psum_01                )
	      	,.psum_out ( psum_02              )
	      	 );
	      PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .IFM_WIDTH(IFM_WIDTH), .POOLING(0)) pe02 (
	      	. clk      ( clk1                              )
	      	,.rst_n    ( rst_n                             )
	      	,.set_reg  ( set_reg                           )
	      	,.ifm      ( ifm_wire                          )
	      	,.wgt      ( wgt_wire[6] )
	      	,.psum_in  ( psum_02                )
	      	,.psum_out ( psum_03              )
	      	 );
	      PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .IFM_WIDTH(IFM_WIDTH), .POOLING(0)) pe10 (
	      	. clk      ( clk1                              )
	      	,.rst_n    ( rst_n                             )
	      	,.set_reg  ( set_reg                           )
	      	,.ifm      ( ifm_wire                          )
	      	,.wgt      ( wgt_wire[5] )
	      	,.psum_in  ( psum_10                )
	      	,.psum_out ( psum_11              )
	      	 );
	      PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .IFM_WIDTH(IFM_WIDTH), .POOLING(0)) pe11 (
	      	. clk      ( clk1                              )
	      	,.rst_n    ( rst_n                             )
	      	,.set_reg  ( set_reg                           )
	      	,.ifm      ( ifm_wire                          )
	      	,.wgt      ( wgt_wire[4] )
	      	,.psum_in  ( psum_11                )
	      	,.psum_out ( psum_12              )
	      	 );
	      PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .IFM_WIDTH(IFM_WIDTH), .POOLING(0)) pe12 (
	      	. clk      ( clk1                              )
	      	,.rst_n    ( rst_n                             )
	      	,.set_reg  ( set_reg                           )
	      	,.ifm      ( ifm_wire                          )
	      	,.wgt      ( wgt_wire[3] )
	      	,.psum_in  ( psum_12                )
	      	,.psum_out ( psum_13              )
	      	 );
	      PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .IFM_WIDTH(IFM_WIDTH), .POOLING(0)) pe20 (
	      	. clk      ( clk1                              )
	      	,.rst_n    ( rst_n                             )
	      	,.set_reg  ( set_reg                           )
	      	,.ifm      ( ifm_wire                          )
	      	,.wgt      ( wgt_wire[2] )
	      	,.psum_in  ( psum_20                )
	      	,.psum_out ( psum_21              )
	      	 );
	      PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .IFM_WIDTH(IFM_WIDTH), .POOLING(0)) pe21 (
	      	. clk      ( clk1                              )
	      	,.rst_n    ( rst_n                             )
	      	,.set_reg  ( set_reg                           )
	      	,.ifm      ( ifm_wire                          )
	      	,.wgt      ( wgt_wire[1] )
	      	,.psum_in  ( psum_21                )
	      	,.psum_out ( psum_22              )
	      	 );
	      PE #(.PSUM_WIDTH(DATA_WIDTH), .WEIGHT_WIDTH(WEIGHT_WIDTH), .IFM_WIDTH(IFM_WIDTH), .POOLING(0)) pe22 (
	      	. clk      ( clk1                              )
	      	,.rst_n    ( rst_n                             )
	      	,.set_reg  ( set_reg                           )
	      	,.ifm      ( ifm_wire                          )
	      	,.wgt      ( wgt_wire[0] )
	      	,.psum_in  ( psum_22                )
	      	,.psum_out ( psum_23              )
	      	 );

      FIFO_ASYNCH #(.DATA_WIDTH(DATA_WIDTH), .FIFO_SIZE(FIFO_SIZE), .ADD_WIDTH(ADD_WIDTH)) fifo_0(
	    	 .clk1          ( clk1                      )
	    	,.clk2          ( clk2                      )
	    	,.rd_clr        ( rd_clr                    )
	    	,.wr_clr        ( wr_clr                    )
	    	,.rd_inc        ( 1'b1                      )
	    	,.wr_inc        ( 1'b1                      )
	    	,.wr_en         ( wr_en[0]            )
	    	,.rd_en         ( rd_en[0]             )
	    	,.data_in_fifo  ( psum_03      )
	    	,.data_out_fifo ( out_fifo_0 )
	    	);
      FIFO_ASYNCH #(.DATA_WIDTH(DATA_WIDTH), .FIFO_SIZE(FIFO_SIZE), .ADD_WIDTH(ADD_WIDTH)) fifo_1(
	    	 .clk1          ( clk1                      )
	    	,.clk2          ( clk2                      )
	    	,.rd_clr        ( rd_clr                    )
	    	,.wr_clr        ( wr_clr                    )
	    	,.rd_inc        ( 1'b1                      )
	    	,.wr_inc        ( 1'b1                      )
	    	,.wr_en         ( wr_en[1]             )
	    	,.rd_en         ( rd_en[1]            )
	    	,.data_in_fifo  ( data_in_fifo_1     )
	    	,.data_out_fifo ( out_fifo_1 )
	    	);
FIFO_ASYNCH_END #(.DATA_WIDTH(DATA_WIDTH), .FIFO_SIZE(FIFO_SIZE), .ADD_WIDTH(ADD_WIDTH)) fifo_end(
        .clk1           ( clk1                             )
        ,.clk2          ( clk2                             )
        ,.rd_clr        ( rd_clr                           )
        ,.wr_clr        ( wr_clr                           )
        ,.rd_inc        ( 1'b1                             )
        ,.wr_inc        ( 1'b1                             )
        ,.wr_en         ( wr_en[KERNEL_SIZE-1]             )
        ,.rd_en         ( rd_en[KERNEL_SIZE-1]             )
        ,.re_buffer     ( re_buffer                        )
        ,.psum_buffer   ( psum_buffer                      )
        ,.data_in_fifo  ( data_in_fifo_2 )
        ,.data_out_fifo ( data_output_temp                 )
		);

  BUFFER #(.DATA_WIDTH(DATA_WIDTH), .IFM_SIZE(IFM_SIZE), .KERNEL_SIZE(KERNEL_SIZE), .STRIDE(STRIDE), .PAD(PAD)) buffer_psum(
     .clk(clk1)
    ,.rst_n(rst_n)
    ,.d_in(data_output_temp)
    ,.d_out(psum_buffer)
    ,.we((CI == 1) ? 1'b0 : rd_en[KERNEL_SIZE-1])
    ,.re((CI == 1) ? 1'b0 : re_buffer)
  );

  CONTROL #(.KERNEL_SIZE(KERNEL_SIZE), .IFM_SIZE(IFM_SIZE+2*PAD), .PAD(PAD), .STRIDE(STRIDE), .CI(CI), .CO(CO)) control (
    .clk1        ( clk1       )
    ,.clk2       ( clk2       )
    ,.rst_n      ( rst_n      )
    ,.start_conv ( start_conv )
    ,.ifm_read   ( ifm_read   )
    ,.wgt_read   ( wgt_read   )
    ,.rd_clr     ( rd_clr     )
    ,.wr_clr     ( wr_clr     )
    ,.out_valid  ( out_valid  )
    ,.set_ifm    ( set_ifm    )
    ,.set_wgt    ( set_wgt    )
    ,.set_reg    ( set_reg    )
    ,.end_conv   ( end_conv   )
    ,.re_buffer  ( re_buffer  )
    ,.rd_en      ( rd_en      )
    ,.wr_en      ( wr_en      )
  );


	wire [7:0] wgt_0;
	wire [7:0] wgt_1;
	wire [7:0] wgt_2;
	wire [7:0] wgt_3;
	wire [7:0] wgt_4;
	wire [7:0] wgt_5;
	wire [7:0] wgt_6;
	wire [7:0] wgt_7;
	wire [7:0] wgt_8;

	assign wgt_0 = wgt_wire[0]; 
	assign wgt_1 = wgt_wire[1]; 
	assign wgt_2 = wgt_wire[2]; 
	assign wgt_3 = wgt_wire[3]; 
	assign wgt_4 = wgt_wire[4]; 
	assign wgt_5 = wgt_wire[5]; 
	assign wgt_6 = wgt_wire[6]; 
	assign wgt_7 = wgt_wire[7]; 
	assign wgt_8 = wgt_wire[8]; 

  genvar wgt_i;
  generate
    for (wgt_i = 0; wgt_i < KERNEL_SIZE*KERNEL_SIZE; wgt_i = wgt_i + 1)
    begin
	    WEIGHT_BUFF #(.DATA_WIDTH(WEIGHT_WIDTH)) wgt_buf (
         .clk      ( clk1            )
         ,.rst_n   ( rst_n           )
         ,.set_wgt ( set_wgt[wgt_i]  )
         ,.wgt_in  ( wgt             )
         ,.wgt_out ( wgt_wire[wgt_i] )
	    	 );
    end
  endgenerate

  IFM_BUFF #(.DATA_WIDTH(IFM_WIDTH)) ifm_buf (
      .clk      ( clk1     )
      ,.rst_n   ( rst_n    )
      ,.set_ifm ( set_ifm  )
      ,.ifm_in  ( ifm      )
      ,.ifm_out ( ifm_wire )
			);

  assign data_output = (RELU) ? ((data_output_temp[DATA_WIDTH-1]) ? 0 : data_output_temp) : data_output_temp; 

endmodule
