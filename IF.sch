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
Text HLabel 2700 4300 0    50   3State ~ 0
IO[0..7]
Text HLabel 2700 4400 0    50   Input ~ 0
Addr[0..15]
Text HLabel 2700 4500 0    50   Input ~ 0
Bank[0..7]
$Sheet
S 4850 3900 1450 1000
U 5FD0D8DC
F0 "Instruction RAM" 50
F1 "InstructionRAM.sch" 50
F2 "PC[0..15]" I L 4850 4000 50 
F3 "InstructionWord[0..15]" O R 6300 4000 50 
F4 "IO[0..7]" T L 4850 4300 50 
F5 "Addr[0..15]" I L 4850 4400 50 
F6 "Bank[0..7]" I L 4850 4500 50 
F7 "~MemLoad" I L 4850 4600 50 
F8 "~MemStore" I L 4850 4700 50 
F9 "~Phi2" I L 4850 4800 50 
$EndSheet
Wire Bus Line
	4500 3700 4750 3700
Wire Bus Line
	2700 4300 4850 4300
Wire Bus Line
	4850 4400 2700 4400
Wire Bus Line
	2700 4500 4850 4500
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
S 3050 3600 1450 500 
U 5FE3DA1C
F0 "sheet5FE3DA15" 50
F1 "Program Counter.sch" 50
F2 "Phi1" I L 3050 3700 50 
F3 "~RST" I L 3050 3800 50 
F4 "~J" I L 3050 4000 50 
F5 "PC[0..15]" O R 4500 3700 50 
F6 "Offset[0..15]" I L 3050 3900 50 
$EndSheet
Text HLabel 2700 3450 0    50   Input ~ 0
Phi1
Wire Wire Line
	3050 3700 2950 3700
Text HLabel 2700 3800 0    50   Input ~ 0
~RST
Wire Wire Line
	3050 3800 2700 3800
Text HLabel 2700 3900 0    50   Input ~ 0
Offset[0..15]
Text HLabel 2700 4000 0    50   Input ~ 0
~J
Wire Wire Line
	3050 4000 2700 4000
Wire Wire Line
	2950 3450 2950 3700
Wire Wire Line
	2950 3450 2700 3450
Wire Wire Line
	6450 3450 6450 3600
Wire Wire Line
	6450 3600 6550 3600
Wire Wire Line
	2950 3450 6450 3450
Connection ~ 2950 3450
Wire Bus Line
	2700 3900 3050 3900
Text HLabel 2700 4600 0    50   Input ~ 0
~MemLoad
Text HLabel 2700 4700 0    50   Input ~ 0
~MemStore
Text HLabel 2700 4800 0    50   Input ~ 0
Phi2
Wire Wire Line
	2700 4600 4850 4600
Wire Wire Line
	4850 4700 2700 4700
Wire Wire Line
	2700 4800 4850 4800
$EndSCHEMATC
