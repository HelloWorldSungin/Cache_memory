module cache_controller (
	input 			clk,			//Same clk from the processor
	input			reset,			//Active low Asychronous reset
	input			ready_mem,		//Active high signal from the main memory
	
	input 	[31:0]		data_up,		//data input from the processor
	input 	[31:0]		data_mem,		//data input from the main memeory

	input	[31:0]		addr_up,		//input address from the processor
	output reg[31:0] 		addr_mem,	//output address to the memory
	
	input			read_up,		//Active high read from the processor
	input 			write_up,		//Active high write from the processor

	output reg			read_mem,	//Active high read to the main memroy
	output reg			write_mem,	//Active high write to the main memro
	output reg			stall_up	//Active high stall to the peocessorc
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
parameter VALID_BIT		= 1;
parameter DIRTY_BIT		= 1;
parameter USED_BIT		= 1;
parameter TAG_BIT		= 20;				//tag bit without dirty, used, valid bits
parameter DIRTY_BIT_INDEX	= (TAG_BIT -1) + 1; 		//21
parameter USED_BIT_INDEX	= (TAG_BIT -1) + 2;		//22
parameter VALID_BIT_INDEX	= (TAG_BIT -1) + 3;		//23
parameter INDEX_BIT		= 32 - TAG_BIT - BLOCK_OFFSET_BIT;	//32-tagbits(20) - block_offset(2) = 10 bits
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

wire	[TAG_BIT-1:0]		tag;
wire	[INDEX_BIT-1:0]		index; 		
wire	[BLOCK_OFFSET_BIT-1:0]	block_offset;
reg	[WORD_SIZE_BIT-1:0]	read_data_word;
reg	[WORD_SIZE_BIT-1:0]	write_data_word;
reg	[WORD_SIZE_BIT-1:0]	write_mem_word;
reg	[BLOCK_SIZE_BIT-1:0]	read_mem_block;
reg	[BLOCK_SIZE_BIT-1:0]	write_mem_block;

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
reg  [WORD_SIZE_BIT-1:0]				db_mux_out;


reg  [(32*BLOCK_SIZE_WORDS)-1:0]			db_read;
reg  [(32*BLOCK_SIZE_WORDS)-1:0]			db_write;
reg  [(32*BLOCK_SIZE_WORDS)-1:0]			db_str_0;
reg  [(32*BLOCK_SIZE_WORDS)-1:0]			db_str_1;

wire [WORD_SIZE_BIT-1:0]				word_mux_out;

reg  [WORD_SIZE_BIT-1:0]				addr_latch;

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
equals #(TAG_BIT) eq_way_0(tag_read_0[TAG_BIT-1:0], tag, hit_equal_way_0);
equals #(TAG_BIT) eq_way_1(tag_read_1[TAG_BIT-1:0], tag, hit_equal_way_1);

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

//assign db_mux_in 	= (db_tb_out_0 == {BLOCK_SIZE_BIT{1'dz}}) ? (((db_tb_out_1 == {BLOCK_SIZE_BIT{1'dz}}) ? {BLOCK_SIZE_BIT{1'dz}}) : db_tb_out_1) : db_tb_out_0;
assign db_mux_in	= (db_tb_out_0 != {BLOCK_SIZE_BIT{1'dz}}) ? db_tb_out_0 : (db_tb_out_1 != {BLOCK_SIZE_BIT{1'dz}}) ? db_tb_out_1 : {BLOCK_SIZE_BIT{1'dz}};
//block_offset_mux
mux4 #(WORD_SIZE_BIT) block_offset_mux(	.s(block_offset), 
					.d0(db_mux_in[WORD_SIZE_BIT-1:0]), 
					.d1(db_mux_in[2*WORD_SIZE_BIT-1:WORD_SIZE_BIT]), 
					.d2(db_mux_in[3*WORD_SIZE_BIT-1:WORD_SIZE_BIT*2]), 
					.d3(db_mux_in[4*WORD_SIZE_BIT-1:WORD_SIZE_BIT*3]), 
					.y(word_mux_out)
					);

assign data_up		= (!write_up) ? read_data_word : {WORD_SIZE_BIT{1'dz}};
assign data_mem		= (write_mem) ? write_data_word : {WORD_SIZE_BIT{1'dz}};

/*
// State Machine
*/

always @(posedge clk, negedge reset) begin
	if(!reset) 
	begin
		//reset outputs
		addr_mem  		<= {WORD_SIZE_BIT{1'd0}};
		read_mem		<= 1'd0;
		write_mem		<= 1'd0;
		stall_up		<= 1'd0;

		//reset internal signals
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

		//reset internal signals from data and address buses
		addr_latch		<= {WORD_SIZE_BIT{1'd0}};
		db_write		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
		tag_write_0		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
		tag_write_1 		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
		db_str_0		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
		db_str_1		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
		tag_str_0		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
		tag_str_1		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
		db_read			<= {TOTAL_TAG_SIZE_BIT{1'd0}};

		//reset State
		state			<= IDLE;
	end
	else 
	begin
		//update state
		state <= next_state;
	end
end

always@(state, read_up, write_up, hit, ready_mem, valid, dirty, hit_way_0, used_way_0, used_way_1, block_offset, update_flag, read_not_write)
begin

end


endmodule
