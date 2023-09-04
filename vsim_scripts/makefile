.PHONY: com sim clean

FLIST = ../bench/*.v ../rtl/*.v

all: 	clean com sim

com:
	vlib work
	vmap work work
	vlog -l com.log -work work +incdir+../rtl/ $(FLIST)

sim:
ifeq ($(wildcard wave.do),wave.do)
	vsim -l sim.log -do "run -all" -do wave.do
else
	vsim -l sim.log -t ns -do "run -all"
endif

clean:
	rm -rf 	./work/ transcript modelsim.ini vsim.wlf \
			*.vcd wlft* vish* *.log
