//
//  CACHE CONTROLLER:
//
module cache_controller (
	input 			clk,			//Same clk from the processor
	input			reset,			//Active low asychronous reset
	input			ready_mem,		//Active high signal from the main memory
	
	input 	[31:0]		data_up,		//data input from the processor
	input 	[31:0]		data_mem,		//data input from the main memeory

	input	[31:0]		addr_up,		//input address from the processor
	output reg[31:0] 	addr_mem,		//output address to the memory
	
	input			read_up,		//Active high read from the processor
	input 			write_up,		//Active high write from the processor
	
	output reg hit_flag,
	output reg miss_flag,
	output reg valid_dirty,
	output reg stall_latch,
	output reg [1:0] idle_plus,

	output reg		read_mem,		//Active high read to the main memroy
	output reg		write_mem,		//Active high write to the main memro
	output reg		stall_up		//Active high stall to the processorc
);
/*
// Parameters
*/
parameter CACHE_LINES		= 2048;//2000;
parameter BLOCK_SIZE_WORDS	= 4;
parameter BLOCK_OFFSET_BIT	= 2;//$clog2(BLOCK_SIZE_WORDS);
parameter BLOCK_SIZE_BYTE 	= 16;//4 * BLOCK_SIZE_WORDS;			    		//16
parameter BLOCK_SIZE_BIT	= 128;//8 * BLOCK_SIZE_BYTE;			    		//128
parameter WORD_SIZE_BIT		= 32;
parameter NUMBER_OF_SETS	= 1024;//1000;							//CACHE_LINES / 2
parameter VALID_BIT		= 1;
parameter DIRTY_BIT		= 1;
parameter USED_BIT		= 1;
parameter TAG_BIT		= 20;							//tag bit without dirty, used, valid bits
parameter LAST_TAG_BIT_INDEX	= 19;	
parameter DIRTY_BIT_INDEX	= TAG_BIT; 						//20
parameter USED_BIT_INDEX	= TAG_BIT + 1;						//21
parameter VALID_BIT_INDEX	= TAG_BIT + 2;						//22
parameter INDEX_BIT			= 10;//32 - TAG_BIT - BLOCK_OFFSET_BIT;		//32-tagbits(20) - block_offset(2) = 10 bits
parameter TOTAL_TAG_SIZE_BIT	= VALID_BIT+USED_BIT+DIRTY_BIT+TAG_BIT; 		//23

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
reg	[BLOCK_SIZE_WORDS-1:0]	word_counter;		//counts word transfer between cache and memory in read & write	
reg				update_flag;		//update MEM state
reg 				read_stall_flag;	//read stall flag that make sure the processor 
							//will stall until the desire cache and data memory read 

reg				write_stall_flag;	//write stall flag that allows the processor to sall until 
							//the correct value is written to the cache and data mem



wire [LAST_TAG_BIT_INDEX:0]	tag;
wire [INDEX_BIT-1:0]		index; 		
wire [BLOCK_OFFSET_BIT-1:0]	block_offset;
reg	[WORD_SIZE_BIT-1:0]	read_data_word;
reg	[WORD_SIZE_BIT-1:0]	write_data_word;
reg	[WORD_SIZE_BIT-1:0]	write_mem_word;
reg	[BLOCK_SIZE_BIT-1:0]	read_mem_block;
wire	[WORD_SIZE_BIT-1:0]	read_mem_word0;
wire	[WORD_SIZE_BIT-1:0]	read_mem_word1;
wire	[WORD_SIZE_BIT-1:0]	read_mem_word2;
wire	[WORD_SIZE_BIT-1:0]	read_mem_word3;
reg	[BLOCK_SIZE_BIT-1:0]	write_mem_block;

reg	read_not_write;								// when reading = 1, writing = 0
reg	write_enable_DB0;							// Active high for DB0
reg	write_enable_DB1;							// Active high for DB1
reg	write_enable_Tag0;							// Active high for Tag0
reg	write_enable_Tag1;							// Active high for Tag1

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

wire [(TOTAL_TAG_SIZE_BIT-1):0]		tag_read_0;	//23bits
wire [(TOTAL_TAG_SIZE_BIT-1):0]		tag_read_1;

reg  [(TOTAL_TAG_SIZE_BIT-1):0]		tag_write_0;
reg  [(TOTAL_TAG_SIZE_BIT-1):0]		tag_write_1;
reg  [(TOTAL_TAG_SIZE_BIT-1):0]		tag_str_0;
reg  [(TOTAL_TAG_SIZE_BIT-1):0]		tag_str_1;

wire [(32*BLOCK_SIZE_WORDS)-1:0]	db_read_0;
wire [(32*BLOCK_SIZE_WORDS)-1:0]	db_read_1;
wire [(32*BLOCK_SIZE_WORDS)-1:0]	db_tb_out_0;
wire [(32*BLOCK_SIZE_WORDS)-1:0]	db_tb_out_1;
wire [(32*BLOCK_SIZE_WORDS)-1:0]	db_mux_in;
reg  [(32*BLOCK_SIZE_WORDS)-1:0]	db_read;
reg  [(32*BLOCK_SIZE_WORDS)-1:0]	db_write;
reg  [(32*BLOCK_SIZE_WORDS)-1:0]	db_str_0;
reg  [(32*BLOCK_SIZE_WORDS)-1:0]	db_str_1;
reg  [(32*BLOCK_SIZE_WORDS)-1:0]	db_mux_out;
wire [WORD_SIZE_BIT-1:0]		word_mux_out;
reg  [32-1:0]				addr_latch;

/*
// States
*/
reg  [2:0] state, next_state; 

reg [1:0] count;

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
assign hit_equal_way_0 = (tag_read_0[LAST_TAG_BIT_INDEX:0] == tag) ? 1 : 0;
assign hit_equal_way_1 = (tag_read_1[LAST_TAG_BIT_INDEX:0] == tag) ? 1 : 0;

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
mux4_assign #(WORD_SIZE_BIT) block_offset_mux(	.s(block_offset), 
					.d0(db_mux_in[WORD_SIZE_BIT-1:0]), 
					.d1(db_mux_in[2*WORD_SIZE_BIT-1:WORD_SIZE_BIT]), 
					.d2(db_mux_in[3*WORD_SIZE_BIT-1:WORD_SIZE_BIT*2]), 
					.d3(db_mux_in[4*WORD_SIZE_BIT-1:WORD_SIZE_BIT*3]), 
					.y(word_mux_out)
					);


assign data_mem = (write_mem)? write_mem_word : 32'dZ;
assign data_up = (!write_up)? read_data_word : 32'dZ;
assign read_mem_word0 = read_mem_block[127:96];
assign read_mem_word1 = read_mem_block[95:64];
assign read_mem_word2 = read_mem_block[63:32];
assign read_mem_word3 = read_mem_block[31:0];

always @ (read_up or write_up) begin
	if (read_up | write_up) stall_latch <= 1;
end
always @ (stall_up) begin
	if (~stall_up) stall_latch <= 0;
end

/*
// State Machine
*/

always @(posedge clk, negedge reset) begin
	if(!reset) 
	begin
		hit_flag <= 0;
		miss_flag <= 0;
		valid_dirty <= 0; idle_plus <= 0; stall_latch <= 0; count <= 0;
		//reset outputs
		addr_mem  		<= {32'd0};
		read_mem		<= 1'd0;
		write_mem		<= 1'd0;
		stall_up		<= 1'd0;

		//reset internal control signals
		word_counter		<= {BLOCK_SIZE_WORDS{1'd0}};
		update_flag		<= 1'd0;
		read_stall_flag		<= 1'd0;
		write_stall_flag	<= 1'd0;
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
		used_way_0, used_way_1, block_offset, update_flag, read_not_write, posedge clk)
begin
	hit_flag <= 0; miss_flag <= 0;
	case(state)

		IDLE:	begin
			if (idle_plus[1]) idle_plus <= 2'b00;
			//set outputs 
			if(read_stall_flag | write_stall_flag)
			stall_up		<= 1'd1;
			else
			stall_up 		<= 1'd0;
			read_mem 		<= 1'd0;
			write_mem 		<= 1'd0;
		
			//set internal control signals
			word_counter		<= {BLOCK_SIZE_WORDS{1'd0}};
			update_flag 		<= 1'd0;
			write_mem_word		<= {WORD_SIZE_BIT{1'd0}};
			write_mem_block 	<= {BLOCK_SIZE_BIT{1'd0}};
			write_enable_DB0 	<= 1'd0;
			write_enable_DB1 	<= 1'd0;
			write_enable_Tag0	<= 1'd0;
			write_enable_Tag1 	<= 1'd0;
			read_mem_block		<= {BLOCK_SIZE_BIT{1'd0}};
			tag_write_0		<= {TOTAL_TAG_SIZE_BIT{1'd0}};
			tag_write_1 		<= {TOTAL_TAG_SIZE_BIT{1'd0}};

			//set internal data and address buses signals 
			addr_latch 			<= addr_up;
			db_write 			<= {(32*BLOCK_SIZE_WORDS){1'd0}};
			
			if(read_up)
			begin
				next_state 		<= READ;
				read_not_write 	<= 1'd1;
				idle_plus <= 2'b01;
			end	
			else if(write_up) begin
				next_state		<= WRITE;
				write_data_word	<= data_up;
				read_not_write 	<= 1'd0;
				idle_plus <= 2'b01;
			end 
			else begin
				next_state		<= state;
			end
			if(read_stall_flag) begin next_state 	<= READ;		//When it's not a hit, after you updating and/or fetching data from data memory
				//miss_flag <= 1;
			end
			if(write_stall_flag) begin next_state <= WRITE;		//you need to do READ or WRITE operation with the updated cache.
				//miss_flag <= 1;
			end
	end
		READ:			begin	
			write_enable_DB0 <= 0;		//it's reading operation, do we not want to modify the data blocks in the cache
			write_enable_DB1 <= 0;
			case(hit) 
				1'd0: 	begin
						//storing values in the cache of that index
						//might need to update data memory with this data
						read_stall_flag <= 1;	
						tag_str_0	<= tag_read_0;	
						tag_str_1	<= tag_read_1;
						db_str_0	<= db_read_0;
						db_str_1	<= db_read_1;
						stall_up	<= 1'd1;
						read_mem 	<= 1'd1;
							if(valid & dirty) begin
								next_state 	<= UPDATE_MEM;
								valid_dirty <=1;
							end
							else begin 
								next_state 	<= READ_MEM;
								
							end
				   	end
				1'd1:	begin
						hit_flag <= 1; count <= count+1;
						if (count == 2) begin count = 0; miss_flag <= 1; end
						if (idle_plus[0]) idle_plus <= 2'b10;
						if (valid_dirty) valid_dirty <= 0;
						//After reading the value, updating the used bit of that tag
						read_data_word 		<= word_mux_out;				
						next_state 		<= IDLE;
						write_enable_Tag0	<= 1'd1;
						write_enable_Tag1	<= 1'd1;
						if(read_stall_flag)
						begin
						@(negedge clk);
						stall_up		<= 1'd0;
						end
						read_stall_flag		<= 1'd0;
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

						//storing values in the cache of that index
						//might need to update data memory with this data
						write_stall_flag <= 1;
						tag_str_0	<= tag_read_0;
						tag_str_1	<= tag_read_1;
						db_str_0	<= db_read_0;
						db_str_1	<= db_read_1;
						stall_up	<= 1'd1;
						read_mem 	<= 1'd1;
		
							if(valid & dirty) begin
								next_state	<= UPDATE_MEM;
								valid_dirty <=1;
							end
							else
								next_state	<= READ_MEM;
		
					end
				1'd1:	begin
						hit_flag <= 1; count <= count+1;
						if (count == 2) begin count = 0; miss_flag <= 1; end
						if (idle_plus[0]) idle_plus <= 2'b10;
						if (valid_dirty) valid_dirty <= 0;
						//After writing to the correct block_offest of the data block
						//update its used bit and dirty bit
						next_state 	<= IDLE;
						write_enable_Tag0 <= 1'd1;
						write_enable_Tag1 <= 1'd1;
						if(write_stall_flag) begin
						@(negedge clk);
						stall_up 		  <= 1'd0;
						end
						write_stall_flag 	  <= 1'd0;
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
			//output the address of the data memory so it can provide us with the data
			addr_mem 	<= {addr_latch[32-1:2],2'd0};
				//if the stall in completed to access the data 
				//memory turn on the read_mem signal to read the data.
				if(ready_mem)
				begin
					read_mem 	<= 1'd1;
					next_state	<= WAIT_FOR_MEM;
				end
				else
				begin	//if the previous states were UPDATE_MEM and WAIT_FOR_MEM
					//we need read_mem to be high to triger the read memory stall 
					//and eventually read data from data memory				
					if(update_flag)	
					read_mem 	= 1'd1;
					else
					read_mem	= 1'd0;
					next_state	<= state;
				end
			update_flag	<= 1'd0; //turning off the update flag
		end
		WAIT_FOR_MEM:	begin
			// this state initiate the data transfer between cache and data memory
					if(ready_mem)
					begin
						read_mem 	<= 1'd0; 
						write_mem 	<= 1'd0; 
						if(update_flag) begin	//update_flag tells this state if need to READ_MEM
							next_state <= READ_MEM;

						end
						else
							next_state <= UPDATE_CACHE;
					end
					else begin
					 	//this initiate write data to the data memory
						if(!read_not_write)
						begin
							write_mem_word 	<= write_mem_block[WORD_SIZE_BIT-1:0];
							write_mem_block	<= {{WORD_SIZE_BIT{1'd0}}, write_mem_block[WORD_SIZE_BIT*4-1:WORD_SIZE_BIT]};
						end
						next_state <= state;
					end
		end
		UPDATE_MEM:		begin		//This state update current data in the cache to the data memory on write back policy
			update_flag	<= 1'd1;
			read_mem	<= 1'd0;
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
				read_not_write  <= 0; 
			end
			else
			begin
			
				write_mem 	<= 1'd0;
				next_state	<= state;
											
			end 
		end

		UPDATE_CACHE:	begin		//This state update the cache with new data from data memory
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
						write_enable_DB0	<= 1;
						write_enable_DB1	<= 0;
						write_enable_Tag0	<= 1;
						write_enable_Tag1	<= 1;
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
		default:	begin
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
tag0_RAM #(INDEX_BIT,TOTAL_TAG_SIZE_BIT, NUMBER_OF_SETS) tag_0_ram(
					.clk(clk),
	 				.addr(index),
					.data_in(tag_write_0),	
					.write_enable(write_enable_Tag0),
					.data_out(tag_read_0)
					);

// TAG RAM For Way_1
tag1_RAM #(INDEX_BIT,TOTAL_TAG_SIZE_BIT, NUMBER_OF_SETS) tag_1_ram(
					.clk(clk),
	 				.addr(index),
					.data_in(tag_write_1),	
					.write_enable(write_enable_Tag1),
					.data_out(tag_read_1)
					);

// Data_blcok for Way_0
data_block0_RAM #(INDEX_BIT ,BLOCK_SIZE_WORDS, TAG_BIT) data_block0_ram(
					.clk(clk),
					.addr(index),
					.data_in(db_write),	
					.write_enable(write_enable_DB0),
					.data_out(db_read_0)
					);
// Data block for Way_1
data_block1_RAM #(INDEX_BIT ,BLOCK_SIZE_WORDS, TAG_BIT) data_block1_ram(
					.clk(clk),
					.addr(index),
					.data_in(db_write),	
					.write_enable(write_enable_DB1),
					.data_out(db_read_1)
					);

endmodule
