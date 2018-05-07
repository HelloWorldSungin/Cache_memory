module cache_controller_tb();

//Inputs
reg 		clk, reset, ready_mem, read_up, write_up;
reg  [31:0]	addr_up;
//Bi-diretional Inputs
wire  [31:0] data_up, data_mem;

//Outputs
wire 		read_mem, write_mem, stall_up;
wire [31:0]	addr_mem;

//Bi-directional signals
reg [31:0]	dcpu, wcpu, dmem, wmem;

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
assign data_up = write_up ? wcpu : 32'dz;



always begin
	#10 clk = ~clk;
end
	
initial begin
	//setting inputs to 0;
	clk	 		<= 1'b0;
	addr_up		<= 32'b0;
	reset	 	<= 1'b0;
	ready_mem	<= 1'b1;
	read_up	 	<= 1'b0;
	write_up	<= 1'b0;
	wcpu <= 32'd0;
	
	#80

	reset <= 1'b1;
	
	#40

	//testing each individual step
	//Read from location
	read_up 	= 1'b1;
	addr_up = 32'b0000_0000_0000_0000_0100_0000_0001_0011;
	dcpu = data_up;
	#20
	read_up = 1'd1;
	dcpu = data_up;
	#20
	read_up = 1'd0;
	#40;

	//  Read to same location
	write_up  = 1'd1;
	wcpu	= 32'd18;
	addr_up = 32'b0000_0000_0000_0000_0100_0000_0001_0011;
	#40

	write_up = 1'd0;
	#40

	// Simple Read from same location to check updated data
	read_up = 1'd1;
	addr_up = 32'b0000_0000_0000_0000_0100_0000_0001_0011;
	dcpu = data_up;
	#20
	read_up = 1'd1;
	dcpu = data_up;
	#20
	read_up = 1'd0;
	#40;


	// Read Miss, reads data from Main Memory (check the dirty bit)
	read_up = 1'd1;
	addr_up = 32'b1100_0000_0000_0000_0000_0000_1001_0001;
	dcpu = data_up;
	#20
	read_up = 1'd1;
	dcpu = data_up;
	@(posedge read_mem);
	ready_mem = 0;
	#80				//20 cycles to stall to access main memory
	ready_mem = 1;	
	#20				
	dmem = 32'h0000;		//first word
	#20
	dmem = 32'h1111;		//second word
	#20
	dmem = 32'h2222;		//thrid word
	#20
	dmem = 32'h3333;		//last word

	#80
	read_up = 1'd0;
	#20;
/*
	// Read Miss Eviction Policy Test
	read_up = 1'd1;
	addr_up = 32'b1100_0000_0000_0000_0000_1111_1111_0011;
	dcpu = data_up;
	#20
	read_up = 1'd1;
	dcpu = data_up;
	@(posedge write_mem);
	ready_mem = 1'd0;
	#400					//20 cycles of stall to access main memory
	ready_mem = 1'd1;

	@(posedge read_mem);
	ready_mem = 1'd0;
	#400					//20 cycles of stall to access main memory

	ready_mem = 1'd1;
	#20
	dmem = 32'hAAAA;		//first word
	#20
	dmem = 32'hBBBB;		//second word
	#20
	dmem = 32'hCCCC;		//thrid word
	#20 
	dmem = 32'hDDDD;		//last word
	#80
	read_up = 1'd0;
	#100
	$stop;
*/
end 


endmodule

