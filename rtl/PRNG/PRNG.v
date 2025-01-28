module PRNG #( parameter DATA_WIDTH = 32, NUMBER_RANDOM = 2) (
	input clk,
	input rst_n,
	input start,
	input re_start,
	output wire out_valid,
	output reg [31:0] data_out,
	output reg end_random,
	output reg [31:0] number_1,
	output reg [31:0] number_2
);

	parameter N = 624          ;
	parameter M = 397          ;
	parameter R = 31           ;
	parameter A = 32'h9908B0DF ;
	parameter U = 11           ;
	parameter D = 32'hFFFFFFFF ;
	parameter S = 7            ;
	parameter B = 32'h9D2C5680 ;
	parameter T = 15           ;
	parameter C = 32'hEFC60000 ;
	parameter L = 18           ;
	parameter F = 1812433253   ;
	parameter SEED = 32'h87878787; 
	parameter W = 32; 

	parameter [2:0] IDLE          = 3'b000;
	parameter [2:0] INIT          = 3'b001;
	parameter [2:0] TRANFORMATION = 3'b010;
	parameter [2:0] TEMPERING     = 3'b011;
	parameter [2:0] END_RANDOM    = 3'b100;

	reg [2:0] current_state, next_state;
	reg [10:0] counter_init;
	reg [10:0] counter_tran;
	reg [10:0] counter_temp;
	wire [W-1:0] upper_mask;
	wire [W-1:0] lower_mask;
	reg [31:0] y;
	reg [31:0] x;
	reg [31:0] x1;
	reg [31:0] out_tranformation;

	//reg [5:0] i;

	reg [31:0] y1,y2,y3,y4,y5,y6,y7,y8,y9,y10;
	assign lower_mask = (1 << R) - 1;
	assign upper_mask = ~lower_mask & {W{1'b1}};
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			current_state <= IDLE;
	  end else begin
			current_state <= next_state;
		end
	end

	always @(*) begin
		case(current_state)
			IDLE: begin
				if(start) begin 
					next_state = INIT;
				end else begin
					next_state = IDLE;
				end
			end
			INIT: begin 
				if(counter_init == N) begin 
					next_state = TRANFORMATION;
				end else begin
					next_state = INIT;
				end
			end
			TRANFORMATION: begin
				if (counter_tran == N) begin
					next_state = TEMPERING;
				end else begin
					next_state = TRANFORMATION;
				end
			end
			TEMPERING: begin
				if(counter_temp == 32) begin
					next_state = END_RANDOM;
				end else begin
					next_state = TEMPERING;
				end
			end
			END_RANDOM: begin
				if(re_start) begin 
					next_state = TRANFORMATION;
				end else begin
					next_state = END_RANDOM;
				end
			end
			default: next_state = IDLE;
			endcase
	end
	reg [31:0] state_vector [623:0] ;
	wire [31:0] temp;
	assign temp = state_vector[counter_init] ^ (state_vector[counter_init] >> (W-2));
  integer i;
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			counter_init <= 0;
			counter_tran <= 0;
			counter_temp <= 0;
			out_tranformation <= 0;
			y   <= 0;
			y1  <= 0;
			y2  <= 0;
			y3  <= 0;
			y4  <= 0;
			y5  <= 0;
			y6  <= 0;
			y7  <= 0;
			y8  <= 0;
			y9  <= 0;
			y10 <= 0;
			x1  <= 0;
			x   <= 0;
			for (i = 0; i < N; i = i + 1) begin
				state_vector[i] <= 0;
			end
		end else begin
			case(next_state)
				IDLE: begin 
					state_vector[0] <= SEED;
				end 
				INIT: begin
					counter_init <= counter_init + 1;
					state_vector[counter_init+1] <= (F * (state_vector[counter_init] ^ (state_vector[counter_init] >> (W-2))) + counter_init) & 32'hFFFFFFFF;
				end
				TRANFORMATION: begin 
					counter_tran <= counter_tran + 1; 
					y <= (state_vector[counter_tran] & upper_mask) + (state_vector[(counter_tran + 1 ) % N] & lower_mask);
					x <= y >> 1;
					if(x[0] == 1) begin
						x1 <= x ^ A;
						state_vector[counter_tran] <= state_vector[((counter_tran + M) % N)] ^ x1;					
					  out_tranformation	 <= state_vector[((counter_tran + M) % N)] ^ x1;					
					end else begin
						state_vector[counter_tran] <= state_vector[((counter_tran + M) % N)] ^ x;					
					  out_tranformation	 <= state_vector[((counter_tran + M) % N)] ^ x;					
						//counter_tran <= 0;
					end
				end
				TEMPERING: begin
					counter_temp <= counter_temp + 1; 
					y1  <= (out_tranformation >> U) ;
					y2  <= out_tranformation ^ y1   ;
					y3  <=  y2 << S                 ;
					y4  <=  y3 & C                  ;
					y5  <=  y4 ^ y2                 ;
					y6  <=  y5 << 15                ;
					y7  <=  y6 & C                  ;
					y8  <=  y7 ^ y5                 ;
					y9  <=  y8 >> L                 ;
					y10 <=  y9 ^ y8                 ;
				end
				END_RANDOM: begin 
					counter_tran <= 0;
					counter_temp <= 0;
				end
			endcase
		end
	end
	wire test;
	assign test = ((counter_temp == 6) | (counter_temp == 7));

	assign out_valid = (counter_temp == 5) ? 1 : 0;

endmodule


	






