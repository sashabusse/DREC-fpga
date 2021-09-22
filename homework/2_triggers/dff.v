`timescale 1ns/10ps

module dff(
	input wire d_i,
	input wire e_i,
	output wire q_o,
	output wire nq_o
);

d_latch d1(
	.d_i(d_i),
	.e_i(~e_i),
	.q_o(),
	.nq_o()
);

d_latch d2(
	.d_i(d1.q_o),
	.e_i(e_i),
	.q_o(q_o),
	.nq_o(nq_o)
);

endmodule