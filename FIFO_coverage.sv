package FIFO_coverage;
import FIFO_transaction::*;
class FIFO_coverage;

FIFO_transaction F_cvg_txn = new();

covergroup cg;

wr_en_cp:coverpoint F_cvg_txn.wr_en;
rd_en_cp:coverpoint F_cvg_txn.rd_en;
wr_ack_cp:coverpoint F_cvg_txn.wr_ack;
overflow_cp:coverpoint F_cvg_txn.overflow;
full_cp:coverpoint F_cvg_txn.full;
empty_cp:coverpoint F_cvg_txn.empty;
almostfull_cp:coverpoint F_cvg_txn.almostfull;
almostempty_cp:coverpoint F_cvg_txn.almostempty;
underflow_cp:coverpoint F_cvg_txn.underflow;



wr_rd_wrack: cross wr_ack_cp, wr_en_cp,rd_en_cp;
wr_rd_overflow: cross overflow_cp, wr_en_cp,rd_en_cp;
wr_rd_underflow: cross underflow_cp, wr_en_cp,rd_en_cp;
wr_rd_full: cross full_cp, wr_en_cp,rd_en_cp;
wr_rd_empty: cross empty_cp, wr_en_cp,rd_en_cp;
wr_rd_almostempty: cross almostempty_cp, wr_en_cp,rd_en_cp;
wr_rd_almostfull: cross almostfull_cp, wr_en_cp,rd_en_cp;


endgroup

function new();
cg =new();

endfunction

function void sample_data(input FIFO_transaction F_txn);
F_cvg_txn = F_txn;
cg.sample();
endfunction


endclass
endpackage
