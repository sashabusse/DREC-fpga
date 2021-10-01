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
reg[7:0] spi_data = 8'b0;
reg		spi_wr = 1'b0;

spi_master master(
	.i_data(spi_data),
	.i_wr_en(spi_wr),
	.clk(spi_clk),
	
	.o_rdy(),
	
	.o_CLK(CLK),
	.o_MOSI(MOSI)
);

// slave instance config
reg spi_r_clr = 1'b0;
wire spi_slave_rdy;
wire[7:0] spi_slave_data;

spi_slave slave(
	.o_data(spi_slave_data),
	.i_r_en(spi_r_clr),
	.clk(spi_clk),
	
	.o_rdy(spi_slave_rdy),
	
	.i_CLK(CLK),
	.i_MOSI(MOSI)
);


// counter to transmit
reg[15:0] data_val = 16'b0;
reg[21:0] clk_cnt = 22'b0;

// transmission
always @(negedge spi_clk) begin
	clk_cnt <= clk_cnt + 22'b1;
	if(clk_cnt == {20{1'b1}}) begin
		data_val <= data_val + 16'b1;
		clk_cnt <= 22'b0;
	end
	
	// initiate first byte transmission
	if(clk_cnt == 22'b0) begin
		spi_data <= data_val[7:0];
		spi_wr <= 1'b1;
	end
	if(clk_cnt == 22'b1) begin
		spi_wr <= 1'b0;
	end
	
	// initiate second byte transmission
	if(clk_cnt == 22'd100) begin
		spi_data <= data_val[15:8];
		spi_wr <= 1'b1;
	end
	if(clk_cnt == 22'd101) begin
		spi_wr <= 1'b0;
	end
end

// receive data
reg[15:0] rx_data = 15'b0;
reg byte_cnt = 1'b0;

always @(negedge spi_clk)
begin
	if (spi_r_clr) begin
	spi_r_clr <= 1'b0;
	end
	
	if (spi_slave_rdy) begin
		if (~byte_cnt) begin
			rx_data[7:0] <= spi_slave_data;
		end
		else begin
			rx_data[15:8] <= spi_slave_data;
		end
		byte_cnt = ~byte_cnt;
		spi_r_clr <= 1'b1;
	end // if (slave.o_rdy)
end

// drive 7 segment indicator
reg[7:0] seg_data = 8'b0;
reg[3:0] seg_en = 4'b0111;

assign seg_data_pins = seg_data;
assign seg_en_pins = seg_en;

always @(posedge indicator_clk)
begin
	seg_en <= {seg_en[2:0], seg_en[3]};
	
	if(seg_en == 4'b0111) begin
		seg_data <= rx_data[7:0];
	end
	else if(seg_en == 4'b1110) begin
		seg_data <= rx_data[15:8];
	end
	else begin
		seg_data <= 8'b00111111;
	end
end

endmodule