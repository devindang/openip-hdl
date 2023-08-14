# VCS: com sim verdi clean
.PHONY: com sim verdi clean

OUTPUT = simv
ALL_DEFINE = +define+FSDB

#Compile command
VCS = vcs +v2k -override_timescale=1ns/1ps						\
		-full64													\
		-fsdb													\
		$(ALL_DEFINE)											\
		-o $(OUTPUT)											\
		-l compile.log											\
		-cpp g++-4.7											\
		-cc gcc-4.7												\
		-LDFLAGS												\
		-Wl,--no-as-needed

#simulation command
SIM = ./$(OUTPUT)												\
	  $(ALL_DEFINE)												\
	  -l $(OUTPUT).log

# make command

all: clean com sim verdi

com:
	$(VCS) -f *.f

sim:
	$(SIM) 

verdi:
	verdi -f *.f -ssf *.fsdb  &
# -sswr novas.rc

clean:
	rm -rf ./csrc *.daidir ./csrc  						\
		*.log  *.vpd  *.vdb  simv* *.key				\
		+race.out* verdi* *fsdb *.conf *.bak *.vcd

