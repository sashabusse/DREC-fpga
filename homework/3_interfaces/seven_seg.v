module seven_seg( 
	input[7:0] data_i,
	input[SEG_CNT-1:0] wr_en_i,
	input clk,
	
	output reg[7:0] seg_data_o,
	output reg[SEG_CNT-1:0] seg_en_o
);

parameter SEG_CNT = 4;

always @(posedge clk)
begin
	seg_en_o <= wr_en_i;
	seg_data_o <= data_i;
end

endmodule