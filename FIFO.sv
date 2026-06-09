////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
// Description: FIFO Design 
////////////////////////////////////////////////////////////////////////////////
module FIFO (FIFO_INTERFACE.DUT fif);

reg [fif.max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [fif.max_fifo_addr:0] count;

reg [fif.FIFO_WIDTH-1:0] mem [fif.FIFO_DEPTH-1:0];

always @(posedge fif.clk or negedge fif.rst_n) begin
	if (!fif.rst_n) begin
		wr_ptr <= 0;
		// Bug detected: Reset signals fif.overflow & fif.wr_ack
		fif.overflow <= 0;
		fif.wr_ack <= 0;
	end
	else if (fif.wr_en && count < fif.FIFO_DEPTH) begin
		mem[wr_ptr] <= fif.data_in;
		fif.wr_ack<=1;                                               
		wr_ptr <= wr_ptr + 1;
	end
	else begin 
		fif.wr_ack <= 0; 
		if (fif.full & fif.wr_en)
			fif.overflow <= 1;
		else
			fif.overflow <= 0;
	end
end

always @(posedge fif.clk or negedge fif.rst_n) begin
	if (!fif.rst_n) begin
		rd_ptr <= 0;
		// Bug detected: Reset signals fif.underflow 
		fif.underflow <= 0;
	end
	else if (fif.rd_en && count != 0) begin
		fif.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
	// Handled fif.underflow behaviour , turned from combinational to sequential
	else begin 
		if (fif.empty & fif.rd_en)
			fif.underflow <= 1;
		else
			fif.underflow <= 0;
	end
end

always @(posedge fif.clk or negedge fif.rst_n) begin
	if (!fif.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({fif.wr_en, fif.rd_en} == 2'b10) && !fif.full) 
			count <= count + 1;
		else if ( ({fif.wr_en, fif.rd_en} == 2'b01) && !fif.empty)
			count <= count - 1;
		// Bug detected: Unhandled case,  If a read and write enables were high and the FIFO was fif.empty, only writing will take place.
		else if ( ({fif.wr_en, fif.rd_en} == 2'b11) && fif.empty)
			count <= count + 1;
		// Bug detected: Unhandled cases,  If a read and write enables were high and the FIFO was fif.full, only reading will take place.
		else if ( ({fif.wr_en, fif.rd_en} == 2'b11) && fif.full)
			count <= count - 1;
	end
end

assign fif.full = (count == fif.FIFO_DEPTH)? 1 : 0;
assign fif.empty = (count == 0)? 1 : 0;
assign fif.almostfull = (count == fif.FIFO_DEPTH-1)? 1 : 0; // Bug detected: fif.FIFO_DEPTH-2 --> fif.FIFO_DEPTH-1
assign fif.almostempty = (count == 1)? 1 : 0;

// Guarded assertions
`ifdef SIM
	// Properties, Assertions & Covers
	always_comb begin 
		if(!fif.rst_n)
		reset_1_assertion: assert final ((!fif.wr_ack)&&(!fif.overflow)&&(!fif.underflow)&&(!wr_ptr)&&(!rd_ptr)&&(!count));
		reset_1_cover: cover final ((!fif.wr_ack)&&(!fif.overflow)&&(!fif.underflow)&&(!wr_ptr)&&(!rd_ptr)&&(!count));
	end

	always_comb begin 
		if((fif.rst_n)&&(count == fif.FIFO_DEPTH))
		full_assertion: assert final (fif.full);
		full_cover: cover (fif.full);
	end

	always_comb begin 
		if((fif.rst_n)&&(count == 0))
		empty_assertion: assert final (fif.empty);
		empty_cover: cover (fif.empty);
	end

	always_comb begin 
		if((fif.rst_n)&&(count == fif.FIFO_DEPTH-1))
		almostfull_assertion: assert final (fif.almostfull);
		almostfull_cover: cover (fif.almostfull);
	end
 
	always_comb begin 
		if((fif.rst_n)&&(count == 1))
		almostempty_assertion: assert final (fif.almostempty);
		almostempty_cover: cover (fif.almostempty);
	end

	property P1;
		@(posedge fif.clk or negedge fif.rst_n) 
		(!fif.rst_n) |-> ((!fif.wr_ack)&&(!fif.overflow)&&(!fif.underflow)&&(!wr_ptr)&&(!rd_ptr)&&(!count));
	endproperty

	property P2;
		@(posedge fif.clk) disable iff(!fif.rst_n)
		(fif.wr_en && !fif.full ) |=> ((fif.wr_ack)&&((wr_ptr==$past(wr_ptr)+1)||(wr_ptr==0 && $past(wr_ptr) +1 == 8)));
	endproperty

	property P3;
		@(posedge fif.clk) disable iff(!fif.rst_n)
		(fif.full & fif.wr_en) |=> (fif.overflow);
	endproperty


	property P4;
		@(posedge fif.clk) disable iff(!fif.rst_n)
		(fif.rd_en && count != 0) |=> ((rd_ptr==$past(rd_ptr)+1)||(rd_ptr==0 && $past(rd_ptr) +1 == 8));
	endproperty 

	property P5;
		@(posedge fif.clk) disable iff(!fif.rst_n)
		(fif.empty & fif.rd_en) |=> (fif.underflow);
	endproperty
	
	property P6;
		@(posedge fif.clk) disable iff(!fif.rst_n)
		(({fif.wr_en, fif.rd_en} == 2'b10) && !fif.full)   |=> ((count==$past(count)+1)||(count==0 && $past(count) +1 == 9));
	endproperty

	property P7;
		@(posedge fif.clk) disable iff(!fif.rst_n)
		( ({fif.wr_en, fif.rd_en} == 2'b01) && !fif.empty)  |=> ((count==$past(count)-1));
	endproperty

	property P8;
		@(posedge fif.clk) disable iff(!fif.rst_n)
		( ({fif.wr_en, fif.rd_en} == 2'b11) && fif.empty)  |=> ((count==$past(count)+1)||(count==0 && $past(count) +1 == 9));
	endproperty 

	property P9;
		@(posedge fif.clk) disable iff(!fif.rst_n)
		( ({fif.wr_en, fif.rd_en} == 2'b11) && fif.full)  |=> ((count==$past(count)-1));
	endproperty

	reset_2_assertion: assert property(P1);
	reset_2_cover: cover property(P1);

	write_assertion: assert property(P2);
	write_cover: cover property(P2);

	overflow_assertion: assert property(P3);
	overflow_cover: cover property(P3);

	read_assertion: assert property(P4);
	read_cover: cover property(P4); 

	underflow_assertion: assert property(P5);
	underflow_cover: cover property(P5);

	write_not_full_assertion: assert property(P6);
	write_not_full_cover: cover property(P6);

	read_not_empty_assertion: assert property(P7);
	read_not_empty_cover: cover property(P7);

	read_write_empty_assertion: assert property(P8);
	read_write_empty_cover: cover property(P8);

	read_write_full_assertion: assert property(P9);
	read_write_full_cover: cover property(P9); 
`endif
endmodule