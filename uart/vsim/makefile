.PHONY: com sim clean

FLIST = ../bench/*.v ../rtl/*.v

all: 	clean com sim

com:
	vlib work
	vmap work work
	vlog -l com.log -work work +incdir+../rtl/ $(FLIST)

sim:
	vsim -l sim.log -t ns -do "run -all"

clean:
	rm -rf 	./work/ transcript modelsim.ini vsim.wlf \
			*.vcd wlft* vish* *.log
