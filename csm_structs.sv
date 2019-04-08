//ECE593 HW1

`include "csm_types.sv"

module csm(
	process_a_info_in,
	process_b_info_in,
	process_a_info_out,
	process_b_info_out,

	clk,
	reset
);


	input 		process_info_in 			process_a_info_in;
	input 		process_info_in 			process_b_info_in;
	output 		process_info_out 			process_a_info_out;
	output 		process_info_out 			process_b_info_out;



	logic [DATA_WIDTH - 1 : 0] registers [(1 << ADD_WIDTH) - 1 : 0];



endmodule
