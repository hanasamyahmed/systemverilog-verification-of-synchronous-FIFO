module top ();

	bit clk;
	
	initial begin
		clk=0;
		forever 
			#1 clk = ~clk;
	end

	
	FIFO_INTERFACE fif (clk);

	FIFO FIFO_DUT (fif);

	FIFO_tb FIFO_TB (fif);

	FIFO_MONITOR FIFO_MON (fif);

endmodule 