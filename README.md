# Turtle16

Turtle16 is a sixteen-bit microcomputer built from discrete logic ICs and other simple parts. This repo contains the Kicad project, and other files necesary to build the hardware, as well as the simulator, assembler, and compiler.

![Photo of Turtle16 CPU](Documentation/Turtle16_Rev_B_Photo_Small.jpg?raw=true "Photo of Turtle16 CPU")

![3D Render of Turtle16 CPU](Generated/Turtle16_Main_Board_Rev_A_c8cebf3f/Render_Front.png?raw=true "3D Render of Turtle16 CPU")


## Project Constraints

Microprocessors and programmable hardware such as CPLDs and FPGAs have been avoided. An exception has been made for primitive GALs as these fit the retro computer aesthetic.


## Getting Started

![Simulator16 Screen Shot](TurtleTools/ScreenShots/Simulator16.png?raw=true "Simulator16 Screen Shot")

The simulator app can be used to simulate the computer and run example programs without having to build the hardware. The interactive debugger can be used to inspect the state of the computer. Several example saved simulator sessions are available in the TurtleTools/Examples/ directory. (At some point, I should add some better demoes. These are mostly just programs that I used in hardware verification.)

To run the simulator, open the TurtleTools Xcode project and run the Simulator16 scheme. Refer to the [Tool Chain](Documentation/TurtleTools.md) page for more details.


## Documentation

* [Architecture Overview](Documentation/Architecture.md)
* [Instruction Set Architecture](Documentation/ISA.md)
* [Programming](Documentation/Programming.md)
* [Tool Chain](Documentation/TurtleTools.md)