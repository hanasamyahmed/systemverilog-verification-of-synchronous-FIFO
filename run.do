vlib work

vlog -f FIFO.list  +cover -covercells +define+SIM

vsim -voptargs=+acc work.top -cover

add wave *

coverage save FIFO.ucdb -onexit 

run -all

#quit -sim

#vcover report FIFO.ucdb -details -annotate -all -output -FIFO_covertr.txt