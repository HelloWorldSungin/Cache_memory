module cache_controller (
	input 			clk,			//Same clk from the processor
	input			reset,			//Active low sychronous reset
	input			ready_mem,		//Active high signal from the main memory
	
	input 	[31:0]		data_up,		//data input from the processor
	input 	[31:0]		data_mem,		//data input from the main memeory

	input	[31:0]		addr_up,		//input address from the processor
	output reg[31:0] 		addr_mem,	//output address to the memory
	
	input			read_up,		//Active high read from the processor
	input 			write_up,		//Active high write from the processor

	output reg			read_mem,	//Active high read to the main memroy
	output reg			write_mem,	//Active high write to the main memro
	output reg			stall_up	//Active high stall to the processorc
);
/*
// Parameters
*/
parameter CACHE_LINES		= 2000;
parameter BLOCK_SIZE_WORDS	= 4;
parameter BLOCK_OFFSET_BIT	= $clog2(BLOCK_SIZE_WORDS);
parameter BLOCK_SIZE_BYTE 	= 4 * BLOCK_SIZE_WORDS;		//16
parameter BLOCK_SIZE_BIT	= 8 * BLOCK_SIZE_BYTE;		//128
parameter WORD_SIZE_BIT		= 32;
parameter NUMBER_OF_SETS	= 1000;				//CACHE_LINES / 2
parameter VALID_BIT			= 1;
parameter DIRTY_BIT			= 1;
parameter USED_BIT			= 1;
parameter TAG_BIT			= 20;				//tag bit without dirty, used, valid bits
parameter LAST_TAG_BIT_INDEX= 19;	
parameter DIRTY_BIT_INDEX	= TAG_BIT; 		//20
parameter USED_BIT_INDEX	= TAG_BIT + 1;		//21
parameter VALID_BIT_INDEX	= TAG_BIT + 2;		//22
parameter INDEX_BIT			= 32 - TAG_BIT - BLOCK_OFFSET_BIT;	//32-tagbits(20) - block_offset(2) = 10 bits
parameter TOTAL_TAG_SIZE_BIT	= VALID_BIT+USED_BIT+DIRTY_BIT+TAG_BIT; //23

/*
// States for FSM
*/
localparam 	IDLE 		= 3'd0;
localparam	READ		= 3'd1;
localparam	WRITE		= 3'd2;
localparam	READ_MEM	= 3'd3;
localparam	WAIT_FOR_MEM	= 3'd4;
localparam	UPDATE_MEM	= 3'd5;
localparam	UPDATE_CACHE	= 3'd6;

/*
// Internal Wires and Registers 
*/
reg	[BLOCK_SIZE_WORDS-1:0]	word_counter;	//counts word transfer between cache and memory in read & write	
reg				update_flag;		//update MEM state

wire [LAST_TAG_BIT_INDEX:0]		tag;
wire [INDEX_BIT-1:0]			index; 		
wire [BLOCK_OFFSET_BIT-1:0]		block_offset;
reg	[WORD_SIZE_BIT-1:0]			read_data_word;
reg	[WORD_SIZE_BIT-1:0]			write_data_word;
reg	[WORD_SIZE_BIT-1:0]			write_mem_word;
reg	[BLOCK_SIZE_BIT-1:0]		read_mem_block;
reg	[BLOCK_SIZE_BIT-1:0]		write_mem_block;

reg	read_not_write;		// when reading = 1, writing = 0
reg	write_enable_DB0;	// Active high for DB0
reg	write_enable_DB1;	// Active high for DB1
reg	write_enable_Tag0;	// Active high for Tag0
reg	write_enable_Tag1;	// Active high for Tag1

/*
// Internal Wires and Registers from data and address
*/
wire hit_way_0;
wire hit_way_1;

wire valid_way_0;
wire valid_way_1;

wire used_way_0;		
wire used_way_1;

wire dirty_way_0;
wire dirty_way_1;

wire hit_equal_way_0;
wire hit_equal_way_1;

wire hit;
wire valid;
wire dirty;

wire [(TOTAL_TAG_SIZE_BIT-1):0]	tag_read_0;	//23bits
wire [(TOTAL_TAG_SIZE_BIT-1):0]	tag_read_1;

reg  [(TOTAL_TAG_SIZE_BIT-1):0]	tag_write_0;
reg  [(TOTAL_TAG_SIZE_BIT-1):0]	tag_write_1;
reg  [(TOTAL_TAG_SIZE_BIT-1):0]	tag_str_0;
reg  [(TOTAL_TAG_SIZE_BIT-1):0]	tag_str_1;

wire [(32*BLOCK_SIZE_WORDS)-1:0]			db_read_0;
wire [(32*BLOCK_SIZE_WORDS)-1:0]			db_read_1;
wire [(32*BLOCK_SIZE_WORDS)-1:0]			db_tb_out_0;
wire [(32*BLOCK_SIZE_WORDS)-1:0]			db_tb_out_1;
wire [(32*BLOCK_SIZE_WORDS)-1:0]			db_mux_in;


reg  [(32*BLOCK_SIZE_WORDS)-1:0]			db_read;
reg  [(32*BLOCK_SIZE_WORDS)-1:0]			db_write;
reg  [(32*BLOCK_SIZE_WORDS)-1:0]			db_str_0;
reg  [(32*BLOCK_SIZE_WORDS)-1:0]			db_str_1;


reg  [(32*BLOCK_SIZE_WORDS)-1:0]			db_mux_out;
wire [WORD_SIZE_BIT-1:0]				word_mux_out;
reg  [32-1:0]							addr_latch;

/*
// States
*/
reg  [2:0] state, next_state; 

/*
// Combination Logics
*/

//assigning input address
assign tag 		= (state == IDLE) ? addr_up[31:12] : addr_latch[31:12];
assign index		= (state == IDLE) ? addr_up[11:2] : addr_latch[11:2];
assign block_offset	= (state == IDLE) ? addr_up[1:0] : addr_latch[1:0];

//assigning tag vars
assign valid_way_0	= tag_read_0[VALID_BIT_INDEX];
assign valid_way_1	= tag_read_1[VALID_BIT_INDEX];

assign used_way_0 	= tag_read_0[USED_BIT_INDEX];
assign used_way_1 	= tag_read_1[USED_BIT_INDEX];

assign dirty_way_0 	= tag_read_0[DIRTY_BIT_INDEX];
assign dirty_way_1	= tag_read_1[DIRTY_BIT_INDEX];

assign valid 		= valid_way_0 & valid_way_1;
assign dirty		= dirty_way_0 | dirty_way_1;

//eq
equals #(TAG_BIT) eq_way_0(tag_read_0[LAST_TAG_BIT_INDEX:0], tag, hit_equal_way_0);
equals #(TAG_BIT) eq_way_1(tag_read_1[LAST_TAG_BIT_INDEX:0], tag, hit_equal_way_1);

assign hit_way_0	= valid_way_0 & hit_equal_way_0;
assign hit_way_1	= valid_way_1 & hit_equal_way_1;
assign hit		= hit_way_0 | hit_way_1;

//tri_buffer
tri_buf #(BLOCK_SIZE_BIT) tri_buffer_way_0(	.a(db_read_0),
						.enable(hit_way_0), 
						.b(db_tb_out_0)
						);
tri_buf #(BLOCK_SIZE_BIT) tri_buffer_way_1(	.a(db_read_1),
						.enable(hit_way_1), 
						.b(db_tb_out_1)
						);  


assign db_mux_in	= (hit_way_0) ? db_tb_out_0 : db_tb_out_1;
//block_offset_mux
mux4 #(WORD_SIZE_BIT) block_offset_mux(	.s(block_offset), 
					.d0(db_mux_in[WORD_SIZE_BIT-1:0]), 
					.d1(db_mux_in[2*WORD_SIZE_BIT-1:WORD_SIZE_BIT]), 
					.d2(db_mux_in[3*WORD_SIZE_BIT-1:WORD_SIZE_BIT*2]), 
					.d3(db_mux_in[4*WORD_SIZE_BIT-1:WORD_SIZE_BIT*3]), 
					.y(word_mux_out)
					);
/*
// State Machine
*/

always @(posedge clk, negedge reset) begin
	if(reset) 
	begin
		//reset outputs
		addr_mem  		<= {32'd0};
		read_mem		<= 1'd0;
		write_mem		<= 1'd0;
		stall_up		<= 1'd0;

		//reset internal control signals
		word_counter		<= {BLOCK_SIZE_WORDS{1'd0}};
		update_flag		<= 1'd0;
		read_data_word 		<= {WORD_SIZE_BIT{1'd0}};
		write_data_word 	<= {WORD_SIZE_BIT{1'd0}};
		write_mem_word 		<= {WORD_SIZE_BIT{1'd0}};
		read_mem_block 		<= {BLOCK_SIZE_BIT{1'd0}};
		write_mem_block 	<= {BLOCK_SIZE_BIT{1'd0}};
		write_enable_DB0	<= 1'd0;
		write_enable_DB1	<= 1'd0;
		write_enable_Tag0	<= 1'd0;
		write_enable_Tag1	<= 1'd0;
		read_not_write		<= 1'd1;

		//reset internal data and address buses signals
		addr_latch		<= {32'd0};
		db_write		<= {(32*BLOCK_SIZE_WORDS){1'd0}};
		db_read			<= {(32*BLOCK_SIZE_WORDS){1'd0}};
		db_str_0		<= {(32*BLOCK_SIZE_WORDS){1'd0}};
		db_str_1		<= {(32*BLOCK_SIZE_WORDS){1'd0}};
		tag_write_0		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
		tag_write_1 		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
		tag_str_0		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
		tag_str_1		<= {TOTAL_TAG_SIZE_BIT{1'd0}};

		//reset State
		state			<= IDLE;
	end
	else 
	begin
		//update state
		state <= next_state;
	end
end

always@(state, read_up, write_up, hit, ready_mem, valid, dirty, hit_way_0, 
		used_way_0, used_way_1, block_offset, update_flag, read_not_write)
begin
	//need to set come vars to 0, will come to this after making the first state

	case(state)

		IDLE:			begin
						//set outputs 
						stall_up			<= 1'd0;
						read_mem 			<= 1'd0;
						write_mem 			<= 1'd0;
					
						//set internal control signals
						word_counter		<= {BLOCK_SIZE_WORDS{1'd0}};
						update_flag 		<= 1'd0;
						write_mem_word		<= {WORD_SIZE_BIT{1'd0}};
						write_mem_block 	<= {BLOCK_SIZE_BIT{1'd0}};
						write_enable_DB0 	<= 1'd0;
						write_enable_DB1 	<= 1'd0;
						write_enable_Tag0	<= 1'd0;
						write_enable_Tag1 	<= 1'd0;
						tag_write_0		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
						tag_write_1 		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
	
						//set internal data and address buses signals 
						addr_latch 			<= addr_up;
						db_write 			<= {(32*BLOCK_SIZE_WORDS){1'd0}};
					
						if(read_up)
						begin
							next_state 		<= READ;
							read_not_write 	<= 1'd1;
						end	
						else if(write_up) begin
							next_state		<= WRITE;
							write_data_word	<= data_up;
							read_not_write 	<= 1'd0;
						end 
						else begin
							next_state		<= state;
						end
					end
		READ:			begin
						write_enable_DB0 <= 0;
						write_enable_DB0 <= 0;
	
						case(hit) 
							1'd0: 	begin
									//updating values up the memory
									tag_str_0	<= tag_read_0;	
									tag_str_1	<= tag_read_1;
									db_str_0	<= db_read_0;
									db_str_1	<= db_read_1;
									stall_up	<= 1'd1;
									if(ready_mem)
										if(valid & dirty)
											next_state 	<= UPDATE_MEM;
										else 
											next_state 	<= READ_MEM;
									else 
										next_state <= state;
	
							   	end
							1'd1:	begin
									next_state 		<= IDLE;
									write_enable_Tag0	<= 1'd1;
									write_enable_Tag1	<= 1'd1;
									stall_up			<= 1'd0;
									read_data_word 		<= word_mux_out;
										if (hit_way_0) begin
											if (used_way_0)	
												tag_write_0	<= tag_read_0;
											else 
												tag_write_0 <= {tag_read_0[VALID_BIT-1], 1'd1, tag_read_0[DIRTY_BIT_INDEX:0]};
											if (used_way_1) 
												tag_write_1	<= tag_read_1;
											else 
												tag_write_1 <= {tag_read_1[VALID_BIT-1], 1'd1, tag_read_1[DIRTY_BIT_INDEX:0]};
										end
										else begin
											if (used_way_1) 
												tag_write_1	<= tag_read_1;
											else 
												tag_write_1 <= {tag_read_1[VALID_BIT-1], 1'd1, tag_read_1[DIRTY_BIT_INDEX:0]};
											if (used_way_1) 
												tag_write_0	<= tag_read_0;
											else 
												tag_write_0 <= {tag_read_0[VALID_BIT-1], 1'd1, tag_read_0[DIRTY_BIT_INDEX:0]};
										end
								end
						endcase
					end
		WRITE:			begin
						case(hit)
							0'd0:	begin
									tag_str_0	<= tag_read_0;
									tag_str_1	<= tag_read_1;
									db_str_0	<= db_read_0;
									db_str_1	<= db_read_1;
									stall_up	<= 1'd1;
									if(ready_mem)
										if(valid & dirty)
											next_state	<= UPDATE_MEM;
										else
											next_state	<= READ_MEM;
									else
										next_state	<= state;
									end
							1'd1:	begin
									next_state 	<= IDLE;
									write_enable_Tag0 <= 1'd1;
									write_enable_Tag1 <= 1'd1;
									stall_up 		  <= 1'd0;
										if(hit_way_0) begin
											write_enable_DB0	<= 1'd1;
											case(block_offset)
												2'd0: db_write <= {db_read_0[BLOCK_SIZE_BIT-1:WORD_SIZE_BIT*1], write_data_word};
												2'd1: db_write <= {db_read_0[BLOCK_SIZE_BIT-1:WORD_SIZE_BIT*2], write_data_word ,db_read_0[WORD_SIZE_BIT-1:0]};
												2'd2: db_write <= {db_read_0[BLOCK_SIZE_BIT-1:WORD_SIZE_BIT*3], write_data_word ,db_read_0[WORD_SIZE_BIT*2-1:0]};
												2'd3: db_write <= {write_data_word ,db_read_0[WORD_SIZE_BIT*3-1:0]};
											endcase
	
											if(used_way_0)
												tag_write_0	<= {tag_read_0[VALID_BIT_INDEX:USED_BIT_INDEX], 1'd1, tag_read_0[LAST_TAG_BIT_INDEX:0]};
											else
												tag_write_0	<= {tag_read_0[VALID_BIT_INDEX], 1'd1, 1'd1, tag_read_0[LAST_TAG_BIT_INDEX:0]};
											if(used_way_1)
												tag_write_1	<= tag_read_1;
											else
												tag_write_1	<= {tag_read_1[VALID_BIT_INDEX], 1'd1, tag_read_1[DIRTY_BIT_INDEX:0]};
										end
										else begin
											write_enable_DB1 <= 1;
											case(block_offset)
												2'd0: db_write <= {db_read_1[BLOCK_SIZE_BIT-1:WORD_SIZE_BIT*1], write_data_word};
												2'd1: db_write <= {db_read_1[BLOCK_SIZE_BIT-1:WORD_SIZE_BIT*2], write_data_word ,db_read_1[WORD_SIZE_BIT-1:0]};
												2'd2: db_write <= {db_read_1[BLOCK_SIZE_BIT-1:WORD_SIZE_BIT*3], write_data_word ,db_read_1[WORD_SIZE_BIT*2-1:0]};
												2'd3: db_write <= {write_data_word ,db_read_1[WORD_SIZE_BIT*3-1:0]};
											endcase

											if(used_way_1)
												tag_write_1	<= {tag_read_1[VALID_BIT_INDEX], 1'd0, 1'd1, tag_read_1[LAST_TAG_BIT_INDEX:0]};
											else
												tag_write_1	<= {tag_read_1[VALID_BIT_INDEX:USED_BIT_INDEX], 1'd1, tag_read_1[LAST_TAG_BIT_INDEX:0]};
											if(used_way_0)
												tag_write_0	<= {tag_read_0[VALID_BIT_INDEX], 1'd0, tag_read_1[DIRTY_BIT_INDEX:0]};
											else
												tag_write_0	<= tag_read_0;
										end


									end
						endcase
						end
		READ_MEM:		begin
						addr_mem 	<= {addr_latch[32-1:2],2'd0};
						update_flag	<= 1'd0;
							if(ready_mem)
							begin
								read_mem 	<= 1'd1;
								next_state	<= WAIT_FOR_MEM;
							end
							else
							begin
								read_mem 	<= 1'd0;
								next_state	<= state;
							end 
						end
//Not sure at the write_mem_word and write_mem_block concatenation
		WAIT_FOR_MEM:	begin
							if(ready_mem)
							begin
								if(update_flag)
									next_state <= READ_MEM;
								else
									next_state <= UPDATE_CACHE;
								read_mem 	<= 1'd0;
								write_mem 	<= 1'd0;
							end
							else
							begin 
								if(!read_not_write)
								begin
									write_mem_word 	<= write_mem_block[WORD_SIZE_BIT-1:0];
									write_mem_block	<= {{WORD_SIZE_BIT{1'd0}}, write_mem_block[WORD_SIZE_BIT*4-1:WORD_SIZE_BIT]};
								end
								next_state <= state;
							end
						end

		UPDATE_MEM:		begin
							update_flag	<= 1'd1;
							if(used_way_0)
							begin
								addr_mem		<= {tag_str_1[LAST_TAG_BIT_INDEX:0], addr_latch[11:2],2'd0};
								write_mem_block	<= db_str_1;
							end
							else
							begin
								addr_mem		<= {tag_str_0[LAST_TAG_BIT_INDEX:0], addr_latch[11:2],2'd0};
								write_mem_block	<= db_str_0;
							end

							if(ready_mem)
							begin
								write_mem 	<= 1'd1;
								next_state	<= WAIT_FOR_MEM;
							end
							else
							begin
								write_mem 	<= 1'd0;
								next_state	<= state;
							end 
						end

		UPDATE_CACHE:	begin
							update_flag <= 1'd0;
						if(word_counter!=4'b1111)
						begin
							read_mem_block 	<= {data_mem, read_mem_block[WORD_SIZE_BIT*4-1:WORD_SIZE_BIT]};
							word_counter <= {1'd1, word_counter[3:1]};
						end
						else 
						begin
							db_write	<= read_mem_block;
							next_state	<= IDLE;
							if (used_way_0) begin
								tag_write_0 	<= {tag_str_0[VALID_BIT_INDEX], 1'd0, tag_str_0[DIRTY_BIT_INDEX:0]};
								tag_write_1 	<= {1'd1, 1'd0, 1'd0, addr_latch[32-1:12]};
								write_enable_DB0	<= 0;
								write_enable_DB1	<= 1;
								write_enable_Tag0	<= 0;
								write_enable_Tag1	<= 0;
							end
							else begin
								tag_write_0 	<= {1'd1, 1'd1, 1'd0, addr_latch[32-1:12]};
								tag_write_1 	<= {tag_str_1[VALID_BIT_INDEX], 1'd1, tag_str_1[DIRTY_BIT_INDEX:0]};
								write_enable_DB0	<= 1;
								write_enable_DB1	<= 0;
								write_enable_Tag0	<= 1;
								write_enable_Tag1	<= 1;
							end
						end
						end
		default:		begin
							//reset outputs
							addr_mem  		<= {32'd0};		
							read_mem		<= 1'd0;		
							write_mem		<= 1'd0;
							stall_up		<= 1'd0;

							//reset internal control signals
							read_data_word 		<= {WORD_SIZE_BIT{1'd0}};
							write_data_word 	<= {WORD_SIZE_BIT{1'd0}};
							write_mem_word 		<= {WORD_SIZE_BIT{1'd0}};
							read_mem_block 		<= {BLOCK_SIZE_BIT{1'd0}};
							write_mem_block 	<= {BLOCK_SIZE_BIT{1'd0}};
							write_enable_DB0	<= 1'd0;
							write_enable_DB1	<= 1'd0;
							write_enable_Tag0	<= 1'd0;
							write_enable_Tag1	<= 1'd0;
							read_not_write		<= 1'd1;	

							//reset internal data and address buses signals
							addr_latch		<= 32'd0;	
							db_write		<= {(32*BLOCK_SIZE_WORDS){1'd0}};
							db_read			<= {(32*BLOCK_SIZE_WORDS){1'd0}};
							db_str_0		<= {(32*BLOCK_SIZE_WORDS){1'd0}};
							db_str_1		<= {(32*BLOCK_SIZE_WORDS){1'd0}};
							tag_write_0		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
							tag_write_1 	<= {TOTAL_TAG_SIZE_BIT{1'd0}};
							tag_str_0		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
							tag_str_1		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
							next_state		<= IDLE;
						end
	endcase
end

// TAG RAM For Way_0
tag0_RAM #(INDEX_BIT,TAG_BIT, NUMBER_OF_SETS) tag_0_ram(
					.clk(clk),
	 				.addr(index),
					.data_in(tag_write_0[19:0]),	
					.write_enable(write_enable_Tag0),
					.data_out(tag_read_0[19:0])
					);

// TAG RAM For Way_1
tag1_RAM #(INDEX_BIT,TAG_BIT, NUMBER_OF_SETS) tag_1_ram(
					.clk(clk),
	 				.addr(index),
					.data_in(tag_write_1[19:0]),	
					.write_enable(write_enable_Tag1),
					.data_out(tag_read_1[19:0])
					);


data_block0_RAM #(INDEX_BIT ,BLOCK_SIZE_WORDS, TAG_BIT) data_block0_ram(
					.clk(clk),
					.addr(index),
					.data_in(db_write),	
					.write_enable(write_enable_DB0),
					.data_out(db_read_0)
					);

data_block1_RAM #(INDEX_BIT ,BLOCK_SIZE_WORDS, TAG_BIT) data_block1_ram(
					.clk(clk),
					.addr(index),
					.data_in(db_write),	
					.write_enable(write_enable_DB1),
					.data_out(db_read_1)
					);

endmodule
