.PHONY: com sim clean

PATH = ../bench/*.v ../rtl/*.v ../rtl/../*.v

all: 	clean com sim

com:
	vlog -l com.log $(PATH)
sim:
ifeq ($(wildcard wave.do),wave.do)
	vsim -l sim.log -do "run -all"
else
	vsim -l sim.log -do "run -all" -do sim.do
endif

clean:
	rm -r 	./work/ transcript modelsim.ini vsim.wlf \
			*.vcd wlft* vish* *.log

