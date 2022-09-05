# Turtle16: Hardware Bugs, Limitations, and Weaknesses

In Rev C, several hardware changes have been to the Simulator made which necessitate corresponding changes to schematics and PCB layouts. This has not yet been done. The new N condition code must be routed through the CPU. The instruction decoder needs changes to accomodate changes to the pinout of the ATF22V10 made when the N condition code was added.

The computer is not self-programming. Instruction memory is stored entirely in a pair of ROMs. The memory must be reprogrammed using a device like the TL866ii+. This could be improved by replacing the instruction ROM ZIF sockets with a dual port memory where one port is connected to the Instruction Decoder and the other port is connected to the system memory bus. This dual port memory could be a true dual port SRAM, or it could be a time-shared SRAM. Some method would need to be introduced to fill the contents of this RAM when the computer first powers on.
* This is a work-in-progress for Rev C where instruction ROM will be replaced with a bit of dual-port memory which is accessible from the memory bus. This complicates the boot process as something must fill this memory when power is first applied to the computer.

The CPU is not capable of forwarding the Store Operand. The Hazard Control Unit works around this limitation by introducing a pipeline stall whenever a Read-After-Write hazard involves the Store Operand.

The implementation of the register file is one of the weaker points of the CPU design. The 7024L15PFG dual port SRAMs are currently difficult to source and can be expensive. A different design based on time-shared multiplexed SRAM would be a better solution, equivalent performance at a lower cost.

Possibly, the instruction decoder ROMs could be replaced with a set of three ATF22V10 to allow instruction decoding in 7ns instead of 45ns. Combine this with changes to instruction memory and the computer will be capable of much higher clock speeds.
* This is a work-in-progress for Rev C where this change is being made.

While not a bug, a weakness of the CPU is the limited number of general-purpose registers. There is space for three three-bit fields in the instruction word. It would also be possible to have the instruction use two operands, where one operand is used as an implicit destination register, as is done in some other ISAs. Taking this approach, the two register fields could both be five bits wide, allowing the number of registers to expand from eight to thirty two. In practical terms, this will greatly reduce register spilling, which is always quite slow.

Another weakness of the CPU is that it does not include a hardware shifter. This means, unintuitively, that left and right shift are very slow operations implemented in terms of addition and bitwise logical operations. The addition of a one cycle barrel shifter would greatly improve performance.

It may have been a mistake to have the RDY signal halt the Phi2 clock. If the Phi2 clock did not halt then peripheral devices could drive the bus independently of the CPU. This is necesary to implement DMA.

There was a hardware bug on Rev A where a program must begin with a single leading NOP at address zero to ensure correct operation during the reset cycle. I'm not sure yet that I've completely solved this problem on Rev B.

The data sheet for the '245 and '374 recommend a pull-up resistor on OE to ensure high impedance state during power up. I should look for places on the PCB, e.g. EX stage, which could benefit from such a change.

The PCB could benefit from many more test points. For example, a test point for the raw clock signal, and test points for the program counter.
* This is being implemented on Rev C.

Test points should have been placed on the front side of the PCB for convenience during debugging. Flipping the PCB to touch a probe to a test point is a very awkward thing to do.
* This is being implemented on Rev C.

For that matter, all components should have been placed on the front side of the PCB. This would greatly simplify assembly.
* This is being implemented on Rev C.

There's not enough space aorund the two 7381 ICs and the two ZIF sockets. This makes rework and debugging difficult. There's not enough room for PLCC-68 sockets either, for example.

The SMD PLCC-32 sockets are a pain to install. Can I do anything differently to make this easier next time? Also, it's really hard to remove chips from these PLCC-32 sockets with the extractor. Use different sockets next time?

~~I notice a stray trace on an internal layer to left of program counter. What’s this doing here?~~ (Fixed in eb44b2d9)

~~The memory bus connector is a low profile connector, and a standard header doesn’t lock in place as expected. Update the part number on the schematics to instead use the standard version of this connector.~~ (Fixed in 4b85c66e)