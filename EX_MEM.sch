EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 8 33
Title "EX/MEM Interstage Register"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 "The interstage pipeline registers between EX and MEM."
$EndDescr
Text HLabel 6700 3700 2    50   Output ~ 0
StoreOp[0..15]
Text HLabel 4700 3700 0    50   Input ~ 0
StoreOpIn[0..15]
Text HLabel 3800 3300 0    50   Input ~ 0
Phi1
Wire Bus Line
	5200 3700 4700 3700
Wire Bus Line
	6700 3700 6350 3700
Wire Wire Line
	5100 3600 5200 3600
Wire Wire Line
	5100 4250 5200 4250
Text HLabel 3800 4450 0    50   Input ~ 0
SelCIn[0..2]
Wire Bus Line
	3800 4450 5200 4450
Wire Bus Line
	3800 4350 5200 4350
Wire Bus Line
	6350 4350 7250 4350
Text HLabel 7250 4450 2    50   Output ~ 0
SelC[0..2]
Wire Bus Line
	6350 4450 7250 4450
$Sheet
S 5200 3500 1150 450 
U 604BC5B1
F0 "Store Operand Register 2" 50
F1 "StoreOperandRegister2.sch" 50
F2 "CP" I L 5200 3600 50 
F3 "D[0..15]" I L 5200 3700 50 
F4 "Q[0..15]" O R 6350 3700 50 
$EndSheet
Wire Wire Line
	5100 3600 5100 4250
Connection ~ 5100 3600
Text HLabel 3800 4350 0    50   Input ~ 0
CtlIn[12..19]
Text HLabel 7250 4350 2    50   Output ~ 0
Ctl[13..19]
$Sheet
S 5200 4150 1150 400 
U 604D665C
F0 "Sheet604D665B" 50
F1 "Ctl_13_23_Register.sch" 50
F2 "CP" I L 5200 4250 50 
F3 "Ctl[13..19]" O R 6350 4350 50 
F4 "CtlIn[12..19]" I L 5200 4350 50 
F5 "SelCIn[0..2]" I L 5200 4450 50 
F6 "SelC[0..2]" O R 6350 4450 50 
F7 "~J" O R 6350 4250 50 
$EndSheet
Text HLabel 7250 4250 2    50   Output ~ 0
~J
Wire Wire Line
	7250 4250 6350 4250
Wire Wire Line
	5100 3300 5100 3600
Wire Wire Line
	3800 3300 5100 3300
$EndSCHEMATC
