module coverage(CSM_bfm bfm);
	import csm_pkg::*;

	covergroup valid_ops @(posedge bfm.clk);

	a_operations : coverpoint bfm.op_set {
			bins a_read = {a_read};
			bins a_write = {a_write};
			bins a_hold = {a_hold};
			bins a_relse = {a_relse};
			}

	b_operations : coverpoint bfm.op_set {
			bins b_read = {b_read};
			bins b_write = {b_write};
			bins b_hold = {b_hold};
			bins b_relse = {b_relse};
			}

	consective_op : coverpoint bfm.op_set {
			bins a_read_twice = (a_read => a_read);
			bins a_write_a_read = (a_write => a_read);
			bins a_read_b_writes = (a_read => b_write);
			bins b_read_a_writes = (b_read => a_write);
			}

	cross a_operations, b_operations;

	endgroup


   covergroup singals @(posedge bfm.clk);
		A_rw : coverpoint bfm.A_rw {
			bins read = {'0};
			bins write = {'1};
			}

		B_rw : coverpoint bfm.B_rw {
			bins read = {'0};
			bins write = {'1};
			}

		A_ack :  coverpoint bfm.A_ack{
			bins no_ack = {'0};
			bins ack = {'1};
			}

		B_ack :  coverpoint bfm.B_ack{
			bins no_ack = {'0};
			bins ack = {'1};
			}

		A_enable : coverpoint bfm.A_enable{
			bins A_disable = {'0};
			bins A_enable = {'1};
			}

		B_enable : coverpoint bfm.B_enable{
			bins B_disable = {'0};
			bins B_enable = {'1};
			}

		A_hold : coverpoint bfm.A_hold;
		B_hold : coverpoint bfm.B_hold;

		A_B_hold : cross A_hold, B_hold;

		A_release : coverpoint bfm.A_release;
		B_release : coverpoint bfm.B_release;

		A_err : coverpoint bfm.A_err;
		B_err : coverpoint bfm.B_err;


		A_in_AD : coverpoint bfm.A_in_AD{
				bins address_data[4] = {[0:$]};
		}

		B_in_AD : coverpoint bfm.B_in_AD{
				bins address_data[4] = {[0:$]};
		}

		A_out_data : coverpoint bfm.A_out_data{
				bins dataout[4] = {[0:$]};
		}

		B_out_data : coverpoint bfm.B_out_data{
				bins dataout[4] = {[0:$]};
		}

	endgroup

	singals singals_cov = new();
	valid_ops ops_cov = new();

endmodule