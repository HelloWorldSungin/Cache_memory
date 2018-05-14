
/*
* Data Memory:
*  - operates under the assumption that the read/write signals will NOT
*    overlap.
*  - May still need to alter input/output ports for the cache.
*/
module data_memory_delayed (
	clk,
	reset,
	wr_en,
	rd_en,
	address,
	wr_data,
	rd_data,
	ready
);
//--Parameters------------------------
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 32;
parameter RAM_DEPTH = 256;//1 << ADDR_WIDTH;
//--Input Ports----------------------
input clk, reset;
input wr_en;
input rd_en;
input [ADDR_WIDTH-1:0] address;
input [DATA_WIDTH-1:0] wr_data;
//--Output Ports----------------------
output reg [DATA_WIDTH-1:0] rd_data;
output ready;

//--Registers---------------------------
reg [DATA_WIDTH-1:0] RAM[0:RAM_DEPTH-1];
reg [ADDR_WIDTH-1:0] addr_hold;
reg [RAM_DEPTH-1:0] i;
reg [4:0] dmem_stall;
reg rd_ip;
reg wr_ip;

assign ready = ~rd_ip & ~wr_ip;

//--Synchrounous (w/ Asynchronous reset)------------
always @ (posedge clk or posedge reset) begin
	if (reset) begin
		dmem_stall <= 0;
		addr_hold <= 0;
		rd_ip <= 0;
		wr_ip <= 0;
		rd_data <= 0;
		for (i = 0; i < RAM_DEPTH; i=i+1)
			RAM[i] = i;
	end
	else begin
		if (~dmem_stall & rd_en) begin
			rd_ip = rd_en;
			addr_hold = address;
		end
		else if (~dmem_stall & wr_en) begin
			wr_ip = wr_en;
			addr_hold = address;
		end
		else if (dmem_stall == 20) begin
			if (rd_ip == 1) begin
				dmem_stall = 0;
				rd_ip = 0;
				rd_data = RAM[addr_hold];
				addr_hold = address;
			end
			else if (wr_ip == 1) begin
				dmem_stall = 0;
				wr_ip = 0;
				RAM[addr_hold] = wr_data;
				addr_hold = address;
			end
		end
		else if (rd_ip | wr_ip) dmem_stall = dmem_stall + 1;
	end
end

endmodule
