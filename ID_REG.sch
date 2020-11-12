EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 68 89
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
Text HLabel 3550 1850 0    50   Input ~ 0
Phi1
Wire Wire Line
	3550 1850 4050 1850
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
Text HLabel 8000 4650 2    50   Output ~ 0
Ctl[0..23]
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
NoConn ~ -450 3350
NoConn ~ -450 4850
NoConn ~ -450 5350
$Comp
L 74xx:74LS04 U?
U 7 1 5FC1E104
P -1050 6150
AR Path="/5D2C0761/5FC1E104" Ref="U?"  Part="7" 
AR Path="/5D2C0720/5FC1E104" Ref="U?"  Part="7" 
AR Path="/5D2C07CD/5FC1E104" Ref="U?"  Part="7" 
AR Path="/60153F0B/5FC1E104" Ref="U104"  Part="7" 
F 0 "U104" H -1050 6200 50  0000 C CNN
F 1 "74AHCT04" H -1050 6100 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -1050 6150 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -1050 6150 50  0001 C CNN
	7    -1050 6150
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 6 1 5FC1E10A
P -750 5350
AR Path="/5D8005AF/5D800744/5FC1E10A" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC1E10A" Ref="U?"  Part="6" 
AR Path="/5D2C07CD/5FC1E10A" Ref="U?"  Part="6" 
AR Path="/60153F0B/5FC1E10A" Ref="U104"  Part="6" 
F 0 "U104" H -750 5667 50  0000 C CNN
F 1 "74AHCT04" H -750 5576 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -750 5350 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -750 5350 50  0001 C CNN
	6    -750 5350
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 2 1 5FC1E110
P -750 3350
AR Path="/5D8005AF/5D800744/5FC1E110" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC1E110" Ref="U?"  Part="2" 
AR Path="/5D2C07CD/5FC1E110" Ref="U?"  Part="2" 
AR Path="/60153F0B/5FC1E110" Ref="U104"  Part="2" 
F 0 "U104" H -750 3667 50  0000 C CNN
F 1 "74AHCT04" H -750 3576 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -750 3350 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -750 3350 50  0001 C CNN
	2    -750 3350
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 5 1 5FC1E116
P -750 4850
AR Path="/5D8005AF/5D800744/5FC1E116" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC1E116" Ref="U?"  Part="5" 
AR Path="/5D2C07CD/5FC1E116" Ref="U?"  Part="5" 
AR Path="/60153F0B/5FC1E116" Ref="U104"  Part="5" 
F 0 "U104" H -750 5167 50  0000 C CNN
F 1 "74AHCT04" H -750 5076 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -750 4850 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -750 4850 50  0001 C CNN
	5    -750 4850
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 4 1 5FC1E11C
P -750 4350
AR Path="/5D8005AF/5D800744/5FC1E11C" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC1E11C" Ref="U?"  Part="4" 
AR Path="/5D2C07CD/5FC1E11C" Ref="U?"  Part="4" 
AR Path="/60153F0B/5FC1E11C" Ref="U104"  Part="4" 
F 0 "U104" H -750 4667 50  0000 C CNN
F 1 "74AHCT04" H -750 4576 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -750 4350 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -750 4350 50  0001 C CNN
	4    -750 4350
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 3 1 5FC1E122
P -750 3850
AR Path="/5D8005AF/5D800744/5FC1E122" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC1E122" Ref="U?"  Part="3" 
AR Path="/5D2C07CD/5FC1E122" Ref="U?"  Part="3" 
AR Path="/60153F0B/5FC1E122" Ref="U104"  Part="3" 
F 0 "U104" H -750 4167 50  0000 C CNN
F 1 "74AHCT04" H -750 4076 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -750 3850 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -750 3850 50  0001 C CNN
	3    -750 3850
	1    0    0    -1  
$EndComp
NoConn ~ -450 3850
NoConn ~ -450 4350
$Comp
L power:VCC #PWR?
U 1 1 5FC1E12A
P -1050 2450
AR Path="/5D2C0761/5FC1E12A" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5FC1E12A" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FC1E12A" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FC1E12A" Ref="#PWR0572"  Part="1" 
F 0 "#PWR0572" H -1050 2300 50  0001 C CNN
F 1 "VCC" H -1033 2623 50  0000 C CNN
F 2 "" H -1050 2450 50  0001 C CNN
F 3 "" H -1050 2450 50  0001 C CNN
	1    -1050 2450
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1050 3350 -1050 3850
Connection ~ -1050 3350
Connection ~ -1050 3850
Wire Wire Line
	-1050 3850 -1050 4350
Connection ~ -1050 4350
Wire Wire Line
	-1050 4350 -1050 4850
Connection ~ -1050 4850
Wire Wire Line
	-1050 4850 -1050 5350
$Comp
L power:GND #PWR?
U 1 1 5FC1E138
P -1050 6800
AR Path="/5D2C0720/5FC1E138" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/5FC1E138" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FC1E138" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FC1E138" Ref="#PWR0573"  Part="1" 
F 0 "#PWR0573" H -1050 6550 50  0001 C CNN
F 1 "GND" H -1045 6627 50  0000 C CNN
F 2 "" H -1050 6800 50  0001 C CNN
F 3 "" H -1050 6800 50  0001 C CNN
	1    -1050 6800
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-1050 6650 -1050 6800
Wire Wire Line
	-1050 5350 -1050 5650
Connection ~ -1050 5350
NoConn ~ -450 2850
$Comp
L 74xx:74LS04 U?
U 1 1 5FC1E142
P 4350 1850
AR Path="/5D8005AF/5D800744/5FC1E142" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC1E142" Ref="U?"  Part="2" 
AR Path="/5D2C07CD/5FC1E142" Ref="U?"  Part="1" 
AR Path="/60153F0B/5FC1E142" Ref="U104"  Part="1" 
F 0 "U104" H 4350 2167 50  0000 C CNN
F 1 "74AHCT04" H 4350 2076 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 4350 1850 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 4350 1850 50  0001 C CNN
	1    4350 1850
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1050 2450 -1050 3350
Wire Wire Line
	4650 1850 4950 1850
Wire Wire Line
	4950 1850 4950 2650
Wire Wire Line
	4950 2650 5050 2650
Wire Wire Line
	4950 2650 4950 3400
Connection ~ 4950 2650
Wire Wire Line
	4950 3400 5050 3400
Wire Wire Line
	4950 3400 4950 4150
Connection ~ 4950 3400
Wire Wire Line
	4950 4150 5050 4150
Wire Wire Line
	4950 4150 4950 4900
Connection ~ 4950 4150
Wire Wire Line
	4950 4900 5050 4900
Wire Bus Line
	2900 3700 2900 4900
$EndSCHEMATC
