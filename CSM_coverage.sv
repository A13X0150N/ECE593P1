module coverage(CSM_bfm bfm);

	covergroup valid_ops;

	coverpoint bfm.op_set {
			bins a_read = {a_read};
			bins a_write = {write};
			bins hold = {hold};
			bins relse = {relse};
			bins read_after_read = {read => read};
			bins read_after_write = {write => read};
	}

   covergroup singals @(negedge bfm.clk);
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

	covergroup ops @(negedge bfm.clk);
		A_read: coverpoint { bfm.A_enable , bfm.A_rw , bfm.A_ack}{
			bins read = {'b100};
		}

		B_read: coverpoint { bfm.B_enable , bfm.B_rw , bfm.B_ack}{
			bins read = {'b100};
		}


		A_write: coverpoint { bfm.A_enable , bfm.A_rw , bfm.A_ack}{
			bins write = {'b110};
		}


		B_write: coverpoint { bfm.B_enable , bfm.B_rw , bfm.B_ack}{
			bins write = {'b110};
		}

		A_read_B_read: cross A_read, B_read;
		A_read_B_write: cross A_read,B_write;
		A_write_B_write: cross A_write, B_write;
	endgroup

	singals singals_cov = new;
	ops ops_cov = new;

endmodule