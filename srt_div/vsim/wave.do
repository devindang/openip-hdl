onerror {resume}
quietly virtual function -install /tb_div/u_srt -env /tb_div/#INITIAL#36 { &{/tb_div/u_srt/rem_r[64], /tb_div/u_srt/rem_r[63], /tb_div/u_srt/rem_r[62], /tb_div/u_srt/rem_r[61], /tb_div/u_srt/rem_r[60], /tb_div/u_srt/rem_r[59] }} a
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} /tb_div/clk
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} /tb_div/rstn
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} /tb_div/vld
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} -radix decimal /tb_div/op1
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} -radix decimal /tb_div/op2
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} -radix decimal /tb_div/rem
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} -radix decimal /tb_div/quo
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} /tb_div/ready
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/clk
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/rstn
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/vld_i
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix decimal /tb_div/u_srt/op1_i
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix decimal /tb_div/u_srt/op2_i
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix decimal /tb_div/u_srt/rem_o
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix decimal /tb_div/u_srt/quo_o
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/ready_o
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/cnt
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix decimal /tb_div/u_srt/op1_r
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix decimal /tb_div/u_srt/op2_r
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix unsigned /tb_div/u_srt/op1_ld
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix unsigned /tb_div/u_srt/op2_ld
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix hexadecimal /tb_div/u_srt/op1_n
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix hexadecimal /tb_div/u_srt/op2_n
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/rem_r
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/q
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/n
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/Q_next
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/QM_next
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/Q_reg
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/QM_reg
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/subs
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/iter
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix unsigned -radixshowbase 1 /tb_div/u_srt/state_next
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix unsigned -radixshowbase 1 /tb_div/u_srt/state_reg
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} -radix binary /tb_div/u_srt/u_qds/r_idx
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} -radix binary /tb_div/u_srt/u_qds/d_idx
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} /tb_div/u_srt/u_qds/q
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} /tb_div/u_srt/u_qds/neg
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} /tb_div/u_srt/u_qds/r_ori
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} /tb_div/u_srt/u_qds/r_ge_0010
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} /tb_div/u_srt/u_qds/r_ge_0011
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} /tb_div/u_srt/u_qds/r_ge_0110
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} /tb_div/u_srt/u_qds/r_ge_0111
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} /tb_div/u_srt/u_qds/r_ge_1000
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} /tb_div/u_srt/u_qds/r_ge_1001
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} /tb_div/u_srt/u_qds/r_ge_1010
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} /tb_div/u_srt/u_qds/r_ge_1011
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} /tb_div/u_srt/u_qds/r_ge_1100
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} /tb_div/u_srt/u_qds/q0
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_qds/Group1 -group {Region: sim:/tb_div/u_srt/u_qds} /tb_div/u_srt/u_qds/q2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {106 ns} 0}
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
WaveRestoreZoom {0 ns} {172 ns}
