package csm_pkg;
      typedef enum bit[2:0] {
                        a_read,
                        a_write,
                        a_hold,
                        a_relse,
                        b_read,
                        b_write,
                        b_hold,
                        b_relse,
                        reset} operation_t;
endpackage : csm_pkg