EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A2 23386 16535
encoding utf-8
Sheet 22 40
Title "REG"
Date ""
Rev ""
Comp ""
Comment1 "write new values into registers when an instruction is retired."
Comment2 "program counter value. The WB stage feeds back into the register file in this stage to"
Comment3 "right operand can either be taken from the register file or the immediate value, or the"
Comment4 "It takes an entire clock cycle to retrieve operands from the register file. The left and"
$EndDescr
Text HLabel 6650 6900 0    50   Input ~ 0
~WRH
Text HLabel 6650 7000 0    50   Input ~ 0
~WRL
Text HLabel 6500 3300 0    50   Input ~ 0
CtlIn[0..23]
Text HLabel 6650 7200 0    50   Input ~ 0
WriteLower[0..7]
Text HLabel 16200 11300 2    50   Output ~ 0
OpR[0..15]
Text HLabel 15000 6600 2    50   Output ~ 0
OpL[0..15]
Text HLabel 16150 9750 2    50   Output ~ 0
StoreOp[0..15]
Text HLabel 9100 10050 0    50   Input ~ 0
PC[0..15]
Text HLabel 6600 4800 0    50   Input ~ 0
Ins[0..15]
Text HLabel 15000 3400 2    50   Output ~ 0
Ctl[5..23]
Text HLabel 6650 7100 0    50   Input ~ 0
WriteUpper[0..7]
Text HLabel 8450 5300 2    50   Output ~ 0
SelCOut[0..2]
Text HLabel 6650 6800 0    50   Input ~ 0
SelCIn[0..2]
$Sheet
S 6950 6700 1200 600 
U 5FAA7AE7
F0 "Register File" 50
F1 "RegisterFile.sch" 50
F2 "~WRH" I L 6950 6900 50 
F3 "~WRL" I L 6950 7000 50 
F4 "WriteUpper[0..7]" I L 6950 7100 50 
F5 "SelC[0..2]" I L 6950 6800 50 
F6 "WriteLower[0..7]" I L 6950 7200 50 
F7 "SelA[0..2]" I R 8150 6900 50 
F8 "SelB[0..2]" I R 8150 7100 50 
F9 "A[0..15]" O R 8150 7200 50 
F10 "B[0..15]" O R 8150 6800 50 
$EndSheet
Wire Bus Line
	6650 7200 6950 7200
Wire Bus Line
	6950 7100 6650 7100
Wire Bus Line
	6650 6800 6950 6800
Wire Wire Line
	6950 6900 6650 6900
Wire Wire Line
	6650 7000 6950 7000
Wire Bus Line
	8150 6900 8250 6900
Wire Bus Line
	6600 4800 6850 4800
Wire Bus Line
	8150 6800 8450 6800
Wire Wire Line
	9150 6700 9250 6700
Wire Bus Line
	12800 6800 10100 6800
Wire Bus Line
	12800 6700 11200 6700
Wire Bus Line
	8150 7100 8350 7100
Wire Bus Line
	8150 7200 8350 7200
Wire Bus Line
	8350 7200 8350 11500
Wire Bus Line
	8350 11500 9300 11500
Text HLabel 6150 4350 0    50   Input ~ 0
Phi2
Wire Wire Line
	6150 4350 6350 4350
Wire Bus Line
	9100 10050 11900 10050
Wire Bus Line
	11900 10050 11900 11400
Wire Bus Line
	11900 11400 14350 11400
Wire Bus Line
	13900 6600 15000 6600
Wire Bus Line
	16200 11300 15450 11300
Connection ~ 8450 6800
Wire Bus Line
	8450 6800 9250 6800
Entry Wire Line
	12100 3300 12200 3400
Wire Wire Line
	12300 6600 12800 6600
Entry Wire Line
	12000 3300 12100 3400
Entry Wire Line
	11900 3300 12000 3400
Wire Wire Line
	12100 3400 12100 9850
Wire Wire Line
	12000 11300 14350 11300
Wire Wire Line
	12000 3400 12000 11300
Text Label 12300 3500 3    50   ~ 0
CtlIn1
Text Label 12200 3500 3    50   ~ 0
CtlIn2
Text Label 12000 3500 3    50   ~ 0
CtlIn4
Entry Bus Bus
	12600 3300 12700 3400
Wire Bus Line
	12700 3400 15000 3400
Text Label 12750 3400 0    50   ~ 0
CtlIn[5..23]
Text Label 12350 6600 0    50   ~ 0
SelLeftOp
Text Label 12300 9850 0    50   ~ 0
SelStoreOpB
Text Label 13650 11300 0    50   ~ 0
SelRightOp
Text Label 12300 9750 0    50   ~ 0
SelStoreOpA
Entry Wire Line
	12200 3300 12300 3400
Wire Wire Line
	12200 3400 12200 9750
Wire Wire Line
	12300 3400 12300 6600
Wire Bus Line
	16150 9750 15450 9750
Text Label 12100 3500 3    50   ~ 0
CtlIn3
Text HLabel 12400 4700 3    50   Output ~ 0
~HLT
Text Label 12400 3500 3    50   ~ 0
CtlIn0
Entry Wire Line
	12400 3400 12300 3300
Wire Wire Line
	12400 4700 12400 3400
Wire Wire Line
	12200 9750 14350 9750
Wire Wire Line
	14350 9850 12100 9850
Wire Bus Line
	11900 10050 14350 10050
Connection ~ 11900 10050
Wire Bus Line
	8450 10150 14350 10150
Wire Bus Line
	8450 6800 8450 10150
Text Notes 13950 11900 0    50   ~ 0
SelRightOp=0  —> Select Register B\nSelRightOp=1  —> Select Program Counter
Text Notes 14350 10600 0    50   ~ 0
SelStoreOp=0  —> Select Register A\nSelStoreOp=1  —> Select Program Counter\nSelStoreOp=2  —> Select 8-bit Immediate Value
NoConn ~ -950 6600
NoConn ~ -950 8100
NoConn ~ -950 8600
$Comp
L 74xx:74LS04 U?
U 7 1 5FC50E59
P -1550 9400
AR Path="/5D2C0761/5FC50E59" Ref="U?"  Part="7" 
AR Path="/5D2C0720/5FC50E59" Ref="U?"  Part="7" 
AR Path="/5D2C07CD/5FC50E59" Ref="U?"  Part="7" 
AR Path="/60906BCD/5FC50E59" Ref="U54"  Part="7" 
F 0 "U54" H -1550 9450 50  0000 C CNN
F 1 "74AHCT04" H -1550 9350 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -1550 9400 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -1550 9400 50  0001 C CNN
	7    -1550 9400
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 6 1 5FC50E5F
P -1250 8600
AR Path="/5D8005AF/5D800744/5FC50E5F" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC50E5F" Ref="U?"  Part="6" 
AR Path="/5D2C07CD/5FC50E5F" Ref="U?"  Part="6" 
AR Path="/60906BCD/5FC50E5F" Ref="U54"  Part="6" 
F 0 "U54" H -1250 8917 50  0000 C CNN
F 1 "74AHCT04" H -1250 8826 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -1250 8600 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -1250 8600 50  0001 C CNN
	6    -1250 8600
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 2 1 5FC50E65
P -1250 6600
AR Path="/5D8005AF/5D800744/5FC50E65" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC50E65" Ref="U?"  Part="2" 
AR Path="/5D2C07CD/5FC50E65" Ref="U?"  Part="2" 
AR Path="/60906BCD/5FC50E65" Ref="U54"  Part="2" 
F 0 "U54" H -1250 6917 50  0000 C CNN
F 1 "74AHCT04" H -1250 6826 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -1250 6600 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -1250 6600 50  0001 C CNN
	2    -1250 6600
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 5 1 5FC50E6B
P -1250 8100
AR Path="/5D8005AF/5D800744/5FC50E6B" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC50E6B" Ref="U?"  Part="5" 
AR Path="/5D2C07CD/5FC50E6B" Ref="U?"  Part="5" 
AR Path="/60906BCD/5FC50E6B" Ref="U54"  Part="5" 
F 0 "U54" H -1250 8417 50  0000 C CNN
F 1 "74AHCT04" H -1250 8326 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -1250 8100 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -1250 8100 50  0001 C CNN
	5    -1250 8100
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 4 1 5FC50E71
P -1250 7600
AR Path="/5D8005AF/5D800744/5FC50E71" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC50E71" Ref="U?"  Part="4" 
AR Path="/5D2C07CD/5FC50E71" Ref="U?"  Part="4" 
AR Path="/60906BCD/5FC50E71" Ref="U54"  Part="4" 
F 0 "U54" H -1250 7917 50  0000 C CNN
F 1 "74AHCT04" H -1250 7826 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -1250 7600 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -1250 7600 50  0001 C CNN
	4    -1250 7600
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 3 1 5FC50E77
P -1250 7100
AR Path="/5D8005AF/5D800744/5FC50E77" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC50E77" Ref="U?"  Part="3" 
AR Path="/5D2C07CD/5FC50E77" Ref="U?"  Part="3" 
AR Path="/60906BCD/5FC50E77" Ref="U54"  Part="3" 
F 0 "U54" H -1250 7417 50  0000 C CNN
F 1 "74AHCT04" H -1250 7326 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -1250 7100 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -1250 7100 50  0001 C CNN
	3    -1250 7100
	1    0    0    -1  
$EndComp
NoConn ~ -950 7100
NoConn ~ -950 7600
$Comp
L power:VCC #PWR?
U 1 1 5FC50E7F
P -1550 5700
AR Path="/5D2C0761/5FC50E7F" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5FC50E7F" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FC50E7F" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC50E7F" Ref="#PWR0242"  Part="1" 
F 0 "#PWR0242" H -1550 5550 50  0001 C CNN
F 1 "VCC" H -1533 5873 50  0000 C CNN
F 2 "" H -1550 5700 50  0001 C CNN
F 3 "" H -1550 5700 50  0001 C CNN
	1    -1550 5700
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1550 6600 -1550 7100
Connection ~ -1550 6600
Connection ~ -1550 7100
Wire Wire Line
	-1550 7100 -1550 7600
Connection ~ -1550 7600
Wire Wire Line
	-1550 7600 -1550 8100
Connection ~ -1550 8100
Wire Wire Line
	-1550 8100 -1550 8600
$Comp
L power:GND #PWR?
U 1 1 5FC50E8D
P -1550 10050
AR Path="/5D2C0720/5FC50E8D" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/5FC50E8D" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FC50E8D" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC50E8D" Ref="#PWR0243"  Part="1" 
F 0 "#PWR0243" H -1550 9800 50  0001 C CNN
F 1 "GND" H -1545 9877 50  0000 C CNN
F 2 "" H -1550 10050 50  0001 C CNN
F 3 "" H -1550 10050 50  0001 C CNN
	1    -1550 10050
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-1550 9900 -1550 10050
Wire Wire Line
	-1550 8600 -1550 8900
Connection ~ -1550 8600
$Comp
L 74xx:74LS04 U?
U 1 1 5FC50E97
P 6650 4350
AR Path="/5D8005AF/5D800744/5FC50E97" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC50E97" Ref="U?"  Part="2" 
AR Path="/5D2C07CD/5FC50E97" Ref="U?"  Part="1" 
AR Path="/60906BCD/5FC50E97" Ref="U54"  Part="1" 
F 0 "U54" H 6650 4667 50  0000 C CNN
F 1 "74AHCT04" H 6650 4576 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 6650 4350 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 6650 4350 50  0001 C CNN
	1    6650 4350
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1550 5700 -1550 6600
Wire Wire Line
	9150 6700 9150 4350
Wire Wire Line
	6950 4350 9150 4350
Wire Wire Line
	9150 6700 9150 11400
Wire Wire Line
	9150 11400 9300 11400
Connection ~ 9150 6700
$Sheet
S 9250 6600 850  300 
U 5FDB0470
F0 "Buffer Port A" 50
F1 "BufferPortA.sch" 50
F2 "CP" I L 9250 6700 50 
F3 "D[0..15]" I L 9250 6800 50 
F4 "Q[0..15]" O R 10100 6800 50 
$EndSheet
$Sheet
S 9300 11300 850  300 
U 5FDCBC44
F0 "Buffer Port B" 50
F1 "BufferPortB.sch" 50
F2 "CP" I L 9300 11400 50 
F3 "D[0..15]" I L 9300 11500 50 
F4 "Q[0..15]" O R 10150 11500 50 
$EndSheet
Wire Bus Line
	14350 11500 10150 11500
$Sheet
S 12800 6500 1100 400 
U 5FDE580B
F0 "Select Left Operand" 50
F1 "SelectLeftOperand.sch" 50
F2 "Ins[0..15]" I L 12800 6700 50 
F3 "A[0..15]" I L 12800 6800 50 
F4 "Z[0..15]" O R 13900 6600 50 
F5 "S" I L 12800 6600 50 
$EndSheet
Text Notes 12750 7250 0    50   ~ 0
SelLeftOp=0  —> Select Register A\nSelLeftOp=1  —> Select 5-bit Immediate Value
$Sheet
S 14350 11200 1100 400 
U 5FE695DA
F0 "Select Right Operand" 50
F1 "SelectRightOperand.sch" 50
F2 "Y[0..15]" I L 14350 11400 50 
F3 "X[0..15]" I L 14350 11500 50 
F4 "Z[0..15]" O R 15450 11300 50 
F5 "S" I L 14350 11300 50 
$EndSheet
$Comp
L Device:C C?
U 1 1 5FEE93E9
P 1050 15400
AR Path="/5D8005AF/5D833E4B/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/5FE21410/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/5FE8EB3D/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FBDE54D/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC56563/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC5BFC9/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FB7DE20/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC8FDC3/5FC8FF79/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC8FDC3/5FC900A7/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC92C6A/5FC930A8/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC92C6A/5FC930B2/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60B264DC/5FCC63EC/5FC8FF79/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60B264DC/5FCC63EC/5FC900A7/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60B264DC/5FCC7594/5FC930A8/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60B264DC/5FCC7594/5FC930B2/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60B264DC/5FCC8AAB/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FDE580B/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FE695DA/5FEE93E9" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FEE93E9" Ref="C54"  Part="1" 
F 0 "C54" H 1165 15446 50  0000 L CNN
F 1 "100nF" H 1165 15355 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.05x0.95mm_HandSolder" H 1088 15250 50  0001 C CNN
F 3 "~" H 1050 15400 50  0001 C CNN
	1    1050 15400
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FEE93EF
P 1050 15250
AR Path="/5D8005AF/5D833E4B/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/5FE21410/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FBDE54D/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC56563/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC5BFC9/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FB7DE20/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC8FDC3/5FC8FF79/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC8FDC3/5FC900A7/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC92C6A/5FC930A8/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC92C6A/5FC930B2/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60B264DC/5FCC63EC/5FC8FF79/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60B264DC/5FCC63EC/5FC900A7/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60B264DC/5FCC7594/5FC930A8/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60B264DC/5FCC7594/5FC930B2/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60B264DC/5FCC8AAB/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FDE580B/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FE695DA/5FEE93EF" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FEE93EF" Ref="#PWR0244"  Part="1" 
F 0 "#PWR0244" H 1050 15100 50  0001 C CNN
F 1 "VCC" H 1067 15423 50  0000 C CNN
F 2 "" H 1050 15250 50  0001 C CNN
F 3 "" H 1050 15250 50  0001 C CNN
	1    1050 15250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FEE93F8
P 1050 15650
AR Path="/5D8005AF/5D833E4B/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/5FE21410/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FBDE54D/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC56563/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC5BFC9/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FB7DE20/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC8FDC3/5FC8FF79/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC8FDC3/5FC900A7/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC92C6A/5FC930A8/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC92C6A/5FC930B2/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60B264DC/5FCC63EC/5FC8FF79/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60B264DC/5FCC63EC/5FC900A7/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60B264DC/5FCC7594/5FC930A8/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60B264DC/5FCC7594/5FC930B2/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60B264DC/5FCC8AAB/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FDE580B/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FE695DA/5FEE93F8" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FEE93F8" Ref="#PWR0245"  Part="1" 
F 0 "#PWR0245" H 1050 15400 50  0001 C CNN
F 1 "GND" H 1055 15477 50  0000 C CNN
F 2 "" H 1050 15650 50  0001 C CNN
F 3 "" H 1050 15650 50  0001 C CNN
	1    1050 15650
	1    0    0    -1  
$EndComp
Wire Wire Line
	1050 15650 1050 15550
$Sheet
S 14350 9650 1100 600 
U 5FF2BBCA
F0 "Select Store Operand" 50
F1 "SelectStoreOp.sch" 50
F2 "Ins[0..15]" I L 14350 9950 50 
F3 "Z[0..15]" O R 15450 9750 50 
F4 "S1" I L 14350 9850 50 
F5 "PC[0..15]" I L 14350 10050 50 
F6 "A[0..15]" I L 14350 10150 50 
F7 "S0" I L 14350 9750 50 
$EndSheet
$Sheet
S 6950 5200 1250 200 
U 606410B1
F0 "Split Out SelC" 50
F1 "SplitOutSelC.sch" 50
F2 "Ins[0..15]" I L 6950 5300 50 
F3 "SelCOut[0..2]" O R 8200 5300 50 
$EndSheet
Wire Bus Line
	8450 5300 8200 5300
$Sheet
S 6950 6000 1150 200 
U 606889E4
F0 "Split Out SelA" 50
F1 "SplitOutSelA.sch" 50
F2 "Ins[0..15]" I L 6950 6100 50 
F3 "SelAOut[0..2]" O R 8100 6100 50 
$EndSheet
Wire Bus Line
	8100 6100 8250 6100
Wire Bus Line
	8250 6100 8250 6900
Wire Bus Line
	6950 6100 6850 6100
Wire Bus Line
	6850 6100 6850 5700
Connection ~ 6850 4800
Wire Bus Line
	11200 4800 11200 6700
$Sheet
S 6950 5600 1050 200 
U 60691E71
F0 "Split Out SelB" 50
F1 "SplitOutSelB.sch" 50
F2 "Ins[0..15]" I L 6950 5700 50 
F3 "SelBOut[0..2]" O R 8000 5700 50 
$EndSheet
Wire Bus Line
	8000 5700 8350 5700
Wire Bus Line
	8350 5700 8350 7100
Wire Bus Line
	6950 5700 6850 5700
Connection ~ 6850 5700
Wire Bus Line
	6850 5700 6850 5300
Wire Bus Line
	6950 5300 6850 5300
Connection ~ 6850 5300
Wire Bus Line
	6850 5300 6850 4800
Wire Bus Line
	11200 6700 11200 9950
Connection ~ 11200 6700
Wire Bus Line
	11200 9950 14350 9950
Wire Bus Line
	6850 4800 11200 4800
Wire Bus Line
	6500 3300 12600 3300
$EndSCHEMATC
