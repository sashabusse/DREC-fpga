`timescale 1ns/10ps

module d_latch(
	input wire d_i,
	input wire e_i,
	output wire q_o,
	output wire nq_o
);

sr_latch sr(
	.r_i((~d_i)&e_i),
	.s_i(d_i&e_i),
	.q_o(q_o),
	.nq_o(nq_o)
);

endmodule

