`timescale 1ns/10ps

module dff_tb;

realtime period = 10;

reg d;
reg clk;
wire q;
wire nq;

dff dff_inst(
	.d_i(d),
	.e_i(clk),
	.q_o(q),
	.nq_o(nq)
);

// variable initalization
initial begin
	d <= 1'b0;
	clk <= 1'b0;
end

// clk generation
always #(period/2) clk <= ~clk;

// test dff here
initial
    begin
		$dumpvars;
		
		write_dff(1'b1);
		write_dff(1'b0);
		write_dff(1'b1);
		write_dff(1'b0);
		write_dff(1'b1);
		write_dff(1'b0);
		write_dff(1'b1);
		
        $finish ;
	end

// simple task to write d value on negedge of clk
task write_dff(input val);
	begin
		@(negedge clk);
		d = val;
	end
endtask


endmodule
