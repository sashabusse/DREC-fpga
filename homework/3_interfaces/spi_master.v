
/**
* brief: implements CPOL=0 CPHA=0 spi master MSB
*/
module spi_master(
	// interface inputs
	input[7:0] i_data,
	input i_wr_en,
	input clk,
	
	// interface outputs
	output o_rdy,
	
	// SPI pins to drive
	output o_CLK,
	output o_MOSI
);

// internal state/data registers
reg 		r_rdy = 1'b1;
reg[7:0] r_tx_data = 8'b0;

// implementation used registers
reg[3:0] tx_bits_done = 4'b1000;
reg 		clk_cnt = 1'b0;

// register to drive SPI pins
reg r_CLK = 1'b0; //CPOL=0
reg r_MOSI = 1'b0;

//count clk steps
//	- clk_cnt == 0 step 1
//	- clk_cnt == 1 step 2
always @(posedge clk)
begin
	if (~tx_bits_done[3]) begin	
		clk_cnt <= ~clk_cnt;
	end
end

// drive CLK
always @(posedge clk)
begin
	// transmission going on
	if(~tx_bits_done[3]) begin
		r_CLK <= clk_cnt;
	end
	
	// idle. just pull the line down for the last time
	else begin
		if (r_CLK) begin
			r_CLK <= 1'b0;
		end
	end
	
end

// operate data register
// drive rdy flag
// update tx_bits_done
always @(posedge clk)
begin
	// ready to read new byte
	if (r_rdy && i_wr_en) begin
		r_tx_data <= i_data;
		r_rdy <= 1'b0;
		tx_bits_done <= 4'b0;
	end
	
	// transmission going
	// 	- shift 1 bit
	//		- set rdy on last bit
	else begin
		if (~clk_cnt) begin
			r_tx_data <= r_tx_data << 1; // should I give bitness of 1?
			// last bit gone for transmission rdy for next byte
			if(tx_bits_done == 4'b0111) begin
				r_rdy <= 1'b1;
			end
		end
		else begin
			tx_bits_done <= tx_bits_done + 4'b1;
		end
	end
	
end

// drive MOSI
always @(posedge clk)
begin
	if (~tx_bits_done[3]) begin
		
		// on first clock:
		// 	- set MOSI
		if (~clk_cnt) begin
			r_MOSI <= r_tx_data[7]; // MSB order
		end
		
		// on the second clock:
		//		- read operation (not implemented for master)
		else begin
		end
	end 
	else begin // if (~tx_bits_done[3])
		if(r_MOSI) begin // is ite equivalent to r_MOSI <= 0;
			r_MOSI <= 0;
		end
	end
	
end


assign o_rdy = r_rdy;

assign o_CLK = r_CLK;
assign o_MOSI = r_MOSI;

endmodule

