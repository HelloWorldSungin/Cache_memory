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
		DB0_mem[addr%NUMBER_OF_SETS] <= data_in;	//need addr%NUMBER_OF_SETS somehow
	end
	read_addr <= addr%NUMBER_OF_SETS;
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
	end
	read_addr <= addr%NUMBER_OF_SETS;
end

assign data_out = DB1_mem[read_addr];	//keep output stable during read operation

endmodule 



module tag0_RAM #(parameter INDEX_BIT = 10, TOTAL_TAG_SIZE_BIT = 23, NUMBER_OF_SETS = 1000)(
	input						clk,
	input	[INDEX_BIT -1:0] 	addr,
	input	[TOTAL_TAG_SIZE_BIT-1:0] 		data_in,	//INDEX_BIT + DIRTY_BIT + USED_BIT + VALID_BIT = 23
	input						write_enable,
	output	[TOTAL_TAG_SIZE_BIT-1:0]		data_out);

localparam LINES = 1 << INDEX_BIT;

reg [22:0] Tag0_mem [0:LINES-1]; 	//4 words, 8 bypes in a word so row x col = TAG_BIT x LINES

integer i;
initial begin
	Tag0_mem[0] 	= 23'b1000_0000_0000_0000_0000_000;		//only valid bit = 1
	Tag0_mem[1]	= 23'b1000_0000_0000_0000_0000_001;		//only valid bit = 1
	Tag0_mem[2] 	= 23'b1000_0000_0000_0000_0000_010;		//only valid bit = 1
	Tag0_mem[3] 	= 23'b1000_0000_0000_0000_0000_011;		//only valid bit = 1
	Tag0_mem[4] 	= 23'b1100_0000_0000_0000_0000_100;		//valid bit and used bit = 1
	Tag0_mem[5]  	= 23'b1100_0000_0000_0000_0000_101;		//valid bit and used bit = 1
	Tag0_mem[6] 	= 23'b1010_0000_0000_0000_0001_000;		//valid bit and dirty bit = 1
	Tag0_mem[7] 	= 23'b0000_0000_0000_0000_1000_000;		//just address with all three bits = 0
for(i = 8; i <1000; i = i + 1)begin
	Tag0_mem[i] 	= 23'd0;
end

end


reg [INDEX_BIT-1:0] read_addr;

always@(posedge clk) begin
	if(write_enable) begin
		Tag0_mem[addr%NUMBER_OF_SETS] <= data_in;
	end
read_addr <= addr%NUMBER_OF_SETS;
end

assign data_out = Tag0_mem[read_addr];	//keep output stable during read operation


endmodule 


module tag1_RAM #(parameter INDEX_BIT = 10, TOTAL_TAG_SIZE_BIT = 23, NUMBER_OF_SETS = 1000)(
	input						clk,
	input	[INDEX_BIT-1:0] 	addr,
	input	[TOTAL_TAG_SIZE_BIT-1:0] 		data_in,	//INDEX_BIT + DIRTY_BIT + USED_BIT + VALID_BIT = 23
	input						write_enable,
	output	[TOTAL_TAG_SIZE_BIT-1:0]		data_out);

localparam LINES = 1 << INDEX_BIT;

reg [22:0] Tag1_mem [0:LINES-1]; 	//4 words, 8 bypes in a word so row x col = TAG_BIT x LINES

integer i;
initial begin
	Tag1_mem[0] 	= 23'b1000_0000_0000_0001_0001_000;		//only valid bit = 1
	Tag1_mem[1]	= 23'b1000_0000_0000_0001_0010_001;		//only valid bit = 1
	Tag1_mem[2] 	= 23'b0000_0000_0000_0001_0001_010;		//only valid bit = 1
	Tag1_mem[3] 	= 23'b1010_0001_0000_0000_0000_011;		//only valid bit = 1
	Tag1_mem[4] 	= 23'b1100_0001_0000_0000_0000_100;		//valid bit and used bit = 1
	Tag1_mem[5]  	= 23'b1100_0010_0000_0000_0000_101;		//valid bit and used bit = 1
	Tag1_mem[6] 	= 23'b1010_0010_0000_0000_0001_000;		//valid bit and dirty bit = 1
	Tag1_mem[7] 	= 23'b0000_0010_0100_0000_1000_000;		//just address with all three bits = 0
for(i = 8; i <1000; i = i + 1)begin
	Tag1_mem[i] 	= 23'd0;
end

end

reg [INDEX_BIT-1:0] read_addr;

always@(posedge clk) begin
	if(write_enable) begin
		Tag1_mem[addr%NUMBER_OF_SETS] <= data_in;
	end
read_addr <= addr%NUMBER_OF_SETS;
end

assign data_out = Tag1_mem[read_addr];	//keep output stable during read operation

endmodule 
