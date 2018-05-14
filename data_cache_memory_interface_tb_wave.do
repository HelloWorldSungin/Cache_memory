onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group data_mem_inputs -radix decimal /data_cache_memory_interface_tb/DUT/data_memory/address
add wave -noupdate -expand -group data_mem_inputs /data_cache_memory_interface_tb/DUT/data_memory/rd_en
add wave -noupdate -expand -group data_mem_inputs /data_cache_memory_interface_tb/DUT/data_memory/reset
add wave -noupdate -expand -group data_mem_inputs /data_cache_memory_interface_tb/DUT/data_memory/wr_data
add wave -noupdate -expand -group data_mem_inputs /data_cache_memory_interface_tb/DUT/data_memory/wr_en
add wave -noupdate -expand -group data_mem_internal /data_cache_memory_interface_tb/DUT/data_memory/state
add wave -noupdate -expand -group data_mem_internal /data_cache_memory_interface_tb/DUT/data_memory/read_flag
add wave -noupdate -expand -group data_mem_internal /data_cache_memory_interface_tb/DUT/data_memory/write_flag
add wave -noupdate -expand -group data_mem_internal /data_cache_memory_interface_tb/DUT/data_memory/dmem_stall
add wave -noupdate -expand -group data_mem_internal -radix decimal /data_cache_memory_interface_tb/DUT/data_memory/data_hold
add wave -noupdate -expand -group data_mem_internal -radix decimal /data_cache_memory_interface_tb/DUT/data_memory/addr_hold
add wave -noupdate -expand -group data_mem_outputs /data_cache_memory_interface_tb/DUT/data_memory/done
add wave -noupdate -expand -group data_mem_outputs /data_cache_memory_interface_tb/DUT/data_memory/rd_data
add wave -noupdate -expand -group data_mem_outputs /data_cache_memory_interface_tb/DUT/data_memory/ready
add wave -noupdate -expand -group cache_inputs /data_cache_memory_interface_tb/DUT/cache_memory/addr_up
add wave -noupdate -expand -group cache_inputs -radix decimal /data_cache_memory_interface_tb/DUT/cache_memory/data_mem
add wave -noupdate -expand -group cache_inputs -radix decimal /data_cache_memory_interface_tb/DUT/cache_memory/data_up
add wave -noupdate -expand -group cache_inputs /data_cache_memory_interface_tb/DUT/cache_memory/read_up
add wave -noupdate -expand -group cache_inputs /data_cache_memory_interface_tb/DUT/cache_memory/ready_mem
add wave -noupdate -expand -group cache_inputs /data_cache_memory_interface_tb/DUT/cache_memory/write_up
add wave -noupdate -expand -group cahce_outputs /data_cache_memory_interface_tb/DUT/cache_memory/addr_mem
add wave -noupdate -expand -group cahce_outputs /data_cache_memory_interface_tb/DUT/cache_memory/read_mem
add wave -noupdate -expand -group cahce_outputs /data_cache_memory_interface_tb/DUT/cache_memory/stall_up
add wave -noupdate -expand -group cahce_outputs /data_cache_memory_interface_tb/DUT/cache_memory/write_mem
add wave -noupdate /data_cache_memory_interface_tb/DUT/clk
add wave -noupdate /data_cache_memory_interface_tb/DUT/reset
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/state
add wave -noupdate -radix decimal /data_cache_memory_interface_tb/DUT/d_up
add wave -noupdate -radix decimal /data_cache_memory_interface_tb/DUT/dmem
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/read_mem_block
add wave -noupdate -radix decimal /data_cache_memory_interface_tb/DUT/cache_memory/read_mem_word0
add wave -noupdate -radix decimal /data_cache_memory_interface_tb/DUT/cache_memory/read_mem_word1
add wave -noupdate -radix decimal /data_cache_memory_interface_tb/DUT/cache_memory/read_mem_word2
add wave -noupdate -radix decimal /data_cache_memory_interface_tb/DUT/cache_memory/read_mem_word3
add wave -noupdate /data_cache_memory_interface_tb/DUT/RE
add wave -noupdate /data_cache_memory_interface_tb/DUT/WE
add wave -noupdate -radix decimal /data_cache_memory_interface_tb/DUT/WD
add wave -noupdate -radix binary /data_cache_memory_interface_tb/DUT/addr
add wave -noupdate -radix decimal /data_cache_memory_interface_tb/DUT/RD
add wave -noupdate /data_cache_memory_interface_tb/DUT/stall
add wave -noupdate /data_cache_memory_interface_tb/DUT/ready_mem
add wave -noupdate /data_cache_memory_interface_tb/DUT/rd_mem
add wave -noupdate /data_cache_memory_interface_tb/DUT/wr_mem
add wave -noupdate /data_cache_memory_interface_tb/DUT/addr_mem
add wave -noupdate -radix decimal /data_cache_memory_interface_tb/DUT/w_up
add wave -noupdate -radix decimal /data_cache_memory_interface_tb/DUT/data_up
add wave -noupdate -radix decimal /data_cache_memory_interface_tb/DUT/data_mem
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/ready_mem
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/hit_way_0
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/hit_way_1
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/valid_way_0
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/valid_way_1
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/used_way_0
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/used_way_1
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/dirty_way_0
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/dirty_way_1
add wave -noupdate -radix binary /data_cache_memory_interface_tb/DUT/cache_memory/tag_read_0
add wave -noupdate -radix binary /data_cache_memory_interface_tb/DUT/cache_memory/tag_read_1
add wave -noupdate -radix hexadecimal /data_cache_memory_interface_tb/DUT/cache_memory/db_read_0
add wave -noupdate -radix hexadecimal /data_cache_memory_interface_tb/DUT/cache_memory/db_read_1
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/read_up
add wave -noupdate -radix binary /data_cache_memory_interface_tb/DUT/cache_memory/tag
add wave -noupdate -radix binary /data_cache_memory_interface_tb/DUT/cache_memory/index
add wave -noupdate -radix binary /data_cache_memory_interface_tb/DUT/cache_memory/block_offset
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/valid
add wave -noupdate /data_cache_memory_interface_tb/DUT/cache_memory/dirty
add wave -noupdate -radix decimal /data_cache_memory_interface_tb/DUT/cache_memory/read_data_word
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {993 ns} 0}
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
WaveRestoreZoom {229 ns} {755 ns}
