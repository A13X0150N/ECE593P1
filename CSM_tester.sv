module tester(CSM_bfm bfm);

	byte 	unsigned 	A_Addr;
	byte 	unsigned 	A_Data;
	byte 	unsigned 	B_Addr;
	byte 	unsigned 	B_Data;
	bit		[3:0]		random_ops;


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
	return address;
endfunction : generate_addr

// task send_and_wait();
// 		fork
// 		bfm.cmd_A_read(addr);
// 		bfm.wait(A)

// end



task A_hold_B_Reads();
		fork
			bfm.cmd_A_hold();
			bfm.cmd_B_read(B_Addr);
		join
endtask

task A_reads_B_holds();
		fork
			bfm.cmd_B_hold();
			bfm.cmd_A_read(A_Addr);
		join
endtask

task A_hold_A_relase_B_Reads();
		bfm.cmd_A_hold();
		bfm.cmd_A_release();
		bfm.cmd_B_read(B_Addr);
endtask

task A_write_twice();
		bfm.cmd_A_write(A_Addr,A_Data);
		bfm.cmd_A_write(A_Addr,A_Data);
endtask

task A_writes_read_same_value();
		bfm.cmd_A_write(A_Addr,A_Data);
		bfm.cmd_A_read(A_Addr);
endtask

task A_writes_B_writes();
		fork
			bfm.cmd_A_write(A_Addr,A_Data);
			bfm.cmd_B_write(B_Addr,B_Data);
		join
endtask

task A_holds_B_holds();
		fork
			bfm.cmd_A_hold();
			bfm.cmd_B_hold();
		join
endtask

task A_had_hold_B_holds();
		bfm.cmd_A_hold();
		bfm.cmd_B_hold();
endtask

initial
begin : initial_part
	repeat (1000) begin: random_loop
		// Note for know probablity of %50 A wants to hold and probablity of %50 B wants to hold
		// so probablity of 0.5*0.5 = 0.25 both try to hold at the same time however, holding same addresses is different
		// each generates 25% all 0 25% all 1 25 % random number
		// For processor A
		// Here we are generating data not address also we need to generate addr for each 8 registers

		random_ops = $random;

		A_Addr = generate_addr();
		A_Data = generate_data();
		B_Addr = generate_addr();
		B_Data = generate_data();

		case(random_ops)
			4'b0000 : bfm.cmd_A_write(A_Addr,A_Data);
			4'b0001 : bfm.cmd_A_read(A_Addr);
			4'b0010 : bfm.cmd_B_write(B_Addr,B_Data);
			4'b0011 : bfm.cmd_B_read(B_Addr);
			4'b0100 : bfm.cmd_A_read_B_read(A_Addr,B_Addr);
			4'b0101 : bfm.cmd_A_read_B_write(A_Addr,B_Addr,B_Data);
			4'b0110 : bfm.cmd_A_write_B_read(A_Addr,B_Addr,A_Data);
			4'b0111 : A_hold_B_Reads(); //We should see an error
			4'b1000 : A_reads_B_holds(); //We should see an error
			4'b1001 : A_hold_A_relase_B_Reads();
			4'b1010 : A_read_twice();
			4'b1011 : A_write_twice();
			4'b1100 : A_writes_read_same_value();
			4'b1101 : A_writes_B_writes();
			4'b1110 : A_holds_B_holds();
			4'b1111 : A_had_hold_B_holds();
			default:
					bfm.cmd_reset();
		endcase
	end	: random_loop

end : initial_part

endmodule : tester

