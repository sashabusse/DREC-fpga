module top(
	input 		clk,
	output[7:0] seg_data_pins,
	output[3:0] seg_en_pins
);

// counter for divider
reg[31:0] div_cnt = 32'b0;
always @(posedge clk)
begin
	div_cnt <= div_cnt + 32'b1;
end

wire spi_clk;
assign spi_clk = div_cnt[2];

wire indicator_clk;
assign indicator_clk = div_cnt[17];

wire CLK;
wire MOSI;

// master instance config
reg[7:0] spi_tx_data = 8'b0;
reg		spi_tx_w = 1'b0;

spi_master master(
	.i_data(spi_tx_data),
	.i_wr_en(spi_tx_w),
	.clk(spi_clk),
	
	.o_rdy(),
	
	.o_CLK(CLK),
	.o_MOSI(MOSI)
);

// slave instance config
reg spi_rx_r = 1'b0;
wire spi_tx_rdy;
wire[7:0] spi_rx_data;

spi_slave slave(
	.o_data(spi_rx_data),
	.i_r_en(spi_rx_r),
	.clk(spi_clk),
	
	.o_rdy(spi_tx_rdy),
	
	.i_CLK(CLK),
	.i_MOSI(MOSI)
);

seven_seg indicator(
	.i_clk(indicator_clk),
	.i_data({{2{8'b00111111}}, rx_data}),
	
	.o_data(seg_data_pins),
	.o_en(seg_en_pins)
);


// counter to transmit
reg[15:0] tx_data = 16'b0;
reg[21:0] tx_clk_cnt = 22'b0;

// transmission
always @(negedge spi_clk) begin
	tx_clk_cnt <= tx_clk_cnt + 22'b1;
	if(tx_clk_cnt == {20{1'b1}}) begin
		tx_data <= tx_data + 16'b1;
		tx_clk_cnt <= 22'b0;
	end
	
	// initiate first byte transmission
	if(tx_clk_cnt == 22'b0) begin
		spi_tx_data <= tx_data[7:0];
		spi_tx_w <= 1'b1;
	end
	if(tx_clk_cnt == 22'b1) begin
		spi_tx_w <= 1'b0;
	end
	
	// initiate second byte transmission
	if(tx_clk_cnt == 22'd100) begin
		spi_tx_data <= tx_data[15:8];
		spi_tx_w <= 1'b1;
	end
	if(tx_clk_cnt == 22'd101) begin
		spi_tx_w <= 1'b0;
	end
end

// receive data
reg[15:0] rx_data = 15'b0;
reg rx_byte_cnt = 1'b0;

always @(negedge spi_clk)
begin
	if (spi_rx_r) begin
	spi_rx_r <= 1'b0;
	end
	
	if (spi_tx_rdy) begin
		if (~rx_byte_cnt) begin
			rx_data[7:0] <= spi_rx_data;
		end
		else begin
			rx_data[15:8] <= spi_rx_data;
		end
		rx_byte_cnt = ~rx_byte_cnt;
		spi_rx_r <= 1'b1;
	end // if (slave.o_rdy)
end

endmodule