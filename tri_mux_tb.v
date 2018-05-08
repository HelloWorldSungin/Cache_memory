module tri_mux_tb();

reg [127:0] db_read_0, db_read_1;
wire [127:0] db_tb_out_0, db_tb_out_1;
reg hit_way_0, hit_way_1;
wire [127:0] db_mux_in1;
reg [1:0] block_offset;
wire [127:0] word_mux_out;


initial begin
	block_offset <= 2'd0;
	db_read_0   <= 128'hFFFFFFFFFFFFFFFF;
	db_read_1   <= 128'h1111111111111111;
	
	hit_way_0   <= 0;
	hit_way_1   <= 0;
	#10
	hit_way_0   <= 1;
	#10
	hit_way_1   <= 1;
	hit_way_0   <= 0;
	#10
	hit_way_1   <= 0;
	hit_way_0   <= 1;

end
parameter BLOCK_SIZE_BIT = 128;
tri_buf #(128) tri_buffer_way_0(	.a(db_read_0),
						.enable(hit_way_0), 
						.b(db_tb_out_0)
						);
tri_buf #(128) tri_buffer_way_1(	.a(db_read_1),
						.enable(hit_way_1), 
						.b(db_tb_out_1)
						);  
assign db_mux_in1 = (hit_way_0) ? db_tb_out_0 : db_tb_out_1;

mux4 #(32) block_offset_mux(		.s(block_offset), 
					.d0(db_mux_in1[32-1:0]), 
					.d1(db_mux_in1[2*32-1:32]), 
					.d2(db_mux_in1[3*32-1:32*2]), 
					.d3(db_mux_in1[4*32-1:32*3]), 
					.y(word_mux_out));
endmodule 