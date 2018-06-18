
module adder (
	input [31:0] a, b,
	output [31:0] y
);
	assign y = a + b;
endmodule

module signext_16_32 (
	input [15:0] src,
	output [31:0] out
);
	assign out = { {16{src[15]}}, src };
endmodule


module zeroext_16_32 (
	input [15:0] src,
	output [31:0] out
);  // This is the zero-extended function module HIGHLIGHTED!!!
	assign out = {16'b0000_0000_0000_0000, src};
endmodule

module sll_2 (
	input [31:0] a,
	output [31:0] y
);
	assign y ={a[29:0], 2'b00};
endmodule


module sll_16 (
	input [15:0] src,
	output [31:0] out
);
	assign out= { src, 16'b0000_0000_0000_0000 };
endmodule


module equals (
	input [31:0] srcA, srcB,
	output eq
);
	assign eq = (srcA == srcB) ? 1 : 0;
endmodule

module equals_cache #(parameter TAG = 20)(
	input [31:0] srcA, srcB,
	output eq
);
	assign eq = (srcA == srcB) ? 1 : 0;
endmodule