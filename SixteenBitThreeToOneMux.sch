EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 83 89
Title "16-Bit 3:1 Mux"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 "Select one of three sixteen-bit inputs"
$EndDescr
$Sheet
S 5050 3250 850  400 
U 5FC930A8
F0 "sheet5FC930A1" 50
F1 "SixteenBitTwoToOneMux.sch" 50
F2 "Z[0..15]" O R 5900 3350 50 
F3 "S" I L 5050 3350 50 
F4 "Y[0..15]" I L 5050 3550 50 
F5 "X[0..15]" I L 5050 3450 50 
$EndSheet
Text HLabel 4400 3350 0    50   Input ~ 0
S0
Text HLabel 4400 2950 0    50   Input ~ 0
S1
Wire Wire Line
	5050 3350 4400 3350
Wire Wire Line
	4400 2950 6700 2950
$Sheet
S 6700 2850 850  800 
U 5FC930B2
F0 "sheet5FC930A2" 50
F1 "SixteenBitTwoToOneMux.sch" 50
F2 "Z[0..15]" O R 7550 2950 50 
F3 "S" I L 6700 2950 50 
F4 "Y[0..15]" I L 6700 3050 50 
F5 "X[0..15]" I L 6700 3350 50 
$EndSheet
Wire Bus Line
	5900 3350 6700 3350
Text HLabel 8200 2950 2    50   Output ~ 0
Z[0..15]
Wire Bus Line
	8200 2950 7550 2950
Text HLabel 4400 3450 0    50   Input ~ 0
A[0..15]
Wire Bus Line
	4400 3450 5050 3450
Text HLabel 4400 3550 0    50   Input ~ 0
B[0..15]
Wire Bus Line
	4400 3550 5050 3550
Text HLabel 4400 3050 0    50   Input ~ 0
C[0..15]
Wire Bus Line
	4400 3050 6700 3050
$EndSCHEMATC
