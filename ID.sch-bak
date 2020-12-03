EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 4 31
Title "ID"
Date ""
Rev ""
Comp ""
Comment1 "Simultaneously, read the register file using indices extracted from the instruction word."
Comment2 "effect conditional instructions."
Comment3 "The decoder takes the condition code from the flags register into account to"
Comment4 "The instruction decoder turns a 5-bit opcode into an array of control signals."
$EndDescr
Text HLabel 9000 2650 2    50   Output ~ 0
ControlWord[1..19]
Text Notes 800  7900 0    50   ~ 0
#   Mnemonic\n——————————\n0  /HLT\n1   SelLeftOp\n2   SelRightOp\n3   SelStoreOpA\n4   SelStoreOpB\n5   /FI\n6   CarryIn\n7   I0\n8   I1\n9   I2\n10  RS0\n11  RS1\n12  /J\n13  /MemLoad\n14  /MemStore\n15  /WRL\n16  /WRH\n17  WriteBackSrcA\n18  WriteBackSrcB
Text HLabel 9800 2300 2    50   Output ~ 0
~HLT
Text Label 9250 2300 0    50   ~ 0
ControlWord0
Entry Wire Line
	9000 2300 8900 2400
Text Notes 1700 7900 0    50   ~ 0
Description\n————————\nHalt Clock\nSelect Left Operand\nSelect Right Operand\nSelect Store Operand 0\nSelect Store Operand 1\nFlags Register In\nALU Carry input\nALU I0 input\nALU I1 input\nALU I2 input\nALU RS0 input\nALU RS1 input\nJump\nMemory Store\nMemory Load\nWrite back low byte\nWrite back high byte\nSource of write back 0\nSource of write back 1
Text HLabel 7400 1950 2    50   Output ~ 0
InsOut[0..10]
Text HLabel 7400 2050 2    50   Output ~ 0
PCOut[0..15]
Wire Wire Line
	9000 2300 9800 2300
Text Label 7950 2400 0    50   ~ 0
ControlWord[0..19]
Wire Bus Line
	7800 2400 8900 2400
Entry Bus Bus
	7800 2550 7900 2650
Text Label 7950 2650 0    50   ~ 0
ControlWord[1..19]
Wire Bus Line
	7900 2650 9000 2650
Wire Bus Line
	7800 2400 7800 2550
Connection ~ 7800 2400
Text Label 3850 2550 2    50   ~ 0
Ins[11..15]
Text HLabel 4100 4850 0    50   Input ~ 0
~WRH
Text HLabel 4100 4950 0    50   Input ~ 0
~WRL
Text HLabel 4100 5050 0    50   Input ~ 0
C[0..15]
Text HLabel 4100 4750 0    50   Input ~ 0
SelC[0..2]
$Sheet
S 5850 3950 1200 1250
U 5FC16AA6
F0 "sheet5FC16A8C" 50
F1 "RegisterFile.sch" 50
F2 "~WRH" I L 5850 4850 50 
F3 "~WRL" I L 5850 4950 50 
F4 "C[0..15]" I L 5850 5050 50 
F5 "SelC[0..2]" I L 5850 4750 50 
F6 "SelA[0..2]" I L 5850 4050 50 
F7 "SelB[0..2]" I L 5850 4450 50 
F8 "B[0..15]" O R 7050 4450 50 
F9 "A[0..15]" O R 7050 4050 50 
$EndSheet
Wire Bus Line
	5850 5050 4100 5050
Wire Bus Line
	4100 4750 5850 4750
Wire Wire Line
	5850 4850 4100 4850
Wire Wire Line
	4100 4950 5850 4950
$Sheet
S 4450 3950 1150 200 
U 5FC16AC7
F0 "sheet5FC16A8E" 50
F1 "SplitOutSelA.sch" 50
F2 "Ins[0..15]" I L 4450 4050 50 
F3 "SelA[0..2]" O R 5600 4050 50 
$EndSheet
Wire Bus Line
	4450 4450 4350 4450
$Sheet
S 4450 4350 1150 200 
U 5FC16AD1
F0 "sheet5FC16A8F" 50
F1 "SplitOutSelB.sch" 50
F2 "Ins[0..15]" I L 4450 4450 50 
F3 "SelB[0..2]" O R 5600 4450 50 
$EndSheet
Wire Bus Line
	4450 4050 4350 4050
Wire Bus Line
	5600 4050 5850 4050
Wire Bus Line
	5850 4450 5600 4450
Text HLabel 7550 4050 2    50   Output ~ 0
A[0..15]
Wire Bus Line
	7550 4050 7050 4050
Text HLabel 7550 4450 2    50   Output ~ 0
B[0..15]
Wire Bus Line
	7550 4450 7050 4450
Text HLabel 4100 4250 0    50   Input ~ 0
Ins[0..15]
Wire Bus Line
	4100 4250 4350 4250
Wire Bus Line
	4350 4050 4350 4250
Connection ~ 4350 4250
Wire Bus Line
	4350 4250 4350 4450
$Sheet
S 3900 2450 1100 600 
U 5FE73F43
F0 "Instruction Decoder" 50
F1 "InstructionDecoder.sch" 50
F2 "Carry" I L 3900 2650 50 
F3 "Z" I L 3900 2750 50 
F4 "Ins[11..15]" I L 3900 2550 50 
F5 "OVF" I L 3900 2850 50 
F6 "~RST" I L 3900 2950 50 
F7 "Ctl[0..23]" O R 5000 2550 50 
$EndSheet
Wire Bus Line
	7800 2150 7800 2400
Text HLabel 6000 1850 0    50   Input ~ 0
Phi1
Text HLabel 6000 2050 0    50   Input ~ 0
PCIn[0..15]
Wire Bus Line
	7400 1950 7250 1950
Wire Bus Line
	7250 2050 7400 2050
Wire Wire Line
	6100 1850 6000 1850
Wire Bus Line
	6100 2050 6000 2050
$Sheet
S 6100 1750 1150 600 
U 5FD3D817
F0 "sheet5FD3D810" 50
F1 "ID_REG.sch" 50
F2 "PCIn[0..15]" I L 6100 2050 50 
F3 "Phi1" I L 6100 1850 50 
F4 "InsIn[0..10]" I L 6100 1950 50 
F5 "PCOut[0..15]" O R 7250 2050 50 
F6 "InsOut[0..10]" O R 7250 1950 50 
F7 "Ctl[0..23]" I L 6100 2250 50 
F8 "ControlWord[0..19]" O R 7250 2150 50 
$EndSheet
Text Label 3800 1950 2    50   ~ 0
Ins[0..10]
Text HLabel 3100 1950 0    50   Input ~ 0
Ins[0..15]
Wire Bus Line
	3900 2550 3400 2550
Entry Bus Bus
	3300 1950 3400 2050
Wire Bus Line
	3400 2050 3400 2550
Wire Bus Line
	6100 2250 5400 2250
Wire Bus Line
	5400 2250 5400 2550
Wire Bus Line
	5400 2550 5000 2550
Text HLabel 3800 2650 0    50   Input ~ 0
Carry
Wire Wire Line
	3900 2650 3800 2650
Text HLabel 3800 2750 0    50   Input ~ 0
Z
Wire Wire Line
	3900 2750 3800 2750
Text HLabel 3800 2850 0    50   Input ~ 0
OVF
Wire Wire Line
	3900 2850 3800 2850
Text HLabel 3800 2950 0    50   Input ~ 0
~RST
Wire Wire Line
	3900 2950 3800 2950
Wire Bus Line
	3100 1950 6100 1950
Wire Bus Line
	7250 2150 7800 2150
Text Notes 7350 4850 0    50   ~ 0
TODO: Need to latch register values A and B at the end of the pipeline stage.
$EndSCHEMATC
