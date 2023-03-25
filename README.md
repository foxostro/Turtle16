# Turtle16

Turtle16 is a sixteen-bit microcomputer built from discrete logic ICs and other simple parts. This repo contains the Kicad project, and other files necesary to build the hardware, as well as the simulator, assembler, and compiler.

[![Photo of Turtle16 CPU](Documentation/Turtle16_Rev_B_Photo_Small.jpg?raw=true "Photo of Turtle16 CPU")](Documentation/Turtle16_Rev_B_Photo.jpg)


## Computer Specifications

* Sixteen-bit homebrew CPU
* Five stage classic RISC pipeline, executing one instruction per clock cycle
* Eight general-purpose registers
* Operand forwarding to automatically resolve read-after-write hazards
* Pipeline stalls to automatically resolve other sorts of hazards
* No branch delay slots
* Primitive branch prediction, always predicting the branch is not taken


## Why did you do this?

I find computer architecture to be very interesting. Having already built a couple of homebrew breadboard computers in the style of the SAP-1, I wanted to do something more advanced. This an opportunity to learn how the classic five stage RISC pipeline works. While it would also be possible to build something like this in an FPGA, or even just an HDL simulator, I appreciate the physical reality of building an actual thing. At the same time, I've been learning so much about PCB layout, circuit design, circuit assembly and construction, and debugging, much of which seems broadly applicable to any electronics project.

Careful self-imposed limitations are important for a successful project. Limitation breeds creativity. For this project, the implementation of the CPU itself has been constrained to use only simple 7400-style parts. This means sticking to discrete logic and other medium-scale integration parts. Microprocessors and advanced FPGAs have been avoided. An exception has been made for primitive GALs as these fit the retro computer aesthetic.

For the computer's peripherals, I might relax these limitations in favor of getting something working. For example, I'm considering using an Arduino to interface with a PC. The sound hardware could be built around a retro-style audio IC such as one of the Yamaha OPL series chips or the Phillips SAA1099.

The danger of relaxing limitations is that it raises the question, why not go further? If I decide it's fine to implement graphics using a retro-style chip like the TMS9918A then why not use a Raspberry Pi, or the Gameduino 3X Dazzler? Why not simply implement the entire computer in an emulator running on a Raspberry Pi? Once placed in an enclosure, it won't look any different. The answer is that the project is not about the goal of building a working computer, or the goal of playing some games. This project is centered around learning how computers work.


## Getting Started

![Simulator16 Screen Shot](TurtleTools/ScreenShots/Simulator16.png?raw=true "Simulator16 Screen Shot")

The simulator app can be used to simulate the computer and run example programs without having to build the hardware. The interactive debugger can be used to inspect the state of the computer. Several example saved simulator sessions are available in the TurtleTools/Examples/ directory. (At some point, I should add some better demoes. These are mostly just programs that I used in hardware verification.)

To run the simulator, open the TurtleTools Xcode project and run the Simulator16 scheme. Refer to the [Tool Chain](Documentation/TurtleTools.md) page for more details.


## Documentation

* [Architecture Overview](Documentation/Architecture.md)
* [Instruction Set Architecture](Documentation/ISA.md)
* [Programming](Documentation/Programming.md)
* [Tool Chain](Documentation/TurtleTools.md)
* [Bugs](Documentation/Bugs.md)
* [Future Work](Documentation/Future.md)
