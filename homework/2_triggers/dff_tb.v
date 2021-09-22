`timescale 1ns/10ps

module dff_tb;

reg d;
reg e;
wire q;
wire nq;

dff dff_inst(
	.d_i(d),
	.e_i(e),
	.q_o(q),
	.nq_o(nq)
);


initial
    begin
		$dumpvars;
		
		e = 1'b0;
		d = 1'b1;
		#(1);
		e = 1'b1;
		#(1)
		e = 1'b0;
		#(1);
		$display(q);
		
		
		d = 1'b0;
		#(1);
		e = 1'b1;
		#(1)
		e = 1'b0;
		#(1);
		$display(q);
		
        $finish ;
	end


task test_dff();
	
	
	
	begin
	end
	

endtask


endmodule
