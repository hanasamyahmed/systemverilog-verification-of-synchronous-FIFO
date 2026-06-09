package FIFO_scoreboard;
	import FIFO_transaction::*;
	import shared_pkg::*;

	FIFO_transaction FIFO_transaction_object = new();

	class FIFO_scoreboard;
		// Reference FIFO
		bit [FIFO_transaction_object.FIFO_WIDTH-1:0] fifo_queue [$];
		int fifo_count = 0;

		// Reference Signals
		logic [FIFO_transaction_object.FIFO_WIDTH-1:0] data_out_ref;

		// check_data Function
		function void check_data(input FIFO_transaction obj_one);

			reference_model(obj_one);

			// Compare the data_out with the reference
			if (obj_one.data_out !== data_out_ref) begin
				$display("Error!!, At time %t, data_out %d doesn't equal data_out_ref %d !!", $time, obj_one.data_out, data_out_ref);
				error_count++;
			end
			else begin
				$display("Success, At time %t, data_out= %d equals data_out_ref= %d", $time, obj_one.data_out, data_out_ref);
				correct_count++;
			end
		endfunction : check_data

		// reference_model Function
		function void reference_model(input FIFO_transaction F_txn);
			// Reset logic
			if (!F_txn.rst_n) begin
				fifo_queue <= {}; 
				fifo_count <= 0;
			end
			else begin
				// Write operation if not full
				if (F_txn.wr_en && fifo_count < FIFO_transaction_object.FIFO_DEPTH) begin
					fifo_queue.push_back(F_txn.data_in);  
					fifo_count <= fifo_queue.size();       
				end

				// Read operation if not empty
				if (F_txn.rd_en && fifo_count != 0) begin
					data_out_ref <= fifo_queue.pop_front();
					fifo_count <= fifo_queue.size();          
				end
				
			end
		endfunction : reference_model

	endclass : FIFO_scoreboard
endpackage : FIFO_scoreboard
