import FIFO_coverage::*;
import FIFO_scoreboard::*;
import shared_pkg::*;
import FIFO_transaction::*;

module FIFO_MONITOR(FIFO_INTERFACE.MONITOR fif);

    FIFO_transaction  F_trans = new();
    FIFO_scoreboard  F_sb = new();
    FIFO_coverage F_cov = new();

    initial begin
        forever begin
            @(negedge fif.clk);
            F_trans.data_in = fif.data_in;
            F_trans.rst_n = fif.rst_n;
            F_trans.wr_en = fif.wr_en;
            F_trans.rd_en = fif.rd_en;
            F_trans.data_out = fif.data_out;
            F_trans.wr_ack= fif.wr_ack;
            F_trans.overflow= fif.overflow;
            F_trans.full= fif.full;
            F_trans.empty= fif.empty;
            F_trans.almostempty= fif.almostempty;
            F_trans.almostfull= fif.almostfull;
            F_trans.underflow= fif.underflow;

            fork
                begin
                    F_cov.sample_data(F_trans);
                end
                begin
                    F_sb.check_data(F_trans);
                end  
            join

            if (test_finished)begin
                $display("Test Finished ...correct counts = %0d , Error counts = %0d",correct_count,error_count);
                $stop;
            end
        end
    end
endmodule