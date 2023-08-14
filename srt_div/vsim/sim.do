quit -sim

set top tb_div

.main clear

#vlib ./lib/
vlib work

vmap work work

# compile verilog file
# use vcom for VHDL instead
vlog -work work ../bench/*.v
vlog -work work ../rtl/*.v

vsim -t ns -voptargs=+acc work.$top

# add wave -recursive $top/*
add wave $top/*

run 1ms
