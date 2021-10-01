`timescale 1ns/10ps

module spi_master_tb();

integer period = 10;

// clk generation
reg clk = 1'b0;
always
begin
	#(period/2);
	clk = ~clk;
end


// spi_master initialization
reg[7:0] spi_data;
reg spi_wr;

spi_master spi_mast_inst(
	.i_data(spi_data),
	.i_wr_en(spi_wr),
	.clk(clk),
	
	.o_rdy(),
	
	.o_CLK(),
	.o_MOSI()
);

// test spi_master
initial
begin
	spi_transmit_test(8'h01);
	spi_transmit_test(8'ha7);
	#(period*100);
	$stop;
end

//single transmission test
task spi_transmit_test(input[7:0] val);

begin
	// wait until empty
	@(spi_mast_inst.o_rdy == 1'b1);
	
	// write data
	@(negedge clk);
	spi_data = val;
	spi_wr = 1'b1;
	@(negedge clk);
	spi_wr = 1'b0;
	
end

endtask

endmodule