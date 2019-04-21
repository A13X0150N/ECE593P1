// CSM_bfm.sv

interface CSM_bfm
#(
    parameter DATABITS = 8,	// Data length
    parameter ERRBITS = 2	// Error signal length
);

///////////////////////////////////////
//         Interface Signals         //
///////////////////////////////////////
// A Inputs
bit [DATABITS-1:0] 	A_in_AD;
bit					A_rw;
bit					A_enable;
bit					A_hold;
bit					A_release;
// A Outputs
wire 				A_ack;
wire [ERRBITS-1:0]	A_err;
wire [DATABITS-1:0]	A_out_data;

// B Inputs
bit [DATABITS-1:0] 	B_in_AD;
bit					B_rw;
bit					B_enable;
bit					B_hold;
bit					B_release;
// B Outputs
wire 				B_ack;
wire [ERRBITS-1:0]	B_err;
wire [DATABITS-1:0]	B_out_data;

// For system general
bit					clk;
bit					reset_n;


///////////////////////////////////////
//          Bus Transactions         //
///////////////////////////////////////
// Reset device
task cmd_reset();
	reset_n = 1;
	@(posedge clk);
	reset_n = 0;
	repeat (10) @(posedge clk);
	reset_n = 1;
endtask : cmd_reset

// Processor A hold
task cmd_A_hold();
	do @(negedge clk);
	while (A_ack == 0);		// Wait for the bus to be free
	A_enable = 1;			// Proc A enable
	A_hold = 1;				// Proc A hold
	do @(negedge clk);
	while (A_ack == 0);		// Wait for the response
	A_enable = 0;			// Proc A disable
	A_hold = 0;
endtask : cmd_A_hold

// Processor A release
task cmd_A_release();
	do @(negedge clk);
	while (A_ack == 0);		// Wait for the bus to be free
	A_enable = 1;			// Proc A enable
	A_release = 1;			// Proc A release
	do @(negedge clk);
	while (A_ack == 0);		// Wait for the response
	A_enable = 0;			// Proc A disable
	A_release = 0;
endtask : cmd_A_release

// Processor A read
task cmd_A_read(bit [DATABITS-1:0] addr);
	A_enable = 1;			// Proc A enable
	A_rw = 0;				// Proc A read
	A_in_AD = addr;			// Put the address on the bus
	do @(negedge clk);
	while (A_ack == 0);		// Wait for the response
	A_enable = 0;			// Proc A disable
endtask : cmd_A_read

// Processor A write
task cmd_A_write(bit [DATABITS-1:0] addr, bit [DATABITS-1:0] data);
	do @(negedge clk);
	while (A_ack == 0);		// Wait for the bus to be free
	A_enable = 1;			// Proc A enable
	A_rw = 1;				// Proc A write
	A_in_AD = addr;			// Put the address on the bus
	@(posedge clk);			// Wait a cycle
	A_in_AD = data;			// Put the data on the bus
	@(negedge clk)			// Wait a half cycle
	A_enable = 0;			// Proc A disable
	A_rw = 0;				// Proc A read
endtask : cmd_A_write

// Processor B hold
task cmd_B_hold();
	do @(negedge clk);
	while (B_ack == 0);		// Wait for the bus to be free
	B_enable = 1;			// Proc B enable
	B_hold = 1;				// Proc B hold
	do @(negedge clk);
	while (B_ack == 0);		// Wait for the response
	B_enable = 0;			// Proc B disable
	B_hold = 0;
endtask : cmd_B_hold

// Processor B release
task cmd_B_release();
	do @(negedge clk);
	while (B_ack == 0);		// Wait for the bus to be free
	B_enable = 1;			// Proc B enable
	B_release = 1;			// Proc B release
	do @(negedge clk);
	while (B_ack == 0);		// Wait for the response
	B_enable = 0;			// Proc B disable
	B_release = 0;
endtask : cmd_B_release

// Processor B read
task cmd_B_read(bit [DATABITS-1:0] addr);
	B_enable = 1;			// Proc B enable
	B_rw = 0;				// Proc B read
	B_in_AD = addr;			// Put the address on the bus
	do @(negedge clk);
	while (B_ack == 0);		// Wait for the response/data
	B_enable = 0;			// Proc B disable
endtask : cmd_B_read


// Processor B write
task cmd_B_write(bit [DATABITS-1:0] addr, bit [DATABITS-1:0] data);
	do @(negedge clk);
	while (B_ack == 0);		// Wait for the bus to be free
	B_enable = 1;			// Proc B enable
	B_rw = 1;				// Proc B write
	B_in_AD = addr;			// Put the address on the bus
	@(posedge clk);			// Wait a cycle
	B_in_AD = data;			// Put the data on the bus
	@(negedge clk)			// Wait a half cycle
	B_enable = 0;			// Proc B disable
	B_rw = 0;				// Proc B read
endtask : cmd_B_write

// Processor A read and Processor B read
task cmd_A_read_B_read(bit [DATABITS-1:0] A_addr, bit [DATABITS-1:0] B_addr);
	A_enable = 1;			// Proc A enable
	B_enable = 1;			// Proc B enable
	A_rw = 0;				// Proc A read
	B_rw = 0;				// Proc B read
	A_in_AD = A_addr;		// Put address A on the bus
	B_in_AD = B_addr;		// Put address B on the bus
	do @(negedge clk);		// Wait for the data
	while ((A_ack == 0) && (B_ack == 0));
	A_enable = 0;			// Proc A disable
	B_enable = 0;			// Proc B disable
endtask : cmd_A_read_B_read

// Processor A read and Processor B write
task cmd_A_read_B_write(bit [DATABITS-1:0] A_addr,bit [DATABITS-1:0] B_addr, bit [DATABITS-1:0] data);
	do @(negedge clk);
	while (B_ack == 0);		// Wait for the bus to be free
	A_enable = 1;			// Proc A enable
	B_enable = 1;			// Proc B enable
	A_rw = 0;				// Proc A read
	B_rw = 1;				// Proc B write
	A_in_AD = A_addr;		// Put the A address on the bus
	B_in_AD = B_addr;		// Put the B address on the bus
	@(posedge clk);			// Wait a cycle
	B_in_AD = data;			// Put the write data on the proc B bus
	do @(negedge clk);
	while (A_ack == 0);		// Wait for the read data for proc A
	A_enable = 0;			// Proc A disable
	B_enable = 0;			// Proc B disable
	B_rw = 0;				// Proc B read
endtask : cmd_A_read_B_write

// Processor A write and Processor B read
task cmd_A_write_B_read(bit [DATABITS-1:0] A_addr,bit [DATABITS-1:0] B_addr, bit [DATABITS-1:0] data);
	do @(negedge clk);
	while (B_ack == 0);		// Wait for the bus to be free
	A_enable = 1;			// Proc A enable
	B_enable = 1;			// Proc B enable
	A_rw = 1;				// Proc A write
	B_rw = 0;				// Proc B read
	A_in_AD = A_addr;		// Put the A address on the bus
	B_in_AD = B_addr;		// Put the B address on the bus
	@(posedge clk);			// Wait a cycle
	A_in_AD = data;			// Put the write data on the proc A bus
	do @(negedge clk);
	while (A_ack == 0);		// Wait for the read data for proc B
	A_enable = 0;			// Proc A disable
	B_enable = 0;			// Proc B disable
	A_rw = 0;				// Proc B read
endtask : cmd_A_write_B_read

endinterface