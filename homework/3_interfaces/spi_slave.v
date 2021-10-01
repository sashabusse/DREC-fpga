module spi_slave(
	// interface inputs
	output[7:0] o_data,
	input 		i_r_en,
	input 		clk,
	
	// interface outputs
	output 		o_rdy,
	
	// SPI pins to drive
	input 		i_CLK,
	input 		i_MOSI
);

// module interface registers
reg[7:0]	r_rx_data = 8'b0;
reg		r_rdy = 1'b0;

// module implementation registers
reg[7:0] r_rx_data_shift;
reg		r_shift_rdy = 1'b0;
reg[1:0]	r_rdy_detect = 2'b0;
reg[2:0] bits_received = 3'b0;

// receive data from MOSI in SPI clock domain
always @(posedge i_CLK)
begin
	r_rx_data_shift <= {r_rx_data_shift[6:0], i_MOSI};
	bits_received <= bits_received + 3'b1;
	
	// on the reception end
	if(bits_received == 3'b111) begin
		r_rx_data <= {r_rx_data_shift[6:0], i_MOSI};
		r_shift_rdy <= 1'b1;
	end
	else begin
		r_shift_rdy <= 1'b0;
	end
end

// set r_rdy in clk clock domain
always @(posedge clk)
begin
	r_rdy_detect <= {r_rdy_detect[0], r_shift_rdy};
	
	// detected posedge
	if(r_rdy_detect[1] == 1'b0 && r_rdy_detect[0] == 1'b1) begin
		r_rdy <= 1'b1;
	end
	
	// clear bit only if it is not set again
	else begin
		if (i_r_en) begin
			r_rdy = 1'b0;
		end
	end
end

assign o_rdy = r_rdy;
assign o_data = r_rx_data;

endmodule