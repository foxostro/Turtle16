# Turtle16

Turtle16 is a sixteen-bit microcomputer built from discrete logic ICs and other simple parts. This repo contains the Kicad project and other files necesary to build the hardware. The toolchain and software is provided in a separate repo.



## Project Constraints

Microprocessors and programmable hardware such as CPLDs and FPGAs have been avoided. An exception has been made for primitive GALs as these fit the retro computer aesthetic.



## Architecture Overview

The CPU uses a Load/Store architecture based on the classic RISC pipeline. There are eight general-purpose registers, each sixteen bits wide. The load/store unit fetches sixteen-bit words from a sixteen-bit address space. Instructions and Data are split into two separate address spaces, avoiding any possible structural hazard from accessing instructions and data simultaneously.

### Pipeline Stages

1. IF — Fetch an instruction from Instruction Memory via the Program Counter
2. ID — Decode instruction and read the register file. This also performs hazard control on decoding the instruction.
3. EX — Marshal operands and perform a computation
4. MEM — Either read or write to memory
5. WB — Write results back to the register file

The control unit implements primitive branch prediction which always predicts the branch is not taken and then flushes the pipeline when it ever actually is, thus avoiding the need for branch delay slots. A delay slot between the ALU's computation of flags and the Instruction Decode stage's use of flags is avoided by having the control unit stall the CPU for one cycle. Read-After-Write hazards are also avoided by stalling the CPU until the hazard has passed.

The register file is implemented in two dual port SRAMs operating in parallel. This allows for a triple-port register file with one write port and two read ports. With careful design, a write in the write-back stage can be assured to be committed before a register file read in the same cycle. Due to space limitations in the instruction word, only three bits can be devoted to the register index. The register can only provide eight homogeneous, general-purpose registers.

The ALU is built around an IDT 7831. This is a monolithic, sixteen-bit ALU IC that was produced in the early 90's.

Peripheral devices may halt the CPU by pulling the shared RDY signal low using an open-drain buffer such as 74AHCT07A. While halted this way, the CPU disconnects from the bus so that peripheral devices may drive the bus as they see fit. The CPU's Phi1 clock immediately drops to zero and stops. The CPU's Phi2 clock is unaffected, and this is the one exposed to peripheral devices.

The clock module ensures /RDY only takes affect on the clock edge so devices may acquire and release /RDY at any time.

The main board does not include RAM or peripherals. The intention is that these devices would be implemented on separate boards and connected to the main board through an external peripheral connector.



## Control Signals

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

For the sake of simplicity, there is no hazard control logic in the CPU. It is the responsibility of the programmer to avoid hazards such as RAW hazards, Flags hazards, and issues related to branch delay slots.



## Opcodes

The ID stage uses a ROM to decode a five-bit opcode into an array of control signals. The opcodes are as follows. Though, this is definitely something that can be redefined by flashing different data to the chips.

0. nop
1. hlt
2. load
3. store
4. li
5. lui
6. cmp
7. add
8. sub
9. and
10. or
11. xor
12. not
13. cmpi
14. addi
15. subi
16. andi
17. ori
18. xori
19. *unused*
20. jmp
21. jr
22. jalr
23. *unused*
24. beq
25. bne
26. blt
27. bge
28. bltu
29. bgeu
30. adc
31. sbc


## Instruction Encoding

At the top-level instructions have the following forms...

Format | Encoding scheme
------ | ---------------
RRR    | `0bkkkk'kccc'aaab'bbxx`
RRI    | `0bkkkk'kccc'aaai'iiii`
RII    | `0bkkkk'kccc'iiii'iiii`
IRI    | `0bkkkk'kiii'aaai'iiii`
IRR    | `0bkkkk'kiii'aaab'bbii`
III    | `0bkkkk'kiii'iiii'iiii`
X      | `0bkkkk'kxxx'xxxx'xxxx`

where 'k' is a 5-bit opcode, 'c' is the index of the register to select in the write back stage, 'a' is the index of the register to select for the ALU left operand, 'b' is the index of the register to select for the ALU right operand, and 'i' is an immediate value.

More generally, there is a field for an opcode and the fields for a, b, and c. Some instructions are able to use unused bits from the latter three fields to form an immediate value. The final two bits may also contribute to an immediate value.



### NOP (X-format)

The NOP instruction specifically has all zero instruction bits. The decoded control signals do not assert any control signals at all. The instruction does nothing.



### HLT (X-format)

The HLT instruction halts the CPU clock. There will be a button to resume execution.



### LOAD (RRI-format)

`0bkkkk'kccc'aaai'iiii`

Loads a sixteen-bit word from memory at the address given by Ra + Imm and writes that value to the register Rc.

```
Rc := mem[Ra + Imm]
```



### STORE (IRR-format)

`0bkkkk'kiii'aaab'bbii`

Stores the contents of the register Rc to memory at the address given by Ra + Imm.

```
mem[Ra + Imm] := Rc
```



### LI (RII-format)

`0bkkkk'kccc'iiii'iiii`

Takes the immediate value, sign-extends it from eight to sixteen bits, and writes it to the register Rc.

```
Rc := Imm
```



### LUI (RII-format)

`0bkkkk'kccc'iiii'iiii`

Takes the immediate value, shifts it left by eight, and writes it to the upper eight bits of the register Rc. (The lower eight bits are unchanged.)

```
Rc[8:15] := Imm
```



### ALU instructions (RRR-format and RRI-format)

The ALU operands are selected by an array of multiplexer circuitry.

The Store Operand may be one of the following...
1. Rb
2. PC + 1
3. Eight-bit immediate value
4. (Eight-bit immediate value) << 8

The Right Operand may be one of the following...
1. Rb
2. The five-bit immediate value, ins[4:0]
3. The five-bit immediate value, ins[10:8, 1:0]
4. The eight-bit immediate value, ins[10:0]

The Left Operand is always Ra.

The instruction decode stage provides control signals to choose the ALU function and set the carry input. The result feeds back to the program counter as well as feeding into the ALU result interstage register. Condition codes produced by the ALU go into a flags register and may be latched if the appropriate control signal is asserted.



### JMP (III-format)

`0bkkkk'kiii'iiii'iiii`

Perform an unconditional pc-relative jump by the eleven-bit offset given in Imm:

```
NPC := PC + Imm
```



### JR (IRI-format)

`0bkkkk'k000'aaai'iiii`

Perform an unconditional absolute jump, computing Ra + Imm and setting PC to the result:

```
NPC := Ra + Imm
```



### JALR (RRI-format)

`0bkkkk'kccc'aaai'iiii`

Perform an unconditional absolute jump, computing Ra + Imm and setting PC to the result. Store the return address in the register Rc.

```
NPC := Ra + Imm
Rc := PC+1
```
	
As this instruction uses a five-bit immediate value, it is expected that most procedure calls will involve a couple of instructions to fill a register with the absolute jump target. The five-bit immediate value is so small that it isn't even expected to be particularly useful, but that removing it entirely is more complicated than leaving it in.



### BEQ (III-format)

`0bkkkk'kiii'iiii'iiii`

Perform a conditional pc-relative jump when the Z flag is set:

```
NPC := PC + Imm
```



### BNE (III-format)

`0bkkkk'kiii'iiii'iiii`

Perform a conditional pc-relative jump when the Z flag is not set:

```
NPC := PC + Imm
```



### BLT (III-format)

`0bkkkk'kiii'iiii'iiii`

Perform a conditional pc-relative jump when the OVF flag is set, performing a signed less-than comparison:

```
NPC := PC + Imm
```



### BGE (III-format)

`0bkkkk'kiii'iiii'iiii`

Perform a conditional pc-relative jump when the OVF flag is not set, performing a signed great-than-or-equal-to comparison:

```
NPC := PC + Imm
```



### BLTU (III-format)

`0bkkkk'kiii'iiii'iiii`

Perform a conditional pc-relative jump when the Carry flag is set, performing an unsigned less-than comparison:

```
NPC := PC + Imm
```



### BGEU (III-format)

`0bkkkk'kiii'iiii'iiii`

Perform a conditional pc-relative jump when the Carry flag is not set, performing an unsigned great-than-or-equal-to comparison:

```
NPC := PC + Imm
```


# TurtleTools

TurtleTools is a toolchain for the Turtle16 microcomputer hardware. This includes a computer Simulator, Assembler, and a compiler for a new high-level language targeting the hardware.