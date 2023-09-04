onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -label sim:/tb_uart/Group1 -group {Region: sim:/tb_uart} /tb_uart/clk
add wave -noupdate -expand -label sim:/tb_uart/Group1 -group {Region: sim:/tb_uart} /tb_uart/clk2
add wave -noupdate -expand -label sim:/tb_uart/Group1 -group {Region: sim:/tb_uart} /tb_uart/rstn
add wave -noupdate -expand -label sim:/tb_uart/Group1 -group {Region: sim:/tb_uart} -radix binary /tb_uart/pwdata
add wave -noupdate -expand -label sim:/tb_uart/Group1 -group {Region: sim:/tb_uart} /tb_uart/psel
add wave -noupdate -expand -label sim:/tb_uart/Group1 -group {Region: sim:/tb_uart} /tb_uart/penable
add wave -noupdate -expand -label sim:/tb_uart/Group1 -group {Region: sim:/tb_uart} /tb_uart/pload
add wave -noupdate -expand -label sim:/tb_uart/Group1 -group {Region: sim:/tb_uart} -radix binary /tb_uart/uart_rxd
add wave -noupdate -expand -label sim:/tb_uart/Group1 -group {Region: sim:/tb_uart} /tb_uart/uart_vld
add wave -noupdate -expand -label sim:/tb_uart/Group1 -group {Region: sim:/tb_uart} /tb_uart/uart_txd
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr} /tb_uart/u_uart_xmtr/clk
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr} /tb_uart/u_uart_xmtr/rstn
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr} /tb_uart/u_uart_xmtr/bus_data_i
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr} /tb_uart/u_uart_xmtr/load_xmt_i
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr} /tb_uart/u_uart_xmtr/seri_data_o
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr} /tb_uart/u_uart_xmtr/data_seri_last
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr} /tb_uart/u_uart_xmtr/data_samp_last
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr} /tb_uart/u_uart_xmtr/ctrl_shift
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr} /tb_uart/u_uart_xmtr/ctrl_clear
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr} /tb_uart/u_uart_xmtr/ctrl_load
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr} /tb_uart/u_uart_xmtr/ctrl_inc_samp_cnt
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl} /tb_uart/u_uart_xmtr/u_xmtr_ctrl/clk
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl} /tb_uart/u_uart_xmtr/u_xmtr_ctrl/rstn
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl} /tb_uart/u_uart_xmtr/u_xmtr_ctrl/load_xmt_i
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl} /tb_uart/u_uart_xmtr/u_xmtr_ctrl/seri_last_i
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl} /tb_uart/u_uart_xmtr/u_xmtr_ctrl/samp_last_i
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl} /tb_uart/u_uart_xmtr/u_xmtr_ctrl/shift_o
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl} /tb_uart/u_uart_xmtr/u_xmtr_ctrl/clear_o
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl} /tb_uart/u_uart_xmtr/u_xmtr_ctrl/load_o
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl} /tb_uart/u_uart_xmtr/u_xmtr_ctrl/inc_samp_cnt_o
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl} /tb_uart/u_uart_xmtr/u_xmtr_ctrl/state_reg
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_ctrl} /tb_uart/u_uart_xmtr/u_xmtr_ctrl/state_next
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_data/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_data} /tb_uart/u_uart_xmtr/u_xmtr_data/clk
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_data/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_data} /tb_uart/u_uart_xmtr/u_xmtr_data/rstn
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_data/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_data} /tb_uart/u_uart_xmtr/u_xmtr_data/load_i
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_data/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_data} /tb_uart/u_uart_xmtr/u_xmtr_data/shift_i
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_data/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_data} /tb_uart/u_uart_xmtr/u_xmtr_data/clear_i
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_data/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_data} /tb_uart/u_uart_xmtr/u_xmtr_data/inc_samp_cnt_i
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_data/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_data} /tb_uart/u_uart_xmtr/u_xmtr_data/bus_data_i
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_data/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_data} /tb_uart/u_uart_xmtr/u_xmtr_data/seri_data_o
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_data/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_data} /tb_uart/u_uart_xmtr/u_xmtr_data/seri_last_o
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_data/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_data} /tb_uart/u_uart_xmtr/u_xmtr_data/samp_last_o
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_data/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_data} /tb_uart/u_uart_xmtr/u_xmtr_data/xmt_datareg
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_data/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_data} /tb_uart/u_uart_xmtr/u_xmtr_data/cnt_samp
add wave -noupdate -label sim:/tb_uart/u_uart_xmtr/u_xmtr_data/Group1 -group {Region: sim:/tb_uart/u_uart_xmtr/u_xmtr_data} /tb_uart/u_uart_xmtr/u_xmtr_data/bit_cnt
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr} /tb_uart/u_uart_rcvr/clk
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr} /tb_uart/u_uart_rcvr/rstn
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr} /tb_uart/u_uart_rcvr/seri_data_i
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr} /tb_uart/u_uart_rcvr/bus_data_o
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr} /tb_uart/u_uart_rcvr/vld_data_o
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr} /tb_uart/u_uart_rcvr/data_samp_last
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr} /tb_uart/u_uart_rcvr/data_seri_last
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr} /tb_uart/u_uart_rcvr/data_start_half
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr} /tb_uart/u_uart_rcvr/ctrl_clr_samp
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr} /tb_uart/u_uart_rcvr/ctrl_inc_samp
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr} /tb_uart/u_uart_rcvr/ctrl_clr_bit
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr} /tb_uart/u_uart_rcvr/ctrl_inc_bit
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr} /tb_uart/u_uart_rcvr/ctrl_shift
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr} /tb_uart/u_uart_rcvr/ctrl_load
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl} /tb_uart/u_uart_rcvr/u_rcvr_ctrl/clk
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl} /tb_uart/u_uart_rcvr/u_rcvr_ctrl/rstn
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl} /tb_uart/u_uart_rcvr/u_rcvr_ctrl/seri_data_i
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl} /tb_uart/u_uart_rcvr/u_rcvr_ctrl/start_half_i
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl} /tb_uart/u_uart_rcvr/u_rcvr_ctrl/samp_last_i
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl} /tb_uart/u_uart_rcvr/u_rcvr_ctrl/seri_last_i
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl} /tb_uart/u_uart_rcvr/u_rcvr_ctrl/clr_samp_cnt_o
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl} /tb_uart/u_uart_rcvr/u_rcvr_ctrl/inc_samp_cnt_o
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl} /tb_uart/u_uart_rcvr/u_rcvr_ctrl/clr_bit_cnt_o
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl} /tb_uart/u_uart_rcvr/u_rcvr_ctrl/inc_bit_cnt_o
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl} /tb_uart/u_uart_rcvr/u_rcvr_ctrl/shift_o
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl} /tb_uart/u_uart_rcvr/u_rcvr_ctrl/load_o
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl} /tb_uart/u_uart_rcvr/u_rcvr_ctrl/state_reg
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_ctrl} /tb_uart/u_uart_rcvr/u_rcvr_ctrl/state_next
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/WD_SIZE
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/HALF_SAMP
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/clk
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/rstn
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/seri_data_i
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/clr_samp_cnt_i
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/inc_samp_cnt_i
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/clr_bit_cnt_i
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/inc_bit_cnt_i
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/shift_i
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/load_i
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/samp_last_o
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/seri_last_o
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/start_half_o
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/bus_data_o
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/vld_data_o
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} -radix binary /tb_uart/u_uart_rcvr/u_rcvr_data/rcv_datareg
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/cnt_samp
add wave -noupdate -expand -label sim:/tb_uart/u_uart_rcvr/u_rcvr_data/Group1 -group {Region: sim:/tb_uart/u_uart_rcvr/u_rcvr_data} /tb_uart/u_uart_rcvr/u_rcvr_data/cnt_bit
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1453778 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {3056814 ps}
