EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 3 34
Title "ID"
Date ""
Rev ""
Comp ""
Comment1 "Simultaneously, read the register file using indices extracted from the instruction word."
Comment2 "effect conditional instructions."
Comment3 "The decoder takes the condition code from the flags register into account to"
Comment4 "The instruction decoder turns a 5-bit opcode into an array of control signals."
$EndDescr
Text HLabel 8300 2650 2    50   Output ~ 0
Ctl_EX[0..20]
Text Notes 800  7900 0    50   ~ 0
#   Mnemonic\n——————————\n0  /HLT\n1   SelStoreOpA\n2   SelStoreOpB\n3   SelRightOpA\n4   SelRightOpB\n5   /FI\n6   CarryIn\n7   I0\n8   I1\n9   I2\n10  RS0\n11  RS1\n12  /J\n13  /MemLoad\n14  /MemStore\n15  /AssertStoreOp\n16  WriteBackSrc\n17  unused\n18  /WRL\n19  /WRH\n20  /WBEN
Text Notes 1700 7900 0    50   ~ 0
Description\n————————\nHalt Clock\nSelect Store Operand 0\nSelect Store Operand 1\nSelect Right Operand 1\nSelect Right Operand 2\nFlags Register In\nALU Carry input\nALU I0 input\nALU I1 input\nALU I2 input\nALU RS0 input\nALU RS1 input\nJump\nMemory Store\nMemory Load\nDrive the Store operand onto the bus I/O lines\nSource of write back 0\nunused\nWrite back low byte\nWrite back high byte\nEnable write back to register file
Text HLabel 8300 2150 2    50   Output ~ 0
Ins_EX[0..10]
Text Label 2950 2750 2    50   ~ 0
Ins_ID[11..15]
Text HLabel 3200 5050 0    50   Input ~ 0
~WRH
Text HLabel 3200 5150 0    50   Input ~ 0
~WRL
Text HLabel 3200 5350 0    50   Input ~ 0
C[0..15]
Text HLabel 3200 4950 0    50   Input ~ 0
SelC_WB[0..2]
$Sheet
S 4950 4150 1200 1300
U 5FC16AA6
F0 "sheet5FC16A8C" 50
F1 "RegisterFile.sch" 50
F2 "~WRH" I L 4950 5050 50 
F3 "~WRL" I L 4950 5150 50 
F4 "C[0..15]" I L 4950 5350 50 
F5 "SelC_WB[0..2]" I L 4950 4950 50 
F6 "SelA[0..2]" I L 4950 4250 50 
F7 "SelB[0..2]" I L 4950 4650 50 
F8 "B[0..15]" O R 6150 4750 50 
F9 "A[0..15]" O R 6150 4250 50 
F10 "~WBEN" I L 4950 5250 50 
$EndSheet
Wire Bus Line
	4950 5350 3200 5350
Wire Bus Line
	3200 4950 4950 4950
Wire Wire Line
	4950 5050 3200 5050
Wire Wire Line
	3200 5150 4950 5150
$Sheet
S 3550 4150 1150 200 
U 5FC16AC7
F0 "sheet5FC16A8E" 50
F1 "SplitOutSelA.sch" 50
F2 "Ins_ID[0..15]" I L 3550 4250 50 
F3 "SelA[0..2]" O R 4700 4250 50 
$EndSheet
Wire Bus Line
	3550 4650 3450 4650
$Sheet
S 3550 4550 1150 200 
U 5FC16AD1
F0 "sheet5FC16A8F" 50
F1 "SplitOutSelB.sch" 50
F2 "Ins_ID[0..15]" I L 3550 4650 50 
F3 "SelB[0..2]" O R 4700 4650 50 
$EndSheet
Wire Bus Line
	3550 4250 3450 4250
Wire Bus Line
	4700 4250 4950 4250
Wire Bus Line
	4950 4650 4700 4650
Text HLabel 8050 4250 2    50   Output ~ 0
A[0..15]
Wire Bus Line
	8050 4250 7550 4250
Text HLabel 8050 4750 2    50   Output ~ 0
B[0..15]
Wire Bus Line
	8050 4750 7550 4750
Text HLabel 3200 4450 0    50   Input ~ 0
Ins_ID[0..15]
Wire Bus Line
	3200 4450 3450 4450
Wire Bus Line
	3450 4250 3450 4450
Connection ~ 3450 4450
Wire Bus Line
	3450 4450 3450 4650
$Sheet
S 3000 2650 1250 750 
U 5FE73F43
F0 "Instruction Decoder" 50
F1 "InstructionDecoder.sch" 50
F2 "Carry" I L 3000 2850 50 
F3 "Z" I L 3000 2950 50 
F4 "Ins_ID[11..15]" I L 3000 2750 50 
F5 "OVF" I L 3000 3050 50 
F6 "~RST" I L 3000 3300 50 
F7 "Ctl_ID[0..23]" O R 4250 2750 50 
F8 "~J" I L 3000 3150 50 
$EndSheet
Wire Wire Line
	5200 2650 5100 2650
Text Label 2750 2150 2    50   ~ 0
Ins_ID[0..10]
Text HLabel 2050 2150 0    50   Input ~ 0
Ins_ID[0..15]
Wire Bus Line
	3000 2750 2350 2750
Entry Bus Bus
	2250 2150 2350 2250
Wire Bus Line
	2350 2250 2350 2750
Wire Bus Line
	5200 2750 4250 2750
Text HLabel 2900 2850 0    50   Input ~ 0
Carry
Wire Wire Line
	3000 2850 2900 2850
Text HLabel 2900 2950 0    50   Input ~ 0
Z
Wire Wire Line
	3000 2950 2900 2950
Text HLabel 2900 3050 0    50   Input ~ 0
OVF
Wire Wire Line
	3000 3050 2900 3050
Wire Wire Line
	3000 3300 2900 3300
Wire Bus Line
	6600 2650 8300 2650
Wire Bus Line
	6600 2150 8300 2150
$Sheet
S 5200 2550 1400 300 
U 5FCFC706
F0 "ID/EX ControlWord" 50
F1 "ID_EX_ControlWord.sch" 50
F2 "Phi1" I L 5200 2650 50 
F3 "Ctl_ID[0..23]" I L 5200 2750 50 
F4 "Ctl_EX[0..20]" O R 6600 2650 50 
$EndSheet
$Sheet
S 5200 1950 1400 300 
U 5FD8C8F4
F0 "ID/EX InstructionWord" 50
F1 "ID_EX_InstructionWord.sch" 50
F2 "Ins_ID[0..10]" I L 5200 2150 50 
F3 "Ins_EX[0..10]" O R 6600 2150 50 
F4 "Phi1" I L 5200 2050 50 
$EndSheet
$Sheet
S 6650 4050 900  300 
U 5FE081C3
F0 "ID/EX A" 50
F1 "ID_EX_A.sch" 50
F2 "AIn[0..15]" I L 6650 4250 50 
F3 "A[0..15]" O R 7550 4250 50 
F4 "Phi1" I L 6650 4150 50 
$EndSheet
Wire Wire Line
	6650 4150 6550 4150
Wire Bus Line
	6150 4250 6650 4250
$Sheet
S 6650 4550 900  300 
U 5FE24A39
F0 "ID/EX B" 50
F1 "ID_EX_B.sch" 50
F2 "BIn[0..15]" I L 6650 4750 50 
F3 "B[0..15]" O R 7550 4750 50 
F4 "Phi1" I L 6650 4650 50 
$EndSheet
Wire Wire Line
	6650 4650 6550 4650
Wire Bus Line
	6150 4750 6650 4750
Wire Wire Line
	5200 2050 5100 2050
Text Notes 7600 4150 0    50   ~ 0
The A port supplies the Left operand.
Text Notes 7600 4650 0    50   ~ 0
The B port supplies the Right operand.
Text GLabel 2900 3300 0    50   Input ~ 0
~RST
Text GLabel 6550 4150 0    50   Input ~ 0
Phi1b
Text GLabel 6550 4650 0    50   Input ~ 0
Phi1b
Text GLabel 5100 2650 0    50   Input ~ 0
Phi1a
Text GLabel 5100 2050 0    50   Input ~ 0
Phi1b
Text HLabel 3200 5250 0    50   Input ~ 0
~WBEN
Wire Wire Line
	3200 5250 4950 5250
Text HLabel 2900 3150 0    50   Input ~ 0
~J
Wire Wire Line
	3000 3150 2900 3150
Wire Bus Line
	2050 2150 5200 2150
$EndSCHEMATC
