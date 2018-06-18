module data_cache_memory_interface (
	clk,
	reset,
	RE,		//ready enable into the cache		
	WE,		//write enable into the cache
	WD,		//write data into the cache
	addr,		//address into the cache
	RD,		//read data from the cache
	stall,		//stall signal from the cache
	
	cache_hit,
	cache_miss,
	valid_dirty,
	idle_plus,
	stall_latch
);

//--Parameters------------------------
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 32;

//--Input Ports----------------------
input clk, reset;
input RE, WE;
input [DATA_WIDTH-1:0] WD;
input [ADDR_WIDTH-1:0] addr;

//--Output Ports----------------------
output [DATA_WIDTH-1:0] RD;
output stall;

output cache_hit;
output cache_miss;
output valid_dirty;
output [1:0] idle_plus;
output stall_latch;
 
//Cache wires

//Data memroy wires
wire done;

//Wires between Cache and Data memory
wire ready_mem;
wire rd_mem, wr_mem;
wire [ADDR_WIDTH-1:0] addr_mem;

reg [DATA_WIDTH-1:0] d_up, w_up, wmem;

//Bi-directional signals
wire [DATA_WIDTH-1:0] data_up, data_mem, dmem;


cache_controller cache_memory (
						.clk(clk),			//Same clk from the processor
						.reset(!reset),			//Active low sychronous reset
						.ready_mem(ready_mem),		//Active high signal from the main memory
					
						.data_up(data_up),		//data input from the processor
						.data_mem(data_mem),	//data input from the main memeory	
						.addr_up(addr),			//input address from the processor
					 	.addr_mem(addr_mem),	//output address to the memory
					 	
					 	.hit_flag(cache_hit),
					 	.miss_flag(cache_miss),
					 	.valid_dirty(valid_dirty),
					 	.idle_plus(idle_plus),
					 	.stall_latch(stall_latch),
					
						.read_up(RE),			//Active high read from the processor
						.write_up(WE),			//Active high write from the processor	
						.read_mem(rd_mem),		//Active high read to the main memroy
						.write_mem(wr_mem),		//Active high write to the main memroy
						.stall_up(stall)		//Active high stall to the peocessorc
);

data_memory_for_cache data_memory_delay(
						.clk(clk),
						.reset(reset),
						.wr_en(wr_mem),
						.rd_en(rd_mem),
						.address(addr_mem),
						.wr_data(wmem),
						.rd_data(dmem),			
						.ready(ready_mem),
						.done(done)
);

assign data_mem = (!wr_mem)? dmem: {DATA_WIDTH{1'dz}};
assign data_up  = (WE)? w_up : {DATA_WIDTH{1'dz}};
assign RD = d_up;


always@(posedge clk, data_up, WD, data_mem, done) begin
	if(RE)
	d_up = data_up;
	if(WE)
	w_up = WD;
	if(wr_mem)
	wmem = data_mem;
end
endmodule 
