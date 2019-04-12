What we should test

	Valid operations
	- A reads
	- B reads
	- A and B reads (Dual Read)
	- Read and writes
    	- A reads B writes
    	- A writes B reads
        	* If a write request is made before a read of the same register, 
			the read should receive the value written to the register. 
			This applies regardless to which process side (A or B) makes the read and write requests.
		* If a read and write to the same register occurs at the same time (e.g. from different sides),
			the old value of the register is returned to the requesting reader

	- A hold B revoked
  	- A revoked B hold

	Concurrent ops
	- A write twice
	- B Write twice
	- A Reads twice
	- Hold followed by a release


  	Data
	- write value and then read it the same
	- read the same value twice


	Invalid operations
		-A writes B writes ==> Dual write error
		-A holds B holds ==> Dual hold
		-A has hold B requests hold ==> B hold revoked
