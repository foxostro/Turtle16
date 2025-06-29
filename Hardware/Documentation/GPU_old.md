# Crush, a GPU for Turtle16

## Specifications

Crush is a CPU designed for graphics applications and so will also be referred to as a GPU in this document. It has thirty-two sixteen-bit general purpose registers, a six stage pipeline, and a separate 64K address space for instruction memory and RAM.

An additional 64K address space is available for RAM which is shared with the controlling CPU. This is accessed with a separate set of load/store instructions. Fast copies between address spaces are possible with a special blit instruction.

The pipeline implements fine-grained multithreading. Each clock the CPU will switch to a different hardware thread, maintaining a separate register file and program counter per thread. This avoids the need for hardware interlocks and pipeline hazard control. There are no stalls. Branch prediction and branch delay slots are not necessary in this scheme. Since the register file is built from an SRAM, this may be implemented by putting the Thread ID into the upper bits of the memory's address input.

A memory-mapped control register will allow the controlling CPU to set the number of threads to execute, with a special value of zero meaning that the entire GPU is to be halted. Typically, the CPU will operate with a number of threads equal to the number of tiles in the frame buffer.

The CPU has special address decoding hardware in the MEM stage to allow each thread to retrieve it's Thread ID from a special memory-mapped register.

A RAMDAC reads the RAM simultaneously with the GPU in order to generate the video signal. It swaps between two 200x150 (30,000 words) frame buffers. This leaves 5,536 words which may be used by the GPU for memory-mapped registers and working memory.

The EX includes a 16-bit ALU for basic arithmetic operations, and also a barrel shifter for performing a logical bit shift in one clock cycle.



## Pipeline

1. IF -- Instruction Fetch
2. ID -- Instruction Decode
3. EX -- Execute
4. MEMA -- Access the first address space, shared with CPU
5. MEMB -- Access the second address space, shared with RAMDAC
6. WB -- Write back



### Intruction Formats

Instructions may take one of the following formats:

Format | Encoding scheme
------ | ---------------
RR     | `0bkkkk'kkaa'aaab'bbbb`
RI     | `0bkkkk'kkaa'aaai'iiii`
I      | `0bkkkk'kkii'iiii'iiii`

The `k' field is a always a six-bit opcode. The `a' field is both the register to use in the right operand and an implied destination register. The `b' field indicates a register to use as the left operand. Otherwise, the RI format replaces the `b' field with a 5-bit opcode. The I format replaces both the `a' and `b' fields with a 10-bit immediate field.


### Opcodes

0. nop
1. hlt
2. lw
3. sw
4. lw2
5. sw2
6. bitblt
7. li
8. li10
9. mov
10. cmp
11. add
12. sub
13. and
14. or
16. xor
17. lsl
18. lsr
19. not
20. cmpi
21. addi
22. subi
23. andi
24. ori
25. xori
26. lsli
27. lsri
28. jmp
29. jr
30. jalr
31. beq / bz
32. bne / bnz
33. blt
34. bge
35. ble
36. bgt
37. bltu
38. bgeu
39. bleu
40. bgtu

Remaining opcodes are reserved for future expansion.



#### NOP (X-format)

The NOP instruction does nothing.



#### HLT (X-format)

The HLT instruction halts the CPU clock. There will be a button to resume execution.



#### LW (RR-format)

`0bkkkk'kkaa'aaab'bbbb`

Loads a sixteen-bit word from memory address space A at the address given by Rb and writes that value to the register Ra.

```
Ra := mem[Rb]
```



#### SW (RR-format)

`0bkkkk'kkaa'aaab'bbbb`

Stores the contents of the register Rb to memory in memory address space B at the address given by Ra.

```
mem[Ra] := Rb
```



#### LW2 (RR-format)

`0bkkkk'kkaa'aaab'bbbb`

Loads a sixteen-bit word from memory address space B at the address given by Rb and writes that value to the register Ra.

```
Ra := mem[Rb]
```



#### SW2 (RR-format)

`0bkkkk'kkaa'aaab'bbbb`

Stores the contents of the register Rb to memory in memory address space B at the address given by Ra.

```
mem[Ra] := Rb
```



#### BITBLT (RR-format)

`0bkkkk'kkaa'aaab'bbbb`

Reads a value from memory address A at the address given by Rb. If the Alpha bit is set then the value us stored to memory address space B at the address given by Ra. This permits the GPU to implement a simple form of transparency.

```
mem[Ra] := Rb
```



#### LI (RI-format)

`0bkkkk'kkaa'aaai'iiii`

Takes the immediate value, sign-extends it to sixteen bits, and writes it to the register Ra.

```
Rc := Imm
```



#### LI10 (I-format)

`0bkkkk'kkii'iiii'iiii`

Takes the 10-bit immediate value, sign-extends it to sixteen bits, and writes it to the register r0.

```
r0 := Imm
```



#### MOV (RR-format)

`0bkkkk'kkaa'aaab'bbbb`

Copies the value of register Rb to register Ra.

```
Ra := Rb
```



#### ALU instructions (RR-format and RI-format)

The ALU operands are selected by an array of multiplexer circuitry.

The Store Operand may be one of the following...
1. Rb
2. PC + 1
3. 5-bit immediate value, sign-extended
4. 10-bit immediate value, sign-extended

The Right Operand may be one of the following...
1. Rb
2. The 5-bit immediate value, sign-extended
3. 10-bit immediate value, sign-extended

The Left Operand is always Ra.

The instruction decode stage provides control signals to choose the ALU function and set the carry input. The result feeds back to the program counter as well as feeding into the ALU result interstage register. Condition codes produced by the ALU go into a flags register and may be latched if the appropriate control signal is asserted.



#### JMP (I-format)

`0bkkkk'kkii'iiii'iiii`

Perform an unconditional pc-relative jump by the 10-bit offset given in Imm:

```
NPC := PC + Imm
```



#### JR (RI-format)

`0bkkkk'kkaa'aaai'iiii`

Perform an unconditional absolute jump, computing Ra + Imm and setting PC to the result:

```
NPC := Ra + Imm
```



#### JALR (RR-format)

`0bkkkk'kkaa'aaab'bbbb`

Perform an unconditional absolute jump, computing Rb + Imm and setting PC to the result. Store the return address in the register Ra.

```
NPC := Rb
Ra := PC+1
```



#### BEQ (I-format)

`0bkkkk'kkii'iiii'iiii`

Perform a conditional pc-relative jump when the Z flag is set:

```
NPC := PC + Imm
```



#### BNE (III-format)

`0bkkkk'kkii'iiii'iiii`

Perform a conditional pc-relative jump when the Z flag is not set:

```
NPC := PC + Imm
```



#### BLT (III-format)

`0bkkkk'kkii'iiii'iiii`

Perform a conditional pc-relative jump when the OVF flag is set, performing a signed less-than comparison:

```
NPC := PC + Imm
```



#### BGE (III-format)

`0bkkkk'kkii'iiii'iiii`

Perform a conditional pc-relative jump when the OVF flag is not set, performing a signed greater-than-or-equal-to comparison:

```
NPC := PC + Imm
```



#### BLTE (III-format)

`0bkkkk'kkii'iiii'iiii`

Perform a conditional pc-relative jump when ?, performing a signed less-than-or-equal-to comparison:

```
NPC := PC + Imm
```



#### BGT (III-format)

`0bkkkk'kkii'iiii'iiii`

Perform a conditional pc-relative jump when ?, performing a signed greater-than comparison:

```
NPC := PC + Imm
```



#### BLTU (III-format)

`0bkkkk'kkii'iiii'iiii`

Perform a conditional pc-relative jump when the Carry flag is set, performing an unsigned less-than comparison:

```
NPC := PC + Imm
```



#### BGEU (III-format)

`0bkkkk'kkii'iiii'iiii`

Perform a conditional pc-relative jump when the Carry flag is not set, performing an unsigned greater-than-or-equal-to comparison:

```
NPC := PC + Imm
```



#### BLTEU (III-format)

`0bkkkk'kkii'iiii'iiii`

Perform a conditional pc-relative jump when ?, performing an unsigned less-than-or-equal-to comparison:

```
NPC := PC + Imm
```



#### BGTU (III-format)

`0bkkkk'kkii'iiii'iiii`

Perform a conditional pc-relative jump when ?, performing an unsigned greater-than comparison:

```
NPC := PC + Imm
```




### Render Kernel

The general algorithm for rendering a tile is as follows. This assumes all sprites are 16x16 so we don’t need to consider the overhead of a dynamic loop or loading the width from memory. Also, the number of virtual sprites is fixed at compile time.

```
struct Sprite {
    srcX: u16
    srcY: u16
    dstX: u16
    dstY: u16
    width: u16
    height: u16
}

let spriteList: [numSprites ; Sprite]
let rasterY: Int = gThreadID

while true {
	for i in 0..kNumberOfSprites {
		// If the sprite overlaps the raster row that we're working on then copy one row of it now. The frame buffer is 256x256, all positions are in [0, 255] and sprites always wrap around the edge of the left and right edge of the frame buffer. We can hide this wrap around by setting some scroll registers on the RAMDAC.
		let srcY = spriteList[i].srcY
		var height = spriteList[i].height
		let y = srcY - rasterY
  	if y > 0 && y < height {
	    let srcX = spriteList[i].srcX
	    let dstX = spriteList[i].dstX
	    let dstY = spriteList[i].dstY
	    var width = spriteList[i].width
	    while height > 0 {
	    	let srcUpper = (srcY + height) << 8
	    	let dstUpper = (dstY + height) << 8
	      while width > 0 {
	        let src: *u16 = srcUpper | (srcX + width)
	        let dst: *u16 = dstUpper | (dstX + width)
	        bitblit(dst, src)
	        width -= 1
	      }
	      height -= 1
	    }
	} // for

	if rasterY == kFrameBufferHeight-1 {
		flipPage()
	} else {
		waitForPageFlip()
	}
} // while true
```

Manually compiling to assembly code, using readable names instead of register names:
```
# let rasterY: Int = gThreadID
LI10 r0, &gThreadID
LOAD tid, r0

LI10 r0, &gCurrentPage
LOAD currentPage, r0

# while true {
MainLoop:

# for i in 0..kNumberOfSprites {
LI10 r0, &spriteList
MOV spriteAddr, r0
SpriteLoop:
LI10 i, kNumberOfSprites


# let srcY = spriteList[i].srcY

LOAD srcY, spriteAddr


		var height = spriteList[i].height
		let y = srcY - rasterY
  	if y > 0 && y < height {
	    let srcX = spriteList[i].srcX
	    let dstX = spriteList[i].dstX
	    let dstY = spriteList[i].dstY
	    var width = spriteList[i].width
	    while height > 0 {
	    	let srcUpper = (srcY + height) << 8
	    	let dstUpper = (dstY + height) << 8
	      while width > 0 {
	        let src: *u16 = srcUpper | (srcX + width)
	        let dst: *u16 = dstUpper | (dstX + width)
	        bitblit(dst, src)
	        width -= 1
	      }
	      height -= 1
	    }

# } // for
ADDI spriteAddr, sizeof(Sprite)
SUBI i, 1
BNZ SpriteLoop

# if rasterY == kFrameBufferHeight-1 {
LI10 r0, kFrameBufferHeight-1
CMP rasterY, r0
BNZ WaitForPageFlip
# Flip the page
LI10 r0, &gCurrentPage
LOAD currentPage, r0
XOR currentPage, 1 # Toggle the LSB to swap the page
STORE r0, currentPage
JMP endIf
WaitForPageFlip:
LI10 r0, &gCurrentPage
LOAD nextPage, r0
CMP currentPage, nextPage
BEQ WaitForPageFlip
endIf:

# } // while true
JMP MainLoop
```