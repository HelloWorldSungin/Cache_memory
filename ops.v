/*
 *  file: ops.v
 *  will be integrated with the ops file in the pipeline
 */

module equals #(parameter TAG = 20)(
	input [TAG - 1:0] tagA, tagB,
	output 				eq
);

assign eq = (tagA == tagB) ? 1 : 0;

endmodule

module tri_buf #(parameter DATA_BLOCK = 128)(
	input 	[DATA_BLOCK - 1 : 0] a,
	input		enable,
	output		b
);

assign b = enable ? a : {DATA_BLOCK{1'dz}};

endmodule

module mux4 #(parameter WORD_SIZE_BIT = 32) (
	input  [1:0] s,
	input  [WORD_SIZE_BIT-1:0] d0, d1, d2, d3,
	output reg [WORD_SIZE_BIT-1:0] y
);
always @ (*)
  begin
    case(s)
      2'b00 : y <= d0;
      2'b01 : y <= d1;
      2'b10 : y <= d2;
      2'b11 : y <= d3;
    endcase
  end
endmodule