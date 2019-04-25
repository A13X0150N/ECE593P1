//////////////////////////////////////////////////////////////////////////
// 	CSM_coverage.sv
//	ECE 593 - Fundamentals of Pressilicon Validation
//	Alex Olson
//	Nurettin Can Orbegi
//	Matty Baba Allos
//	Assignment 1 - Packages
// 	----------------------------------------------------
// 	Description: Includes csm_pkg which is operation_t
//////////////////////////////////////////////////////////////////////////
package csm_pkg;
      typedef enum bit[3:0] {
                        a_read,
                        a_write,
                        a_hold,
                        a_relse,
                        b_read,
                        b_write,
                        b_hold,
                        b_relse,
                        rst} operation_t;
endpackage : csm_pkg