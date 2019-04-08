
parameter int ADDR_WIDTH 		= 			3;
parameter int DATA_WIDTH 		= 			5;
parameter int ERROR_WIDTH 		= 			3;

typedef struct packed {
	logic [ADDR_LEGTH -1 : 0 ] 					addr;
	logic [DATA_WIDTH -1: 0] 					data;
	logic 										rw;
	logic 										en;
	logic 										hold;
	logic 										relase;
} process_info_in;


typedef struct packed {
	logic [DATA_WIDTH -1: 0] 					data;
	logic 										ack;
	logic [ERROR_WIDTH -1: 0] 					err;
} process_info_out;