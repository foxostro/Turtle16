# Turtle16: Architecture Overview

Turtle16 is a sixteen-bit microcomputer built from discrete logic ICs and other simple parts.

The CPU uses a Load/Store architecture based on the classic RISC pipeline. There are eight general-purpose registers, each sixteen bits wide. The load/store unit fetches sixteen-bit words from a sixteen-bit address space. Instructions and Data are split into two separate address spaces, avoiding any possible structural hazard from accessing instructions and data simultaneously.

[CPU block diagram](CPU_Block_Diagram.png)

Pipeline Stages:

1. IF — Fetch an instruction from Instruction Memory via the Program Counter. This stage is split into a Program Counter part and an Instruction Memory part and takes two clock cycles to complete. This is sometimes written in diagrams as two pipeline stages, PC and IF.
2. ID — Decode instruction and read the register file. This also performs hazard control on decoding the instruction, and operand forwarding / bypassing.
3. EX — Marshal operands and perform a computation
4. MEM — Either read or write to memory
5. WB — Write results back to the register file


## Clock

[![Clock](Clock_Small.png?raw=true "Clock module")](Clock.png)

On paper, I estimate the CPU clock can run at speeds up to 12MHz. This has not yet been tested.

Peripheral devices may halt the CPU by pulling the shared RDY signal low using an open-drain buffer such as 74AHCT07A. While halted this way, the CPU disconnects from the bus so that peripheral devices may drive the bus as they see fit. The CPU's Phi1 clock immediately drops to zero and stops. The CPU's Phi2 clock is unaffected, and this is the one exposed to peripheral devices.

The clock module ensures /RDY only takes affect on the clock edge so devices may acquire and release /RDY at any time.

The HLT instruction will halt the clock. Pressing the resume button permits execution for one clock cycle, giving the CPU enough time to clear the HLT and continue execution. This allows programs to have breakpoints in them for debugging.


## Instruction Fetch (IF)

[![Instruction Fetch](IF_Small.png?raw=true "Instruction Fetch pipeline stage")](IF.png)

The Program Counter uses the IDT 7381. This is configured in various modes of operation to implement functionality for increment, reset, jump to an absolute branch target, or jump to a relative branch target.


## Instruction Decode (ID)

[![Instruction Decode](ID_Small.png?raw=true "Instruction Decode pipeline stage")](ID.png)

The ID stage uses a ROM to decode a five-bit opcode in the instruction word to a set of twenty one control signals.

Control Signals:

0. /HLT — Halt the clock
1. SelStoreOpA — Select the source of the Store operand
2. SelStoreOpB — "
3. SelRightOpA — Select the source of the Right operand
4. SelRightOpB — "
5. /FI — Update the flags register
6. ALU C0 — ALU carry-in
7. ALU I0 — ALU function bit 0
8. ALU I1 — ALU function bit 1
9. ALU I2 — ALU function bit 2
10. ALU RS0 — ALU RS0 operand mux control
11. ALU RS1 — ALU RS1 operand mux control
12. /J — Instruct the program counter to add the specified offset to itself.
13. /JABS — Absolute jump
14. /MemLoad — Drive /MemLoad onto the bus, instructing peripheral device to Load
15. /MemStore — Drive /MemStore onto the bus, instructing peripheral device to Store
16. /AssertStoreOp — Drive the Store operand onto the bus I/O lines
17. WriteBackSrc — Select the source to write back to the register file
18. /WRL — Write the lower upper byte in the register file's write port
19. /WRH — Write the upper byte in the register file's write port
20. /WBEN — Enable write back to register file

The control unit implements primitive branch prediction which always predicts the branch is not taken and then flushes the pipeline when it ever actually is, thus avoiding the need for branch delay slots.

The control unit will take care to resolve various hazards automatically. Hazards involving CPU Flags are resolved by stalling the CPU until the hazard has passed. Several types of Read-after-write hazards are resolved by forwarding the desired operand from a subsequent pipeline stage back into Instruction Decode. If the desired result is in the store operand then this is not possible and the pipeline stalls.

(Forwarding of the store operand is left as a possible improvement for a future hardware revision.)

The register file is implemented in two dual port SRAMs operating in parallel. This allows for a triple-port register file with one write port and two read ports. With careful design, a write in the write-back stage can be assured to be committed before a register file read in the same cycle. Due to space limitations in the instruction word, only three bits can be devoted to the register index. The register file can only provide eight homogeneous, general-purpose registers.

As an aside, the implementation of the reigster file is one of the weaker points of the CPU design. These dual port SRAMs are currently difficult to source and can be expensive. A different design based on time-shared multiplexed SRAM would be a better solution, equivalent performance at a lower cost.


## Execute (EX)

[![Execute](EX_Small.png?raw=true "Execute pipeline stage")](EX.png)

The ALU is built around an IDT 7381. This is a monolithic, sixteen-bit ALU IC that was produced in the early 90's. This IC is slightly easier to work with than the venerable 74x181 used in other "7400-series computer" designs.

Operand selection is implemented by using banks of bus transceivers to select one of several sources as input to the ALU. The result is latched in an inter-stage pipeline register. The flags are latched in their own register which feeds back into the ID stage.

The ALU result feeds back into the IF stage to allow it to be used by the program counter on a branch.


## Memory (MEM)

[![Memory](MEM_Small.png?raw=true "Memory pipeline stage")](MEM.png)

The MEM stage accesses memory. If the CPU is in the halted state then it does not assert signals on the address or data lines, instead effectively disconnecting by putting a bus transceiver into a high impedence state.


## Writeback (WB)

[![Writeback](WB_Small.png?raw=true "Writeback pipeline stage")](WB.png)

The WB stage writes a result back to the register file. This must be done in time to read that same value from the register file in the same clock cycle.


## Peripherals

The main board does not include RAM or peripherals. The intention is that these devices would be implemented on separate boards and connected to the main board through an external peripheral connector.


## Hardware Bugs

The CPU is not capable of forwarding the Store Operand. The Hazard Control Unit works around this limitation by introducing a pipeline stall whenever a Read-After-Write hazard involves the Store Operand.

The HLT test program isn't halting. There must be some bug in the Halt/Resume circuit yet to be understood.
