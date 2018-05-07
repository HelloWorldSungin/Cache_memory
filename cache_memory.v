module data_block0_RAM #(parameter INDEX_BIT = 10, BLOCK_SIZE_WORDS = 4, NUMBER_OF_SETS = 1000)(
	input					clk,
	input	[INDEX_BIT-1:0] 		addr,
	input	[(32*BLOCK_SIZE_WORDS)-1:0] 	data_in,	//main memory has 32 bit addr each slot has 128 bits
	input					write_enable,
	output	[(32*BLOCK_SIZE_WORDS)-1:0]		data_out);

localparam LINES = 1 << INDEX_BIT;

reg [(32*BLOCK_SIZE_WORDS)-1:0] DB0_mem [0:LINES-1]; 	//4 words, 8 bypes in a word so row x col = 32*BLOCK_SIZE_WORDS x LINES


integer i;
initial begin
for(i = 0; i < 1000; i = i + 1) begin
	DB0_mem[i][127:96] 	= i*4;
	DB0_mem[i][95:64] 	= i*4 + 1;
	DB0_mem[i][63:32] 	= i*4 + 2;
	DB0_mem[i][31:0] 	= i*4 + 3;
	end
end

reg [INDEX_BIT-1:0] read_addr;

always@(posedge clk) begin
	if(write_enable) begin
		DB0_mem[addr%NUMBER_OF_SETS] <= data_in;
		read_addr <= addr%NUMBER_OF_SETS;
	end
end

assign data_out = DB0_mem[read_addr];	//keep output stable during read operation

endmodule 



module data_block1_RAM #(parameter INDEX_BIT = 10, BLOCK_SIZE_WORDS = 4, NUMBER_OF_SETS = 1000)(
	input					clk,
	input	[INDEX_BIT-1:0] 		addr,
	input	[(32*BLOCK_SIZE_WORDS)-1:0] 	data_in,	//main memory has 32 bit addr each slot has 128 bits
	input					write_enable,
	output	[(32*BLOCK_SIZE_WORDS)-1:0]		data_out);

localparam LINES = 1 << INDEX_BIT;

reg [(32*BLOCK_SIZE_WORDS)-1:0] DB1_mem [0:LINES-1]; 	//4 words, 8 bypes in a word so row x col = 32*BLOCK_SIZE_WORDS x LINES

integer i;
initial begin
for(i = 0; i < 1000; i = i + 1) begin
	DB1_mem[i][127:96] 	= i*4 + 4000;
	DB1_mem[i][95:64] 	= i*4 + 1 + 4000;
	DB1_mem[i][63:32] 	= i*4 + 2 + 4000;
	DB1_mem[i][31:0] 	= i*4 + 3 + 4000;
	end
end


reg [INDEX_BIT-1:0] read_addr;

always@(posedge clk) begin
	if(write_enable) begin
		DB1_mem[addr%NUMBER_OF_SETS] <= data_in;
		read_addr <= addr%NUMBER_OF_SETS;
	end
end

assign data_out = DB1_mem[read_addr];	//keep output stable during read operation

endmodule 



module tag0_RAM #(parameter INDEX_BIT = 10, TAG_BIT = 23, NUMBER_OF_SETS = 1000)(
	input						clk,
	input	[INDEX_BIT-1:0] 	addr,
	input	[TAG_BIT-1:0] 		data_in,	//INDEX_BIT + DIRTY_BIT + USED_BIT + VALID_BIT = 23
	input						write_enable,
	output	[TAG_BIT-1:0]		data_out);

localparam LINES = 1 << INDEX_BIT;

reg [TAG_BIT-1:0] Tag0_mem [0:LINES-1]; 	//4 words, 8 bypes in a word so row x col = TAG_BIT x LINES

integer i;
initial begin
for(i = 0; i < 1000; i = i + 1)
	Tag0_mem[i] = 20'd0;
end


reg [INDEX_BIT-1:0] read_addr;

always@(posedge clk) begin
	if(write_enable) begin
		Tag0_mem[addr%NUMBER_OF_SETS] <= data_in;
		read_addr <= addr%NUMBER_OF_SETS;
	end
end

assign data_out = Tag0_mem[read_addr];	//keep output stable during read operation


endmodule 


module tag1_RAM #(parameter INDEX_BIT = 10, TAG_BIT = 23, NUMBER_OF_SETS = 1000)(
	input						clk,
	input	[INDEX_BIT-1:0] 	addr,
	input	[TAG_BIT-1:0] 		data_in,	//INDEX_BIT + DIRTY_BIT + USED_BIT + VALID_BIT = 23
	input						write_enable,
	output	[TAG_BIT-1:0]		data_out);

localparam LINES = 1 << INDEX_BIT;

reg [TAG_BIT-1:0] Tag1_mem [0:LINES-1]; 	//4 words, 8 bypes in a word so row x col = TAG_BIT x LINES

integer i;
initial begin
for(i = 0; i < 1000; i = i + 1)
	Tag1_mem[i] = 20'd0;
end

reg [INDEX_BIT-1:0] read_addr;

always@(posedge clk) begin
	if(write_enable) begin
		Tag1_mem[addr%NUMBER_OF_SETS] <= data_in;
		read_addr <= addr%NUMBER_OF_SETS;
	end
end

assign data_out = Tag1_mem[read_addr];	//keep output stable during read operation

endmodule 
