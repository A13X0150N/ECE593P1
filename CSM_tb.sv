// CSM_tb.sv

module CSM_tb;

initial $display("\n\n\t***** Starting CSM_tb top level *****\n");


CSM_bfm 	bfm();
tester		tester_i	(bfm);
coverage	coverage_i	(bfm);
//scoreboard	scoreboard_i(bfm);

// DUT signals
//logic [7:0] A_in_AD, B_in_AD,
//            A_out_data, B_out_data;
//logic [1:0] A_err, B_err;
//logic       A_rw, A_enable, A_hold, A_release,
//            B_rw, B_enable, B_hold, B_release,
//            clk, reset_n, A_ack, B_ack;

always begin
	#1 bfm.clk = ~bfm.clk;
end


CSM dut(.A_in_AD(bfm.A_in_AD), .B_in_AD(bfm.B_in_AD), .A_out_data(bfm.A_out_data), .B_out_data(bfm.B_out_data),
	    .A_err(bfm.A_err), .B_err(bfm.B_err), .A_rw(bfm.A_rw), .A_enable(bfm.A_enable), .A_hold(bfm.A_hold),
	    .A_release(bfm.A_release), .B_rw(bfm.B_rw), .B_enable(bfm.B_enable), .B_hold(bfm.B_hold), .B_release(bfm.B_release),
	    .A_ack(bfm.A_ack), .B_ack(bfm.B_ack), .clk(bfm.clk), .reset_n(bfm.reset_n));




initial $display("\n\t***** Ending CSM_tb top level *****\n\n\n");

endmodule
