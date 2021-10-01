`timescale 1ns/10ps

module spi_transmission_tb();

realtime period = 10;
reg clk = 1'b0;
always
begin
	#(period/2);
	clk = ~clk;
end

// master instance config
reg[7:0] spi_tx_data = 8'ha3;
reg 		spi_tx_wr = 1'b0;

spi_master master(
	.i_data(spi_tx_data),
	.i_wr_en(spi_tx_wr),
	.clk(clk),
	
	.o_rdy(),
	
	.o_CLK(),
	.o_MOSI()
);

// slave instance config
reg spi_rx_en = 1'b0;

spi_slave slave(
	.o_data(),
	.i_r_en(spi_rx_en),
	.clk(clk),
	
	.o_rdy(),
	
	.i_CLK(master.o_CLK),
	.i_MOSI(master.o_MOSI)
);

//single master transmission
task spi_transmit_test(input[7:0] val);
begin
	// wait until empty
	@(master.o_rdy == 1'b1);
	
	// write data
	@(negedge clk);
	spi_tx_data = val;
	spi_tx_wr = 1'b1;
	@(negedge clk);
	spi_tx_wr = 1'b0;
	
end
endtask

initial begin
	spi_transmit_test(8'h17);
	spi_transmit_test(8'he2);
	#(1000);
	$stop;
end

endmodule