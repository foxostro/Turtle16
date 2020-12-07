EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 30 33
Title "IF"
Date ""
Rev ""
Comp ""
Comment1 "All jumps are PC-relative jumps which add an offset to the program counter."
Comment2 "address space to allow the program to be modified."
Comment3 "RAM serving as Instruction Memory. The second port of the RAM is mapped into the data"
Comment4 "The Instruction Fetch stage retrieves sixteen-bit instructions from a dual port"
$EndDescr
$Sheet
S 6550 3500 1150 600 
U 5FCE2082
F0 "sheet5FCE207B" 50
F1 "IF_ID.sch" 50
F2 "PCIn[0..15]" I L 6550 3700 50 
F3 "PCOut[0..15]" O R 7700 3600 50 
F4 "InsIn[0..15]" I L 6550 4000 50 
F5 "InsOut[0..15]" O R 7700 3700 50 
F6 "Phi1" I L 6550 3600 50 
$EndSheet
Text HLabel 8000 3700 2    50   Output ~ 0
InsOut[0..15]
Text HLabel 8000 3600 2    50   Output ~ 0
PCOut[0..15]
Wire Bus Line
	8000 3600 7700 3600
Wire Bus Line
	7700 3700 8000 3700
Wire Bus Line
	4500 3700 4750 3700
Wire Bus Line
	4850 4000 4750 4000
Wire Bus Line
	4750 4000 4750 3700
Wire Bus Line
	4750 3700 6550 3700
Connection ~ 4750 3700
Wire Bus Line
	6300 4000 6550 4000
$Sheet
S 3050 3600 1450 600 
U 5FE3DA1C
F0 "sheet5FE3DA15" 50
F1 "Program Counter.sch" 50
F2 "Phi1" I L 3050 3700 50 
F3 "~RST" I L 3050 3850 50 
F4 "~J" I L 3050 4100 50 
F5 "PC[0..15]" O R 4500 3700 50 
F6 "Offset[0..15]" I L 3050 4000 50 
$EndSheet
Wire Wire Line
	3050 3700 2700 3700
Wire Wire Line
	3050 3850 2700 3850
Text HLabel 2700 4000 0    50   Input ~ 0
Offset[0..15]
Text HLabel 2700 4100 0    50   Input ~ 0
~J
Wire Wire Line
	3050 4100 2700 4100
Wire Bus Line
	2700 4000 3050 4000
$Sheet
S 4850 3900 1450 200 
U 5FD0D8DC
F0 "Instruction Memory" 50
F1 "InstructionRAM.sch" 50
F2 "PC[0..15]" I L 4850 4000 50 
F3 "InstructionWord[0..15]" O R 6300 4000 50 
$EndSheet
Text GLabel 2700 3850 0    50   Input ~ 0
~RST
Text GLabel 2700 3700 0    50   Input ~ 0
Phi1d
Wire Wire Line
	6550 3600 6450 3600
Text GLabel 6450 3600 0    50   Input ~ 0
Phi1b
$EndSCHEMATC
