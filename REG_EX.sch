EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 15 48
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text HLabel 6600 2500 2    50   Output ~ 0
OpR[0..15]
Text HLabel 6600 1800 2    50   Output ~ 0
OpL[0..15]
Text HLabel 6600 3200 2    50   Output ~ 0
StoreOp[0..15]
Text HLabel 4600 2500 0    50   Input ~ 0
OpRIn[0..15]
Text HLabel 4600 1800 0    50   Input ~ 0
OpLIn[0..15]
Text HLabel 4600 3200 0    50   Input ~ 0
StoreOpIn[0..15]
Text HLabel 2150 4950 0    50   Input ~ 0
SelCIn[0..2]
Text HLabel 7500 5350 2    50   Output ~ 0
SelC[0..2]
$Sheet
S 5100 1600 1150 500 
U 5FD447EB
F0 "Left Operand" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 5100 1800 50 
F3 "Q[0..15]" O R 6250 1800 50 
F4 "CP" I L 5100 1700 50 
$EndSheet
Wire Bus Line
	5100 1800 4600 1800
Text HLabel 3750 1100 0    50   Input ~ 0
Phi1
Wire Wire Line
	3750 1100 4250 1100
Wire Bus Line
	6600 1800 6250 1800
$Sheet
S 5100 2300 1150 500 
U 5FD44E3D
F0 "Right Operand" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 5100 2500 50 
F3 "Q[0..15]" O R 6250 2500 50 
F4 "CP" I L 5100 2400 50 
$EndSheet
Wire Bus Line
	5100 2500 4600 2500
Wire Bus Line
	6600 2500 6250 2500
$Sheet
S 5100 3000 1150 500 
U 5FD45557
F0 "Store Operand" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 5100 3200 50 
F3 "Q[0..15]" O R 6250 3200 50 
F4 "CP" I L 5100 3100 50 
$EndSheet
Wire Bus Line
	5100 3200 4600 3200
Wire Bus Line
	6600 3200 6250 3200
$Sheet
S 5100 4250 1150 500 
U 5FD45834
F0 "sheet5FD4582D" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 5100 4450 50 
F3 "Q[0..15]" O R 6250 4450 50 
F4 "CP" I L 5100 4350 50 
$EndSheet
Wire Bus Line
	8550 4450 6250 4450
Wire Bus Line
	6900 5150 6250 5150
Text HLabel 2150 4100 0    50   Input ~ 0
CtlIn[5..23]
Wire Bus Line
	2150 4950 3550 4950
Entry Bus Bus
	3550 4950 3650 5050
Entry Bus Bus
	3550 4850 3650 4950
Wire Bus Line
	3650 5150 5100 5150
Text Label 3250 4850 0    50   ~ 0
D[3..5]
Text Label 3250 4950 0    50   ~ 0
D[0..2]
Wire Bus Line
	7500 5350 7000 5350
Wire Bus Line
	8550 5450 7000 5450
Entry Bus Bus
	7000 5350 6900 5250
Entry Bus Bus
	7000 5450 6900 5350
Text Label 7050 5350 0    50   ~ 0
Z[0..2]
Text Label 3800 5150 0    50   ~ 0
D[0..7]
Text Label 6550 5150 0    50   ~ 0
Z[0..7]
Text Label 7050 5450 0    50   ~ 0
Z[3..5]
Text HLabel 9650 3900 2    50   Output ~ 0
Ctl[5..23]
Entry Bus Bus
	2650 4350 2750 4450
Wire Bus Line
	2750 4450 5100 4450
Text Label 2800 4450 0    50   ~ 0
CtlIn[8..23]
Entry Bus Bus
	2650 4750 2750 4850
Wire Bus Line
	2750 4850 3550 4850
Text Label 2750 4850 0    50   ~ 0
CtlIn[5..7]
Wire Bus Line
	2150 4100 2650 4100
Entry Bus Bus
	8550 5450 8650 5350
Entry Bus Bus
	8550 4450 8650 4350
Wire Bus Line
	8650 3900 9650 3900
Text Label 8450 4450 2    50   ~ 0
Ctl[8..23]
Text Label 8450 5450 2    50   ~ 0
Ctl[5..7]
$Comp
L power:GND #PWR0133
U 1 1 5FBB479B
P 3150 4700
F 0 "#PWR0133" H 3150 4450 50  0001 C CNN
F 1 "GND" V 3155 4572 50  0000 R CNN
F 2 "" H 3150 4700 50  0001 C CNN
F 3 "" H 3150 4700 50  0001 C CNN
	1    3150 4700
	0    1    1    0   
$EndComp
Text Label 3250 4700 0    50   ~ 0
D6
Wire Wire Line
	3150 4700 3550 4700
Entry Wire Line
	3550 4700 3650 4800
Text Label 7150 5550 2    50   ~ 0
Z6
Wire Wire Line
	7400 5550 7000 5550
Entry Wire Line
	7000 5550 6900 5450
NoConn ~ 7400 5550
$Comp
L power:GND #PWR0132
U 1 1 5FC17578
P 3150 4600
F 0 "#PWR0132" H 3150 4350 50  0001 C CNN
F 1 "GND" V 3155 4472 50  0000 R CNN
F 2 "" H 3150 4600 50  0001 C CNN
F 3 "" H 3150 4600 50  0001 C CNN
	1    3150 4600
	0    1    1    0   
$EndComp
Text Label 3250 4600 0    50   ~ 0
D7
Wire Wire Line
	3150 4600 3550 4600
Entry Wire Line
	3550 4600 3650 4700
$Sheet
S 5100 4950 1150 500 
U 5FC18C0A
F0 "sheet5FC18C05" 50
F1 "EightBitPipelineRegister.sch" 50
F2 "CP" I L 5100 5050 50 
F3 "D[0..7]" I L 5100 5150 50 
F4 "Z[0..7]" O R 6250 5150 50 
$EndSheet
Text Label 7150 5650 2    50   ~ 0
Z7
Wire Wire Line
	7400 5650 7000 5650
Entry Wire Line
	7000 5650 6900 5550
NoConn ~ 7400 5650
NoConn ~ -250 3050
NoConn ~ -250 4550
NoConn ~ -250 5050
$Comp
L 74xx:74LS04 U?
U 7 1 5FC492C0
P -850 5850
AR Path="/5D2C0761/5FC492C0" Ref="U?"  Part="7" 
AR Path="/5D2C0720/5FC492C0" Ref="U?"  Part="7" 
AR Path="/5D2C07CD/5FC492C0" Ref="U?"  Part="7" 
AR Path="/60A72859/5FC492C0" Ref="U99"  Part="7" 
F 0 "U99" H -850 5900 50  0000 C CNN
F 1 "74AHCT04" H -850 5800 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -850 5850 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -850 5850 50  0001 C CNN
	7    -850 5850
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 6 1 5FC492C6
P -550 5050
AR Path="/5D8005AF/5D800744/5FC492C6" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC492C6" Ref="U?"  Part="6" 
AR Path="/5D2C07CD/5FC492C6" Ref="U?"  Part="6" 
AR Path="/60A72859/5FC492C6" Ref="U99"  Part="6" 
F 0 "U99" H -550 5367 50  0000 C CNN
F 1 "74AHCT04" H -550 5276 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -550 5050 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -550 5050 50  0001 C CNN
	6    -550 5050
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 2 1 5FC492CC
P -550 3050
AR Path="/5D8005AF/5D800744/5FC492CC" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC492CC" Ref="U?"  Part="2" 
AR Path="/5D2C07CD/5FC492CC" Ref="U?"  Part="2" 
AR Path="/60A72859/5FC492CC" Ref="U99"  Part="2" 
F 0 "U99" H -550 3367 50  0000 C CNN
F 1 "74AHCT04" H -550 3276 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -550 3050 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -550 3050 50  0001 C CNN
	2    -550 3050
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 5 1 5FC492D2
P -550 4550
AR Path="/5D8005AF/5D800744/5FC492D2" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC492D2" Ref="U?"  Part="5" 
AR Path="/5D2C07CD/5FC492D2" Ref="U?"  Part="5" 
AR Path="/60A72859/5FC492D2" Ref="U99"  Part="5" 
F 0 "U99" H -550 4867 50  0000 C CNN
F 1 "74AHCT04" H -550 4776 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -550 4550 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -550 4550 50  0001 C CNN
	5    -550 4550
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 4 1 5FC492D8
P -550 4050
AR Path="/5D8005AF/5D800744/5FC492D8" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC492D8" Ref="U?"  Part="4" 
AR Path="/5D2C07CD/5FC492D8" Ref="U?"  Part="4" 
AR Path="/60A72859/5FC492D8" Ref="U99"  Part="4" 
F 0 "U99" H -550 4367 50  0000 C CNN
F 1 "74AHCT04" H -550 4276 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -550 4050 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -550 4050 50  0001 C CNN
	4    -550 4050
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 3 1 5FC492DE
P -550 3550
AR Path="/5D8005AF/5D800744/5FC492DE" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC492DE" Ref="U?"  Part="3" 
AR Path="/5D2C07CD/5FC492DE" Ref="U?"  Part="3" 
AR Path="/60A72859/5FC492DE" Ref="U99"  Part="3" 
F 0 "U99" H -550 3867 50  0000 C CNN
F 1 "74AHCT04" H -550 3776 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -550 3550 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -550 3550 50  0001 C CNN
	3    -550 3550
	1    0    0    -1  
$EndComp
NoConn ~ -250 3550
NoConn ~ -250 4050
$Comp
L power:VCC #PWR?
U 1 1 5FC492E6
P -850 2150
AR Path="/5D2C0761/5FC492E6" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5FC492E6" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FC492E6" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FC492E6" Ref="#PWR0535"  Part="1" 
F 0 "#PWR0535" H -850 2000 50  0001 C CNN
F 1 "VCC" H -833 2323 50  0000 C CNN
F 2 "" H -850 2150 50  0001 C CNN
F 3 "" H -850 2150 50  0001 C CNN
	1    -850 2150
	1    0    0    -1  
$EndComp
Wire Wire Line
	-850 3050 -850 3550
Connection ~ -850 3050
Connection ~ -850 3550
Wire Wire Line
	-850 3550 -850 4050
Connection ~ -850 4050
Wire Wire Line
	-850 4050 -850 4550
Connection ~ -850 4550
Wire Wire Line
	-850 4550 -850 5050
$Comp
L power:GND #PWR?
U 1 1 5FC492F4
P -850 6500
AR Path="/5D2C0720/5FC492F4" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/5FC492F4" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FC492F4" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FC492F4" Ref="#PWR0536"  Part="1" 
F 0 "#PWR0536" H -850 6250 50  0001 C CNN
F 1 "GND" H -845 6327 50  0000 C CNN
F 2 "" H -850 6500 50  0001 C CNN
F 3 "" H -850 6500 50  0001 C CNN
	1    -850 6500
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-850 6350 -850 6500
Wire Wire Line
	-850 5050 -850 5350
Connection ~ -850 5050
$Comp
L 74xx:74LS04 U?
U 1 1 5FC492FE
P 4550 1100
AR Path="/5D8005AF/5D800744/5FC492FE" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC492FE" Ref="U?"  Part="2" 
AR Path="/5D2C07CD/5FC492FE" Ref="U?"  Part="1" 
AR Path="/60A72859/5FC492FE" Ref="U99"  Part="1" 
F 0 "U99" H 4550 1417 50  0000 C CNN
F 1 "74AHCT04" H 4550 1326 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 4550 1100 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 4550 1100 50  0001 C CNN
	1    4550 1100
	1    0    0    -1  
$EndComp
Wire Wire Line
	-850 2150 -850 3050
Wire Wire Line
	4850 1100 5000 1100
Wire Wire Line
	5000 1100 5000 1700
Wire Wire Line
	5000 1700 5100 1700
Wire Wire Line
	5000 1700 5000 2400
Wire Wire Line
	5000 2400 5100 2400
Connection ~ 5000 1700
Wire Wire Line
	5000 2400 5000 3100
Wire Wire Line
	5000 3100 5100 3100
Connection ~ 5000 2400
Wire Wire Line
	5000 3100 5000 4350
Wire Wire Line
	5000 4350 5100 4350
Connection ~ 5000 3100
Wire Wire Line
	5000 4350 5000 5050
Wire Wire Line
	5000 5050 5100 5050
Connection ~ 5000 4350
Wire Bus Line
	8650 3900 8650 5350
Wire Bus Line
	2650 4100 2650 4750
Wire Bus Line
	6900 5150 6900 5550
Wire Bus Line
	3650 4700 3650 5150
$EndSCHEMATC
