//////////////////////////////////////////////////////////////////////////
//  CSM_bfm.sv
//  ECE 593 - Fundamentals of Pre-Silicon Validation
//  Alex Olson
//  Can Orbegi
//  Matty Baba Allos
//  Assignment 2 - CSM Design
//  ----------------------------------------------------------------------
//  Description: Interface for processor A and processor B signals interacting with the design.
//               The signals in the interface are transaction-based using these tasks:
//
//
//      CSM_bfm bfm();                                          For this example, use an instance called "bfm"
//
//
//      bfm.cmd_reset();                                        Send a a reset signal into the device
//
//      bfm.cmd_A_hold();                                       Send a hold signal for processor A
//
//      bfm.cmd_A_release();                                    Send a release signal for processor A
//
//      bfm.cmd_A_read(address_A);                              Send a read command and address on first cycle
//                                                              Data is returned to A_in_AD on the subsequent cycle
//
//      bfm.cmd_A_write(address_A, data_A);                     Send a write command and address on first cycle
//                                                              Data is written to  A_in_AD on the subsequent cycle
//
//      bfm.cmd_B_hold();                                       Send a hold signal for processor B
//
//      bfm.cmd_B_release();                                    Send a release signal for processor B
//
//      bfm.cmd_B_read(address_B);                              Send a read command and address on first cycle
//                                                              Data is returned to B_in_AD on the subsequent cycle
//
//      bfm.cmd_B_write(address_B, data_B);                     Send a write command and address on first cycle
//                                                              Data is written to  B_in_AD on the subsequent cycle
//
//      bfm.cmd_A_read_B_read(address_A, address_B);            Send a read command and addresses on first cycle
//                                                              Data is returned to A_in_AD and B_in_AD on the subsequent cycle
//
//      bfm.cmd_A_read_B_write(address_A, address_B, data_B);   Send read/write commands and addresses on first cycle
//                                                              Data is written to B_in_AD amd returned to A_in_BD on subsequent cycle
//
//      bfm.cmd_A_write_B_read(address_A, address_B, data_A);   Send read/write commands and addresses on first cycle
//                                                              Data is written to A_in_AD amd returned to B_in_BD on subsequent cycle
//
//
//////////////////////////////////////////////////////////////////////////

interface CSM_bfm
#(
    parameter DATABITS = 8,      // Data length
    parameter ERRBITS = 2        // Error signal length
);

    import csm_pkg::*;


///////////////////////////////////////
//         Interface Signals         //
///////////////////////////////////////
// A Inputs
bit [DATABITS-1:0]  A_in_AD;
bit                 A_rw;
bit                 A_enable;
bit                 A_hold;
bit                 A_release;
// A Outputs
wire                A_ack;
wire [ERRBITS-1:0]  A_err;
wire [DATABITS-1:0] A_out_data;

// B Inputs
bit [DATABITS-1:0]  B_in_AD;
bit                 B_rw;
bit                 B_enable;
bit                 B_hold;
bit                 B_release;
// B Outputs
wire                B_ack;
wire [ERRBITS-1:0]  B_err;
wire [DATABITS-1:0] B_out_data;

// For system general
bit                 clk;
bit                 reset_n;

operation_t  op_set;

///////////////////////////////////////
//          Bus Transactions         //
///////////////////////////////////////

task send_op(input byte addr, input byte data, input operation_t iop);
    op_set = iop;

     case (iop)
            a_read   : cmd_A_read(addr);
            a_write  : cmd_A_write(addr,data);
            a_hold   : cmd_A_hold();
            a_relse  : cmd_B_release();
            b_read   : cmd_B_read(addr);
            b_write  : cmd_B_write(addr,data);
            b_hold   : cmd_B_hold();
            b_relse  : cmd_B_release();
      endcase // case (op_choice)
endtask

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
    while (A_ack == 0);     // Wait for the bus to be free
    A_hold = 1;             // Proc A hold
    A_enable = 1;           // Proc A enable
    do @(negedge clk);
    while (A_ack == 0);     // Wait for the response
    A_enable = 0;           // Proc A disable
    A_hold = 0;
endtask : cmd_A_hold

// Processor A release
task cmd_A_release();
    do @(negedge clk);
    while (A_ack == 0);     // Wait for the bus to be free
    A_release = 1;          // Proc A release
    A_enable = 1;           // Proc A enable
    do @(negedge clk);
    while (A_ack == 0);     // Wait for the response
    A_enable = 0;           // Proc A disable
    A_release = 0;
endtask : cmd_A_release

// Processor A read
task cmd_A_read(bit [DATABITS-1:0] addr);
    do @(negedge clk);
    while (A_ack == 0);     // Wait for the response
    A_rw = 0;               // Proc A read
    A_in_AD = addr;         // Put the address on the bus
    A_enable = 1;           // Proc A enable
    #2;
    A_enable = 0;           // Proc A disable
endtask : cmd_A_read

// Processor A write
task cmd_A_write(bit [DATABITS-1:0] addr, bit [DATABITS-1:0] data);
    do @(negedge clk);
    while (A_ack == 0);     // Wait for the bus to be free
    A_rw = 1;               // Proc A write
    A_in_AD = addr;         // Put the address on the bus
    A_enable = 1;           // Proc A enable
    @(posedge clk);         // Wait a cycle
    A_in_AD = data;         // Put the data on the bus
    @(negedge clk)          // Wait a half cycle
    A_enable = 0;           // Proc A disable
    A_rw = 0;               // Proc A read
endtask : cmd_A_write

// Processor B hold
task cmd_B_hold();
    do @(negedge clk);
    while (B_ack == 0);     // Wait for the bus to be free
    B_hold = 1;             // Proc B hold
    B_enable = 1;           // Proc B enable
    do @(negedge clk);
    while (B_ack == 0);     // Wait for the response
    B_enable = 0;           // Proc B disable
    B_hold = 0;
endtask : cmd_B_hold

// Processor B release
task cmd_B_release();
    do @(negedge clk);
    while (B_ack == 0);     // Wait for the bus to be free
    B_release = 1;          // Proc B release
    B_enable = 1;           // Proc B enable
    do @(negedge clk);
    while (B_ack == 0);     // Wait for the response
    B_enable = 0;           // Proc B disable
    B_release = 0;
endtask : cmd_B_release

// Processor B read
task cmd_B_read(bit [DATABITS-1:0] addr);
    do @(negedge clk);
    while (B_ack == 0);     // Wait for the response/data
    B_rw = 0;               // Proc B read
    B_in_AD = addr;         // Put the address on the bus
    B_enable = 1;           // Proc B enable
    #2;
    B_enable = 0;           // Proc B disable
endtask : cmd_B_read


// Processor B write
task cmd_B_write(bit [DATABITS-1:0] addr, bit [DATABITS-1:0] data);
    do @(negedge clk);
    while (B_ack == 0);     // Wait for the bus to be free
    B_rw = 1;               // Proc B write
    B_in_AD = addr;         // Put the address on the bus
    B_enable = 1;           // Proc B enable
    @(posedge clk);         // Wait a cycle
    B_in_AD = data;         // Put the data on the bus
    @(negedge clk)          // Wait a half cycle
    B_enable = 0;           // Proc B disable
    B_rw = 0;               // Proc B read
endtask : cmd_B_write

endinterface : CSM_bfm