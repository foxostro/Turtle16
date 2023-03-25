# Turtle16: Future Work

## Interrupts

The Turtle16 CPU lacks interrupts and exceptions entirely. While I have a plan to implement these, it does require changes across the entire CPU and will not come sooner than Rev D. It requires extensive changes to the ID stage and Register File too. In short, new CSRs can be added to record the exception cause, the PC of the interrupted instruction, the address of the exception handler, and a status register to enable/disable interrupts. New instructions can be added to store and load these registers from a program and they are intrinsically accessible within the ID stage. A new instruction must be added to return from an exception, re-enabling interrupts and jumping to the address of the exception handler. New shared, open-collector IRQ lines must be added to the system memory bus, possibly by rearranging pins and replacing some of the ground pins. The ID stage will detect that an IRQ line has been asserted and respond by interrupting the current instruction, recording CPU state in the CSRs, disabling interrupts, and jumping to the address of the exception handler.

## Virtual Memory and Larger Amounts of RAM

The The memory banking system allows different memory mappings to be applied under different banking configurations. One idea I've considered is always mapping built-in instruction RAM into the upper half of the address space, and having peripherals such as Video and Audio devices map into the lower half of the address space in different banks. It would also be possible to add a MMU peripheral where the lower half of the address space is an MMU which mediates access to peripherals by way of a page table in memory. However, 32K of address space does not leave room for many pages of memory.

One of the memory-mapped peripherals could be a large RAM. Say, a 128MB DRAM SIMM. The lower fixteen bits of the memory address are specified on the memory bus. The upper twelve bits of the address space are specified by a memory-mapped page register. A running program must be aware of the page register and many memory accesses will require several instructions. A compiler could help to make this transparent to the programmer.

## Bit Shifter

Bit shifting with the ALU today is very difficult and expensive, especially shifting right. Fortunately, this complexity can mostly be hidden by the compiler which provides LSL and LSR instructions in the intermediate representation ISA and compiles to long sequences of native instructions to implement the operation. Adding hardware support for bit shifting would provide a massive performance improvement. Even a bit shifter which only shifts one bit to the right would be a massive improvement.

With additional control lines, and additional circuitry in the EX stage, it would be possible to implement a full sixteen-bit one-cycle shifter. Though, this will require a lot of additional logic and PCB real estate.

The SelRightOp signal can expanded from two bits to three bits with one additional control signal going into the EX stage. The SelectRightOperand unit can accept the three bit input and has four unused outputs on the decoder (U40) which can be used to control shifting modes. One additional 74AHCT16245 bus transceiver in this unit can provide the ability to perform logical and arithmetic shifts to the right by one bit. This will surely provide massive imnprovements to performance with minimal additional logic and minimal additional area.

## Branch Prediction

It would be possible to implement branch prediction in the CPU. The possible benefit of this is to eliminate the two cycle stall after a branch in correctly predicted branches.

One of the simplest possible improvements would be to predict that backwards branches are taken. More complicated branch predictors are also possible but require additonal logic and a lot of PCB real estate.

## Superscalar

Quad pumped memory would allow the instruction fetch stage to fetch two instructions each cycle and perform two memory accesses in the MEM stage each cycle. The pipeline can be duplicated so that we execute two instructions at the same time. This may involve some restrictions on which instructions may be placed in the even and odd positions, similar to what we see on the original Pentium processor. This definitely will involve a lot of additional logic in the ID stage for hazard control.

## Two-address Instructions

The sixteen-bit instructions of the Turtle16 ISA do not leave many bits to encode registers. The current compromise is to support only eight GPRs. It would be possible to move to an ISA with two operands to allow for a four-bit register index and up to sixteen GPRs. This, of course, requires extensive changes across the CPU, Simulator, and tool chain.