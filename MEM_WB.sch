EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 44 86
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text HLabel 4400 1650 0    50   Input ~ 0
ALUResultIn[0..15]
Text HLabel 6400 2350 2    50   Output ~ 0
StoreOp[0..15]
Text HLabel 4400 2350 0    50   Input ~ 0
StoreOpIn[0..15]
Text HLabel 6400 1650 2    50   Output ~ 0
ALUResult[0..15]
$Sheet
S 4900 1450 1150 500 
U 6005FCF2
F0 "sheet6005FCE5" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 4900 1650 50 
F3 "Q[0..15]" O R 6050 1650 50 
F4 "CP" I L 4900 1550 50 
$EndSheet
Wire Bus Line
	4900 1650 4400 1650
Text HLabel 3650 1050 0    50   Input ~ 0
Phi1
Wire Wire Line
	3650 1050 4050 1050
Wire Bus Line
	6400 1650 6050 1650
$Sheet
S 4900 2150 1150 500 
U 6005FCFB
F0 "sheet6005FCE6" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 4900 2350 50 
F3 "Q[0..15]" O R 6050 2350 50 
F4 "CP" I L 4900 2250 50 
$EndSheet
Wire Bus Line
	4900 2350 4400 2350
Wire Bus Line
	6400 2350 6050 2350
Text HLabel 2000 3650 0    50   Input ~ 0
SelCIn[0..2]
$Sheet
S 4900 3650 1150 500 
U 5FC5F3B1
F0 "sheet5FC5F3AB" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 4900 3850 50 
F3 "Q[0..15]" O R 6050 3850 50 
F4 "CP" I L 4900 3750 50 
$EndSheet
Text HLabel 2000 3350 0    50   Input ~ 0
CtlIn[15..23]
Wire Bus Line
	2000 3650 3400 3650
Entry Bus Bus
	3400 3550 3500 3650
Wire Bus Line
	3500 3850 4900 3850
Text Label 3100 3550 0    50   ~ 0
D[3..11]
Text Label 3100 3650 0    50   ~ 0
D[0..2]
Text Label 3650 3850 0    50   ~ 0
D[0..15]
Entry Bus Bus
	2450 3450 2550 3550
Wire Bus Line
	2550 3550 3400 3550
Wire Bus Line
	2000 3350 2450 3350
Entry Bus Bus
	3400 3650 3500 3750
$Comp
L power:GND #PWR?
U 1 1 5FC5F3C5
P 3000 3350
AR Path="/60A72859/5FC5F3C5" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/5FC5F3C5" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/5FC5F3C5" Ref="#PWR0182"  Part="1" 
F 0 "#PWR0182" H 3000 3100 50  0001 C CNN
F 1 "GND" V 3005 3222 50  0000 R CNN
F 2 "" H 3000 3350 50  0001 C CNN
F 3 "" H 3000 3350 50  0001 C CNN
	1    3000 3350
	0    1    1    0   
$EndComp
Text Label 3100 3350 0    50   ~ 0
D12
Wire Wire Line
	3000 3350 3400 3350
Entry Wire Line
	3400 3350 3500 3450
Wire Bus Line
	2450 3350 2450 3450
Text HLabel 9050 3650 2    50   Output ~ 0
SelC[0..2]
Text HLabel 9050 3350 2    50   Output ~ 0
Ctl[15..23]
Wire Bus Line
	9050 3650 7650 3650
Entry Bus Bus
	7650 3550 7550 3650
Wire Bus Line
	7550 3850 6050 3850
Text Label 7650 3550 0    50   ~ 0
Q[3..11]
Text Label 7650 3650 0    50   ~ 0
Q[0..2]
Text Label 7400 3850 2    50   ~ 0
Q[0..15]
Entry Bus Bus
	8600 3450 8500 3550
Wire Bus Line
	8500 3550 7650 3550
Text Label 8500 3550 2    50   ~ 0
Ctl[15..23]
Wire Bus Line
	9050 3350 8600 3350
Entry Bus Bus
	7650 3650 7550 3750
Text Label 7650 3400 0    50   ~ 0
Q12
Wire Wire Line
	8050 3400 7650 3400
Entry Wire Line
	7650 3400 7550 3500
Wire Bus Line
	8600 3350 8600 3450
NoConn ~ 8050 3400
$Comp
L power:GND #PWR?
U 1 1 5FC5F3E1
P 3000 3250
AR Path="/60A72859/5FC5F3E1" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/5FC5F3E1" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/5FC5F3E1" Ref="#PWR0181"  Part="1" 
F 0 "#PWR0181" H 3000 3000 50  0001 C CNN
F 1 "GND" V 3005 3122 50  0000 R CNN
F 2 "" H 3000 3250 50  0001 C CNN
F 3 "" H 3000 3250 50  0001 C CNN
	1    3000 3250
	0    1    1    0   
$EndComp
Text Label 3100 3250 0    50   ~ 0
D13
Wire Wire Line
	3000 3250 3400 3250
Entry Wire Line
	3400 3250 3500 3350
Text Label 7650 3300 0    50   ~ 0
Q13
Wire Wire Line
	8050 3300 7650 3300
Entry Wire Line
	7650 3300 7550 3400
NoConn ~ 8050 3300
Text Label 2550 3550 0    50   ~ 0
CtlIn[15..23]
$Comp
L power:GND #PWR?
U 1 1 5FC60181
P 3000 3150
AR Path="/60A72859/5FC60181" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/5FC60181" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/5FC60181" Ref="#PWR0180"  Part="1" 
F 0 "#PWR0180" H 3000 2900 50  0001 C CNN
F 1 "GND" V 3005 3022 50  0000 R CNN
F 2 "" H 3000 3150 50  0001 C CNN
F 3 "" H 3000 3150 50  0001 C CNN
	1    3000 3150
	0    1    1    0   
$EndComp
Text Label 3100 3150 0    50   ~ 0
D14
Wire Wire Line
	3000 3150 3400 3150
Entry Wire Line
	3400 3150 3500 3250
$Comp
L power:GND #PWR?
U 1 1 5FC6018A
P 3000 3050
AR Path="/60A72859/5FC6018A" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/5FC6018A" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/5FC6018A" Ref="#PWR0179"  Part="1" 
F 0 "#PWR0179" H 3000 2800 50  0001 C CNN
F 1 "GND" V 3005 2922 50  0000 R CNN
F 2 "" H 3000 3050 50  0001 C CNN
F 3 "" H 3000 3050 50  0001 C CNN
	1    3000 3050
	0    1    1    0   
$EndComp
Text Label 3100 3050 0    50   ~ 0
D15
Wire Wire Line
	3000 3050 3400 3050
Entry Wire Line
	3400 3050 3500 3150
Text Label 7650 3200 0    50   ~ 0
Q14
Wire Wire Line
	8050 3200 7650 3200
Entry Wire Line
	7650 3200 7550 3300
Text Label 7650 3100 0    50   ~ 0
Q15
Wire Wire Line
	8050 3100 7650 3100
Entry Wire Line
	7650 3100 7550 3200
NoConn ~ 8050 3200
NoConn ~ 8050 3100
NoConn ~ -400 2500
NoConn ~ -400 4000
NoConn ~ -400 4500
$Comp
L 74xx:74LS04 U?
U 7 1 5FC24107
P -1000 5300
AR Path="/5D2C0761/5FC24107" Ref="U?"  Part="7" 
AR Path="/5D2C0720/5FC24107" Ref="U?"  Part="7" 
AR Path="/5D2C07CD/5FC24107" Ref="U?"  Part="7" 
AR Path="/5FF41DF6/5FC24107" Ref="U100"  Part="7" 
F 0 "U100" H -1000 5350 50  0000 C CNN
F 1 "74AHCT04" H -1000 5250 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -1000 5300 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -1000 5300 50  0001 C CNN
	7    -1000 5300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 6 1 5FC2410D
P -700 4500
AR Path="/5D8005AF/5D800744/5FC2410D" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC2410D" Ref="U?"  Part="6" 
AR Path="/5D2C07CD/5FC2410D" Ref="U?"  Part="6" 
AR Path="/5FF41DF6/5FC2410D" Ref="U100"  Part="6" 
F 0 "U100" H -700 4817 50  0000 C CNN
F 1 "74AHCT04" H -700 4726 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -700 4500 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -700 4500 50  0001 C CNN
	6    -700 4500
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 2 1 5FC24113
P -700 2500
AR Path="/5D8005AF/5D800744/5FC24113" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC24113" Ref="U?"  Part="2" 
AR Path="/5D2C07CD/5FC24113" Ref="U?"  Part="2" 
AR Path="/5FF41DF6/5FC24113" Ref="U100"  Part="2" 
F 0 "U100" H -700 2817 50  0000 C CNN
F 1 "74AHCT04" H -700 2726 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -700 2500 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -700 2500 50  0001 C CNN
	2    -700 2500
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 5 1 5FC24119
P -700 4000
AR Path="/5D8005AF/5D800744/5FC24119" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC24119" Ref="U?"  Part="5" 
AR Path="/5D2C07CD/5FC24119" Ref="U?"  Part="5" 
AR Path="/5FF41DF6/5FC24119" Ref="U100"  Part="5" 
F 0 "U100" H -700 4317 50  0000 C CNN
F 1 "74AHCT04" H -700 4226 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -700 4000 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -700 4000 50  0001 C CNN
	5    -700 4000
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 4 1 5FC2411F
P -700 3500
AR Path="/5D8005AF/5D800744/5FC2411F" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC2411F" Ref="U?"  Part="4" 
AR Path="/5D2C07CD/5FC2411F" Ref="U?"  Part="4" 
AR Path="/5FF41DF6/5FC2411F" Ref="U100"  Part="4" 
F 0 "U100" H -700 3817 50  0000 C CNN
F 1 "74AHCT04" H -700 3726 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -700 3500 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -700 3500 50  0001 C CNN
	4    -700 3500
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 3 1 5FC24125
P -700 3000
AR Path="/5D8005AF/5D800744/5FC24125" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC24125" Ref="U?"  Part="3" 
AR Path="/5D2C07CD/5FC24125" Ref="U?"  Part="3" 
AR Path="/5FF41DF6/5FC24125" Ref="U100"  Part="3" 
F 0 "U100" H -700 3317 50  0000 C CNN
F 1 "74AHCT04" H -700 3226 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -700 3000 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -700 3000 50  0001 C CNN
	3    -700 3000
	1    0    0    -1  
$EndComp
NoConn ~ -400 3000
NoConn ~ -400 3500
$Comp
L power:VCC #PWR?
U 1 1 5FC2412D
P -1000 1600
AR Path="/5D2C0761/5FC2412D" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5FC2412D" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FC2412D" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/5FC2412D" Ref="#PWR0537"  Part="1" 
F 0 "#PWR0537" H -1000 1450 50  0001 C CNN
F 1 "VCC" H -983 1773 50  0000 C CNN
F 2 "" H -1000 1600 50  0001 C CNN
F 3 "" H -1000 1600 50  0001 C CNN
	1    -1000 1600
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1000 2500 -1000 3000
Connection ~ -1000 2500
Connection ~ -1000 3000
Wire Wire Line
	-1000 3000 -1000 3500
Connection ~ -1000 3500
Wire Wire Line
	-1000 3500 -1000 4000
Connection ~ -1000 4000
Wire Wire Line
	-1000 4000 -1000 4500
$Comp
L power:GND #PWR?
U 1 1 5FC2413B
P -1000 5950
AR Path="/5D2C0720/5FC2413B" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/5FC2413B" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FC2413B" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/5FC2413B" Ref="#PWR0538"  Part="1" 
F 0 "#PWR0538" H -1000 5700 50  0001 C CNN
F 1 "GND" H -995 5777 50  0000 C CNN
F 2 "" H -1000 5950 50  0001 C CNN
F 3 "" H -1000 5950 50  0001 C CNN
	1    -1000 5950
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-1000 5800 -1000 5950
Wire Wire Line
	-1000 4500 -1000 4800
Connection ~ -1000 4500
$Comp
L 74xx:74LS04 U?
U 1 1 5FC24145
P 4350 1050
AR Path="/5D8005AF/5D800744/5FC24145" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC24145" Ref="U?"  Part="2" 
AR Path="/5D2C07CD/5FC24145" Ref="U?"  Part="1" 
AR Path="/5FF41DF6/5FC24145" Ref="U100"  Part="1" 
F 0 "U100" H 4350 1367 50  0000 C CNN
F 1 "74AHCT04" H 4350 1276 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 4350 1050 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 4350 1050 50  0001 C CNN
	1    4350 1050
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1000 1600 -1000 2500
Wire Wire Line
	4650 1050 4800 1050
Wire Wire Line
	4800 1050 4800 1550
Wire Wire Line
	4800 1550 4900 1550
Wire Wire Line
	4800 1550 4800 2250
Connection ~ 4800 1550
Wire Wire Line
	4800 2250 4900 2250
Wire Wire Line
	4800 2250 4800 3750
Connection ~ 4800 2250
Wire Wire Line
	4800 3750 4900 3750
Wire Bus Line
	3500 3150 3500 3850
Wire Bus Line
	7550 3200 7550 3850
$EndSCHEMATC
