module data_memory_for_cache (
	clk, reset,
	wr_en, rd_en,
	address, wr_data,
	rd_data,
	ready, done
);
//--Parameters----------------------------------------------------------------
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 32;
parameter RAM_DEPTH = 65536;//2^14 words
localparam BLOCK_SIZE = 4;
//--Input Ports---------------------------------------------------------------
input clk, reset;
input rd_en, wr_en;
input [ADDR_WIDTH-1:0] address;
input [DATA_WIDTH-1:0] wr_data;
//--Output Ports--------------------------------------------------------------
output reg [DATA_WIDTH-1:0] rd_data;
output reg ready;
output reg done;
//--Registers-----------------------------------------------------------------
reg [DATA_WIDTH-1:0] RAM [0:RAM_DEPTH-1];
reg [ADDR_WIDTH-1:0] addr_hold;
reg [ADDR_WIDTH-1:0] block_addr;
reg [DATA_WIDTH-1:0] data_hold;
reg [2:0] state, next_state;
reg [4:0] dmem_stall;
reg [1:0] block_count;
reg read_flag;
reg write_flag;
reg update_mem_flag;
//--State Constants-----------------------------------------------------------
localparam IDLE = 0;
localparam READ_IP = 1;
localparam READ_MEM = 2;
localparam WRITE_IP = 3;		//we write to the memory in this stage
localparam WRITE_MEM = 4;
localparam DONE = 5;
////
localparam READY = 6;
////

//initial $readmemb("ascending_int.mem", RAM);
//initial $readmemb("descending_int.mem", RAM);
//initial $readmemb("random_int.mem", RAM);
integer i;
initial for (i = 0; i < RAM_DEPTH; i=i+1) RAM[i] = i;

//--Synchronous State Transitions---------------------------------------------
always @ (posedge clk or posedge reset) begin
	if (reset) state <= IDLE;
	else state <= next_state;
end
//--Combinational Block-------------------------------------------------------
always @ (state or rd_en or wr_en or dmem_stall or ready or done or block_count) begin
	next_state = 3'bx;
	case (state)
		IDLE: begin
			if (rd_en) begin
				ready=0;
				//@(negedge clk);
				next_state = READ_IP;
			end
			else if (wr_en) begin
				ready=0;
				//@(negedge clk);
				next_state = WRITE_IP;
			end
			else next_state = IDLE;
		end
		/*
		READ_IP: begin
			if (dmem_stall==19) next_state = READ_MEM;
			else next_state = READ_IP;
		end
		*/
		//
		READ_IP: begin
			if (dmem_stall==19) next_state = READY;
			else next_state = READ_IP;
		end
		READY: begin
			if (dmem_stall==20) begin
			next_state=READY;
			end
			else begin
			next_state = READ_MEM;
			end
			if (wr_en) begin
			next_state = WRITE_IP;
			end
		end
		//
		READ_MEM: begin
			if (block_count == BLOCK_SIZE-1) next_state = DONE;
			else next_state = READ_MEM;
		end
		WRITE_IP: begin
			if (dmem_stall == 3) next_state = WRITE_MEM;
			else next_state = WRITE_IP;
		end
		WRITE_MEM: begin next_state = DONE; end
		DONE: begin next_state = IDLE; end
	endcase
end
//--Update Registers & Outputs Synchronously----------------------------------
always @ (posedge clk or posedge reset) begin
	if (reset) begin
		rd_data <= 0;
		ready <= 1;
		done <= 0;
		dmem_stall <= 0;
		addr_hold <= 0;
		block_addr <= 0;
		data_hold <= 0;
		block_count <= 0;
		update_mem_flag <= 0;
		read_flag <= 0;
		write_flag <= 0;
		//for (i = 0; i < RAM_DEPTH; i=i+1) RAM[i] = {$random} % RAM_DEPTH;
	end else begin
		case (state)
			IDLE: begin
				if (rd_en) begin
					read_flag <= 1;
				end
				else if (wr_en) begin
					write_flag <= 1;
				end
			end
			READ_IP: begin  
				  dmem_stall <= dmem_stall + 1;
				  if(read_flag) begin
					block_addr <= {address[31:2], 2'b00};
					addr_hold <= address;
					read_flag <= 0;
				  end
				end
			//
			READY: begin
				if (dmem_stall==20) begin
					dmem_stall <= 0;
					addr_hold <= 0;
					ready <= 1;
				end else begin
					done <= 1;
				end
				//
				if(wr_en) begin
					ready <= 0;	
				end
			end
			//
			READ_MEM: begin
				block_count <= block_count + 1;
			end
			/*
			READ_MEM: begin
			rd_data <= RAM[block_addr + block_count];
			block_count <= block_count + 1;
			dmem_stall <= 0;
			addr_hold <= 0;
			ready <= 1;
			done <= 1;
			end
			*/
			WRITE_IP: begin 
				RAM[address + dmem_stall] <= wr_data;
				dmem_stall <= dmem_stall + 1; 
				if(write_flag) begin
					addr_hold <= address;
					data_hold <= wr_data;
					write_flag <= 0;
				  end
				end
			WRITE_MEM: begin
				dmem_stall <= 0;
				//RAM[addr_hold] <= data_hold;
				addr_hold <= 0;
				data_hold <= 0;
				ready <= 1;
				done <= 1;
				//
			end
			DONE: begin
				block_count <= 0;
				rd_data <= 0;
				done <= 0;
			end
		endcase
	end
end
always @ (negedge clk) begin
	if (state == READ_MEM) begin
		rd_data <= RAM[block_addr + block_count];
	
	$monitor (
		"@%d: block_addr=%d, block_count=%d",
		$time, block_addr, block_count
	);
		//block_count <= block_count + 1;
	
	end
end



endmodule

