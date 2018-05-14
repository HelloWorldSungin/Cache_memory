`define DATA_W 32
`define ADDR_W 32
module data_cache_memory_interface_tb();

//INPUTS
reg clk, reset;
reg RE;			//ready enable into the cache		
reg WE;			//write enable into the cache
reg [`DATA_W-1:0] WD;		//write data into the cache
reg [`ADDR_W-1:0] addr;		//address into the cache

//OUTPUTS
wire [`DATA_W-1:0] RD;		//read data from the cache
wire stall;			//stall signal from the cache

data_cache_memory_interface DUT(
	.clk(clk),
	.reset(reset),
	.RE(RE),		//ready enable into the cache		
	.WE(WE),		//write enable into the cache
	.WD(WD),		//write data into the cache
	.addr(addr),		//address into the cache
	.RD(RD),		//read data from the cache
	.stall(stall)		//stall signal from the cache
);

always begin
	#10 clk = ~clk;
end

initial begin
	clk 	<= 1'd0;
	RE  	<= 1'd0;
	WE  	<= 1'd0;
	reset 	<= 1'd1;
	WD  	<= {`DATA_W{1'd0}};
	addr 	<= {`ADDR_W{1'd0}};
	
	#80
	reset	= 1'd0;
	#40
	
	RE	= 1'd1;
	addr 	= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
	#20
	RE	= 1'd0;
	#40;

	WE 	= 1'd1;
	WD	= 32'd100;
	addr	= 32'd0000_0000_0000_0000_0000_0000_0000_0000;
	#20
	WE	= 1'd0;
	#40;

	RE 	= 1'd1;
	addr 	= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
	#20
	RE	= 1'd0;
	#40;

	RE	= 1'd1;
	addr	= 32'b0000_0000_0001_1101_1010_0000_0000_1001;		//index 2
	#630
	RE	= 1'd0;
	#20;
	
	RE 	= 1'd1;
	addr	= 32'b0000_0000_0001_0011_0011_0000_0011_1111;		//index 15
	#640
	RE	= 1'd0;
	#40;

	RE 	= 1'd1;
	addr 	= 32'b0000_0000_0111_0010_1010_0000_0001_1001;		//index 6
	#1220
	RE 	= 1'd0;
	#40;
	
	WE	= 1'd1;
	WD	= 32'd200;
	addr	= 32'b0000_0000_01010_0001_1011_0000_0011_0011;		//index 12
	#630
	WE	= 1'd0;
	#40;

end

endmodule
