onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cache_controller_tb2/DUT/clk
add wave -noupdate /cache_controller_tb2/DUT/reset
add wave -noupdate -radix unsigned /cache_controller_tb2/DUT/state
add wave -noupdate -radix decimal /cache_controller_tb2/DUT/data_up
add wave -noupdate -radix decimal /cache_controller_tb2/d_up
add wave -noupdate -radix decimal /cache_controller_tb2/dmem
add wave -noupdate -radix decimal /cache_controller_tb2/DUT/data_mem
add wave -noupdate -radix binary /cache_controller_tb2/DUT/word_counter
add wave -noupdate -radix decimal /cache_controller_tb2/DUT/read_mem_block
add wave -noupdate -radix decimal /cache_controller_tb2/DUT/read_mem_word0
add wave -noupdate -radix decimal /cache_controller_tb2/DUT/read_mem_word1
add wave -noupdate -radix decimal /cache_controller_tb2/DUT/read_mem_word2
add wave -noupdate -radix decimal /cache_controller_tb2/DUT/read_mem_word3
add wave -noupdate -radix decimal /cache_controller_tb2/w_up
add wave -noupdate -radix binary /cache_controller_tb2/addr_up
add wave -noupdate /cache_controller_tb2/DUT/hit_way_0
add wave -noupdate /cache_controller_tb2/DUT/valid_way_0
add wave -noupdate /cache_controller_tb2/DUT/used_way_0
add wave -noupdate /cache_controller_tb2/DUT/dirty_way_0
add wave -noupdate /cache_controller_tb2/DUT/hit_way_1
add wave -noupdate /cache_controller_tb2/DUT/valid_way_1
add wave -noupdate /cache_controller_tb2/DUT/used_way_1
add wave -noupdate /cache_controller_tb2/DUT/dirty_way_1
add wave -noupdate -radix binary /cache_controller_tb2/DUT/tag_read_0
add wave -noupdate -radix binary /cache_controller_tb2/DUT/tag_read_1
add wave -noupdate /cache_controller_tb2/DUT/db_read_0
add wave -noupdate /cache_controller_tb2/DUT/db_read_1
add wave -noupdate /cache_controller_tb2/DUT/read_up
add wave -noupdate /cache_controller_tb2/DUT/write_up
add wave -noupdate -radix binary /cache_controller_tb2/DUT/tag
add wave -noupdate -radix decimal /cache_controller_tb2/DUT/index
add wave -noupdate -radix binary /cache_controller_tb2/DUT/block_offset
add wave -noupdate /cache_controller_tb2/DUT/ready_mem
add wave -noupdate -color {Light Steel Blue} /cache_controller_tb2/read_up
add wave -noupdate -color {Light Steel Blue} /cache_controller_tb2/write_up
add wave -noupdate /cache_controller_tb2/read_mem
add wave -noupdate /cache_controller_tb2/write_mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2131 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 174
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
WaveRestoreZoom {1840 ns} {2470 ns}
