# Crush, a pipelined multithreaded GPU for Turtle16

## Specifications

Crush is a CPU designed for graphics applications and so will also be referred to as a GPU in this document. It has thirty-two sixteen-bit general purpose registers, a six stage pipeline, and a separate 64K address space for instruction memory and RAM. While the data memory bus and eah register is sixteen-bits wide, the instruction word itself is 32-bits wide.

An additional 64K address space is available for RAM which is shared with the controlling CPU. This is accessed with a separate set of load/store instructions. Fast copies between address spaces are possible with a special blit instruction.

The pipeline implements fine-grained multithreading. Each clock the CPU will switch to a different hardware thread, maintaining a separate register file and program counter per thread. This avoids the need for hardware interlocks and pipeline hazard control. There are no stalls. Branch prediction and branch delay slots are not necessary in this scheme. Since the register file is built from an SRAM, this may be implemented by putting the Thread ID into the upper bits of the memory's address input.

A memory-mapped control register will allow the controlling CPU to set the number of threads to execute, with a special value of zero meaning that the entire GPU is to be halted. Typically, the CPU will operate with a number of threads equal to the number of tiles in the frame buffer.

The CPU has special address decoding hardware in the MEM stage to allow each thread to retrieve it's Thread ID from a special memory-mapped register.

The EX stage of the pipeline includes a 16-bit ALU for basic arithmetic operations, and also a barrel shifter for performing a logical bit shift in one clock cycle. (Aside: the render kernel discussed below only uses left shifts by three and by eight. So we could get away with implementing a bit shifter which provides this functionality and not a full barrel shifter.)

The GPU-side memory bank swaps between two 256x256 frame buffers according to a memory-mapped control register which is used to select the current page and flip pages. The RAMDAC operates on the opposite bank of memory as the GPU at all times. The RAMDAC will generate a video signal using a 200x150 window in the frame buffer which can be moved with a pair of memory-mapped scrolling control registers. 

Image data is always assumed to be in power-of-two sizes. Images in memory and in the frame buffer are assumed to be addressable with simple bit shift and bitwise-or so as to reduce the amount of arithmetic needed to index into the bitmaps. Like so: `addr = ((y << 8) | x)`. This leads to behavior where sprites always wrap around the edges of the frame buffer. Use the scrolling registers to move this wrapping behavior off screen if this is undesirable.

The first version of Crush will probably have a single execution core. However, it seems at this stage that most pipeline stages will be able to operate twice in one clock, with the exception perhaps of control logic and the ALU. Specifically, it may be possible to perform two instruction fetches and two memory accesses (per bank) in one clock cycle. A dual-core processor implementation is therefore a possibility which would immediately double the performance of the GPU.



## Pipeline

1. IF -- Instruction Fetch
2. ID -- Instruction Decode
3. EX -- Execute
4. MEMA -- Access the first address space, shared with CPU
5. MEMB -- Access the second address space, shared with RAMDAC
6. WB -- Write back



### Instruction Formats

Instructions may take one of the following formats:

Format | Encoding scheme
------ | ------------------------------------------------
I      | `0bkkkk'kkcc'ccca'aaaa'iiii'iiii'iiii'iiii'iiii`
R      | `0bkkkk'kkcc'ccca'aaaa'bbbb'bbxx'xxxx'xxxx'xxxx`
X      | `0bkkkk'kkxx'xxxx'xxxx'xxxx'xxxx'xxxx'xxxx'xxxx`

The `k' field is a 6-bit opcode.
The `c' field is a 5-bit index to specify the destination register.
The `a' field is a 5-bit index to specify the left operand register.
The `b' field is a 5-bit index to specify the right operand register.
The `i` field is a 16-bit immediate value.


### Opcodes

0. nop
1. hlt
2. lw
3. sw
4. lw2
5. sw2
6. bitblt
7. li
8. add
9. addi
10. sub
11. subi
12. and
13. andi
14. or
15. ori
16. xor
17. xori
18. lsl
19. lsli
20. lsr
21. lsri
22. not
23. jmp
24. jr
25. jalr
26. beq
27. bne
28. blt
29. bge
30. ble
31. bgt
32. bltu
33. bgeu
34. bleu
35. bgtu

Remaining opcodes are reserved for future expansion.



#### NOP (X-format)

The NOP instruction does nothing. An instruction word which contains all zeroes is always a NOP.



#### HLT (X-format)

The HLT instruction halts the CPU clock. There will be a button to resume execution.



#### LW (R-format)

Loads a sixteen-bit word from memory address space 1 at the address given by Ra and writes that value to the register Rc. The immediate value allows the program to specify a static offset into memory.

```
Rc := mem1[Ra + Imm]
```



#### SW (I-format)

Stores the contents of the register Rc to memory in memory address space 1 at the address given by Ra. The immediate value allows the program to specify a static offset into memory.

```
mem1[Ra + Imm] := Rc
```



#### LW2 (I-format)

Loads a sixteen-bit word from memory address space 2 at the address given by Ra and writes that value to the register Rc. The immediate value allows the program to specify a static offset into memory.

```
Rc := mem2[Ra + Imm]
```



#### SW2 (I-format)

Stores the contents of the register Rc to memory in memory address space 2 at the address given by Ra. The immediate value allows the program to specify a static offset into memory.

```
mem2[Ra + Imm] := Rc
```



#### BITBLT (I-format)

Reads a value from memory address A at the address given by Ra. If the Alpha bit is set then the value is stored to memory address space B at the address given by Ra. This permits the GPU to implement screen door transparency. The immediate value allows the program to specify a static offset into memory.

```
mem2[Ra + Imm] := mem1[Ra + Imm]
```



#### LI (I-format)

Takes the 16-bit immediate value and writes it to the register Rc.

```
Rc := Imm
```



#### ADD (R-format)

Adds the values of the two register operands and writes the result to register Rc.

```
Rc := Ra + Rb
```



#### ADDI (I-format)

Adds the values of the register operand to the immediate value and writes the result to register Rc.

```
Rc := Ra + Imm
```



#### SUB (R-format)

Subtracts the values of the two register operands and writes the result to register Rc.

```
Rc := Ra + Rb
```



#### SUBI (I-format)

Subtracts the immediate value from the register operand and writes the result to register Rc.

```
Rc := Ra - Imm
```



#### AND (R-format)

Computes the bitwise AND of the values of the two register operands and writes the result to register Rc.

```
Rc := Ra & Rb
```



#### ANDI (I-format)

Computes the bitwise AND the values of the register operand and the immediate value and writes the result to register Rc.

```
Rc := Ra & Imm
```



#### OR (R-format)

Computes the bitwise OR of the values of the two register operands and writes the result to register Rc.

```
Rc := Ra | Rb
```



#### ORI (I-format)

Computes the bitwise OR the values of the register operand and the immediate value and writes the result to register Rc.

```
Rc := Ra | Imm
```



#### XOR (R-format)

Computes the bitwise XOR of the values of the two register operands and writes the result to register Rc.

```
Rc := Ra ^ Rb
```



#### XORI (I-format)

Computes the bitwise XOR the values of the register operand and the immediate value and writes the result to register Rc.

```
Rc := Ra ^ Imm
```



#### LSL (R-format)

Computes the logical left shift of the two register operands and writes the result to register Rc.

```
Rc := Ra << Rb
```



#### LSLI (I-format)

Computes the logical left shift of the register operand and the immediate value and writes the result to register Rc.

```
Rc := Ra << Imm
```



#### LSR (R-format)

Computes the logical right shift of the two register operands and writes the result to register Rc.

```
Rc := Ra >> Rb
```



#### LSRI (I-format)

Computes the logical right shift of the register operand and the immediate value and writes the result to register Rc.

```
Rc := Ra >> Imm
```



#### NOT (I-format)

Computes the bitwise negation of the register operand and writes the result to register Rc.

```
Rc := ~Ra
```



#### JMP (I-format)

Perform an unconditional pc-relative jump by the offset specified in the 16-bit immediate value.

```
NPC := PC + Imm
```



#### JR (R-format)

Perform an unconditional absolute jump, computing Ra + Imm and setting PC to the result:

```
NPC := Ra + Imm
```



#### JALR (I-format)

Perform an unconditional absolute jump to the branch target specified by Ra + Imm. Store the return address in the register Rc.

```
NPC := Ra + Imm
Rc := PC
```



#### BEQ (I-format)

Compare the values of the two register operands. If Ra == Rb then perform a pc-relative jump by the offset specified in the immediate value.

```
NPC := PC + Imm
```



#### BNE (I-format)

Compare the values of the two register operands. If Ra != Rb then perform a pc-relative jump by the offset specified in the immediate value.

```
NPC := PC + Imm
```



#### BLT (I-format)

Compare the values of the two register operands. If Ra < Rb then perform a pc-relative jump by the offset specified in the immediate value.

```
NPC := PC + Imm
```



#### BGE (I-format)

Compare the values of the two register operands. If Ra >= Rb then perform a pc-relative jump by the offset specified in the immediate value.

```
NPC := PC + Imm
```



#### BLTE (I-format)

Compare the values of the two register operands. If Ra <= Rb then perform a pc-relative jump by the offset specified in the immediate value.

```
NPC := PC + Imm
```



#### BGT (I-format)

Compare the values of the two register operands. If Ra > Rb then perform a pc-relative jump by the offset specified in the immediate value.

```
NPC := PC + Imm
```



#### BLTU (I-format)

Compare the values of the two register operands. If Ra < Rb then perform a pc-relative jump by the offset specified in the immediate value. This is an unsigned comparison.

```
NPC := PC + Imm
```



#### BGEU (I-format)

Compare the values of the two register operands. If Ra >= Rb then perform a pc-relative jump by the offset specified in the immediate value. This is an unsigned comparison.

```
NPC := PC + Imm
```



#### BLTEU (I-format)

Compare the values of the two register operands. If Ra <= Rb then perform a pc-relative jump by the offset specified in the immediate value. This is an unsigned comparison.

```
NPC := PC + Imm
```



#### BGTU (I-format)

Compare the values of the two register operands. If Ra > Rb then perform a pc-relative jump by the offset specified in the immediate value. This is an unsigned comparison.

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
}

let spriteList: [numSprites ; Sprite]
let rasterY: Int = gThreadID
let dst0 = rasterY << 8

while true {
	// Draw the background tile layer
	for tileX in 0..<kTileMapWidth {
		let tileId = tileMap[rasterY + tileX]
		let tilePixel = tileImageData[tileId]
		let dst = dst0 + (tileX * 8)
		bitblit(dst, tilePixel, 0)
		bitblit(dst, tilePixel, 1)
		bitblit(dst, tilePixel, 2)
		bitblit(dst, tilePixel, 3)
		bitblit(dst, tilePixel, 4)
		bitblit(dst, tilePixel, 5)
		bitblit(dst, tilePixel, 6)
		bitblit(dst, tilePixel, 7)
	}

	for i in 0..kNumberOfSprites {
		let srcY = spriteList[i].srcY
		let y = srcY - rasterY
  	if y > 0 && y < kSpriteHeight {
	    let srcX = spriteList[i].srcX
	    let src = (y << 8) | srcX
    	let dst = dst0 | dstX

    	bitblit(dst, src, 0)
    	bitblit(dst, src, 1)
    	bitblit(dst, src, 2)
    	bitblit(dst, src, 3)
    	bitblit(dst, src, 4)
    	bitblit(dst, src, 5)
    	bitblit(dst, src, 6)
    	bitblit(dst, src, 7)
    	bitblit(dst, src, 8)
    	bitblit(dst, src, 9)
    	bitblit(dst, src, 10)
    	bitblit(dst, src, 11)
    	bitblit(dst, src, 12)
    	bitblit(dst, src, 13)
    	bitblit(dst, src, 14)
    	bitblit(dst, src, 15)
    } // if
	} // for

	if rasterY == kFrameBufferHeight-1 {
		flipPage()
	} else {
		waitForPageFlip()
	}
} // while true
```

Manually compile to assembly code. Use readable names instead of register names. There are less than 32 unique names here so there won't be any register spilling:

```
# let rasterY: Int = gThreadID
LI tid, &gThreadID

LI zero, 0
LI currentPage, &gCurrentPage

# let dst0 = rasterY << 8
LSLI dst0, rasterY, 8

LI spriteAddr, &gSpriteList

LI tileMapAddr0, &gTileMap
ADD tileMapAddr0, tileMapAddr0, rasterY

LI tileImageDataAddr, &gTileImageData


# while true {
MainLoop:

# Optimized code to draw the tile map on this row...
# This takes 12*25=300 cycles
for tileX in 0..<32 {
	LW tile, tileMapAddr0, tileX
	LSLI tile, 3
	ADD tile, tileImageDataAddr, tile
	ADDI tileDst, dst0, tileX
	BITBLIT tileDst, tile, 0
	BITBLIT tileDst, tile, 1
	BITBLIT tileDst, tile, 2
	BITBLIT tileDst, tile, 3
	BITBLIT tileDst, tile, 4
	BITBLIT tileDst, tile, 5
	BITBLIT tileDst, tile, 6
	BITBLIT tileDst, tile, 7
}

# for i in 0..<kNumberOfSprites {
SpriteLoop:
LI i, kNumberOfSprites

# let srcY = spriteList[i].srcY
LW srcY, spriteAddr, offsetof(srcY)

# var height = spriteList[i].height
LW height, spriteAddr, offsetof(height)

# let y = srcY - rasterY
SUB y, srcY, rasterY

# if y > 0 && y < height {
BLE y, zero, NotInBounds
BGE y, height, NotInBounds

# let srcX = spriteList[i].srcX
LW srcX, spriteAddr, offsetof(srcX)

# let src = (y << 8) | srcX
LSLI src, y, 8
OR src, src, srcX

# let dst = dst0 | dstX
OR dst, dst0, dstX

BITBLIT dst, src, 0
BITBLIT dst, src, 1
BITBLIT dst, src, 2
BITBLIT dst, src, 3
BITBLIT dst, src, 4
BITBLIT dst, src, 5
BITBLIT dst, src, 6
BITBLIT dst, src, 7
BITBLIT dst, src, 8
BITBLIT dst, src, 9
BITBLIT dst, src, 10
BITBLIT dst, src, 11
BITBLIT dst, src, 12
BITBLIT dst, src, 13
BITBLIT dst, src, 14
BITBLIT dst, src, 15

# } // if
NotInBounds:

# } // for
ADDI spriteAddr, sizeof(Sprite)
SUBI i, 1
BNZ SpriteLoop

# if rasterY == kFrameBufferHeight-1 {
LI10 currentPageAddr, &gCurrentPage
LI10 frameBufferHeightMinusOne, kFrameBufferHeight-1
BEQ rasterY, frameBufferHeightMinusOne, WaitForPageFlip
# Flip the page
LW currentPage, currentPageAddr
XOR currentPage, 1 # Toggle the LSB to swap the page
SW currentPageAddr, currentPage
JMP endIf
WaitForPageFlip:
LOAD nextPage, currentPageAddr
BEQ currentPage, nextPage, WaitForPageFlip
endIf:

# } // while true
JMP MainLoop
```


### Render Kernel Performance

The render kernel can operate on an unlimited number of 16x16 sprites. However, at a certain point, performance will degrade and we'll be unable to meet the frame time budget. Let's make some assumptions and then calculate a rough estimate of the time needed to render a frame.

The tile map is a 32x32 map and each tile is 8x8 in size. We only render 25 tiles because those are the ones that are visible on screen. We support three tile map layers.

Assume there are N sprites in the sprite list. Assume a 20MHz clock cycle (50ns). Assume the machine supports up to 256 threads, and that we'll be using 150 of those to render the 150 visible rows of the frame buffer.

In 32ms, there are 640,000 clock cycles. We divide those cycles between 150 threads to get a budget of 4266 cycles per thread.

Manually counting the cycles in the above program, we express the number of clock cycles in terms of the number of sprites N, considering only the main loop:

```
SpriteLoop = N * 29
PageFlip = 7
MainLoop = 300*3 + 4 + SpriteLoop + PageFlip
4266 = 300*3 + 4 + N*29 + 7
N = (4266 - (300*3 + 4 + 7)) / 19
N = 176.6
```

A maximum of 176 sprites is great! I'd probably cap it at 128 to provide some slack.

Possibly, there's enough free cycles to add additional features such as adding fine scrolling to the tile map layers.

If we add a second thread to the GPU then performance greatly improves. Each core can operate on one half of the frame buffer. Each thread would then immediately have double the amount of time to complete it's work:

```
SpriteLoop = N * 29
PageFlip = 7
MainLoop = 300*3 + 4 + SpriteLoop + PageFlip
8533 = 300*3 + 4 + N*29 + 7
N = (8533 - (300*3 + 4 + 7)) / 19
N = 401
```

A maximum of 401 sprites is more than enough. So we could consider instead adding new features such as sprites of different sizes and additional scrolling capabilities. Transparency with blending might be possible if it's used for a small number of on-screen sprites.

I'm fairly certain there isn't going to be enough cycles to implement sprite scaling or rotation.

The CPU can change the program on the GPU to change it's capabilities to suit the needs of the current app. For example, one game could use blending transparency and another uses lots of sprites. Some apps may want to proceed at a lower frame rate and use the cycles for something like line drawing, or raw pixel access, in a paint program.

Using eight bits of the register file address lines for a thread ID means we cannot use 4K x 16 dual port SRAMS here. So if 256 threads is too many then we consider chaning the kernel to have it handle multiple scanlines ever frame. (Unroll the loop at the expense of additional instruction memory.) The 4K x 16 SRAMs have 12 address lines. We need 5 for the register IDs which leaves 7 for a thread ID. That allows for up to 127 threads. So, we can run with 75 threads and have each one handle two rows.
