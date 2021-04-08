EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 35 39
Title "IF"
Date "2021-04-01"
Rev "A (c15ecb9b)"
Comp ""
Comment1 "All jumps are PC-relative jumps which add an offset to the program counter."
Comment2 "address space to allow the program to be modified."
Comment3 "RAM serving as Instruction Memory. The second port of the RAM is mapped into the data"
Comment4 "The Instruction Fetch stage retrieves sixteen-bit instructions from a dual port"
$EndDescr
Text HLabel 8000 3450 2    50   Output ~ 0
Ins_ID[0..15]
Text HLabel 8000 3700 2    50   Output ~ 0
PC_EX[0..15]
Wire Bus Line
	8000 3700 7700 3700
Wire Bus Line
	7700 3450 8000 3450
Wire Bus Line
	4500 4000 4750 4000
Wire Bus Line
	4850 4000 4750 4000
Wire Bus Line
	4750 4000 4750 3550
Wire Bus Line
	4750 3550 6550 3550
Wire Bus Line
	6300 4000 6550 4000
Wire Wire Line
	3050 3850 2700 3850
Text HLabel 2700 4000 0    50   Input ~ 0
Y_EX[0..15]
Text HLabel 2700 4100 0    50   Input ~ 0
~J
Wire Wire Line
	3050 4100 2700 4100
Wire Bus Line
	2700 4000 3050 4000
$Sheet
S 4850 3900 1450 300 
U 5FD0D8DC
F0 "Instruction Memory" 50
F1 "InstructionRAM.sch" 50
F2 "PC[0..15]" I L 4850 4000 50 
F3 "Ins_IF[0..15]" O R 6300 4000 50 
F4 "FLUSH_IF" I L 4850 4100 50 
$EndSheet
Text GLabel 2700 3850 0    50   Input ~ 0
~RST
$Sheet
S 3050 3600 1450 800 
U 5FE3DA1C
F0 "sheet5FE3DA15" 50
F1 "Program Counter.sch" 50
F2 "~RST" I L 3050 3850 50 
F3 "~J" I L 3050 4100 50 
F4 "PC[0..15]" O R 4500 4000 50 
F5 "Y_EX[0..15]" I L 3050 4000 50 
F6 "~JABS" I L 3050 4200 50 
F7 "STALL" I L 3050 4300 50 
F8 "FLUSH_IF" O R 4500 4100 50 
$EndSheet
$Sheet
S 6550 3350 1150 750 
U 5FCE2082
F0 "sheet5FCE207B" 50
F1 "IF_ID.sch" 50
F2 "PC[0..15]" I L 6550 3550 50 
F3 "PC_EX[0..15]" O R 7700 3700 50 
F4 "Ins_IF[0..15]" I L 6550 4000 50 
F5 "Ins_ID[0..15]" O R 7700 3450 50 
F6 "STALL" I L 6550 3450 50 
$EndSheet
Text HLabel 2700 4200 0    50   Input ~ 0
~JABS
Wire Wire Line
	3050 4200 2700 4200
Wire Wire Line
	4850 4100 4500 4100
Connection ~ 4750 4000
Text HLabel 2700 4300 0    50   Input ~ 0
STALL
Wire Wire Line
	3050 4300 2700 4300
Text HLabel 6200 3450 0    50   Input ~ 0
STALL
Wire Wire Line
	6550 3450 6200 3450
$EndSCHEMATC
