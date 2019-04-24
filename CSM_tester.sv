module tester(CSM_bfm bfm);

	import csm_pkg::*;


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

task A_hold_B_Reads();
		fork
			bfm.send_op(A_Addr, A_Data, a_hold);
			bfm.send_op(B_Addr, B_Data, b_read);
		join
endtask

task A_reads_B_holds();
		fork
			bfm.send_op(B_Addr, B_Data, b_hold);
			bfm.send_op(A_Addr, A_Data, a_read);
		join
endtask

task A_hold_A_relase_B_Reads();
		bfm.send_op(A_Addr, A_Data, a_hold);
		bfm.send_op(A_Addr, A_Data, a_relse);
		bfm.send_op(B_Addr, B_Data, b_read);
endtask

task A_write_twice();
		bfm.send_op(A_Addr, A_Data, a_write);
		bfm.send_op(A_Addr, A_Data, a_write);
endtask

task A_writes_read_same_value();
		bfm.send_op(A_Addr, A_Data, a_write);
		bfm.send_op(A_Addr, A_Data, a_read);
endtask

task A_writes_B_writes();
		fork
			bfm.send_op(A_Addr, A_Data, a_write);
			bfm.send_op(B_Addr, B_Data, b_write);
		join
endtask

task A_holds_B_holds();
		fork
			bfm.send_op(A_Addr, A_Data, a_hold);
			bfm.send_op(B_Addr, B_Data, b_hold);
		join
endtask

task A_had_hold_B_holds();
		bfm.send_op(A_Addr, A_Data, a_hold);
		bfm.send_op(B_Addr, B_Data, b_hold);
endtask

task A_read_B_write();
	bfm.send_op(A_Addr, A_Data, a_read);
	bfm.send_op(B_Addr, B_Data, b_write);
endtask

task A_write_B_read();
	bfm.send_op(A_Addr, A_Data, a_write);
	bfm.send_op(B_Addr, B_Data, b_read);
endtask

task A_read_twice();
	bfm.send_op(A_Addr, A_Data, a_read);
	bfm.send_op(A_Addr, A_Data, a_read);
endtask
	
task A_read_B_read();
	bfm.send_op(A_Addr, A_Data, a_read);
	bfm.send_op(B_Addr, B_Data, b_read);
endtask

initial
begin : initial_part
	repeat (1000) begin: random_loop
		

		random_ops = $random;

		A_Addr = generate_addr();
		A_Data = generate_data();
		B_Addr = generate_addr();
		B_Data = generate_data();
		
		case(random_ops)
			4'b0000 : bfm.send_op(A_Addr, A_Data, a_read);
			4'b0001 : bfm.send_op(A_Addr, A_Data, a_write);
			4'b0010 : bfm.send_op(B_Addr, B_Data, b_write);
			4'b0011 : bfm.send_op(B_Addr, B_Data, b_read);
			4'b0100 : A_read_B_read();
			4'b0101 : A_read_B_write();
			4'b0110 : A_write_B_read();
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
					bfm.cmd_reset(); // never resets
		endcase
	end	: random_loop

end : initial_part

endmodule : tester

