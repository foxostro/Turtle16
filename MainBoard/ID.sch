EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 23 39
Title "ID"
Date "2021-04-22"
Rev "A (4274ea32)"
Comp ""
Comment1 "Simultaneously, read the register file using indices extracted from the instruction word."
Comment2 "effect conditional instructions."
Comment3 "The decoder takes the condition code from the flags register into account to"
Comment4 "The instruction decoder turns a 5-bit opcode into an array of control signals."
$EndDescr
Text HLabel 3750 2850 0    50   Input ~ 0
~J
Wire Wire Line
	4600 2850 3750 2850
Text HLabel 6800 2950 2    50   Output ~ 0
STALL
Wire Bus Line
	4600 3250 3950 3250
Wire Bus Line
	4600 3350 3950 3350
Text Label 3950 3250 0    50   ~ 0
SelA[0..2]
Text Label 3950 3350 0    50   ~ 0
SelB[0..2]
Text HLabel 3750 3450 0    50   Input ~ 0
SelC_MEM[0..2]
Wire Bus Line
	3750 3450 4600 3450
Text HLabel 3750 3150 0    50   Input ~ 0
Ctl_MEM[14..20]
Wire Bus Line
	3750 3150 4600 3150
Wire Bus Line
	4600 3050 3950 3050
Text Label 3950 3050 0    50   ~ 0
Ctl_EX[0..20]
Wire Wire Line
	6000 2950 6800 2950
Wire Bus Line
	4600 2950 3950 2950
Text Label 4500 2950 2    50   ~ 0
Ins_ID[11..15]
Wire Bus Line
	3750 3550 4600 3550
Text HLabel 3750 3550 0    50   Input ~ 0
Ins_EX[0..10]
Text HLabel 8300 1450 2    50   Output ~ 0
Ctl_EX[0..20]
Text Notes 1700 7900 0    50   ~ 0
Description\n————————\nHalt Clock\nSelect Store Operand 0\nSelect Store Operand 1\nSelect Right Operand 1\nSelect Right Operand 2\nFlags Register In\nALU Carry input\nALU I0 input\nALU I1 input\nALU I2 input\nALU RS0 input\nALU RS1 input\nJump\nAbsolute Jump\nMemory Load\nMemory Store\nDrive the Store operand onto the bus I/O lines\nSelect write back source\nWrite back low byte\nWrite back high byte\nEnable write back to register file
Text HLabel 8300 950  2    50   Output ~ 0
Ins_EX[0..10]
Text Label 2950 1550 2    50   ~ 0
Ins_ID[11..15]
Text HLabel 3800 6200 0    50   Input ~ 0
~WRH
Text HLabel 3800 6300 0    50   Input ~ 0
~WRL
Text HLabel 3800 6500 0    50   Input ~ 0
C[0..15]
Text HLabel 3800 6100 0    50   Input ~ 0
SelC_WB[0..2]
$Sheet
S 5300 5300 1200 1300
U 60693BAE
F0 "sheet60693B94" 50
F1 "RegisterFile.sch" 50
F2 "~WRH" I L 5300 6200 50 
F3 "~WRL" I L 5300 6300 50 
F4 "C[0..15]" I L 5300 6500 50 
F5 "SelC_WB[0..2]" I L 5300 6100 50 
F6 "SelA[0..2]" I L 5300 5400 50 
F7 "SelB[0..2]" I L 5300 5800 50 
F8 "RegisterB[0..15]" O R 6500 6300 50 
F9 "RegisterA[0..15]" O R 6500 5400 50 
F10 "~WBEN" I L 5300 6400 50 
$EndSheet
Wire Bus Line
	5300 6500 3800 6500
Wire Bus Line
	3800 6100 5300 6100
Wire Wire Line
	5300 6200 3800 6200
Wire Wire Line
	3800 6300 5300 6300
$Sheet
S 3450 5300 1150 200 
U 60693BB6
F0 "sheet60693B95" 50
F1 "SplitOutSelA.sch" 50
F2 "Ins_ID[0..15]" I L 3450 5400 50 
F3 "SelA[0..2]" O R 4600 5400 50 
$EndSheet
Wire Bus Line
	3450 5800 3300 5800
$Sheet
S 3450 5700 1150 200 
U 60693BBB
F0 "sheet60693B96" 50
F1 "SplitOutSelB.sch" 50
F2 "Ins_ID[0..15]" I L 3450 5800 50 
F3 "SelB[0..2]" O R 4600 5800 50 
$EndSheet
Wire Bus Line
	3450 5400 3300 5400
Wire Bus Line
	4600 5400 5300 5400
Wire Bus Line
	5300 5800 4600 5800
Text HLabel 9900 5100 2    50   Output ~ 0
A[0..15]
Wire Bus Line
	9900 5100 9400 5100
Text HLabel 9900 6000 2    50   Output ~ 0
B[0..15]
Wire Bus Line
	9900 6000 9400 6000
Text HLabel 3150 5600 0    50   Input ~ 0
Ins_ID[0..15]
Wire Bus Line
	3150 5600 3300 5600
Wire Bus Line
	3300 5400 3300 5600
Connection ~ 3300 5600
Wire Bus Line
	3300 5600 3300 5800
$Sheet
S 3000 1450 1250 750 
U 60693BCF
F0 "sheet60693B97" 50
F1 "InstructionDecoder.sch" 50
F2 "Carry" I L 3000 1650 50 
F3 "Z" I L 3000 1750 50 
F4 "Ins_ID[11..15]" I L 3000 1550 50 
F5 "OVF" I L 3000 1850 50 
F6 "~RST" I L 3000 2000 50 
F7 "Ctl_ID[0..20]" O R 4250 1550 50 
F8 "FLUSH" I L 3000 2100 50 
$EndSheet
Text Label 2750 950  2    50   ~ 0
Ins_ID[0..10]
Text HLabel 2050 950  0    50   Input ~ 0
Ins_ID[0..15]
Wire Bus Line
	3000 1550 2350 1550
Entry Bus Bus
	2250 950  2350 1050
Wire Bus Line
	2350 1050 2350 1550
Text HLabel 2900 1650 0    50   Input ~ 0
Carry
Wire Wire Line
	3000 1650 2900 1650
Text HLabel 2900 1750 0    50   Input ~ 0
Z
Wire Wire Line
	3000 1750 2900 1750
Text HLabel 2900 1850 0    50   Input ~ 0
OVF
Wire Wire Line
	3000 1850 2900 1850
Wire Wire Line
	3000 2000 2900 2000
Wire Bus Line
	6600 1450 8300 1450
Wire Bus Line
	6600 950  8300 950 
$Sheet
S 5200 1350 1400 400 
U 60693BE1
F0 "sheet60693B98" 50
F1 "ID_EX_ControlWord.sch" 50
F2 "Ctl_ID[0..23]" I L 5200 1550 50 
F3 "Ctl_EX[0..20]" O R 6600 1450 50 
$EndSheet
$Sheet
S 5200 750  1400 300 
U 60693BE5
F0 "sheet60693B99" 50
F1 "ID_EX_InstructionWord.sch" 50
F2 "Ins_ID[0..10]" I L 5200 950 50 
F3 "Ins_EX[0..10]" O R 6600 950 50 
$EndSheet
$Sheet
S 8500 5000 900  300 
U 60693BE9
F0 "sheet60693B9A" 50
F1 "ID_EX_A.sch" 50
F2 "A_ID[0..15]" I L 8500 5100 50 
F3 "A[0..15]" O R 9400 5100 50 
$EndSheet
Wire Bus Line
	6500 5400 7250 5400
Wire Bus Line
	6500 6300 7250 6300
Text Notes 9450 5000 0    50   ~ 0
The A port supplies\nthe Left operand.
Text Notes 9450 5900 0    50   ~ 0
The B port supplies\nthe Right operand.
Text GLabel 2900 2000 0    50   Input ~ 0
~RST
Text HLabel 3800 6400 0    50   Input ~ 0
~WBEN
Wire Wire Line
	3800 6400 5300 6400
Text Label 4850 5400 0    50   ~ 0
SelA[0..2]
Text Label 4850 5800 0    50   ~ 0
SelB[0..2]
Text Label 4300 1550 0    50   ~ 0
Ctl_ID[0..20]
Wire Bus Line
	4250 1550 5200 1550
Text Label 7250 950  0    50   ~ 0
Ins_EX[0..10]
Text Label 7250 1450 0    50   ~ 0
Ctl_EX[0..20]
$Sheet
S 8500 5900 900  300 
U 60693BFB
F0 "sheet60693B9B" 50
F1 "ID_EX_B.sch" 50
F2 "B_ID[0..15]" I L 8500 6000 50 
F3 "B[0..15]" O R 9400 6000 50 
$EndSheet
Text Notes 800  7900 0    50   ~ 0
#   Mnemonic\n——————————\n0  /HLT\n1   SelStoreOpA\n2   SelStoreOpB\n3   SelRightOpA\n4   SelRightOpB\n5   /FI\n6   CarryIn\n7   I0\n8   I1\n9   I2\n10  RS0\n11  RS1\n12  /J\n13  /JABS\n14  /MemLoad\n15  /MemStore\n16  /AssertStoreOp\n17  WriteBackSrc\n18  /WRL\n19  /WRH\n20  /WBEN
Wire Wire Line
	6150 2850 6150 2400
Wire Wire Line
	2900 2400 2900 2100
Wire Wire Line
	2900 2100 3000 2100
$Sheet
S 7250 5000 1100 700 
U 60ADB1D2
F0 "Operand Forwarding A" 50
F1 "OperandForwardingA.sch" 50
F2 "FWD_A" I L 7250 5100 50 
F3 "A_ID[0..15]" O R 8350 5100 50 
F4 "RegisterA[0..15]" I L 7250 5400 50 
F5 "Y_EX[0..15]" I L 7250 5500 50 
F6 "Y_MEM[0..15]" I L 7250 5600 50 
F7 "FWD_EX_TO_A" I L 7250 5200 50 
F8 "FWD_MEM_TO_A" I L 7250 5300 50 
$EndSheet
Wire Bus Line
	8500 5100 8350 5100
Wire Bus Line
	8500 6000 8350 6000
$Sheet
S 7250 5900 1100 700 
U 60D2706D
F0 "Operand Forwarding B" 50
F1 "OperandForwardingB.sch" 50
F2 "FWD_B" I L 7250 6000 50 
F3 "B_ID[0..15]" O R 8350 6000 50 
F4 "RegisterB[0..15]" I L 7250 6300 50 
F5 "Y_EX[0..15]" I L 7250 6400 50 
F6 "Y_MEM[0..15]" I L 7250 6500 50 
F7 "FWD_EX_TO_B" I L 7250 6100 50 
F8 "FWD_MEM_TO_B" I L 7250 6200 50 
$EndSheet
Text HLabel 7050 4300 1    50   Input ~ 0
Y_EX[0..15]
Text HLabel 7150 4300 1    50   Input ~ 0
Y_MEM[0..15]
Wire Bus Line
	7150 4300 7150 5600
Wire Bus Line
	7150 5600 7250 5600
Wire Bus Line
	7150 5600 7150 6500
Wire Bus Line
	7150 6500 7250 6500
Connection ~ 7150 5600
Wire Bus Line
	7250 6400 7050 6400
Wire Bus Line
	7050 6400 7050 5500
Wire Bus Line
	7050 5500 7250 5500
Wire Bus Line
	7050 5500 7050 4300
Connection ~ 7050 5500
$Sheet
S 4600 2750 1400 900 
U 5FDA967F
F0 "Hazard Control" 50
F1 "HazardControl.sch" 50
F2 "SelC_MEM[0..2]" I L 4600 3450 50 
F3 "SelA[0..2]" I L 4600 3250 50 
F4 "SelB[0..2]" I L 4600 3350 50 
F5 "Ins_EX[0..10]" I L 4600 3550 50 
F6 "Ctl_MEM[14..20]" I L 4600 3150 50 
F7 "Ctl_EX[0..20]" I L 4600 3050 50 
F8 "~J" I L 4600 2850 50 
F9 "Ins_ID[11..15]" I L 4600 2950 50 
F10 "STALL" O R 6000 2950 50 
F11 "FLUSH" O R 6000 2850 50 
F12 "FWD_A" O R 6000 3050 50 
F13 "FWD_EX_TO_A" O R 6000 3150 50 
F14 "FWD_MEM_TO_A" O R 6000 3250 50 
F15 "FWD_EX_TO_B" O R 6000 3450 50 
F16 "FWD_MEM_TO_B" O R 6000 3550 50 
F17 "FWD_B" O R 6000 3350 50 
$EndSheet
Wire Wire Line
	6150 2850 6000 2850
Wire Wire Line
	6150 2400 2900 2400
Wire Wire Line
	6000 3050 6950 3050
Wire Wire Line
	6950 3050 6950 5100
Wire Wire Line
	6950 5100 7250 5100
Wire Wire Line
	6000 3150 6900 3150
Wire Wire Line
	6900 3150 6900 5200
Wire Wire Line
	6900 5200 7250 5200
Wire Wire Line
	6000 3250 6850 3250
Wire Wire Line
	6850 3250 6850 5300
Wire Wire Line
	6850 5300 7250 5300
Wire Wire Line
	6000 3350 6800 3350
Wire Wire Line
	6800 3350 6800 6000
Wire Wire Line
	6800 6000 7250 6000
Wire Wire Line
	7250 6100 6750 6100
Wire Wire Line
	6750 6100 6750 3450
Wire Wire Line
	6750 3450 6000 3450
Wire Wire Line
	6000 3550 6700 3550
Wire Wire Line
	6700 3550 6700 6200
Wire Wire Line
	6700 6200 7250 6200
Text Notes 7250 4300 0    50   ~ 0
Operands from subsequent pipeline\nstages feed back to the ID stage\nand may be selected for use now to\nresolve a RAW hazard.
Wire Wire Line
	1300 2700 1100 2700
Wire Wire Line
	2450 2700 2600 2700
$Comp
L Connector:TestPoint TP?
U 1 1 6085C0DC
P 1300 2700
AR Path="/5D2C0720/6085C0DC" Ref="TP?"  Part="1" 
AR Path="/5FE35007/6085C0DC" Ref="TP?"  Part="1" 
AR Path="/5FED3839/6085C0DC" Ref="TP18"  Part="1" 
F 0 "TP18" V 1254 2888 50  0000 L CNN
F 1 "Z" V 1345 2888 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_D1.0mm" H 1500 2700 50  0001 C CNN
F 3 "~" H 1500 2700 50  0001 C CNN
	1    1300 2700
	0    1    1    0   
$EndComp
$Comp
L Connector:TestPoint TP?
U 1 1 6085C0E2
P 2450 2700
AR Path="/5D2C0720/6085C0E2" Ref="TP?"  Part="1" 
AR Path="/5FE35007/6085C0E2" Ref="TP?"  Part="1" 
AR Path="/5FED3839/6085C0E2" Ref="TP21"  Part="1" 
F 0 "TP21" V 2400 3050 50  0000 R CNN
F 1 "GND" V 2500 3050 50  0000 R CNN
F 2 "TestPoint:TestPoint_Pad_D1.0mm" H 2650 2700 50  0001 C CNN
F 3 "~" H 2650 2700 50  0001 C CNN
	1    2450 2700
	0    -1   1    0   
$EndComp
Wire Wire Line
	1300 3000 1100 3000
$Comp
L power:GND #PWR?
U 1 1 6085C0EA
P 2600 3150
AR Path="/5D2C0720/6085C0EA" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/6085C0EA" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/6085C0EA" Ref="#PWR0434"  Part="1" 
F 0 "#PWR0434" H 2600 2900 50  0001 C CNN
F 1 "GND" H 2605 2977 50  0000 C CNN
F 2 "" H 2600 3150 50  0001 C CNN
F 3 "" H 2600 3150 50  0001 C CNN
	1    2600 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	2450 3000 2600 3000
Wire Wire Line
	2600 3000 2600 3150
Wire Wire Line
	2600 2700 2600 3000
Connection ~ 2600 3000
$Comp
L Connector:TestPoint TP?
U 1 1 6085C0F4
P 1300 3000
AR Path="/5D2C0720/6085C0F4" Ref="TP?"  Part="1" 
AR Path="/5FE35007/6085C0F4" Ref="TP?"  Part="1" 
AR Path="/5FED3839/6085C0F4" Ref="TP19"  Part="1" 
F 0 "TP19" V 1254 3188 50  0000 L CNN
F 1 "OVF" V 1345 3188 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_D1.0mm" H 1500 3000 50  0001 C CNN
F 3 "~" H 1500 3000 50  0001 C CNN
	1    1300 3000
	0    1    1    0   
$EndComp
$Comp
L Connector:TestPoint TP?
U 1 1 6085C0FA
P 2450 3000
AR Path="/5D2C0720/6085C0FA" Ref="TP?"  Part="1" 
AR Path="/5FE35007/6085C0FA" Ref="TP?"  Part="1" 
AR Path="/5FED3839/6085C0FA" Ref="TP22"  Part="1" 
F 0 "TP22" V 2400 3350 50  0000 R CNN
F 1 "GND" V 2500 3350 50  0000 R CNN
F 2 "TestPoint:TestPoint_Pad_D1.0mm" H 2650 3000 50  0001 C CNN
F 3 "~" H 2650 3000 50  0001 C CNN
	1    2450 3000
	0    -1   1    0   
$EndComp
Wire Wire Line
	1300 2400 1100 2400
Wire Wire Line
	2450 2400 2600 2400
$Comp
L Connector:TestPoint TP?
U 1 1 6085DF61
P 1300 2400
AR Path="/5D2C0720/6085DF61" Ref="TP?"  Part="1" 
AR Path="/5FE35007/6085DF61" Ref="TP?"  Part="1" 
AR Path="/5FED3839/6085DF61" Ref="TP17"  Part="1" 
F 0 "TP17" V 1254 2588 50  0000 L CNN
F 1 "Carry" V 1345 2588 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_D1.0mm" H 1500 2400 50  0001 C CNN
F 3 "~" H 1500 2400 50  0001 C CNN
	1    1300 2400
	0    1    1    0   
$EndComp
$Comp
L Connector:TestPoint TP?
U 1 1 6085DF67
P 2450 2400
AR Path="/5D2C0720/6085DF67" Ref="TP?"  Part="1" 
AR Path="/5FE35007/6085DF67" Ref="TP?"  Part="1" 
AR Path="/5FED3839/6085DF67" Ref="TP20"  Part="1" 
F 0 "TP20" V 2400 2750 50  0000 R CNN
F 1 "GND" V 2500 2750 50  0000 R CNN
F 2 "TestPoint:TestPoint_Pad_D1.0mm" H 2650 2400 50  0001 C CNN
F 3 "~" H 2650 2400 50  0001 C CNN
	1    2450 2400
	0    -1   1    0   
$EndComp
Wire Wire Line
	2600 2400 2600 2700
Wire Bus Line
	2050 950  5200 950 
Text HLabel 1100 2400 0    50   Input ~ 0
Carry
Text HLabel 1100 2700 0    50   Input ~ 0
Z
Text HLabel 1100 3000 0    50   Input ~ 0
OVF
$EndSCHEMATC
