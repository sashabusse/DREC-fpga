`timescale 1ns/10ps

module sr_latch(
	input wire r_i,
	input wire s_i,
	output wire q_o,
	output wire nq_o
);

assign q_o = ~(nq_o | r_i);
assign nq_o = ~(q_o | s_i);

endmodule