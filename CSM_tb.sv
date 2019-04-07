// CSM_tb.sv

module CSM_tb;

initial $display("\n\n\t***** Starting CSM_tb top level *****\n");

// DUT signals
logic [7:0] A_in_AD, B_in_AD,
            A_out_data, B_out_data;
logic [1:0] A_err, B_err;       
logic       A_rw, A_enable, A_hold, A_release,
            B_rw, B_enable, B_hold, B_release,
            clk, reset_n, A_ack, B_ack;

CSM dut(.*);


initial $display("\n\t***** Ending CSM_tb top level *****\n\n\n");

endmodule
