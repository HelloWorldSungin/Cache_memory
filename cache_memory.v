//
//  DATA CACHE (BLOCK[0]):
//
module data_block0_RAM #(
	parameter 	INDEX_BIT = 10,
				BLOCK_SIZE_WORDS = 4,
				NUMBER_OF_SETS = 1024
)(	input								clk,
	input	[INDEX_BIT-1:0] 			addr,
	//main memory has 32 bit addr each slot has 128 bits
	input	[(32*BLOCK_SIZE_WORDS)-1:0] data_in,
	input								write_enable,
	output	[(32*BLOCK_SIZE_WORDS)-1:0]	data_out
);
localparam LINES = 1 << INDEX_BIT;
//4 words, 8 bypes in a word so row x col = 32*BLOCK_SIZE_WORDS x LINES
reg [(32*BLOCK_SIZE_WORDS)-1:0] DB0_mem [0:LINES-1];
integer i;
initial for(i = 0; i < 1024; i = i + 1)	DB0_mem[i] = 0;

reg [INDEX_BIT-1:0] read_addr;

always@(posedge clk) begin
	if(write_enable) begin
		//need addr%NUMBER_OF_SETS somehow
		DB0_mem[addr%NUMBER_OF_SETS] <= data_in;
	end
	read_addr <= addr%NUMBER_OF_SETS;
end
//keep output stable during read operation
assign data_out = DB0_mem[read_addr];	
endmodule 

//
//  DATA CACHE (BLOCK[1]):
//
module data_block1_RAM #(
	parameter 	INDEX_BIT = 10,
				BLOCK_SIZE_WORDS = 4,
				NUMBER_OF_SETS = 1024
)(	input								clk,
	input	[INDEX_BIT-1:0] 			addr,
	//main memory has 32 bit addr each slot has 128 bits
	input	[(32*BLOCK_SIZE_WORDS)-1:0] data_in,
	input								write_enable,
	output	[(32*BLOCK_SIZE_WORDS)-1:0]	data_out
);
localparam LINES = 1 << INDEX_BIT;
//4 words, 8 bypes in a word so row x col = 32*BLOCK_SIZE_WORDS x LINES
reg [(32*BLOCK_SIZE_WORDS)-1:0] DB1_mem [0:LINES-1];
integer i;
initial for(i = 0; i < 1024; i = i + 1)	DB1_mem[i] = 0;

reg [INDEX_BIT-1:0] read_addr;

always@(posedge clk) begin
	if(write_enable) begin
		DB1_mem[addr%NUMBER_OF_SETS] <= data_in;
	end
	read_addr <= addr%NUMBER_OF_SETS;
end
//keep output stable during read operation
assign data_out = DB1_mem[read_addr];
endmodule 


//
//  DATA CACHE (TAG[0]):
//
module tag0_RAM #(
	parameter 	INDEX_BIT = 10,
				TOTAL_TAG_SIZE_BIT = 23,
				NUMBER_OF_SETS = 1024
)(	input							clk,
	input  [INDEX_BIT -1:0] 		addr,
	//INDEX_BIT + DIRTY_BIT + USED_BIT + VALID_BIT = 23
	input  [TOTAL_TAG_SIZE_BIT-1:0] data_in,
	input							write_enable,
	output [TOTAL_TAG_SIZE_BIT-1:0]	data_out
);
localparam LINES = 1 << INDEX_BIT;
//4 words, 8 bypes in a word so row x col = TAG_BIT x LINES
reg [22:0] Tag0_mem [0:LINES-1]; 
integer i;
initial begin
/*	
	Tag0_mem[0] = 23'b1100_0000_0000_0000_0000_000;	//only valid bit = 1
	Tag0_mem[1]	= 23'b1000_0000_0000_0000_0000_001;	//only valid bit = 1
	Tag0_mem[2]	= 23'b1000_0000_0000_0000_0000_010;	//only valid bit = 1
	Tag0_mem[3]	= 23'b1000_0000_0000_0000_0000_011;	//only valid bit = 1
	Tag0_mem[4]	= 23'b1100_0000_0000_0000_0000_100;	//valid bit and used bit = 1
	Tag0_mem[5] = 23'b1010_0000_0000_0000_0000_101;	//valid bit and used bit = 1
	Tag0_mem[6]	= 23'b1010_0000_0000_0000_0000_110;	//valid bit and dirty bit = 1
	Tag0_mem[7]	= 23'b0000_0000_0000_0010_0000_000;	//just address with all three bits = 0
	Tag0_mem[8] = 23'b1100_0000_0000_0100_0000_111;	//valid bit is 1 and used bit is one also
*/
	for(i = 0; i < 1024; i = i + 1)begin
		Tag0_mem[i] = 23'd0;
	end
end
reg [INDEX_BIT-1:0] read_addr;

always@(posedge clk) begin
	if(write_enable) begin
		Tag0_mem[addr%NUMBER_OF_SETS] <= data_in;
	end
	read_addr <= addr%NUMBER_OF_SETS;
end
//keep output stable during read operation
assign data_out = Tag0_mem[read_addr];
endmodule 

//
//  DATA CACHE (TAG[1]):
//
module tag1_RAM #(
	parameter 	INDEX_BIT = 10,
				TOTAL_TAG_SIZE_BIT = 23,
				NUMBER_OF_SETS = 1024
)(	input							clk,
	input  [INDEX_BIT-1:0] 			addr,
	//INDEX_BIT + DIRTY_BIT + USED_BIT + VALID_BIT = 23
	input  [TOTAL_TAG_SIZE_BIT-1:0] data_in,
	input							write_enable,
	output [TOTAL_TAG_SIZE_BIT-1:0] data_out
);
localparam LINES = 1 << INDEX_BIT;
//4 words, 8 bypes in a word so row x col = TAG_BIT x LINES
reg [22:0] Tag1_mem [0:LINES-1];
integer i;
initial begin
/*
	Tag1_mem[0] = 23'b0000_1000_0000_0111_1101_000;	//only used bit = 1
	Tag1_mem[1]	= 23'b1100_0000_0000_0111_1101_001;	//valid bit and used bit = 1
	Tag1_mem[2] = 23'b0000_1000_0000_0111_1101_010;	//valid bit is 0
	Tag1_mem[3] = 23'b0000_1100_0000_0111_1101_011;	//valid bit is 0
	Tag1_mem[4] = 23'b1000_0000_0000_0111_1101_100;	//only valid bit = 1
	Tag1_mem[5] = 23'b1100_0000_0010_0111_1101_101;	//valid bit is 0
	Tag1_mem[6] = 23'b1100_0000_0000_0111_1001_110;	//valid bit and dirty bit = 1
	Tag1_mem[7] = 23'b1110_0000_0000_0111_1101_111;	//just address with all three bits = 0
	Tag1_mem[8]	= 23'b1010_0000_0000_0111_1110_000;	//valid and dirty bits are one LRU = 0
	*/
	for(i = 0; i < 1024; i = i + 1)begin
		Tag1_mem[i] = 23'd0;
	end
end
reg [INDEX_BIT-1:0] read_addr;

always@(posedge clk) begin
	if(write_enable) begin
		Tag1_mem[addr%NUMBER_OF_SETS] <= data_in;
	end
	read_addr <= addr%NUMBER_OF_SETS;
end
//keep output stable during read operation
assign data_out = Tag1_mem[read_addr];

endmodule 
