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

task send_request(
input byte	A_in_Addr_t;
input byte	A_in_Data_t;
input bit	A_rw_t;
input bit	A_enable_t;
input bit	A_hold_t;
input bit	A_release_t;
//B
input byte	B_in_Addr_t;
input byte	B_in_Data_t;
input bit	B_rw_t;
input bit	B_enable_t;
input bit	B_hold_t;
input bit	B_release_t;
);

A_rw = A_rw_t;
A_enable = A_enable_t;
A_hold = A_hold_t;
A_release = A_release_t;

// Note: try to change data and address before 2 cycle 
// add reset operation
if(A_rw_t && A_enable_t) // Write operation
begin
	A_in_AD = A_in_Addr_t;
	@posedge(clk); // after one cycle
	A_in_AD = A_in_Data;
	// @posedge(clk); // Keep it 2 cycle
end
else if(!A_rw_t && A_enable_t) // read
begin
	A_in_AD = A_in_Addr_t;
	@posedge(clk); // keep it 2 cycle
	// @posedge(clk); // keep it 2 cycle
end

B_rw = B_rw_t;
B_enable = B_enable_t;
B_hold = B_hold_t;
B_release = B_release_t;

// intentionally, I did not checked ack signals here
// I also attempt to write read when ack signal is low ???????
if(B_rw_t && B_enable_t) // Write operation
begin
	B_in_AD = B_in_Addr_t;
	@posedge(clk); // after one cycle
	B_in_AD = B_in_Data;
	// @posedge(clk); // Keep it 2 cycle
end
else if(!B_rw_t && B_enable_t) // read
begin
	B_in_AD = B_in_Addr_t;
	@posedge(clk); // keep it 2 cycle
	// @posedge(clk); // keep it 2 cycle
end

endtask : send_op

endinterface

module tester(CSM_bfm bfm);

function byte generate_data();
	bit	[1:0]	probablity; // It can be 00, 01, 10 or 11
	probablity = $random;
	
	if(probablity == 2'b00)
		return 8'h00;
	else if(probablity == 2'b01)
		return	8'hFF;
	else
		return $random;
endfunction : generate_data

function byte generate_addr();
	byte		address;
	address = 	$random & 2'b11; // It can be 0,1,2,3
	return address
endfunction : generate_addr

function bit generate_rw(); // when we call this we need to check if Ack signal for that process is high or not also, if its read we need to check output
	return $random;
endfunction : generate_rw

function bit generate_enable(); // when we call this we need to check if Ack signal for that process is high or not
	return $random;
endfunction : generate_enable

function bit generate_hold(); // This part needs to change according to document (Hold sometimes needs to remain its status)
	return $random;
endfunction : generate_release

initial
begin : initial_part
	byte 	unsigned 	A_in_Addr;
	byte 	unsigned 	A_in_Data;
	bit					A_rw;
	bit					A_enable;
	bit					A_hold;
	bit					A_release;
	
	byte 	unsigned 	B_in_Addr;
	byte 	unsigned 	B_in_Data;
	bit					B_rw;
	bit					B_enable;
	bit					B_hold;
	bit					B_release;
	
	repeat (1000) begin: random_loop
		// Note for know probablity of %50 A wants to hold and probablity of %50 B wants to hold 
		// so probablity of 0.5*0.5 = 0.25 both try to hold at the same time however, holding same addresses is different
		// each generates 25% all 0 25% all 1 25 % random number
		// For processor A
		// Here we are generating data not address also we need to generate addr for each 8 registers
		
		bit	[1:0]	random_ops; // It can be 00, 01, 10 or 11
		random_ops = $random;
		
		// Write data A_EN = 1 && A_rw = 1
		if(random_ops == 2'b01) // do write
		begin
			A_in_Addr = generate_addr();
			A_in_Data = generate_data();
			A_rw = 1;
			A_enable = 1;
			A_hold = 0;
			A_release = 0;
		end
		else if(random_ops == 2'b10) // Do read
		begin
			A_in_Addr = generate_addr();
			A_in_Data = generate_data();
			A_rw = 0;
			A_enable = 1;
			A_hold = 0;
			A_release = 0;
		end
		else // Random operation includes non of read or write
		begin
			A_in_Addr = generate_addr();
			A_in_Data = generate_data();
			A_rw = generate_rw();
			A_enable = generate_enable();
			A_hold = generate_hold();
			A_release = generate_hold();
		end
		// We should write another exclusive condition for hold release operation
		
		// For B
		
				bit	[1:0]	random_ops; // It can be 00, 01, 10 or 11
		random_ops = $random;
		
		// Write data A_EN = 1 && A_rw = 1
		if(random_ops == 2'b01) // do write
		begin
			B_in_Addr = generate_addr();
			B_in_Data = generate_data();
			B_rw = 1;
			B_enable = 1;
			B_hold = 0;
			B_release = 0;
		end
		else if(random_ops == 2'b10) // Do read
		begin
			B_in_Addr = generate_addr();
			B_in_Data = generate_data();
			B_rw = 0;
			B_enable = 1;
			B_hold = 0;
			B_release = 0;
		end
		else // Random operation includes non of read or write
		begin
			B_in_Addr = generate_addr();
			B_in_Data = generate_data();
			B_rw = generate_rw();
			B_enable = generate_enable();
			B_hold = generate_hold();
			B_release = generate_hold();
		end
		bfm.send_request(
							A_in_Addr,
							A_in_Data,
							A_rw,
							A_enable,
							A_hold,
							A_release,
							//B
							B_in_Addr,
							B_in_Data,
							B_rw,
							B_enable,
							B_hold,
							B_release		
		);
	end	: random_loop

end : initial_part

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
