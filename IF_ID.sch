EESchema Schematic File Version 4
LIBS:MainBoard-cache
EELAYER 29 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 9 89
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text HLabel 4400 3500 0    50   Input ~ 0
PCIn[0..15]
Text HLabel 6550 3500 2    50   Output ~ 0
PCOut[0..15]
Text HLabel 4400 4250 0    50   Input ~ 0
InsIn[0..15]
Text HLabel 6550 4250 2    50   Output ~ 0
InsOut[0..15]
$Sheet
S 4900 3300 1150 500 
U 5FC6FC04
F0 "sheet5FC6FBFF" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 4900 3500 50 
F3 "Q[0..15]" O R 6050 3500 50 
F4 "CP" I L 4900 3400 50 
$EndSheet
Wire Bus Line
	4900 3500 4400 3500
Text HLabel 4400 3400 0    50   Input ~ 0
Phi1
Wire Wire Line
	4400 3400 4900 3400
Wire Bus Line
	6550 3500 6050 3500
$Sheet
S 4900 4050 1150 500 
U 5FC806D1
F0 "sheet5FC806CA" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 4900 4250 50 
F3 "Q[0..15]" O R 6050 4250 50 
F4 "CP" I L 4900 4150 50 
$EndSheet
Wire Bus Line
	4900 4250 4400 4250
Text HLabel 4400 4150 0    50   Input ~ 0
Phi1
Wire Wire Line
	4400 4150 4900 4150
Wire Bus Line
	6550 4250 6050 4250
$EndSCHEMATC
