# Turtle16 ISA

This document describes the Instruction Set Architecture of the Turtle16 CPU, a sixteen-bit RISC CPU with eight general-purpose registers. The CPU has been designed to avoid delay slots, a classic RISC pitfall.



## Opcodes

The ID stage uses a ROM to decode a five-bit opcode into an array of control signals. The opcodes are as follows.

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
27. bgt
28. bltu
29. bgtu
30. adc
31. sbc


## Condition Codes

The CPU uses an internal register to record four condition codes, used in conditional instructions BEQ, BNE, BLT, BGT, BLTU, BGTU, ADC, and SBC. The condition codes are...
* C -- Carry. The ALU computation cannot fit in the result and carries out a bit.
* Z -- Zero. The result is zero.
* V -- Overflow. The ALU computation results in twos complement signed overflow.
* N -- Negative. The most significant bit of the result is set.


## Instruction Encoding

At the top-level instructions have the following forms...

Format | Encoding scheme
------ | ---------------
RRR    | `0bkkkk'kccc'aaab'bbxx`
RRI    | `0bkkkk'kccc'aaai'iiii`
RII    | `0bkkkk'kccc'iiii'iiii`
XRI    | `0bkkkk'kxxx'aaai'iiii`
IRR    | `0bkkkk'kiii'aaab'bbii`
III    | `0bkkkk'kiii'iiii'iiii`
X      | `0bkkkk'kxxx'xxxx'xxxx`

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

Stores the contents of the register Rb to memory at the address given by Ra + Imm.

```
mem[Ra + Imm] := Rb
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

The instruction decode stage provides control signals to choose the ALU function and set the carry input. The result feeds back to the program counter as well as feeding into the ALU result interstage register. Condition codes produced by the ALU go into an internal flags register and may be latched if the appropriate control signal is asserted.



### JMP (III-format)

`0bkkkk'kiii'iiii'iiii`

Perform an unconditional pc-relative jump by the eleven-bit offset given in Imm:

```
NPC := PC + Imm
```



### JR (XRI-format)

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

Perform a conditional pc-relative jump when Z==1:

```
NPC := PC + Imm
```



### BNE (III-format)

`0bkkkk'kiii'iiii'iiii`

Perform a conditional pc-relative jump when Z==0:

```
NPC := PC + Imm
```



### BLT (III-format)

`0bkkkk'kiii'iiii'iiii`

Perform a conditional pc-relative jump when N!=V, performing a signed less-than comparison:

```
NPC := PC + Imm
```



### BGT (III-format)

`0bkkkk'kiii'iiii'iiii`

Perform a conditional pc-relative jump when (Z==0) && (N==V), performing a signed greater-than comparison:

```
NPC := PC + Imm
```



### BLTU (III-format)

`0bkkkk'kiii'iiii'iiii`

Perform a conditional pc-relative jump when C==0, performing an unsigned less-than comparison:

```
NPC := PC + Imm
```



### BGTU (III-format)

`0bkkkk'kiii'iiii'iiii`

Perform a conditional pc-relative jump when C==1 && Z==0, performing an unsigned greater-than comparison:

```
NPC := PC + Imm
```
