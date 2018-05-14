`define DATA_W 32
`define ADDR_W 32
`define RAM_D 1024

module data_memory_20cycle_tb ();
//--Declare Simulation Parameters------------------------------------
reg clk, reset;
reg wr_en, rd_en;
reg [`ADDR_W-1:0] address;
reg [`DATA_W-1:0] wr_data;
wire [`DATA_W-1:0] rd_data;
wire ready, done;
//--Clock Generator (20 clocks/cycle)--------------------------------
always #10 clk = ~clk;
//--Initialize the data memory unit----------------------------------
data_memory #(
	.DATA_WIDTH(`DATA_W),
	.ADDR_WIDTH(`ADDR_W),
	.RAM_DEPTH(`RAM_D)
) dmem_dut (
	.clk(clk),
	.reset(reset),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.address(address),
	.wr_data(wr_data),
	.rd_data(rd_data),
	.ready(ready),
	.done(done)
);
//--Main Stimulus Generation-----------------------------------------
initial begin
	clk <= 1;
	reset <= 1;
	wr_en <= 0;
	rd_en <= 0;
	address <= 0;
	wr_data <= 0;
	#20
	reset <= 0;
	#20
	wr_en <= 1;
	wr_data <= {$random} % (1<<(`DATA_W/2));
	address <= {$random} % (`RAM_D-1);
	#20
	wr_en <= 0;
	wr_data <= 0;
	address <= 0;
	repeat (10) begin
	#600
	rd_en <= 1;
	address <= {$random} % (`RAM_D-1);
	#20
	rd_en <= 0;
	address <= 0;
	#600
	wr_en <= 1;
	wr_data <= {$random} % (1<<(`DATA_W/2));
	address <= {$random} % (`RAM_D-1);
	#20
	wr_en <= 0;
	wr_data <= 0;
	address <= 0;
	end
end
//--Monitor Simulation Results-------------------------------------
initial begin
	$monitor (
		"@%d: rd_en=%b, wr_en=%b, addr=%d, wr_data=%d, rd_data=%d",
		$time, rd_en, wr_en, address, wr_data, rd_data
	);
end

endmodule
