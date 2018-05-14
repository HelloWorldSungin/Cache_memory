
module cache_controller_tb2();

//Inputs
reg 		clk, reset, ready_mem, read_up, write_up;
reg  [31:0]	addr_up;
//Bi-diretional Inputs
wire  [31:0] data_up, data_mem;

//Outputs
wire 		read_mem, write_mem, stall_up;
wire [31:0]	addr_mem;

//Bi-directional signals
reg [31:0]	d_up, w_up, dmem;

cache_controller DUT(
						.clk(clk),				//Same clk from the processor
						.reset(reset),			//Active low sychronous reset
						.ready_mem(ready_mem),	//Active high signal from the main memory
					
						.data_up(data_up),		//data input from the processor
						.data_mem(data_mem),	//data input from the main memeory	
						.addr_up(addr_up),		//input address from the processor
					 	.addr_mem(addr_mem),	//output address to the memory
					
						.read_up(read_up),		//Active high read from the processor
						.write_up(write_up),	//Active high write from the processor	
						.read_mem(read_mem),	//Active high read to the main memroy
						.write_mem(write_mem),	//Active high write to the main memroy
						.stall_up(stall_up)		//Active high stall to the peocessorc
);

//The purpose of this statemnet is to eliminate the case where 
//both processor and memory try to write to the processor at the same time

assign data_mem	= (!write_mem)?	dmem: 32'dz;
assign data_up = write_up ? w_up : 32'dz;

always@(posedge clk, data_up) begin
	if(read_up) begin
	d_up = data_up;
	end
	if(write_up) begin
	w_up = data_up;
	end
end

always begin
	#10 clk = ~clk;
end
	
initial begin
	// setting inputs to 0;
	clk	 	<= 1'b0;
	addr_up		<= 32'b0;
	reset	 	<= 1'b0;
	ready_mem	<= 1'b1;
	read_up	 	<= 1'b0;
	write_up	<= 1'b0;
	w_up <= 32'd0;
	
	#80

	reset <= 1'b1;
	
	#40


	// Read from cache location (hit)
	// STATE: IDLE(0) -> READ(1) -> IDLE(0)
	// expected value: data_up = 3 and d_up = 3 by half cycle late
	read_up 	= 1'd1;
	addr_up = 32'b0000_0000_0000_0000_0000_0000_0000_0000;	
	#20				
	read_up = 1'd0;									
	#40;

	// write to the same cache location (hit)
	// STATE: IDLE(0) -> WRITE(2) -> IDLE(0)
	// expected value: data_up = 100
	write_up  = 1'd1;
	w_up	= 32'd100;
	addr_up = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
	#20
	write_up = 1'd0;
	#40

	// read from the same location to check if data is updated to 100
	// STATE: IDLE(0) -> READ(1) ->IDLE(0)
	// expected value: data_up = 100 and d_up = 100 by half cycle late
	read_up = 1'd1;
	addr_up = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
	#20
	read_up = 1'd0;
	#40;

	// Read Miss, reads data from Main Memory (Dirty bit = 0, valid bit = 1)
	// STATE: IDLE(0) -> READ(1) -> READ_MEM(3) -> WAIT_FOR_MEM(4) -> UPDATE_CACHE(6)
	// Expected value: read_mem_block = 9000, 9001, 9002, 9003. data_up = 9003 
	read_up = 1'd1;
	//addr_up = 32'b0000_1100_0100_0011_1010_0011_1110_1000;
	addr_up = 32'b0000_0011_0000_0000_0010_0000_0000_1000;
	#20
	@(posedge read_mem);
	ready_mem = 0;
	#100				//5 cycles to stall to access main memory (in pipeline, it's going to stall for 20 cycles)
	ready_mem = 1;	
	#20	
	@(negedge clk);			
	dmem = 32'd9003;		//first word
	#20
	dmem = 32'd9002;		//second word
	#20
	dmem = 32'd9001;		//thrid word
	#20
	dmem = 32'd9000;		//last word
	#80
	read_up = 1'd0;
	#20;

	// Read Miss, reads data from Main Memory (Dirty bit = 0, valid bit = 0)
	// STATE: IDLE(0) -> READ(1) -> READ_MEM(3) -> WAIT_FOR_MEM(4) -> UPDATE_CACHE(6)
	// Expected value: read_mem_block = 8000, 8001, 8002, 8003. data_up = 8000 
	read_up = 1'd1;
	//addr_up = 32'b1101_1001_1000_1100_1110_0000_0000_1011;
	addr_up = 32'b1101_1100_0010_0000_0110_0000_0100_0011;
	#20
	@(posedge read_mem);
	ready_mem = 0;
	#100				//5 cycles to stall to access main memory (in pipeline, it's going to stall for 20 cycles)
	ready_mem = 1;	
	#20	
	@(negedge clk);			
	dmem = 32'd8003;		//first word
	#20
	dmem = 32'd8002;		//second word
	#20
	dmem = 32'd8001;		//thrid word
	#20
	dmem = 32'd8000;		//last word
	#80
	read_up = 1'd0;
	#20;



	//Read Miss Eviction Write Back Policy Test (Dirty bit = 1, valid bit = 1)
	//STATE: IDLE(0)-> READ(1)-> UPDATE_MEM(5)-> WAIT_FOR_MEM(4)-> READ_MEM(3)-> WAIT_FOR_MEM(4)-> UPDATE_CACHE(6)
	//Expected values:dmem = 10003->10002->10001->10000, read_mem_block= 10000->10001->10002->10003. data_up = 10001
	read_up = 1'd1;
	//addr_up = 32'b1111_0111_1010_0000_0110_0000_0001_1001;
	addr_up = 32'b1111_0111_1010_0000_0110_0000_0001_1001;
	#20
	@(posedge write_mem);
	ready_mem = 1'd0;
	#100					//20 cycles of stall to access main memory
	ready_mem = 1'd1;
	@(posedge read_mem);
	ready_mem = 1'd0;
	#80					//20 cycles of stall to access main memory
	ready_mem = 1'd1;
	#20
	@(negedge clk);
	dmem = 32'd10003;		//first word
	#20
	dmem = 32'd10002;		//second word
	#20
	dmem = 32'd10001;		//thrid word
	#20 
	dmem = 32'd10000;		//last word
	#80
	read_up = 1'd0;
	#40;

	//Write miss with valid and dirty = 0
	write_up = 1'd1;
	w_up 	= 32'd200;
	addr_up = 32'b0000_0011_1100_0000_1001_0000_0011_0011;
	#20
	@(posedge read_mem);
	ready_mem = 1'd0;
	#100
	ready_mem = 1'd1;
	#20;
	@(negedge clk);
	dmem = 32'd3333;
	#20
	dmem = 32'd4444;
	#20
	dmem = 32'd5555;
	#20
	dmem = 32'd6666;
	#100
	write_up = 1'd0;
	#40;

	//checking if the data is writen
	read_up 	= 1'd1;
	addr_up = 32'b0000_0011_1100_0000_1001_0000_0011_0011;	
	#20				
	read_up = 1'd0;									
	#60
	
	//Write miss with valid  and dirty = 1
	write_up = 1'd1;
	w_up 	 = 32'd300;
	addr_up  = 32'b0011_0100_1111_0110_1001_0000_0010_0010;
	#20
	@(posedge write_mem)
	ready_mem = 1'd0;
	#100					//20 cycles of stall to access main memory
	ready_mem = 1'd1;
	@(posedge read_mem);
	ready_mem = 1'd0;
	#100					//20 cycles of stall to access main memory
	ready_mem = 1'd1;
	#20
	@(negedge clk);
	dmem = 32'd1234;		//first word
	#20
	dmem = 32'd1233;		//second word
	#20
	dmem = 32'd1232;		//thrid word
	#20 
	dmem = 32'd1231;		//last word
	#100
	write_up = 1'd0;
	#40;

	//checking if the data is writen
	read_up = 1'd1;
	addr_up = 32'b0011_0100_1111_0110_1001_0000_0010_0010;	
	#20				
	read_up = 1'd0;									
	#60;
/*
	read_up = 1'd1;
	addr_up = 32'b0000_0011_1100_0000_1001_0000_0011_0011;
	d_up = data_up;
	#20
	read_up = 1'd1;
	d_up = data_up;
	#20
	read_up = 1'd0;
	#40;
*/
end 


endmodule

