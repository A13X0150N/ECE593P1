//////////////////////////////////////////////////////////////////////////
// 	CSM.sv
//	ECE 593 - Fundamentals of Pressilicon Validation
//	Alex Olson
//	Can Orbegi
//	Matty Baba Allos
//	Assignment 1 - CSM Design
// 	----------------------------------------------------
// 	Description: Critical section manager has 8 different 8-bit registers
//	Each register can be edited by one of two processors.  Processors
//  concurrently read and write registers. Processors can lock
//	one register to use exclusively. That time second processor cannot
//	use locked register.
//////////////////////////////////////////////////////////////////////////
module CSM
#(
    parameter DATABITS = 8,	// Data lenght
    parameter MEMSIZE = 8	// Indicates How many register CSM has
)
(
    input logic  [DATABITS-1:0] A_in_AD, B_in_AD, 	// Address and data inputs
    input logic  A_rw, A_enable, A_hold, A_release,	// read/write, Enable, hold and release inputs for each processor 
                 B_rw, B_enable, B_hold, B_release,
                 clk, reset_n,						// General system inputs
    output logic [DATABITS-1:0] A_out_data='0, B_out_data='0,	// Data outputs normally 0
    output logic [1:0] A_err='0, B_err='0,			// Error outputs
    output logic A_ack=0, B_ack=0					// Acknowledgment signals if no error ack signals = 1
);

// Error codes
// 00 -> NO_ERROR: 	There is no error
// 01 -> IN_USE:	owned by other processor
// 10 -> DUAL_WRITE:Concurrent write
// 11 -> DUAL_HOLD:	Concurrent hold
enum bit [1:0] { NO_ERROR, IN_USE, DUAL_WRITE, DUAL_HOLD } ERROR_CODES;

// Memory states
typedef enum logic [2:0] {  IDLE, 
                            A_READ, A_WRITE, 
                            B_READ, B_WRITE,
                            A_READ_B_WRITE, A_WRITE_B_READ, 
                            DUAL_READ } memory_states;

memory_states current_state = IDLE; 
memory_states next_state = IDLE;

localparam MEMBITS = $clog2(MEMSIZE);

// Register table with 8-bits of data and 8 total registers
logic [DATABITS-1:0] mem [MEMSIZE];

// Delayed signals for output reference
logic [DATABITS-1:0] A_in_delay, B_in_delay;


// Delay the signals by one clock cycle
always_ff @(posedge clk or negedge reset_n) begin
	
    if (~reset_n) begin : GAR_delay_signals
        A_in_delay <= '0;
        B_in_delay <= '0;
    end : GAR_delay_signals

    else begin : delay_signals
        A_in_delay <= A_in_AD;
        B_in_delay <= B_in_AD;
    end : delay_signals

end


// Drive the state machine
always_ff @(posedge clk or negedge reset_n) begin : state_transition
    current_state <= reset_n ? next_state : IDLE;
end : state_transition


// Next state and memory logic
always_comb begin : memory_logic
    unique case (current_state)	
       IDLE: begin
            // Simultaneous reading and writing
            if ((A_enable & B_enable) && (A_err == NO_ERROR) && (B_err == NO_ERROR)) begin
                if (A_rw & ~B_rw) begin
                    next_state = A_WRITE_B_READ;
                end
                else if (~A_rw & B_rw) begin
                    next_state = A_READ_B_WRITE;
                end
                else begin
                    next_state = DUAL_READ;
                end
            end

            // Only processor A is reading/writing
            else if (A_enable && (A_err == NO_ERROR)) begin
                next_state = A_rw ? A_WRITE : A_READ;
            end

            // Only processor B is reading/writing
            else if (B_enable && (B_err == NO_ERROR)) begin
                next_state = B_rw ? B_WRITE : B_READ;
            end

            // Neither processor is requesting to read/write
            else begin
                next_state = IDLE;
            end
        end

        A_READ: begin 
            A_out_data = mem[A_in_delay[MEMBITS-1:0]];
            next_state = IDLE;
        end

        A_WRITE: begin 
            mem[A_in_delay[MEMBITS-1:0]] = A_in_AD;
            next_state = IDLE;
        end

        B_READ: begin 
            B_out_data = mem[B_in_delay[MEMBITS-1:0]];
            next_state = IDLE;
        end

        B_WRITE: begin 
            mem[B_in_delay[MEMBITS-1:0]] = B_in_AD;
            next_state = IDLE;
        end

        A_READ_B_WRITE: begin 
            A_out_data = mem[A_in_delay[MEMBITS-1:0]];	// Read before write
            mem[B_in_delay[MEMBITS-1:0]] = B_in_AD;
            next_state = IDLE;
        end

        A_WRITE_B_READ: begin 
            B_out_data = mem[B_in_delay[MEMBITS-1:0]];	// Read before write
            mem[A_in_delay[MEMBITS-1:0]] = A_in_AD;
            next_state = IDLE;
        end

        DUAL_READ: begin 
            A_out_data = mem[A_in_delay[MEMBITS-1:0]];
            B_out_data = mem[B_in_delay[MEMBITS-1:0]];
            next_state = IDLE;
        end
    endcase
end : memory_logic


// Error Output Logic
always_comb begin : error_output
	
    if (A_rw & B_rw) begin : simultaneous_write
        A_err = DUAL_WRITE;
        B_err = DUAL_WRITE;
        A_ack = 0;
        B_ack = 0;
    end : simultaneous_write

    else if (A_hold | B_hold) begin : hold_errors
        if (A_hold & B_hold) begin
            A_err = DUAL_HOLD;
            B_err = DUAL_HOLD;
            A_ack = 0;
            B_ack = 0;
        end
        else if (A_hold) begin
            A_err = NO_ERROR;
            B_err = IN_USE;
            A_ack = 1;
            B_ack = 0;
        end
        else begin
            A_err = IN_USE;
            B_err = NO_ERROR;
            A_ack = 0;
            B_ack = 1;
        end
    end : hold_errors

    else if (A_release | B_release) begin : release_errors
        A_err = ~B_release;
        B_err = ~A_release;
        A_ack = B_release;
        B_ack = A_release;
    end : release_errors

    else begin : no_errors
        A_err = NO_ERROR;
        B_err = NO_ERROR;
        A_ack = 1;
        B_ack = 1;
    end : no_errors
end : error_output

endmodule
