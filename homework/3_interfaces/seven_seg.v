module seven_seg( 
	input 		i_clk,
	input[31:0]	i_data,
	
	output[7:0] o_data,
	output[3:0] o_en
);

reg[3:0] r_en = 4'b0111;
assign o_en = r_en;

reg[7:0] r_data = 8'b0;
assign o_data = r_data;

always @(posedge i_clk)
begin
	r_en <= {r_en[2:0], r_en[3]};
	
	case (r_en)
		4'b0111: r_data <= i_data[7:0];
		4'b1110: r_data <= i_data[15:8];
		4'b1101: r_data <= i_data[23:16];
		4'b1011: r_data <= i_data[31:24];
	endcase
end

endmodule