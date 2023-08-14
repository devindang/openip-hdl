onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} /tb_div/clk
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} /tb_div/rstn
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} /tb_div/op1
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} /tb_div/op2
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} /tb_div/result
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/clk
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/rstn
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/op1_i
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/op2_i
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/res_o
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/op2_ld
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -expand /tb_div/u_srt/op2_n
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -expand /tb_div/u_srt/rem_r
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -expand /tb_div/u_srt/n
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_find_ld2/Group1 -group {Region: sim:/tb_div/u_srt/u_find_ld2} /tb_div/u_srt/u_find_ld2/op
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_find_ld2/Group1 -group {Region: sim:/tb_div/u_srt/u_find_ld2} /tb_div/u_srt/u_find_ld2/pos
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_find_ld2/Group1 -group {Region: sim:/tb_div/u_srt/u_find_ld2} /tb_div/u_srt/u_find_ld2/op_t
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_find_ld2/Group1 -group {Region: sim:/tb_div/u_srt/u_find_ld2} /tb_div/u_srt/u_find_ld2/pos_oh
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_find_ld2/Group1 -group {Region: sim:/tb_div/u_srt/u_find_ld2} /tb_div/u_srt/u_find_ld2/i
add wave -noupdate -expand -label sim:/tb_div/u_srt/u_find_ld2/Group1 -group {Region: sim:/tb_div/u_srt/u_find_ld2} /tb_div/u_srt/u_find_ld2/j
add wave -noupdate -expand /tb_div/u_srt/Q_reg
add wave -noupdate -expand /tb_div/u_srt/QM_reg
add wave -noupdate -expand /tb_div/u_srt/n
add wave -noupdate -expand /tb_div/u_srt/q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {164 ns} 0}
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
WaveRestoreZoom {0 ns} {373 ns}
