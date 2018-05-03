module data_block0_RAM #(parameter BLOCK_SIZE_WORDS = 4, NUMBER_OF_SET = 1000)(
	input					clk,
	input	[31:0] 				addr,
	input	[(32*BLOCK_SIZE_WORDS)-1:0] 	data_in,	//main memory has 32 bit addr each slot has 128 bits
	input					write_enable,
	output	[(32*BLOCK_SIZE_WORDS)-1:0]		data_out);

reg [(32*BLOCK_SIZE_WORDS)-1:0] DB0_mem [0:NUMBER_OF_SET-1]; 	//4 words, 8 bypes in a word so row x col = 32*BLOCK_SIZE_WORDS x NUMBER_OF_SET-1

initial begin
	$readmemb("data_block0.dat", DB0_mem);
end

reg [31:0] read_addr;

always@(posedge clk) begin
	if(write_enable) begin
		DB0_mem[addr] <= data_in;
		read_addr <= addr;
	end
end

assign dout = DB0_mem[read_addr];	//keep output stable during read operation

endmodule 



module data_block1_RAM #(parameter BLOCK_SIZE_WORDS = 4, NUMBER_OF_SET = 1000)(
	input					clk,
	input	[31:0] 				addr,
	input	[(32*BLOCK_SIZE_WORDS)-1:0] 	data_in,	//main memory has 32 bit addr each slot has 128 bits
	input					write_enable,
	output	[(32*BLOCK_SIZE_WORDS)-1:0]		data_out);

reg [(32*BLOCK_SIZE_WORDS)-1:0] DB1_mem [0:NUMBER_OF_SET-1]; 	//4 words, 8 bypes in a word so row x col = 32*BLOCK_SIZE_WORDS x NUMBER_OF_SET-1

initial begin
	$readmemb("data_block1.dat", DB1_mem);
end

reg [31:0] read_addr;

always@(posedge clk) begin
	if(write_enable) begin
		DB1_mem[addr] <= data_in;
		read_addr <= addr;
	end
end

assign dout = DB1_mem[read_addr];	//keep output stable during read operation

endmodule 



module tag1_RAM #(parameter TAG_BIT = 20, NUMBER_OF_SET = 1000)(
	input					clk,
	input	[31:0] 				addr,
	input	[(TAG_BIT+3)-1:0] 		data_in,	//TAG_BIT + DIRTY_BIT + USED_BIT + VALID_BIT = 23
	input					write_enable,
	output	[(TAG_BIT+3)-1:0]		data_out);

reg [(TAG_BIT+3)-1:0] Tag1_mem [0:NUMBER_OF_SET-1]; 	//4 words, 8 bypes in a word so row x col = 32*BLOCK_SIZE_WORDS x NUMBER_OF_SET-1

initial begin
	$readmemb("tag1.dat", Tag1_mem);
end

reg [31:0] read_addr;

always@(posedge clk) begin
	if(write_enable) begin
		Tag1_mem[addr] <= data_in;
		read_addr <= addr;
	end
end

assign dout = Tag1_mem[read_addr];	//keep output stable during read operation

endmodule 


module tag2_RAM #(parameter TAG_BIT = 20, NUMBER_OF_SET = 1000)(
	input					clk,
	input	[31:0] 				addr,
	input	[(TAG_BIT+3)-1:0] 		data_in,	//TAG_BIT + DIRTY_BIT + USED_BIT + VALID_BIT = 23
	input					write_enable,
	output	[(TAG_BIT+3)-1:0]		data_out);

reg [(TAG_BIT+3)-1:0] Tag2_mem [0:NUMBER_OF_SET-1]; 	//4 words, 8 bypes in a word so row x col = 32*BLOCK_SIZE_WORDS x NUMBER_OF_SET-1

initial begin
	$readmemb("tag2.dat", Tag2_mem);
end

reg [31:0] read_addr;

always@(posedge clk) begin
	if(write_enable) begin
		Tag2_mem[addr] <= data_in;
		read_addr <= addr;
	end
end

assign dout = Tag2_mem[read_addr];	//keep output stable during read operation

endmodule 
