onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cache_controller_tb/clk
add wave -noupdate /cache_controller_tb/reset
add wave -noupdate -color Gold -radix unsigned /cache_controller_tb/DUT/state
add wave -noupdate -color Gold -radix decimal /cache_controller_tb/DUT/data_up
add wave -noupdate -radix decimal /cache_controller_tb/d_up
add wave -noupdate -radix decimal /cache_controller_tb/dmem
add wave -noupdate -radix binary /cache_controller_tb/DUT/word_counter
add wave -noupdate /cache_controller_tb/DUT/read_mem_block
add wave -noupdate -radix decimal /cache_controller_tb/DUT/read_mem_word0
add wave -noupdate -radix decimal /cache_controller_tb/DUT/read_mem_word1
add wave -noupdate -radix decimal /cache_controller_tb/DUT/read_mem_word2
add wave -noupdate -radix decimal /cache_controller_tb/DUT/read_mem_word3
add wave -noupdate -radix decimal /cache_controller_tb/w_up
add wave -noupdate -color Gold -radix binary /cache_controller_tb/addr_up
add wave -noupdate /cache_controller_tb/DUT/hit_way_0
add wave -noupdate /cache_controller_tb/DUT/hit_way_1
add wave -noupdate /cache_controller_tb/DUT/valid_way_0
add wave -noupdate /cache_controller_tb/DUT/valid_way_1
add wave -noupdate /cache_controller_tb/DUT/used_way_0
add wave -noupdate /cache_controller_tb/DUT/used_way_1
add wave -noupdate /cache_controller_tb/DUT/dirty_way_0
add wave -noupdate /cache_controller_tb/DUT/dirty_way_1
add wave -noupdate -radix binary /cache_controller_tb/DUT/tag_read_0
add wave -noupdate -radix decimal /cache_controller_tb/DUT/tag_read_1
add wave -noupdate -radix hexadecimal /cache_controller_tb/DUT/db_read_0
add wave -noupdate /cache_controller_tb/DUT/db_read_1
add wave -noupdate /cache_controller_tb/read_up
add wave -noupdate /cache_controller_tb/write_up
add wave -noupdate -radix binary /cache_controller_tb/DUT/tag
add wave -noupdate -radix binary /cache_controller_tb/DUT/index
add wave -noupdate -radix binary /cache_controller_tb/DUT/block_offset
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1082 ns} 0}
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
WaveRestoreZoom {752 ns} {1540 ns}
