import shared_pkg::*;
import FIFO_transaction::*;
import FIFO_coverage::*;
import FIFO_scoreboard::*;


module FIFO_tb (FIFO_INTERFACE.TEST fif);

	FIFO_transaction trans_obj_tb = new();
	initial begin
		 
		 fif.rst_n=0; fif.rd_en=0; fif.wr_en=0; fif.data_in=0;
		 @(negedge fif.clk);
		 fif.rst_n=1;
		 @(negedge fif.clk);

		 
		 repeat(10_000) begin
		 	assert(trans_obj_tb.randomize());
		 	fif.rst_n=trans_obj_tb.rst_n;
		 	fif.rd_en=trans_obj_tb.rd_en;
		 	fif.wr_en=trans_obj_tb.wr_en;
		 	fif.data_in=trans_obj_tb.data_in;
		 	@(negedge fif.clk);
		 end

		  test_finished =1;
	end

endmodule : FIFO_tb

