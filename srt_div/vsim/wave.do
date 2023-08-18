onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} /tb_div/clk
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} /tb_div/rstn
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} -radix decimal /tb_div/op1
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} -radix decimal /tb_div/op2
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} -radix decimal /tb_div/rem
add wave -noupdate -expand -label sim:/tb_div/Group1 -group {Region: sim:/tb_div} -radix decimal /tb_div/quo
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/clk
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/rstn
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix binary /tb_div/u_srt/op1_i
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix binary /tb_div/u_srt/op2_i
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix binary /tb_div/u_srt/rem_o
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix binary /tb_div/u_srt/quo_o
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix unsigned /tb_div/u_srt/op1_ld
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix unsigned /tb_div/u_srt/op2_ld
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix binary /tb_div/u_srt/op1_n
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -radix binary /tb_div/u_srt/op2_n
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -childformat {{{/tb_div/u_srt/Q_reg[3]} -radix binary} {{/tb_div/u_srt/Q_reg[2]} -radix binary} {{/tb_div/u_srt/Q_reg[1]} -radix binary} {{/tb_div/u_srt/Q_reg[0]} -radix binary}} -subitemconfig {{/tb_div/u_srt/Q_reg[3]} {-radix binary} {/tb_div/u_srt/Q_reg[2]} {-radix binary} {/tb_div/u_srt/Q_reg[1]} {-radix binary} {/tb_div/u_srt/Q_reg[0]} {-radix binary}} /tb_div/u_srt/Q_reg
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -expand /tb_div/u_srt/QM_reg
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -expand /tb_div/u_srt/q
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -expand /tb_div/u_srt/n
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/subs
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/iter
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/i1
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} /tb_div/u_srt/i2
add wave -noupdate -expand -label sim:/tb_div/u_srt/Group1 -group {Region: sim:/tb_div/u_srt} -childformat {{{/tb_div/u_srt/rem_r[3]} -radix binary} {{/tb_div/u_srt/rem_r[2]} -radix binary} {{/tb_div/u_srt/rem_r[1]} -radix binary} {{/tb_div/u_srt/rem_r[0]} -radix binary}} -expand -subitemconfig {{/tb_div/u_srt/rem_r[3]} {-height 15 -radix binary} {/tb_div/u_srt/rem_r[2]} {-height 15 -radix binary} {/tb_div/u_srt/rem_r[1]} {-height 15 -radix binary} {/tb_div/u_srt/rem_r[0]} {-height 15 -radix binary}} /tb_div/u_srt/rem_r
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/r_idx}
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/d_idx}
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/q}
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/neg}
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/r_ori}
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/r_ge_0010}
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/r_ge_0011}
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/r_ge_0110}
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/r_ge_0111}
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/r_ge_1000}
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/r_ge_1001}
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/r_ge_1010}
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/r_ge_1011}
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/r_ge_1100}
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/q0}
add wave -noupdate -expand -group /qds0 {/tb_div/u_srt/for_qds[0]/u_qds/q2}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {61 ns} 0}
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
