EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 26 34
Title "OP"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 "program counter, values form the register file, and immediate values."
Comment4 "Marshal ALU operands by selecting between a palette of available values such as the"
$EndDescr
Text HLabel 2450 2350 0    50   Input ~ 0
CtlIn[1..19]
Text HLabel 8900 4200 2    50   Output ~ 0
StoreOp[0..15]
Text HLabel 2450 5700 0    50   Input ~ 0
PC[0..15]
Text HLabel 2450 2450 0    50   Input ~ 0
Ins[0..10]
Text HLabel 8900 4400 2    50   Output ~ 0
Ctl[5..19]
Wire Bus Line
	2450 3750 4250 3750
Entry Wire Line
	4550 2350 4650 2450
Entry Wire Line
	4450 2350 4550 2450
Entry Wire Line
	4350 2350 4450 2450
Wire Wire Line
	4550 2450 4550 4250
Text Label 4750 2450 3    50   ~ 0
CtlIn1
Text Label 4650 2450 3    50   ~ 0
CtlIn2
Text Label 4450 2450 3    50   ~ 0
CtlIn4
Entry Bus Bus
	8400 2350 8500 2450
Wire Bus Line
	8500 2450 9050 2450
Text Label 8550 2450 0    50   ~ 0
CtlIn[5..19]
Entry Wire Line
	4650 2350 4750 2450
Wire Wire Line
	4650 2450 4650 4150
Wire Wire Line
	4750 2450 4750 2800
Wire Bus Line
	7300 4200 6500 4200
Text Label 4550 2450 3    50   ~ 0
CtlIn3
Text Notes 5250 5050 0    50   ~ 0
SelStoreOp=0  —> Select Register A\nSelStoreOp=1  —> Select Program Counter\nSelStoreOp=2  —> Select 8-bit Immediate Value
$Sheet
S 5250 3500 1250 200 
U 606410B1
F0 "Split Out SelC" 50
F1 "SplitOutSelC.sch" 50
F2 "Ins[0..10]" I L 5250 3600 50 
F3 "SelCOut[0..2]" O R 6500 3600 50 
$EndSheet
Wire Bus Line
	4350 2450 4350 2900
$Sheet
S 5250 4000 1250 700 
U 5FF2BBCA
F0 "Select Store Operand" 50
F1 "SelectStoreOp.sch" 50
F2 "StoreOp[0..15]" O R 6500 4200 50 
F3 "SelStoreOpA" I L 5250 4150 50 
F4 "SelStoreOpB" I L 5250 4250 50 
F5 "Ins[0..10]" I L 5250 4350 50 
F6 "A[0..15]" I L 5250 4450 50 
F7 "PC[0..15]" I L 5250 4550 50 
$EndSheet
Text HLabel 6950 4100 0    50   Input ~ 0
Phi1
Wire Wire Line
	6950 4100 7300 4100
Wire Bus Line
	8700 4200 8900 4200
Wire Bus Line
	8700 4400 8900 4400
Wire Bus Line
	7150 4300 7300 4300
Text HLabel 8900 4300 2    50   Output ~ 0
SelC[0..2]
Wire Bus Line
	8900 4300 8700 4300
Wire Bus Line
	6600 4450 7150 4450
Text Label 6650 4450 0    50   ~ 0
CtlIn[5..19]
Wire Bus Line
	7300 4400 7150 4400
Wire Bus Line
	7150 4400 7150 4450
Wire Bus Line
	7150 4300 7150 3600
Wire Bus Line
	7150 3600 6500 3600
Text HLabel 8150 5500 2    50   Output ~ 0
RightOp[0..15]
Wire Bus Line
	8150 5500 6450 5500
Text Notes 5250 6050 0    50   ~ 0
SelRightOp=0  —> Select Register B\nSelRightOp=1  —> Select Program Counter
$Sheet
S 5250 5300 1200 500 
U 5FE695DA
F0 "Select Right Operand" 50
F1 "SelectRightOperand.sch" 50
F2 "PC[0..15]" I L 5250 5700 50 
F3 "B[0..15]" I L 5250 5600 50 
F4 "RightOp[0..15]" O R 6450 5500 50 
F5 "SelRightOp" I L 5250 5500 50 
$EndSheet
Text Notes 7600 5400 0    50   ~ 0
The latch for RightOp is at the\nbeginning of the EX stage.
Wire Wire Line
	4450 2450 4450 5500
Text Notes 5250 3350 0    50   ~ 0
SelLeftOp=0  —> Select Register A\nSelLeftOp=1  —> Select 5-bit Immediate Value
Wire Bus Line
	4250 3000 5250 3000
$Sheet
S 5250 2600 1100 500 
U 5FDE580B
F0 "Select Left Operand" 50
F1 "SelectLeftOperand.sch" 50
F2 "Ins[0..10]" I L 5250 2900 50 
F3 "A[0..15]" I L 5250 3000 50 
F4 "LeftOp[0..15]" O R 6350 2800 50 
F5 "SelLeftOp" I L 5250 2800 50 
$EndSheet
Wire Bus Line
	6350 2800 8250 2800
Text HLabel 8250 2800 2    50   Output ~ 0
LeftOp[0..15]
Text Notes 7650 2700 0    50   ~ 0
The latch for LeftOp is at the\nbeginning of the EX stage.
Wire Wire Line
	4750 2800 5250 2800
Wire Wire Line
	4450 5500 5250 5500
Connection ~ 4350 2900
Wire Bus Line
	4350 2900 4350 3600
Wire Bus Line
	4250 3000 4250 3750
Wire Bus Line
	4350 3600 5250 3600
Wire Bus Line
	4350 2900 5250 2900
Connection ~ 4350 3600
Wire Bus Line
	4350 3600 4350 4350
Wire Wire Line
	5250 4150 4650 4150
Wire Wire Line
	5250 4250 4550 4250
Wire Bus Line
	2450 5700 5150 5700
Connection ~ 5150 5700
Wire Bus Line
	5150 5700 5250 5700
Wire Bus Line
	5250 4550 5150 4550
Wire Bus Line
	5150 4550 5150 5700
Wire Bus Line
	4250 4450 5250 4450
Wire Bus Line
	5250 4350 4350 4350
Text HLabel 2450 3750 0    50   Input ~ 0
A[0..15]
Text HLabel 2450 5600 0    50   Input ~ 0
B[0..15]
Wire Bus Line
	2450 2450 4350 2450
Wire Bus Line
	2450 5600 5250 5600
Connection ~ 4250 3750
Wire Bus Line
	4250 3750 4250 4450
Wire Bus Line
	2450 2350 8400 2350
$Sheet
S 7300 4000 1400 700 
U 5FD9B0CB
F0 "OP/EX" 50
F1 "OP_EX.sch" 50
F2 "StoreOp[0..15]" O R 8700 4200 50 
F3 "StoreOpIn[0..15]" I L 7300 4200 50 
F4 "Phi1" I L 7300 4100 50 
F5 "SelCIn[0..2]" I L 7300 4300 50 
F6 "SelC[0..2]" O R 8700 4300 50 
F7 "CtlIn[5..19]" I L 7300 4400 50 
F8 "Ctl[5..19]" O R 8700 4400 50 
$EndSheet
$EndSCHEMATC
