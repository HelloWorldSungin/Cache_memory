onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Gold /data_cache_memory_interface_tb/DUT/clk
add wave -noupdate -color Gold /data_cache_memory_interface_tb/DUT/reset
add wave -noupdate -color Gold /data_cache_memory_interface_tb/DUT/RE
add wave -noupdate -color Gold /data_cache_memory_interface_tb/DUT/WE
add wave -noupdate -color Gold -radix decimal /data_cache_memory_interface_tb/DUT/WD
add wave -noupdate -color Gold -radix binary /data_cache_memory_interface_tb/DUT/addr
add wave -noupdate -color Gold /data_cache_memory_interface_tb/DUT/cache_memory/read_up
add wave -noupdate -color {Medium Spring Green} -radix decimal /data_cache_memory_interface_tb/DUT/RD
add wave -noupdate -color {Medium Spring Green} /data_cache_memory_interface_tb/DUT/stall
add wave -noupdate -radix unsigned /data_cache_memory_interface_tb/DUT/cache_memory/state
add wave -noupdate -radix unsigned /data_cache_memory_interface_tb/DUT/data_memory/dmem_stall
add wave -noupdate -radix decimal /data_cache_memory_interface_tb/DUT/dmem
add wave -noupdate -radix decimal /data_cache_memory_interface_tb/DUT/data_up
add wave -noupdate -expand -group data_mem_inputs -radix binary /data_cache_memory_interface_tb/DUT/data_memory/address
add wave -noupdate -expand -group data_mem_inputs /data_cache_memory_interface_tb/DUT/data_memory/rd_en
add wave -noupdate -expand -group data_mem_inputs /data_cache_memory_interface_tb/DUT/data_memory/wr_en
add wave -noupdate -expand -group data_mem_inputs -radix decimal /data_cache_memory_interface_tb/DUT/data_memory/wr_data
add wave -noupdate -expand -group data_mem_outputs /data_cache_memory_interface_tb/DUT/data_memory/done
add wave -noupdate -expand -group data_mem_outputs -radix decimal /data_cache_memory_interface_tb/DUT/data_memory/rd_data
add wave -noupdate -expand -group data_mem_outputs /data_cache_memory_interface_tb/DUT/data_memory/ready
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/hit_way_0
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/valid_way_0
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/used_way_0
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/dirty_way_0
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/hit_way_1
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/valid_way_1
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/used_way_1
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/dirty_way_1
add wave -noupdate -radix binary /data_cache_memory_interface_tb/DUT/cache_memory/tag_read_0
add wave -noupdate -radix binary /data_cache_memory_interface_tb/DUT/cache_memory/tag_read_1
add wave -noupdate -radix hexadecimal /data_cache_memory_interface_tb/DUT/cache_memory/db_read_0
add wave -noupdate -radix hexadecimal /data_cache_memory_interface_tb/DUT/cache_memory/db_read_1
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/valid
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/dirty
add wave -noupdate -radix binary /data_cache_memory_interface_tb/DUT/cache_memory/tag
add wave -noupdate -radix binary /data_cache_memory_interface_tb/DUT/cache_memory/index
add wave -noupdate -radix binary /data_cache_memory_interface_tb/DUT/cache_memory/block_offset
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1282 ns} 0}
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
WaveRestoreZoom {1025 ns} {1291 ns}
