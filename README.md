# Cache_memory (Memory Hierarchy Design)
Developing Cache Memory that goes into the 32bit pipeline processor
The current cache has 32 KByte two-way set associative with four-word blcok.
The Cache follows the write back policy. 

Introduction:
Our original pipelined MIPS processor design from project 1 makes many assumptions that result in an inaccurate, unrealistic model of an actual processor. One of the major inaccuracies in our previous model is that access to the data memory unit from the processor takes 0 cycles. In reality, reading and writing from main memory requires the most time to complete than any other operation performed by the processing unit. 
In order to combat this significant delay imposed by memory accesses, memory hierarchies have been added to processor designs to reduce the amount of times the processor must directly access main memory. Currently in our design of MIPS we have 2 levels of memory, the register file and a data memory with a 0 cycle access time. In order to represent a more realistic processor we will add a 20 cycle delay to all read and write operations to the data memory unit as well as an L1 cache that acts as an intermediary between the processor and the main data memory. If the requested data is present in the cache then the memory operation will take 1 cycle, otherwise … The idea is to exploit the temporal and spatial locality of memory accesses that occur frequently in most programs. By previously accessed data in the cache, we can eliminate the need to access main memory directly the next time that data is requested by the processor. 
The addition of this memory hierarchy into our pipeline breaks the balance between the clock cycles required for each stage of the pipeline. The memory stage will require many more cycles than the other stages if the memory request from the processor “misses” in the L1 cache. In other words, new data hazards have to accounted for because there are cases where instructions containing operands whose data is dependent upon a previous, incomplete access to memory.

Design Methodology:
1. Modified Data Memory Unit (with 20 cycle access time):
In our original implementation of data memory, we did not find a need to include the memread_m signal as an input to the memory unit. Since there were no delays associated with memory accesses, other than those caused by data dependencies, our old model simply connected the readdata_m output of the data memory unit to the data word requested by the processor at any given time. This is a truly ideal memory model that assumes that reading from memory takes 0 cycles and the data is ready instantaneously. 
Now that both reading and writing from memory incurs a 20 cycle delay in the execution of our pipelined MIPS processor, it is necessary to distinguish the instructions that utilize and access the data memory unit from those that do not. The MIPS instruction set is designed in a very specific way, such that load/store instructions are the only ones that interact with memory. This makes our life much easier in our attempts to design a functional, pipelined processor that is free of all hazards while maintaining efficiency through instruction-level parallelism.

2. Cache Unit for Data Memory:
Our data memory cache design has the following properties:
32 KB total data capacity: 8,192 words
2-way set associativity: Two available cache entries per index
Allows the cache to store up to 2 blocks with the same index mappings.
When this number exceeds 2, the least-recently-used (LRU) block is replaced, and written back to main memory if it contains more up-to-date data.
4-word block size: Each data block in the cache consists of four 32-bit words (128 bits).
The cache accesses the main memory 4 words, 32 bits each, at a time. This allows for the exploitation of the spatial locality of memory requests seen frequently in a myriad of different programs.
2,048 total lines in the entire cache, 1024 in each set.
Each line is composed of the following:
USED (1-bit): Replacement scheme decision
VALID (1-bit): Data block verification
DIRTY (1-bit): Updated in cache but not main memory
condition for writeback on a “cache miss”
TAG (20-bit): Address subsection; condition for “cache hit”
INDEX (10-bit): Position within cache memory
BLOCK_OFFSET (2-bit): Word selection within data blocks.
Write-back policy: Updating of main memory behavior.
Initially writing is only done to the memory instance within the cache, only when the same block is being replaced in the cache is it written back to the main memory.
This writing scheme minimizes the frequency of accesses to main memory, which improves the clocks per instruction (CPI) of the processor due to the significant delays incurred from memory operations.
Can also result in the loss of data if the processor were to crash at any given time. 
