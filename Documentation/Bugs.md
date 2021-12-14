# Turtle16: Hardware Bugs

The HLT test program isn't halting. There must be some bug in the Halt/Resume circuit yet to be understood.

Perhaps it was a mistake to have the RDY signal halt the Phi2 clock. If it did not halt then peripheral devices could drive the bus, and other peripheral devices, independently of the CPU. This is necesary to implement DMA.


## Hardware Limitations and Weaknesses

The computer is not self-programming. Instruction memory is stored entirely in a pair of EEPROMs. (Well, in truth, these are actually NOR flash ICs, but I consider that to be a tiny implementation detail.) The memory must be reprogrammed using a device like the TL866ii+. This could be improved by replacing the instruction ROM ZIF sockets with a dual port memory where one port is connected to the Instruction Decoder and the other port is connected to the system memory bus. This dual port memory could be a true dual port SRAM, or it could be a time-shared SRAM.

The CPU is not capable of forwarding the Store Operand. The Hazard Control Unit works around this limitation by introducing a pipeline stall whenever a Read-After-Write hazard involves the Store Operand.

The implementation of the reigster file is one of the weaker points of the CPU design. These dual port SRAMs are currently difficult to source and can be expensive. A different design based on time-shared multiplexed SRAM would be a better solution, equivalent performance at a lower cost.

While not a bug, a weakness of the CPU is the limited number of general-purpose registers. There is space for three three-bit fields in the instruction word. It would also be possible to have the instruction use two operands, where one operand is used an implicit destination register, as is done in some other ISAs. Taking this approach, the two register fields could both be five bits wide, allowing the number of registers to expand from eight to thirty two. In practical terms, this will greatly reduce register spilling, which is always quite slow.

Another weakness of the CPU is that it does not include a hardware shifter. This means, unintuitively, that left and right shift are very slow operations implemented in terms of addition and bitwise logical operations. The addition of a one cycle barrel shifter would greatly improve performance.