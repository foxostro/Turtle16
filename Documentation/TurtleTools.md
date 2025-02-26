# Turtle16: TurtleTools

TurtleTools is a toolchain for the Turtle16 microcomputer hardware. This includes a computer Simulator, Assembler, and a Compiler for a new high-level language targeting the hardware.

# Simulator16

![Simulator16 Screen Shot](../TurtleTools/ScreenShots/Simulator16.png?raw=true "Simulator16 Screen Shot")

The Simulator app allows simulation of program execution. The interactive debugger allows careful inspection of computer state at each clock tick. There is a view to show disassembly of code in instruction memory. There are views to display the contents of memory in the computer's various address spaces.

The current implementation of the Simulator app attempts to accurately model all the individual pieces of hardware, including compiling and emulating GAL HDL code. The implementation sacrifices performance in favor of a model which will be useful in debugging the actual hardware. A faster interpreter, or even a JIT, is a project that could be attempted in the future.

Please refer to the TurtleTools/Examples/ directory for examples of saved simulator sessions.


# TurtleAssembler

```
usage: TurtleAssembler <INPUT> <OUTPUT>
```

The TurtleAssembler command line tool compiles a single file of assembly source code to a single instruction memory image.

Example assembly program:
```
# Turtle16 program to compute fibonacci numbers.
NOP # We must start a program with a single NOP instruction.
LI r0, 0
LI r1, 1
LI r7, 0
loop:
ADD r2, r0, r1
ADDI r0, r1, 0
ADDI r7, r7, 1
ADDI r1, r2, 0
CMPI r7, 9
BLT loop
HLT
```

Please refer to the TurtleTools/Examples/ directory for more example code.


# Snap

There is also a compiler for a new high-level language called Snap which is covered in more detail [here](Snap.md). Programs written in this language are compiled to machine code which can execute in the simulator app and flashed to instruction EEPROM to be run on real hardware.


```
USAGE:
Snap [test] [options] file...

OPTIONS:
	test       Compile the program for testing and run immediately in a VM.
	-h         Display available options
	-o <file>  Specify the output filename
	-S         Output assembly code
	-ir        Output intermediate representation
	-ast-dump  Print the abstract syntax tree to stdout
	-q         Quiet. Do not print progress to stdout
	-O0        Disable optimizations
```

There is also a compiler for a new high-level language called Snap.

Example Snap program:
```
var a = 1
var b = 1
for i in 0..10 {
	var fib = b + a
	a = b
	b = fib
}
```

Another, slightly more complex example:
```
import audio
import serial

func main() {
	let noteLength = 2
	setMasterAudioGain(0x80)
	serialInit()
	serialPuts("Piano\n")
	while true {
		while serialCount() == 0 {}
		let character = serialGet()
		if character == 'a' {
			serialPuts("A3\n")
			playNote(noteA3, noteLength)
		}
		else if character == 's' {
			serialPuts("B3\n")
			playNote(noteB3, noteLength)
		}
		else if character == 'd' {
			serialPuts("C4\n")
			playNote(noteC4, noteLength)
		}
		else if character == 'f' {
			serialPuts("D4\n")
			playNote(noteD4, noteLength)
		}
		else if character == 'g' {
			serialPuts("E4\n")
			playNote(noteE4, noteLength)
		}
		else if character == 'h' {
			serialPuts("F4\n")
			playNote(noteF4, noteLength)
		}
		else if character == 'j' {
			serialPuts("G4\n")
			playNote(noteG4, noteLength)
		}
		else if character == 'k' {
			serialPuts("A4\n")
			playNote(noteA4, noteLength)
		}
		else if character == 'l' {
			serialPuts("B4\n")
			playNote(noteB4, noteLength)
		}
	}
}

```

Please refer to the TurtleTools/Examples/ directory for more example code. The [ReceiveFile.snap](../TurtleTools/Examples/ReceiveFile.snap) program show cases structs, traits, dynamic dispatch, unit tests, and other language features.