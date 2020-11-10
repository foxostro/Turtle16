EESchema Schematic File Version 4
LIBS:MainBoard-cache
EELAYER 29 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 71 88
Title "ID/REG Interstage Registers"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 "Registers holding state between the ID and REG stages of the pipeline."
$EndDescr
$Sheet
S 5050 2550 1150 500 
U 5FCDD090
F0 "Program Counter Value" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 5050 2750 50 
F3 "Q[0..15]" O R 6200 2750 50 
F4 "CP" I L 5050 2650 50 
$EndSheet
Wire Bus Line
	5050 2750 4550 2750
Text HLabel 4550 2650 0    50   Input ~ 0
Phi1
Wire Wire Line
	4550 2650 5050 2650
Wire Bus Line
	8000 2750 6200 2750
Text HLabel 8000 2750 2    50   Output ~ 0
PC[0..15]
$Sheet
S 5050 3300 1150 500 
U 5FD148F1
F0 "Instruction Word" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 5050 3500 50 
F3 "Q[0..15]" O R 6200 3500 50 
F4 "CP" I L 5050 3400 50 
$EndSheet
Wire Bus Line
	5050 3500 4550 3500
Text HLabel 4550 3500 0    50   Input ~ 0
InsIn[0..15]
Text HLabel 4550 3400 0    50   Input ~ 0
Phi1
Wire Wire Line
	4550 3400 5050 3400
Text HLabel 4550 2750 0    50   Input ~ 0
PCIn[0..15]
$Sheet
S 5050 4050 1150 500 
U 5FD202DF
F0 "Control Word [0..15]" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 5050 4250 50 
F3 "Q[0..15]" O R 6200 4250 50 
F4 "CP" I L 5050 4150 50 
$EndSheet
Wire Bus Line
	5050 4250 3000 4250
Text HLabel 2400 3700 0    50   Input ~ 0
CtlIn[0..23]
Text HLabel 4550 4150 0    50   Input ~ 0
Phi1
Wire Wire Line
	4550 4150 5050 4150
Text HLabel 8000 4650 2    50   Output ~ 0
Ctl[0..23]
Text HLabel 4550 4900 0    50   Input ~ 0
Phi1
Wire Wire Line
	4550 4900 5050 4900
Wire Bus Line
	8000 3500 6200 3500
Text HLabel 8000 3500 2    50   Output ~ 0
Ins[0..15]
Entry Bus Bus
	2900 4150 3000 4250
Text Label 3050 4250 0    50   ~ 0
CtlIn[0..15]
Wire Bus Line
	5050 5000 3000 5000
Entry Bus Bus
	2900 4900 3000 5000
Text Label 3050 5000 0    50   ~ 0
CtlIn[16..23]
Wire Bus Line
	2400 3700 2900 3700
$Sheet
S 5050 4800 1150 500 
U 5FBEE9DC
F0 "sheet5FBEE9D7" 50
F1 "EightBitPipelineRegister.sch" 50
F2 "CP" I L 5050 4900 50 
F3 "D[0..7]" I L 5050 5000 50 
F4 "Z[0..7]" O R 6200 5000 50 
$EndSheet
Entry Bus Bus
	7250 5000 7350 4900
Entry Bus Bus
	7250 4250 7350 4350
Wire Bus Line
	6200 5000 7250 5000
Wire Bus Line
	7350 4900 7350 4650
Wire Bus Line
	8000 4650 7350 4650
Text Label 6800 5000 0    50   ~ 0
Ctl[16..23]
Text Label 6750 4250 0    50   ~ 0
Ctl[0..15]
Wire Bus Line
	7350 4350 7350 4650
Connection ~ 7350 4650
Wire Bus Line
	6200 4250 7250 4250
Wire Bus Line
	2900 3700 2900 4900
$EndSCHEMATC
