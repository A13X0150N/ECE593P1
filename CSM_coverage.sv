module coverage(CSM_bfm bfm);

   covergroup ops;
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
			bins A_disable = {'0};
			bins A_enable = {'1};
			}

		A_err : coverpoint bfm.A_err;
		B_err : coverpoint bfm.B_err;

		// A_ops : cross A_rw, A_enable, A_ack{
		// 	bin read = {A_rw.read, A_enable.A_enable,A_ack.no_ack};
		// }

	endgroup
endmodule