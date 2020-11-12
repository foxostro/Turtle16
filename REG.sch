EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A2 23386 16535
encoding utf-8
Sheet 55 86
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
Text HLabel 6600 5250 0    50   Input ~ 0
Ins[0..15]
Text HLabel 15000 3400 2    50   Output ~ 0
Ctl[5..23]
Text HLabel 6650 7100 0    50   Input ~ 0
WriteUpper[0..7]
Text HLabel 8450 5550 2    50   Output ~ 0
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
F7 "A[0..15]" I R 8150 6800 50 
F8 "SelA[0..2]" I R 8150 6900 50 
F9 "B[0..15]" I R 8150 7200 50 
F10 "SelB[0..2]" I R 8150 7100 50 
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
Entry Bus Bus
	7150 5850 7250 5950
Text Label 7600 5950 2    50   ~ 0
Ins[2..4]
Wire Bus Line
	7250 5950 8250 5950
Wire Bus Line
	8150 6900 8250 6900
Wire Bus Line
	6600 5250 7150 5250
Entry Bus Bus
	7150 5750 7250 5850
Text Label 7600 5850 2    50   ~ 0
Ins[5..7]
Wire Bus Line
	7250 5850 8350 5850
Entry Bus Bus
	7150 5450 7250 5550
Text Label 7650 5550 2    50   ~ 0
Ins[8..10]
Wire Bus Line
	7250 5550 8450 5550
Wire Bus Line
	8250 5950 8250 6900
Wire Bus Line
	8350 5850 8350 7100
Entry Bus Bus
	7150 5550 7250 5650
Text Label 7600 5750 2    50   ~ 0
Ins[0..7]
Wire Bus Line
	7250 5650 10100 5650
$Sheet
S 12800 6500 850  400 
U 5FBDE54D
F0 "Select Left Operand" 50
F1 "SixteenBitTwoToOneMux.sch" 50
F2 "Z[0..15]" O R 13650 6600 50 
F3 "S" I L 12800 6600 50 
F4 "Y[0..15]" I L 12800 6700 50 
F5 "X[0..15]" I L 12800 6800 50 
$EndSheet
Wire Bus Line
	8150 6800 8450 6800
$Sheet
S 9250 6600 1150 500 
U 5FC2B5F4
F0 "Buffer Register A" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 9250 6800 50 
F3 "Q[0..15]" O R 10400 6800 50 
F4 "CP" I L 9250 6700 50 
$EndSheet
Wire Wire Line
	9150 6700 9250 6700
Wire Bus Line
	12800 6800 10400 6800
Entry Wire Line
	10100 6050 10200 6150
Entry Wire Line
	10100 6200 10200 6300
Entry Wire Line
	10100 6350 10200 6450
Text Label 10200 6450 0    50   ~ 0
Ins[0]
Text Label 10200 6300 0    50   ~ 0
Ins[1]
Text Label 10200 6150 0    50   ~ 0
Ins[2]
Entry Wire Line
	11100 6450 11200 6550
Entry Wire Line
	11100 6300 11200 6400
Entry Wire Line
	11100 6150 11200 6250
Entry Wire Line
	11100 6000 11200 6100
Entry Wire Line
	11100 5850 11200 5950
Entry Wire Line
	11100 5700 11200 5800
$Comp
L power:GND #PWR0246
U 1 1 5FC45B98
P 10800 5700
F 0 "#PWR0246" H 10800 5450 50  0001 C CNN
F 1 "GND" V 10805 5572 50  0000 R CNN
F 2 "" H 10800 5700 50  0001 C CNN
F 3 "" H 10800 5700 50  0001 C CNN
	1    10800 5700
	0    1    1    0   
$EndComp
Entry Wire Line
	11100 5550 11200 5650
Entry Wire Line
	11100 5400 11200 5500
Entry Wire Line
	11100 5250 11200 5350
$Comp
L power:GND #PWR0245
U 1 1 5FC46C02
P 10800 5550
F 0 "#PWR0245" H 10800 5300 50  0001 C CNN
F 1 "GND" V 10805 5422 50  0000 R CNN
F 2 "" H 10800 5550 50  0001 C CNN
F 3 "" H 10800 5550 50  0001 C CNN
	1    10800 5550
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0244
U 1 1 5FC46C09
P 10800 5400
F 0 "#PWR0244" H 10800 5150 50  0001 C CNN
F 1 "GND" V 10805 5272 50  0000 R CNN
F 2 "" H 10800 5400 50  0001 C CNN
F 3 "" H 10800 5400 50  0001 C CNN
	1    10800 5400
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0243
U 1 1 5FC46C10
P 10800 5250
F 0 "#PWR0243" H 10800 5000 50  0001 C CNN
F 1 "GND" V 10805 5122 50  0000 R CNN
F 2 "" H 10800 5250 50  0001 C CNN
F 3 "" H 10800 5250 50  0001 C CNN
	1    10800 5250
	0    1    1    0   
$EndComp
Entry Wire Line
	11100 5100 11200 5200
Entry Wire Line
	11100 4950 11200 5050
Entry Wire Line
	11100 4800 11200 4900
$Comp
L power:GND #PWR0242
U 1 1 5FC4766E
P 10800 5100
F 0 "#PWR0242" H 10800 4850 50  0001 C CNN
F 1 "GND" V 10805 4972 50  0000 R CNN
F 2 "" H 10800 5100 50  0001 C CNN
F 3 "" H 10800 5100 50  0001 C CNN
	1    10800 5100
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0241
U 1 1 5FC47675
P 10800 4950
F 0 "#PWR0241" H 10800 4700 50  0001 C CNN
F 1 "GND" V 10805 4822 50  0000 R CNN
F 2 "" H 10800 4950 50  0001 C CNN
F 3 "" H 10800 4950 50  0001 C CNN
	1    10800 4950
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0240
U 1 1 5FC4767C
P 10800 4800
F 0 "#PWR0240" H 10800 4550 50  0001 C CNN
F 1 "GND" V 10805 4672 50  0000 R CNN
F 2 "" H 10800 4800 50  0001 C CNN
F 3 "" H 10800 4800 50  0001 C CNN
	1    10800 4800
	0    1    1    0   
$EndComp
Entry Wire Line
	11100 4650 11200 4750
Entry Wire Line
	11100 4500 11200 4600
Entry Wire Line
	11100 4350 11200 4450
$Comp
L power:GND #PWR0239
U 1 1 5FC47D35
P 10800 4650
F 0 "#PWR0239" H 10800 4400 50  0001 C CNN
F 1 "GND" V 10805 4522 50  0000 R CNN
F 2 "" H 10800 4650 50  0001 C CNN
F 3 "" H 10800 4650 50  0001 C CNN
	1    10800 4650
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0238
U 1 1 5FC47D3C
P 10800 4500
F 0 "#PWR0238" H 10800 4250 50  0001 C CNN
F 1 "GND" V 10805 4372 50  0000 R CNN
F 2 "" H 10800 4500 50  0001 C CNN
F 3 "" H 10800 4500 50  0001 C CNN
	1    10800 4500
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0237
U 1 1 5FC47D43
P 10800 4350
F 0 "#PWR0237" H 10800 4100 50  0001 C CNN
F 1 "GND" V 10805 4222 50  0000 R CNN
F 2 "" H 10800 4350 50  0001 C CNN
F 3 "" H 10800 4350 50  0001 C CNN
	1    10800 4350
	0    1    1    0   
$EndComp
Entry Wire Line
	11100 4200 11200 4300
$Comp
L power:GND #PWR0236
U 1 1 5FC48675
P 10800 4200
F 0 "#PWR0236" H 10800 3950 50  0001 C CNN
F 1 "GND" V 10805 4072 50  0000 R CNN
F 2 "" H 10800 4200 50  0001 C CNN
F 3 "" H 10800 4200 50  0001 C CNN
	1    10800 4200
	0    1    1    0   
$EndComp
Wire Wire Line
	10800 4200 11100 4200
Wire Wire Line
	10800 4350 11100 4350
Wire Wire Line
	10800 4500 11100 4500
Wire Wire Line
	10800 4650 11100 4650
Wire Wire Line
	10800 4800 11100 4800
Wire Wire Line
	10800 4950 11100 4950
Wire Wire Line
	10800 5100 11100 5100
Wire Wire Line
	10800 5250 11100 5250
Wire Wire Line
	10800 5400 11100 5400
Wire Wire Line
	10800 5550 11100 5550
Wire Wire Line
	10800 5700 11100 5700
Wire Wire Line
	10200 6150 11100 6150
Wire Wire Line
	10200 6300 11100 6300
Wire Wire Line
	10200 6450 11100 6450
Wire Bus Line
	12800 6700 11200 6700
Text Label 11100 6300 2    50   ~ 0
Y1
Text Label 11100 6450 2    50   ~ 0
Y0
Text Label 11100 6150 2    50   ~ 0
Y2
Text Label 11100 6000 2    50   ~ 0
Y3
Text Label 11100 5850 2    50   ~ 0
Y4
Text Label 11100 5700 2    50   ~ 0
Y5
Text Label 11100 5550 2    50   ~ 0
Y6
Text Label 11100 5400 2    50   ~ 0
Y7
Text Label 11100 5250 2    50   ~ 0
Y8
Text Label 11100 5100 2    50   ~ 0
Y9
Text Label 11100 4950 2    50   ~ 0
Y10
Text Label 11100 4800 2    50   ~ 0
Y11
Text Label 11100 4650 2    50   ~ 0
Y12
Text Label 11100 4500 2    50   ~ 0
Y13
Text Label 11100 4350 2    50   ~ 0
Y14
Text Label 11100 4200 2    50   ~ 0
Y15
Entry Wire Line
	10100 5900 10200 6000
Text Label 10200 6000 0    50   ~ 0
Ins[3]
Wire Wire Line
	10200 6000 11100 6000
$Sheet
S 9300 11300 1150 500 
U 5FC56568
F0 "Buffer Register B" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 9300 11500 50 
F3 "Q[0..15]" O R 10450 11500 50 
F4 "CP" I L 9300 11400 50 
$EndSheet
Wire Bus Line
	14350 11500 10450 11500
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
	9100 10050 14100 10050
Wire Bus Line
	14100 10050 14100 11400
Wire Bus Line
	14100 11400 14350 11400
Wire Bus Line
	13650 6600 15000 6600
Wire Bus Line
	16200 11300 15200 11300
Entry Bus Bus
	7150 5650 7250 5750
Text Label 7600 5650 2    50   ~ 0
Ins[0..3]
Entry Wire Line
	10150 9350 10250 9450
Entry Wire Line
	10150 9500 10250 9600
Entry Wire Line
	10150 9650 10250 9750
Text Label 10250 9750 0    50   ~ 0
Ins0
Text Label 10250 9600 0    50   ~ 0
Ins1
Text Label 10250 9450 0    50   ~ 0
Ins2
Entry Wire Line
	11150 9750 11250 9850
Entry Wire Line
	11150 9600 11250 9700
Entry Wire Line
	11150 9450 11250 9550
Entry Wire Line
	11150 9300 11250 9400
Entry Wire Line
	11150 9150 11250 9250
Entry Wire Line
	11150 9000 11250 9100
Entry Wire Line
	11150 8850 11250 8950
Entry Wire Line
	11150 8700 11250 8800
Entry Wire Line
	11150 8550 11250 8650
$Comp
L power:GND #PWR0254
U 1 1 5FC792F6
P 10850 8550
F 0 "#PWR0254" H 10850 8300 50  0001 C CNN
F 1 "GND" V 10855 8422 50  0000 R CNN
F 2 "" H 10850 8550 50  0001 C CNN
F 3 "" H 10850 8550 50  0001 C CNN
	1    10850 8550
	0    1    1    0   
$EndComp
Entry Wire Line
	11150 8400 11250 8500
Entry Wire Line
	11150 8250 11250 8350
Entry Wire Line
	11150 8100 11250 8200
$Comp
L power:GND #PWR0253
U 1 1 5FC792FF
P 10850 8400
F 0 "#PWR0253" H 10850 8150 50  0001 C CNN
F 1 "GND" V 10855 8272 50  0000 R CNN
F 2 "" H 10850 8400 50  0001 C CNN
F 3 "" H 10850 8400 50  0001 C CNN
	1    10850 8400
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0252
U 1 1 5FC79305
P 10850 8250
F 0 "#PWR0252" H 10850 8000 50  0001 C CNN
F 1 "GND" V 10855 8122 50  0000 R CNN
F 2 "" H 10850 8250 50  0001 C CNN
F 3 "" H 10850 8250 50  0001 C CNN
	1    10850 8250
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0251
U 1 1 5FC7930B
P 10850 8100
F 0 "#PWR0251" H 10850 7850 50  0001 C CNN
F 1 "GND" V 10855 7972 50  0000 R CNN
F 2 "" H 10850 8100 50  0001 C CNN
F 3 "" H 10850 8100 50  0001 C CNN
	1    10850 8100
	0    1    1    0   
$EndComp
Entry Wire Line
	11150 7950 11250 8050
Entry Wire Line
	11150 7800 11250 7900
Entry Wire Line
	11150 7650 11250 7750
$Comp
L power:GND #PWR0250
U 1 1 5FC79314
P 10850 7950
F 0 "#PWR0250" H 10850 7700 50  0001 C CNN
F 1 "GND" V 10855 7822 50  0000 R CNN
F 2 "" H 10850 7950 50  0001 C CNN
F 3 "" H 10850 7950 50  0001 C CNN
	1    10850 7950
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0249
U 1 1 5FC7931A
P 10850 7800
F 0 "#PWR0249" H 10850 7550 50  0001 C CNN
F 1 "GND" V 10855 7672 50  0000 R CNN
F 2 "" H 10850 7800 50  0001 C CNN
F 3 "" H 10850 7800 50  0001 C CNN
	1    10850 7800
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0248
U 1 1 5FC79320
P 10850 7650
F 0 "#PWR0248" H 10850 7400 50  0001 C CNN
F 1 "GND" V 10855 7522 50  0000 R CNN
F 2 "" H 10850 7650 50  0001 C CNN
F 3 "" H 10850 7650 50  0001 C CNN
	1    10850 7650
	0    1    1    0   
$EndComp
Entry Wire Line
	11150 7500 11250 7600
$Comp
L power:GND #PWR0247
U 1 1 5FC79327
P 10850 7500
F 0 "#PWR0247" H 10850 7250 50  0001 C CNN
F 1 "GND" V 10855 7372 50  0000 R CNN
F 2 "" H 10850 7500 50  0001 C CNN
F 3 "" H 10850 7500 50  0001 C CNN
	1    10850 7500
	0    1    1    0   
$EndComp
Wire Wire Line
	10850 7500 11150 7500
Wire Wire Line
	10850 7650 11150 7650
Wire Wire Line
	10850 7800 11150 7800
Wire Wire Line
	10850 7950 11150 7950
Wire Wire Line
	10850 8100 11150 8100
Wire Wire Line
	10850 8250 11150 8250
Wire Wire Line
	10850 8400 11150 8400
Wire Wire Line
	10850 8550 11150 8550
Wire Wire Line
	10250 9450 11150 9450
Wire Wire Line
	10250 9600 11150 9600
Wire Wire Line
	10250 9750 11150 9750
Text Label 11150 9600 2    50   ~ 0
Y1
Text Label 11150 9750 2    50   ~ 0
Y0
Text Label 11150 9450 2    50   ~ 0
Y2
Text Label 11150 9300 2    50   ~ 0
Y3
Text Label 11150 9150 2    50   ~ 0
Y4
Text Label 11150 9000 2    50   ~ 0
Y5
Text Label 11150 8850 2    50   ~ 0
Y6
Text Label 11150 8700 2    50   ~ 0
Y7
Text Label 11150 8550 2    50   ~ 0
Y8
Text Label 11150 8400 2    50   ~ 0
Y9
Text Label 11150 8250 2    50   ~ 0
Y10
Text Label 11150 8100 2    50   ~ 0
Y11
Text Label 11150 7950 2    50   ~ 0
Y12
Text Label 11150 7800 2    50   ~ 0
Y13
Text Label 11150 7650 2    50   ~ 0
Y14
Text Label 11150 7500 2    50   ~ 0
Y15
Entry Wire Line
	10150 9200 10250 9300
Text Label 10250 9300 0    50   ~ 0
Ins3
Wire Wire Line
	10250 9300 11150 9300
Entry Wire Line
	10150 8750 10250 8850
Entry Wire Line
	10150 8900 10250 9000
Entry Wire Line
	10150 9050 10250 9150
Text Label 10250 9150 0    50   ~ 0
Ins4
Text Label 10250 9000 0    50   ~ 0
Ins5
Text Label 10250 8850 0    50   ~ 0
Ins6
Entry Wire Line
	10150 8600 10250 8700
Text Label 10250 8700 0    50   ~ 0
Ins7
Wire Wire Line
	10250 8700 11150 8700
Wire Wire Line
	10250 8850 11150 8850
Wire Wire Line
	10250 9000 11150 9000
Wire Wire Line
	10250 9150 11150 9150
Wire Bus Line
	7250 5750 8550 5750
Wire Bus Line
	8550 5750 8550 8500
Wire Bus Line
	8550 8500 10150 8500
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
Text Label 12350 6700 0    50   ~ 0
Y[0..15]
Text Label 12250 9950 0    50   ~ 0
Y[0..15]
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
	16150 9750 15150 9750
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
$Sheet
S 14350 9650 800  600 
U 5FC92C6A
F0 "Sheet5FC92C69" 50
F1 "SixteenBitThreeToOneMux.sch" 50
F2 "S1" I L 14350 9850 50 
F3 "S0" I L 14350 9750 50 
F4 "Z[0..15]" O R 15150 9750 50 
F5 "B[0..15]" I L 14350 10050 50 
F6 "C[0..15]" I L 14350 9950 50 
F7 "A[0..15]" I L 14350 10150 50 
$EndSheet
Wire Wire Line
	12200 9750 14350 9750
Wire Wire Line
	14350 9850 12100 9850
Wire Bus Line
	11250 9950 14350 9950
Wire Bus Line
	14100 10050 14350 10050
Connection ~ 14100 10050
$Sheet
S 14350 11200 850  400 
U 5FC56563
F0 "Select Right Operand" 50
F1 "SixteenBitTwoToOneMux.sch" 50
F2 "Z[0..15]" O R 15200 11300 50 
F3 "S" I L 14350 11300 50 
F4 "Y[0..15]" I L 14350 11400 50 
F5 "X[0..15]" I L 14350 11500 50 
$EndSheet
Wire Bus Line
	8450 10150 14350 10150
Wire Bus Line
	8450 6800 8450 10150
Text Notes 13950 11900 0    50   ~ 0
SelRightOp=0  —> Select Register B\nSelRightOp=1  —> Select Program Counter
Text Notes 12750 7250 0    50   ~ 0
SelLeftOp=0  —> Select Register A\nSelLeftOp=1  —> Select 5-bit Immediate Value
Entry Wire Line
	10100 5750 10200 5850
Text Label 10200 5850 0    50   ~ 0
Ins[4]
Wire Wire Line
	10200 5850 11100 5850
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
AR Path="/60906BCD/5FC50E59" Ref="U103"  Part="7" 
F 0 "U103" H -1550 9450 50  0000 C CNN
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
AR Path="/60906BCD/5FC50E5F" Ref="U103"  Part="6" 
F 0 "U103" H -1250 8917 50  0000 C CNN
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
AR Path="/60906BCD/5FC50E65" Ref="U103"  Part="2" 
F 0 "U103" H -1250 6917 50  0000 C CNN
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
AR Path="/60906BCD/5FC50E6B" Ref="U103"  Part="5" 
F 0 "U103" H -1250 8417 50  0000 C CNN
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
AR Path="/60906BCD/5FC50E71" Ref="U103"  Part="4" 
F 0 "U103" H -1250 7917 50  0000 C CNN
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
AR Path="/60906BCD/5FC50E77" Ref="U103"  Part="3" 
F 0 "U103" H -1250 7417 50  0000 C CNN
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
AR Path="/60906BCD/5FC50E7F" Ref="#PWR0570"  Part="1" 
F 0 "#PWR0570" H -1550 5550 50  0001 C CNN
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
AR Path="/60906BCD/5FC50E8D" Ref="#PWR0571"  Part="1" 
F 0 "#PWR0571" H -1550 9800 50  0001 C CNN
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
AR Path="/60906BCD/5FC50E97" Ref="U103"  Part="1" 
F 0 "U103" H 6650 4667 50  0000 C CNN
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
Wire Bus Line
	7150 5250 7150 5850
Wire Bus Line
	10100 5650 10100 6350
Wire Bus Line
	6500 3300 12600 3300
Wire Bus Line
	10150 8500 10150 9650
Wire Bus Line
	11250 7600 11250 9950
Wire Bus Line
	11200 4300 11200 6700
$EndSCHEMATC
