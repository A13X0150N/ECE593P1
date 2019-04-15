interface CSM_bfm;

// Interface For A
// inputs
byte 	unsigned 	A_in_AD;
bit					A_rw;
bit					A_enable;
bit					A_hold;
bit					A_release;
// Outputs
wire 				A_ack;
wire	[1:0]		A_err;
wire	[7:0]		A_out_data;

// Interface For B
// inputs
byte 	unsigned 	B_in_AD;
bit					B_rw;
bit					B_enable;
bit					B_hold;
bit					B_release;
// Outputs
wire 				B_ack;
wire	[1:0]		B_err;
wire	[7:0]		B_out_data;

// For system general
bit					clk;
bit					reset_n;
endinterface

module tester(CSM_bfm bfm);

function byte generate_addr();
	byte		address;
	bit	[1:0]	probablity; // It can be 00, 01, 10 or 11
	probablity = $random;
	
	if(probablity == 2'b00)
		return 8'h00;
	else if(probablity == 2'b01)
		return	8'hFF;
	else
		return $random;
endfunction : generate_addr

function bit generate_rw(); // when we call this we need to check if Ack signal for that process is high or not
	return $random;
endfunction : generate_rw

function bit generate_enable(); // when we call this we need to check if Ack signal for that process is high or not
	return $random;
endfunction : generate_enable

function bit generate_hold(); // when we call this we need to check if Ack signal and Err for that processor
	return $random;
endfunction : generate_release

initial
begin
	byte 	unsigned 	A_in_AD;
	bit					A_rw;
	bit					A_enable;
	bit					A_hold;
	bit					A_release;
	
	repeat (1000) begin: random_loop
		// Note for know probablity of %50 A wants to hold and probablity of %50 B wants to hold 
		// so probablity of 0.5*0.5 = 0.25 both try to hold at the same time however, holding same addresses is different
		// each generates 25% all 0 25% all 1 25 % random number
		// For processor A
		A_in_AD = generate_addr();
		if(bfm.A_ack)
			A_rw = generate_rw();
		else
			A_rw = 1'b0; // However test it try to make high even though A_ack is low
		A_enable = generate_enable();
		A_hold = generate_hold();
		A_release = generate_release();
		// For processor B;
		B_in_AD = generate_addr();
		if(bfm.B_ack)
			B_rw = generate_rw();
		else
			B_rw = 1'b0; // However test it try to make high even though A_ack is low
		B_enable = generate_enable();
		B_hold = generate_hold();
		B_release = generate_release();
	end	: random_loop

end

endmodule : tester

// CSM_tb.sv

module CSM_tb;

initial $display("\n\n\t***** Starting CSM_tb top level *****\n");

CSM_bfm bfm();
tester		tester_i	(bfm);
//coverage	coverage_i	(bfm);
//scoreboard	scoreboard_i(bfm);

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
