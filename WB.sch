EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 18 33
Title "WB"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 "allowing instructions to set half of a sixteen-bit word without bitwise masks."
Comment3 "This can load the upper eight bits of the register, the lower eight bits, or both,"
Comment4 "The Write Back stage chooses a value and writes it back to the register file."
$EndDescr
Text HLabel 9150 4850 2    50   Output ~ 0
C[0..15]
Text HLabel 2800 5050 0    50   Input ~ 0
ALUResultIn[0..15]
Text Notes 5300 5700 0    50   ~ 0
Src=0  —> Select ALU Result\nSrc=1  —> Select Store Operand\nSrc=2  —> Select Store Operand (byte swapped)
Wire Bus Line
	6400 5050 2800 5050
Text HLabel 2750 5450 0    50   Input ~ 0
StoreOp[0..15]
Entry Wire Line
	4900 3550 5000 3650
Entry Wire Line
	5050 3550 5150 3650
Entry Wire Line
	4450 3550 4550 3650
Entry Wire Line
	4600 3550 4700 3650
Text Label 5150 3700 3    50   ~ 0
Ctl18
Text Label 5000 3700 3    50   ~ 0
Ctl19
Text Label 4700 3700 3    50   ~ 0
Ctl16
Text Label 4550 3700 3    50   ~ 0
Ctl17
Wire Wire Line
	5150 3650 5150 4000
Wire Wire Line
	5000 3650 5000 4100
$Sheet
S 6400 4650 1250 600 
U 6025930D
F0 "Select Write Back Source" 50
F1 "SelectWriteBackSource.sch" 50
F2 "C[0..15]" O R 7650 4850 50 
F3 "WriteBackSrcB" I L 6400 4950 50 
F4 "StoreOp[0..15]" I L 6400 5150 50 
F5 "ALUResult[0..15]" I L 6400 5050 50 
F6 "WriteBackSrcA" I L 6400 4850 50 
F7 "Phi1" I L 6400 4750 50 
$EndSheet
Text HLabel 9150 4100 2    50   Output ~ 0
~WRH
Wire Bus Line
	7650 4850 9150 4850
Text HLabel 1400 3550 0    50   Input ~ 0
CtlIn[16..20]
Wire Bus Line
	1400 3550 1850 3550
Text HLabel 3200 3650 2    50   Output ~ 0
SelC[0..2]
Wire Bus Line
	3000 3650 3200 3650
$Sheet
S 2850 5250 1150 400 
U 5FE6C116
F0 "sheet5FE6C101" 50
F1 "StoreOperandRegister3.sch" 50
F2 "Phi1" I L 2850 5350 50 
F3 "D[0..15]" I L 2850 5450 50 
F4 "Q[0..15]" O R 4000 5450 50 
$EndSheet
$Sheet
S 1850 3350 1150 400 
U 5FE6C11D
F0 "sheet5FE6C102" 50
F1 "Ctl_15_23_Register.sch" 50
F2 "Phi1" I L 1850 3450 50 
F3 "SelCIn[0..2]" I L 1850 3650 50 
F4 "SelC[0..2]" O R 3000 3650 50 
F5 "Ctl[16..20]" O R 3000 3550 50 
F6 "CtlIn[16..20]" I L 1850 3550 50 
$EndSheet
Text HLabel 1400 3650 0    50   Input ~ 0
SelCIn[0..2]
Wire Bus Line
	1850 3650 1400 3650
Wire Wire Line
	2750 5350 2850 5350
Wire Wire Line
	1400 3450 1850 3450
Wire Bus Line
	2750 5450 2850 5450
Wire Bus Line
	6400 5150 4600 5150
Wire Bus Line
	4600 5150 4600 5450
Wire Bus Line
	4600 5450 4000 5450
Text HLabel 9150 4000 2    50   Output ~ 0
~WRL
Text GLabel 6300 4750 0    50   Input ~ 0
Phi1c
Text GLabel 2750 5350 0    50   Input ~ 0
Phi1c
Text GLabel 1400 3450 0    50   Input ~ 0
Phi1c
Wire Wire Line
	4700 3650 4700 4850
Wire Wire Line
	4550 3650 4550 4950
Wire Wire Line
	5150 4000 9150 4000
Wire Wire Line
	5000 4100 9150 4100
Wire Wire Line
	6300 4750 6400 4750
Text Label 3850 3550 0    50   ~ 0
Ctl[16..20]
Entry Wire Line
	4750 3550 4850 3650
Text Label 4850 3700 3    50   ~ 0
Ctl20
Wire Wire Line
	4700 4850 6400 4850
Wire Wire Line
	4550 4950 6400 4950
Text HLabel 9150 4200 2    50   Output ~ 0
~WBEN
Wire Wire Line
	4850 3650 4850 4200
Wire Wire Line
	4850 4200 9150 4200
Wire Bus Line
	3000 3550 5050 3550
$EndSCHEMATC
