EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 30 33
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
Text Label 4650 4850 0    50   ~ 0
WriteBackSrcA
Text Label 4650 4950 0    50   ~ 0
WriteBackSrcB
Wire Bus Line
	5300 5050 2800 5050
Text HLabel 2750 5450 0    50   Input ~ 0
StoreOp[0..15]
Entry Wire Line
	3950 2600 4050 2700
Entry Wire Line
	4100 2600 4200 2700
Entry Wire Line
	3500 2600 3600 2700
Entry Wire Line
	3650 2600 3750 2700
Entry Wire Line
	3800 2600 3900 2700
Wire Wire Line
	3600 2700 3600 3100
NoConn ~ 3600 3100
Text Label 4200 2750 3    50   ~ 0
Ctl15
Text Label 4050 2750 3    50   ~ 0
Ctl16
Text Label 3900 2750 3    50   ~ 0
Ctl17
Text Label 3750 2750 3    50   ~ 0
Ctl18
Text Label 3600 2750 3    50   ~ 0
Ctl19
Wire Wire Line
	4200 2700 4200 3050
Wire Wire Line
	3900 2700 3900 4850
Wire Wire Line
	3900 4850 5300 4850
Wire Wire Line
	3750 2700 3750 4950
Wire Wire Line
	3750 4950 5300 4950
Wire Wire Line
	4200 3050 9150 3050
Wire Wire Line
	4050 2700 4050 3150
$Sheet
S 5300 4650 1250 600 
U 6025930D
F0 "Select Write Back Source" 50
F1 "SelectWriteBackSource.sch" 50
F2 "C[0..15]" O R 6550 4850 50 
F3 "WriteBackSrcB" I L 5300 4950 50 
F4 "StoreOp[0..15]" I L 5300 5150 50 
F5 "ALUResult[0..15]" I L 5300 5050 50 
F6 "WriteBackSrcA" I L 5300 4850 50 
F7 "Phi1" I L 5300 4750 50 
$EndSheet
Text HLabel 9150 3150 2    50   Output ~ 0
~WRH
Wire Bus Line
	6550 4850 9150 4850
Text HLabel 5050 4500 0    50   Input ~ 0
Phi1
Wire Wire Line
	5150 4750 5300 4750
Wire Wire Line
	5150 4750 5150 4500
Wire Wire Line
	5150 4500 5050 4500
Text HLabel 1400 3550 0    50   Input ~ 0
CtlIn[15..19]
Text HLabel 2750 5350 0    50   Input ~ 0
Phi1
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
F2 "CP" I L 2850 5350 50 
F3 "D[0..15]" I L 2850 5450 50 
F4 "Q[0..15]" O R 4000 5450 50 
$EndSheet
$Sheet
S 1850 3350 1150 400 
U 5FE6C11D
F0 "sheet5FE6C102" 50
F1 "Ctl_15_23_Register.sch" 50
F2 "CP" I L 1850 3450 50 
F3 "CtlIn[15..19]" I L 1850 3550 50 
F4 "SelCIn[0..2]" I L 1850 3650 50 
F5 "SelC[0..2]" O R 3000 3650 50 
F6 "Ctl[15..19]" O R 3000 3550 50 
$EndSheet
Text HLabel 1400 3650 0    50   Input ~ 0
SelCIn[0..2]
Wire Bus Line
	1850 3650 1400 3650
Wire Wire Line
	2750 5350 2850 5350
Text HLabel 1400 3450 0    50   Input ~ 0
Phi1
Wire Wire Line
	1400 3450 1850 3450
Wire Bus Line
	2750 5450 2850 5450
Wire Bus Line
	5300 5150 4600 5150
Wire Bus Line
	4600 5150 4600 5450
Wire Bus Line
	4600 5450 4000 5450
Wire Bus Line
	3200 2600 3200 3550
Wire Bus Line
	3000 3550 3200 3550
Text Label 3200 3350 1    50   ~ 0
Ctl[15..19]
Wire Wire Line
	4050 3150 9150 3150
Text HLabel 9150 3050 2    50   Output ~ 0
~WRL
Wire Bus Line
	3200 2600 4100 2600
$EndSCHEMATC
