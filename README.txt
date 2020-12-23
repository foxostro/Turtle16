Turtle16 is a sixteen-bit microcomputer built from discrete logic ICs and other simple parts. This repo contains the Kicad project and other files necesary to build the hardware. The toolchain and software is provided in a separate repo.

Project Constraints
-------------------

Microprocessors and programmable hardware such as CPLDs and FPGAs have been avoided. An exception has been made for primitive GALs as these fit the retro computer aesthetic.


Architecture Overview
---------------------
The CPU uses a Load/Store architecture based on the classic RISC pipeline. There are eight general-purpose registers, each sixteen bits wide. The load/store unit fetches sixteen-bit words from a sixteen-bit address space. Instructions and Data are split into two separate address spaces, avoiding any possible structural hazard from accessing instructions and data simultaneously.

The control unit implements primitive branch prediction which always predicts the branch is not taken and then flushes the pipeline when it ever actually is, thus avoiding the need for branch delay slots. A delay slot between the ALU's computation of flags and the Instruction Decode stage's use of flags is avoided by having the control unit stall the CPU for one cycle. Read-After-Write hazards are also avoided by stalling the CPU until the hazard has passed.

The register file is implemented in two dual port SRAMs operating in parallel. This allows for a triple port register file with one write port and two read ports. With careful design, a write in the write-back stage can be assured to be committed before a register file read in the same cycle.

The ALU is built around an IDT 7831. This is a monolithic, sixteen-bit ALU IC that was produced in the early 90's.

The main board does not include RAM or peripherals. The intention is that these devices would be implemented on separate boards and connected to the main board through an external peripheral connector.



Control Signals
---------------
The instruction decoder in the ID stage of the CPU pipeline decode the five-bit opcode into twenty one control signals which control subsequent pipeline stages.

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

The ID stage contains hazard control logic which additionally produces signals for stalling and flushing the pipeline:

STALL_PC -- Stalls the Program Counter in the IF stage.
/STALL_IF -- Stalls the Instruction Fetch unit in the IF stage.