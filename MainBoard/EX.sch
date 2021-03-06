EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 14 35
Title "EX"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 "ID stage of the CPU pipeline."
Comment3 "The ALU condition codes may be latched in a flags register which feeds back into the"
Comment4 "The EX stage is built around the IDT 7381 sixteen-bit ALU IC."
$EndDescr
Wire Wire Line
	8950 4550 9300 4550
Wire Wire Line
	9300 4450 8950 4450
NoConn ~ 8950 5150
NoConn ~ 8950 5050
NoConn ~ 8950 4950
NoConn ~ 8950 4850
NoConn ~ 8950 4750
$Comp
L power:GND #PWR?
U 1 1 5FE1BD7A
P 8450 5750
AR Path="/5D2C0CE4/5FE1BD7A" Ref="#PWR?"  Part="1" 
AR Path="/60A71BBF/5FE1BD7A" Ref="#PWR0198"  Part="1" 
F 0 "#PWR0198" H 8450 5500 50  0001 C CNN
F 1 "GND" H 8455 5577 50  0000 C CNN
F 2 "" H 8450 5750 50  0001 C CNN
F 3 "" H 8450 5750 50  0001 C CNN
	1    8450 5750
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FE1B681
P 8450 4150
AR Path="/5D2C0CE4/5FE1B681" Ref="#PWR?"  Part="1" 
AR Path="/60A71BBF/5FE1B681" Ref="#PWR0197"  Part="1" 
F 0 "#PWR0197" H 8450 4000 50  0001 C CNN
F 1 "VCC" H 8467 4323 50  0000 C CNN
F 2 "" H 8450 4150 50  0001 C CNN
F 3 "" H 8450 4150 50  0001 C CNN
	1    8450 4150
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS377 U27
U 1 1 5FE1ACC2
P 8450 4950
F 0 "U27" H 8150 5750 50  0000 C CNN
F 1 "74ABT377" H 8150 5650 50  0000 C CNN
F 2 "Package_SO:TSSOP-20_4.4x6.5mm_P0.65mm" H 8450 4950 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74abt377a" H 8450 4950 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Texas-Instruments/SN74ABT377APWR?qs=LzFo6vGRJ4tDfpbrS0MCHg%3D%3D" H 8450 4950 50  0001 C CNN "Mouser"
	1    8450 4950
	1    0    0    -1  
$EndComp
Text HLabel 9300 4550 2    50   Output ~ 0
Z
Text HLabel 9300 4450 2    50   Output ~ 0
Carry
$Comp
L power:GND #PWR0192
U 1 1 5FE21D5C
P 7950 4750
F 0 "#PWR0192" H 7950 4500 50  0001 C CNN
F 1 "GND" V 7955 4622 50  0000 R CNN
F 2 "" H 7950 4750 50  0001 C CNN
F 3 "" H 7950 4750 50  0001 C CNN
	1    7950 4750
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0193
U 1 1 5FE21F4C
P 7950 4850
F 0 "#PWR0193" H 7950 4600 50  0001 C CNN
F 1 "GND" V 7955 4722 50  0000 R CNN
F 2 "" H 7950 4850 50  0001 C CNN
F 3 "" H 7950 4850 50  0001 C CNN
	1    7950 4850
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0194
U 1 1 5FE2214D
P 7950 4950
F 0 "#PWR0194" H 7950 4700 50  0001 C CNN
F 1 "GND" V 7955 4822 50  0000 R CNN
F 2 "" H 7950 4950 50  0001 C CNN
F 3 "" H 7950 4950 50  0001 C CNN
	1    7950 4950
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0195
U 1 1 5FE222C6
P 7950 5050
F 0 "#PWR0195" H 7950 4800 50  0001 C CNN
F 1 "GND" V 7955 4922 50  0000 R CNN
F 2 "" H 7950 5050 50  0001 C CNN
F 3 "" H 7950 5050 50  0001 C CNN
	1    7950 5050
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0196
U 1 1 5FE2243F
P 7950 5150
F 0 "#PWR0196" H 7950 4900 50  0001 C CNN
F 1 "GND" V 7955 5022 50  0000 R CNN
F 2 "" H 7950 5150 50  0001 C CNN
F 3 "" H 7950 5150 50  0001 C CNN
	1    7950 5150
	0    1    1    0   
$EndComp
Text Label 5300 1100 0    50   ~ 0
Ctl_EX[14..20]
$Comp
L Device:C C?
U 1 1 600839BF
P 950 7400
AR Path="/5D8005AF/5D833E4B/600839BF" Ref="C?"  Part="1" 
AR Path="/5FE21410/600839BF" Ref="C?"  Part="1" 
AR Path="/5FE8EB3D/600839BF" Ref="C?"  Part="1" 
AR Path="/60153F0B/600839BF" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FBDE54D/600839BF" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC2B5F4/600839BF" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC56568/600839BF" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FCDD090/600839BF" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD148F1/600839BF" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD202DF/600839BF" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD2B946/600839BF" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD447EB/600839BF" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD44E3D/600839BF" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45108/600839BF" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45557/600839BF" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45834/600839BF" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD47CBA/600839BF" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/600400AF/600839BF" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60040306/600839BF" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60040791/600839BF" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60044374/600839BF" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/6004437C/600839BF" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/6004F414/600839BF" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FCF2/600839BF" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FCFB/600839BF" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FD06/600839BF" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FD11/600839BF" Ref="C?"  Part="1" 
AR Path="/60A71BBF/600839BF" Ref="C34"  Part="1" 
F 0 "C34" H 1065 7446 50  0000 L CNN
F 1 "100nF" H 1065 7355 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 988 7250 50  0001 C CNN
F 3 "~" H 950 7400 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 950 7400 50  0001 C CNN "Mouser"
	1    950  7400
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 600839CB
P 950 7250
AR Path="/5D8005AF/5D833E4B/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/5FE21410/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FBDE54D/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC2B5F4/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC56568/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FCDD090/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD148F1/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD202DF/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD2B946/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD447EB/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD44E3D/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45108/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45557/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45834/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD47CBA/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/600400AF/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040306/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040791/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60044374/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/6004437C/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/6004F414/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCF2/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCFB/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FD06/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FD11/600839CB" Ref="#PWR?"  Part="1" 
AR Path="/60A71BBF/600839CB" Ref="#PWR0190"  Part="1" 
F 0 "#PWR0190" H 950 7100 50  0001 C CNN
F 1 "VCC" H 967 7423 50  0000 C CNN
F 2 "" H 950 7250 50  0001 C CNN
F 3 "" H 950 7250 50  0001 C CNN
	1    950  7250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 600839D4
P 950 7650
AR Path="/5D8005AF/5D833E4B/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/5FE21410/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FBDE54D/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC2B5F4/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC56568/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FCDD090/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD148F1/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD202DF/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD2B946/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD447EB/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD44E3D/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45108/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45557/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45834/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD47CBA/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/600400AF/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040306/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040791/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60044374/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/6004437C/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/6004F414/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCF2/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCFB/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FD06/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FD11/600839D4" Ref="#PWR?"  Part="1" 
AR Path="/60A71BBF/600839D4" Ref="#PWR0191"  Part="1" 
F 0 "#PWR0191" H 950 7400 50  0001 C CNN
F 1 "GND" H 955 7477 50  0000 C CNN
F 2 "" H 950 7650 50  0001 C CNN
F 3 "" H 950 7650 50  0001 C CNN
	1    950  7650
	1    0    0    -1  
$EndComp
Wire Wire Line
	950  7650 950  7550
Wire Wire Line
	8950 4650 9300 4650
Text HLabel 9300 4650 2    50   Output ~ 0
OVF
Wire Wire Line
	7800 5350 7950 5350
Text HLabel 9700 2600 2    50   Output ~ 0
StoreOp_MEM[0..15]
Wire Bus Line
	9700 2600 9500 2600
Wire Bus Line
	9500 1100 9750 1100
Text HLabel 9750 2000 2    50   Output ~ 0
SelC_MEM[0..2]
Wire Bus Line
	9500 2000 9750 2000
Text HLabel 9750 1100 2    50   Output ~ 0
Ctl_MEM[14..20]
$Sheet
S 7850 900  1650 1250
U 5FD8D70A
F0 "sheet5FD8D6EB" 50
F1 "Ctl_13_23_Register.sch" 50
F2 "Ctl_MEM[14..20]" O R 9500 1100 50 
F3 "Ctl_EX[14..20]" I L 7850 1100 50 
F4 "SelC_EX[0..2]" I L 7850 2000 50 
F5 "SelC_MEM[0..2]" O R 9500 2000 50 
F6 "Phi1" I L 7850 1000 50 
$EndSheet
$Sheet
S 7850 3350 1150 450 
U 5FD8D713
F0 "sheet5FD8D6EC" 50
F1 "ALUResultRegister.sch" 50
F2 "Phi1" I L 7850 3450 50 
F3 "Y_EX[0..15]" I L 7850 3600 50 
F4 "Y_MEM[0..15]" O R 9000 3600 50 
$EndSheet
Text HLabel 9750 3600 2    50   Output ~ 0
Y_MEM[0..15]
Wire Bus Line
	9750 3600 9000 3600
Wire Wire Line
	7550 1000 7850 1000
Wire Wire Line
	7550 3450 7850 3450
Text HLabel 1250 1000 0    50   Input ~ 0
Ctl_EX[0..20]
Text HLabel 1250 4600 0    50   Input ~ 0
Ins_EX[0..10]
Entry Wire Line
	3150 1000 3250 1100
Entry Wire Line
	3050 1000 3150 1100
Entry Wire Line
	2950 1000 3050 1100
Text Label 3350 1100 3    50   ~ 0
Ctl_EX1
Text Label 3250 1100 3    50   ~ 0
Ctl_EX2
Text Label 3050 1100 3    50   ~ 0
Ctl_EX4
Entry Bus Bus
	5100 1000 5200 1100
Entry Wire Line
	3250 1000 3350 1100
Text Label 3150 1100 3    50   ~ 0
Ctl_EX3
Text Notes 3850 3500 0    50   ~ 0
SelStoreOp=0  —> Select Register B\nSelStoreOp=1 —> Select Register B << 8\nSelStoreOp=2  —> Select PC+1 (return address)\nSelStoreOp=3  —> Select 8-bit Immediate Value
$Sheet
S 3850 1900 1450 200 
U 5FDDE44F
F0 "sheet5FDDE431" 50
F1 "SplitOutSelC.sch" 50
F2 "Ins_EX[0..10]" I L 3850 2000 50 
F3 "SelC_EX[0..2]" O R 5300 2000 50 
$EndSheet
$Sheet
S 3850 2400 1450 700 
U 5FDDE458
F0 "sheet5FDDE432" 50
F1 "SelectStoreOp.sch" 50
F2 "SelStoreOpA" I L 3850 2550 50 
F3 "SelStoreOpB" I L 3850 2650 50 
F4 "Ins_EX[0..10]" I L 3850 2750 50 
F5 "B[0..15]" I L 3850 2850 50 
F6 "PC_EX[0..15]" I L 3850 2950 50 
F7 "StoreOp_EX[0..15]" O R 5300 2600 50 
$EndSheet
Text Notes 3600 5200 0    50   ~ 0
SelRightOp=0  —> Select Register B\nSelRightOp=1  —> Select Immediate ins[4:0]\nSelRightOp=2  —> Select Immediate ins[10:8, 1:0]\nSelRightOp=3  —> Select Immediate ins[10:0]
Text HLabel 1250 4700 0    50   Input ~ 0
B[0..15]
Text HLabel 1250 5300 0    50   Input ~ 0
A[0..15]
Text Label 2950 1100 3    50   ~ 0
Ctl_EX5
Entry Wire Line
	2750 1000 2850 1100
Text Label 2850 1100 3    50   ~ 0
Ctl_EX6
Entry Wire Line
	2350 1000 2450 1100
Text Label 2750 1100 3    50   ~ 0
Ctl_EX7
Entry Wire Line
	2450 1000 2550 1100
Text Label 2650 1100 3    50   ~ 0
Ctl_EX8
Entry Wire Line
	2550 1000 2650 1100
Text Label 2550 1100 3    50   ~ 0
Ctl_EX9
Entry Wire Line
	2650 1000 2750 1100
Text Label 2450 1100 3    50   ~ 0
Ctl_EX10
Text Label 2350 1100 3    50   ~ 0
Ctl_EX11
Entry Wire Line
	2250 1000 2350 1100
Entry Wire Line
	2850 1000 2950 1100
Wire Wire Line
	5800 5400 2850 5400
Wire Wire Line
	5800 5500 2750 5500
Wire Wire Line
	5800 5600 2650 5600
Wire Wire Line
	5800 5800 2450 5800
Wire Wire Line
	5800 5900 2350 5900
Text HLabel 1250 2000 0    50   Input ~ 0
Ins_EX[0..10]
Wire Bus Line
	1250 2000 3850 2000
Wire Wire Line
	7550 2500 7850 2500
Wire Bus Line
	5300 2600 7850 2600
Wire Bus Line
	5200 1100 7850 1100
Wire Bus Line
	7850 3600 7000 3600
Wire Bus Line
	7000 3600 7000 4350
Wire Bus Line
	7000 4350 6900 4350
Wire Wire Line
	2950 6250 7650 6250
Wire Wire Line
	7650 6250 7650 5450
Wire Wire Line
	7650 5450 7950 5450
Wire Wire Line
	3850 2550 3350 2550
Wire Wire Line
	3850 2650 3250 2650
Text HLabel 1250 2750 0    50   Input ~ 0
Ins_EX[0..10]
Text HLabel 1250 2850 0    50   Input ~ 0
B[0..15]
Wire Bus Line
	1250 2850 3850 2850
Wire Bus Line
	1250 2750 3850 2750
Text HLabel 1250 2950 0    50   Input ~ 0
PC_EX[0..15]
Wire Bus Line
	1250 2950 3850 2950
Text Notes 6250 3050 0    50   ~ 0
The program counter uses the result\nfrom this point as a jump offset.
Text Notes 8850 5900 0    50   ~ 0
This doesn’t have to be a 74ABT device,\nbut Mouser doesn’t normally stock the\n74AHCT377 we would otherwise use.
Text HLabel 9750 3100 2    50   Output ~ 0
Y_EX[0..15]
Wire Bus Line
	9750 3100 7000 3100
Wire Bus Line
	7000 3100 7000 3600
Connection ~ 7000 3600
Wire Bus Line
	1250 5300 5800 5300
Entry Wire Line
	2150 1000 2250 1100
Text Label 2250 1100 3    50   ~ 0
Ctl_EX12
Wire Wire Line
	2250 1100 2250 1600
Text HLabel 2250 1600 3    50   Output ~ 0
~J
Wire Bus Line
	3600 4600 1250 4600
Wire Bus Line
	3600 4700 1250 4700
Wire Wire Line
	3050 4400 3600 4400
Wire Wire Line
	6900 4450 7950 4450
Wire Wire Line
	6900 4550 7950 4550
Wire Wire Line
	6900 4650 7950 4650
Wire Bus Line
	5000 4700 5800 4700
$Sheet
S 5800 4250 1100 1750
U 5FC6FE4B
F0 "ALU" 50
F1 "ALU.sch" 50
F2 "RightOp[0..15]" I L 5800 4700 50 
F3 "LeftOp[0..15]" I L 5800 5300 50 
F4 "Z" O R 6900 4550 50 
F5 "C16" O R 6900 4450 50 
F6 "OVF" O R 6900 4650 50 
F7 "C0" I L 5800 5400 50 
F8 "I0" I L 5800 5500 50 
F9 "I1" I L 5800 5600 50 
F10 "I2" I L 5800 5700 50 
F11 "RS0" I L 5800 5800 50 
F12 "RS1" I L 5800 5900 50 
F13 "Y_EX[0..15]" O R 6900 4350 50 
$EndSheet
$Sheet
S 3600 4200 1400 600 
U 5FDDE478
F0 "Select Right Operand" 50
F1 "SelectRightOperand.sch" 50
F2 "Ins_EX[0..10]" I L 3600 4600 50 
F3 "B[0..15]" I L 3600 4700 50 
F4 "SelRightOpA" I L 3600 4300 50 
F5 "RightOp[0..15]" O R 5000 4700 50 
F6 "SelRightOpB" I L 3600 4400 50 
$EndSheet
Text GLabel 7550 1000 0    50   Input ~ 0
Phi1a
Text GLabel 7550 2500 0    50   Input ~ 0
Phi1a
Text GLabel 7550 3450 0    50   Input ~ 0
Phi1c
Text GLabel 7800 5350 0    50   Input ~ 0
Phi1a
Wire Wire Line
	3600 4300 3150 4300
Entry Wire Line
	3350 1000 3450 1100
Text Label 3450 1100 3    50   ~ 0
Ctl_EX0
Wire Wire Line
	3450 1100 3450 1600
Text HLabel 3450 1600 3    50   Output ~ 0
~HLT
Wire Wire Line
	3350 1100 3350 2550
Wire Wire Line
	3250 1100 3250 2650
Wire Wire Line
	3150 1100 3150 4300
Wire Wire Line
	3050 1100 3050 4400
Wire Wire Line
	2550 5700 5800 5700
Wire Wire Line
	2950 6250 2950 1100
Wire Wire Line
	2850 1100 2850 5400
Wire Wire Line
	2750 1100 2750 5500
Wire Wire Line
	2650 1100 2650 5600
Wire Wire Line
	2550 1100 2550 5700
Wire Wire Line
	2450 1100 2450 5800
Wire Wire Line
	2350 1100 2350 5900
$Sheet
S 7850 2400 1650 450 
U 5FD8D6FE
F0 "sheet5FD8D6EA" 50
F1 "StoreOperandRegister2.sch" 50
F2 "Phi1" I L 7850 2500 50 
F3 "StoreOp_EX[0..15]" I L 7850 2600 50 
F4 "StoreOp_MEM[0..15]" O R 9500 2600 50 
$EndSheet
Text Label 2150 1100 3    50   ~ 0
Ctl_EX13
Wire Wire Line
	2150 1100 2150 1600
Text HLabel 2150 1600 3    50   Output ~ 0
~JABS
Entry Wire Line
	2050 1000 2150 1100
Wire Bus Line
	5300 2000 7850 2000
Wire Bus Line
	1250 1000 5100 1000
$EndSCHEMATC
