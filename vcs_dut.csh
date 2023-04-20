#!/bin/csh
 

#fail
vlogan -full64 -work work -top top -f vlog_inputs.txt -sverilog +incdir+./ "+define+synthesis" "+define+SYNTHESIS" -full64
vcs -full64  work.top -top work.top -hw_top=top

#ok
#vlogan -full64 -work work -sverilog -f file.txt -l vlogan.log
#vcs -full64 -timescale=1ns/1ns -top top -hw_top=top 



