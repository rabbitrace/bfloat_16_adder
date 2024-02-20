onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_bfloat16_adder/sum
add wave -noupdate /test_bfloat16_adder/ready
add wave -noupdate /test_bfloat16_adder/a
add wave -noupdate /test_bfloat16_adder/b
add wave -noupdate /test_bfloat16_adder/clock
add wave -noupdate /test_bfloat16_adder/nreset
add wave -noupdate /test_bfloat16_adder/reala
add wave -noupdate /test_bfloat16_adder/realb
add wave -noupdate /test_bfloat16_adder/realsum
add wave -noupdate /test_bfloat16_adder/ra
add wave -noupdate /test_bfloat16_adder/rb
add wave -noupdate /test_bfloat16_adder/a1/a_exponent
add wave -noupdate /test_bfloat16_adder/a1/b_exponent
add wave -noupdate /test_bfloat16_adder/a1/sum_exponent
add wave -noupdate /test_bfloat16_adder/a1/a_combination
add wave -noupdate /test_bfloat16_adder/a1/b_combination
add wave -noupdate /test_bfloat16_adder/a1/sum_combination
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {212550 ps} 0}
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
WaveRestoreZoom {0 ps} {324860 ps}
