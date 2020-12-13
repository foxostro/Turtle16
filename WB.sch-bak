EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 13 34
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
Text HLabel 1400 5050 0    50   Input ~ 0
Y_WB[0..15]
Text Notes 6400 5500 0    50   ~ 0
Src=0  —> Select ALU Result\nSrc=1  —> Select Store Operand
Wire Bus Line
	6400 5050 1400 5050
Text HLabel 1400 5150 0    50   Input ~ 0
StoreOp_WB[0..15]
Entry Wire Line
	4900 3550 5000 3650
Entry Wire Line
	5050 3550 5150 3650
Entry Wire Line
	4600 3550 4700 3650
Text Label 5150 3700 3    50   ~ 0
Ctl_WB18
Text Label 5000 3700 3    50   ~ 0
Ctl_WB19
Text Label 4700 3700 3    50   ~ 0
Ctl_WB16
Wire Wire Line
	5150 3650 5150 4300
Wire Wire Line
	5000 3650 5000 4400
$Sheet
S 6400 4750 1250 500 
U 6025930D
F0 "Select Write Back Source" 50
F1 "SelectWriteBackSource.sch" 50
F2 "C[0..15]" O R 7650 4850 50 
F3 "StoreOp_WB[0..15]" I L 6400 5150 50 
F4 "Y_WB[0..15]" I L 6400 5050 50 
F5 "WriteBackSrc" I L 6400 4850 50 
$EndSheet
Text HLabel 9150 4400 2    50   Output ~ 0
~WRH
Wire Bus Line
	7650 4850 9150 4850
Text HLabel 1400 3550 0    50   Input ~ 0
Ctl_WB[16..20]
Text HLabel 9150 4300 2    50   Output ~ 0
~WRL
Wire Wire Line
	4700 3650 4700 4850
Wire Wire Line
	5150 4300 9150 4300
Wire Wire Line
	5000 4400 9150 4400
Entry Wire Line
	4750 3550 4850 3650
Text Label 4850 3700 3    50   ~ 0
Ctl_WB20
Wire Wire Line
	4700 4850 6400 4850
Text HLabel 9150 4500 2    50   Output ~ 0
~WBEN
Wire Wire Line
	4850 3650 4850 4500
Wire Wire Line
	4850 4500 9150 4500
Wire Bus Line
	1400 5150 6400 5150
Entry Wire Line
	4450 3550 4550 3650
Wire Bus Line
	1400 3550 5050 3550
NoConn ~ 4550 4100
Wire Wire Line
	4550 3650 4550 4100
Text Label 4550 3700 3    50   ~ 0
Ctl_WB17
$EndSCHEMATC
