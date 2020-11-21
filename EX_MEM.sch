EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 7 33
Title "EX/MEM Interstage Register"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 "The interstage pipeline registers between EX and MEM."
$EndDescr
Text HLabel 6850 4400 2    50   Output ~ 0
StoreOp[0..15]
Text HLabel 3400 4400 0    50   Input ~ 0
StoreOpIn[0..15]
Text HLabel 3400 2700 0    50   Input ~ 0
Phi1
Wire Bus Line
	4800 4400 3400 4400
Wire Bus Line
	6850 4400 5950 4400
Wire Wire Line
	4700 4300 4800 4300
Wire Wire Line
	4700 4950 4800 4950
Text HLabel 3400 5150 0    50   Input ~ 0
SelCIn[0..2]
Wire Bus Line
	3400 5150 4800 5150
Wire Bus Line
	3400 5050 4800 5050
Wire Bus Line
	5950 5050 6850 5050
Text HLabel 6850 5150 2    50   Output ~ 0
SelC[0..2]
Wire Bus Line
	5950 5150 6850 5150
$Sheet
S 4800 4200 1150 450 
U 604BC5B1
F0 "Store Operand Register 2" 50
F1 "StoreOperandRegister2.sch" 50
F2 "CP" I L 4800 4300 50 
F3 "D[0..15]" I L 4800 4400 50 
F4 "Q[0..15]" O R 5950 4400 50 
$EndSheet
Wire Wire Line
	4700 4300 4700 4950
Connection ~ 4700 4300
Text HLabel 3400 5050 0    50   Input ~ 0
CtlIn[12..19]
Text HLabel 6850 5050 2    50   Output ~ 0
Ctl[13..19]
$Sheet
S 4800 4850 1150 400 
U 604D665C
F0 "Sheet604D665B" 50
F1 "Ctl_13_23_Register.sch" 50
F2 "CP" I L 4800 4950 50 
F3 "Ctl[13..19]" O R 5950 5050 50 
F4 "CtlIn[12..19]" I L 4800 5050 50 
F5 "SelCIn[0..2]" I L 4800 5150 50 
F6 "SelC[0..2]" O R 5950 5150 50 
F7 "~J" O R 5950 4950 50 
$EndSheet
Text HLabel 6850 4950 2    50   Output ~ 0
~J
Wire Wire Line
	6850 4950 5950 4950
Wire Wire Line
	4700 2700 4700 3600
Wire Wire Line
	3400 2700 4700 2700
$Sheet
S 4800 3500 1150 450 
U 5FB8FC1F
F0 "Sheet5FB8FC1E" 50
F1 "ALUResultRegister.sch" 50
F2 "CP" I L 4800 3600 50 
F3 "F[0..15]" I L 4800 3750 50 
F4 "ALUResult[0..15]" O R 5950 3750 50 
$EndSheet
Text HLabel 6850 3750 2    50   Output ~ 0
ALUResult[0..15]
Wire Bus Line
	6850 3750 5950 3750
Wire Wire Line
	4800 3600 4700 3600
Connection ~ 4700 3600
Wire Wire Line
	4700 3600 4700 4300
Text HLabel 3400 3750 0    50   Input ~ 0
F[0..15]
Wire Bus Line
	4800 3750 3400 3750
$EndSCHEMATC
