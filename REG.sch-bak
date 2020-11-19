EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A3 16535 11693
encoding utf-8
Sheet 22 41
Title "REG"
Date ""
Rev ""
Comp ""
Comment1 "write new values into registers when an instruction is retired."
Comment2 "program counter value. The WB stage feeds back into the register file in this stage to"
Comment3 "right operand can either be taken from the register file or the immediate value, or the"
Comment4 "It takes an entire clock cycle to retrieve operands from the register file. The left and"
$EndDescr
Text HLabel 3900 4450 0    50   Input ~ 0
~WRH
Text HLabel 3900 4550 0    50   Input ~ 0
~WRL
Text HLabel 3750 850  0    50   Input ~ 0
CtlIn[0..19]
Text HLabel 3900 4750 0    50   Input ~ 0
WriteLower[0..7]
Text HLabel 13450 8850 2    50   Output ~ 0
OpR[0..15]
Text HLabel 12250 4150 2    50   Output ~ 0
OpL[0..15]
Text HLabel 13400 7300 2    50   Output ~ 0
StoreOp[0..15]
Text HLabel 6350 7600 0    50   Input ~ 0
PC[0..15]
Text HLabel 3850 2350 0    50   Input ~ 0
Ins[0..10]
Text HLabel 12250 950  2    50   Output ~ 0
Ctl[5..19]
Text HLabel 3900 4650 0    50   Input ~ 0
WriteUpper[0..7]
Text HLabel 5700 2850 2    50   Output ~ 0
SelCOut[0..2]
Text HLabel 3900 4350 0    50   Input ~ 0
SelCIn[0..2]
$Sheet
S 4200 4250 1200 600 
U 5FAA7AE7
F0 "Register File" 50
F1 "RegisterFile.sch" 50
F2 "~WRH" I L 4200 4450 50 
F3 "~WRL" I L 4200 4550 50 
F4 "WriteUpper[0..7]" I L 4200 4650 50 
F5 "SelC[0..2]" I L 4200 4350 50 
F6 "WriteLower[0..7]" I L 4200 4750 50 
F7 "SelA[0..2]" I R 5400 4450 50 
F8 "SelB[0..2]" I R 5400 4650 50 
F9 "B[0..15]" O R 5400 4750 50 
F10 "A[0..15]" O R 5400 4350 50 
$EndSheet
Wire Bus Line
	3900 4750 4200 4750
Wire Bus Line
	4200 4650 3900 4650
Wire Bus Line
	3900 4350 4200 4350
Wire Wire Line
	4200 4450 3900 4450
Wire Wire Line
	3900 4550 4200 4550
Wire Bus Line
	5400 4450 5500 4450
Wire Bus Line
	3850 2350 4100 2350
Wire Bus Line
	5400 4350 5700 4350
Wire Wire Line
	6400 4250 6500 4250
Wire Bus Line
	10050 4350 7550 4350
Wire Bus Line
	10050 4250 8450 4250
Wire Bus Line
	5400 4650 5600 4650
Wire Bus Line
	5400 4750 5600 4750
Wire Bus Line
	5600 4750 5600 9050
Wire Bus Line
	5600 9050 6550 9050
Text HLabel 3400 6250 0    50   Input ~ 0
Phi2
Wire Wire Line
	3400 6250 3600 6250
Wire Bus Line
	6350 7600 9150 7600
Wire Bus Line
	9150 7600 9150 8950
Wire Bus Line
	9150 8950 11600 8950
Wire Bus Line
	11150 4150 12250 4150
Wire Bus Line
	13450 8850 12700 8850
Connection ~ 5700 4350
Wire Bus Line
	5700 4350 6500 4350
Entry Wire Line
	9350 850  9450 950 
Wire Wire Line
	9550 4150 10050 4150
Entry Wire Line
	9250 850  9350 950 
Entry Wire Line
	9150 850  9250 950 
Wire Wire Line
	9350 950  9350 7400
Wire Wire Line
	9250 8850 11600 8850
Wire Wire Line
	9250 950  9250 8850
Text Label 9550 1050 3    50   ~ 0
CtlIn1
Text Label 9450 1050 3    50   ~ 0
CtlIn2
Text Label 9250 1050 3    50   ~ 0
CtlIn4
Entry Bus Bus
	9850 850  9950 950 
Wire Bus Line
	9950 950  12250 950 
Text Label 10000 950  0    50   ~ 0
CtlIn[5..19]
Text Label 9600 4150 0    50   ~ 0
SelLeftOp
Text Label 9550 7400 0    50   ~ 0
SelStoreOpB
Text Label 10900 8850 0    50   ~ 0
SelRightOp
Text Label 9550 7300 0    50   ~ 0
SelStoreOpA
Entry Wire Line
	9450 850  9550 950 
Wire Wire Line
	9450 950  9450 7300
Wire Wire Line
	9550 950  9550 4150
Wire Bus Line
	13400 7300 12700 7300
Text Label 9350 1050 3    50   ~ 0
CtlIn3
Text HLabel 9650 2250 3    50   Output ~ 0
~HLT
Text Label 9650 1050 3    50   ~ 0
CtlIn0
Entry Wire Line
	9650 950  9550 850 
Wire Wire Line
	9650 2250 9650 950 
Wire Wire Line
	9450 7300 11600 7300
Wire Wire Line
	11600 7400 9350 7400
Wire Bus Line
	9150 7600 11600 7600
Connection ~ 9150 7600
Wire Bus Line
	5700 7700 11600 7700
Wire Bus Line
	5700 4350 5700 7700
Text Notes 11200 9450 0    50   ~ 0
SelRightOp=0  —> Select Register B\nSelRightOp=1  —> Select Program Counter
Text Notes 11600 8150 0    50   ~ 0
SelStoreOp=0  —> Select Register A\nSelStoreOp=1  —> Select Program Counter\nSelStoreOp=2  —> Select 8-bit Immediate Value
Wire Wire Line
	4200 6250 6400 6250
Wire Wire Line
	6400 4250 6400 6250
Wire Wire Line
	6400 8950 6550 8950
$Sheet
S 6500 4150 1050 300 
U 5FDB0470
F0 "Buffer Port A" 50
F1 "BufferPortA.sch" 50
F2 "CP" I L 6500 4250 50 
F3 "Ain[0..15]" I L 6500 4350 50 
F4 "Aout[0..15]" O R 7550 4350 50 
$EndSheet
$Sheet
S 6550 8850 1100 300 
U 5FDCBC44
F0 "Buffer Port B" 50
F1 "BufferPortB.sch" 50
F2 "CP" I L 6550 8950 50 
F3 "Bin[0..15]" I L 6550 9050 50 
F4 "Bout[0..15]" O R 7650 9050 50 
$EndSheet
Wire Bus Line
	11600 9050 7650 9050
$Sheet
S 10050 4050 1100 400 
U 5FDE580B
F0 "Select Left Operand" 50
F1 "SelectLeftOperand.sch" 50
F2 "Ins[0..10]" I L 10050 4250 50 
F3 "A[0..15]" I L 10050 4350 50 
F4 "Z[0..15]" O R 11150 4150 50 
F5 "S" I L 10050 4150 50 
$EndSheet
Text Notes 10000 4800 0    50   ~ 0
SelLeftOp=0  —> Select Register A\nSelLeftOp=1  —> Select 5-bit Immediate Value
$Sheet
S 11600 8750 1100 400 
U 5FE695DA
F0 "Select Right Operand" 50
F1 "SelectRightOperand.sch" 50
F2 "Y[0..15]" I L 11600 8950 50 
F3 "X[0..15]" I L 11600 9050 50 
F4 "Z[0..15]" O R 12700 8850 50 
F5 "S" I L 11600 8850 50 
$EndSheet
$Sheet
S 11600 7200 1100 600 
U 5FF2BBCA
F0 "Select Store Operand" 50
F1 "SelectStoreOp.sch" 50
F2 "Ins[0..10]" I L 11600 7500 50 
F3 "Z[0..15]" O R 12700 7300 50 
F4 "S1" I L 11600 7400 50 
F5 "PC[0..15]" I L 11600 7600 50 
F6 "A[0..15]" I L 11600 7700 50 
F7 "S0" I L 11600 7300 50 
$EndSheet
$Sheet
S 4200 2750 1250 200 
U 606410B1
F0 "Split Out SelC" 50
F1 "SplitOutSelC.sch" 50
F2 "Ins[0..10]" I L 4200 2850 50 
F3 "SelCOut[0..2]" O R 5450 2850 50 
$EndSheet
Wire Bus Line
	5700 2850 5450 2850
$Sheet
S 4200 3550 1150 200 
U 606889E4
F0 "Split Out SelA" 50
F1 "SplitOutSelA.sch" 50
F2 "Ins[0..10]" I L 4200 3650 50 
F3 "SelAOut[0..2]" O R 5350 3650 50 
$EndSheet
Wire Bus Line
	5350 3650 5500 3650
Wire Bus Line
	5500 3650 5500 4450
Wire Bus Line
	4200 3650 4100 3650
Wire Bus Line
	4100 3650 4100 3250
Connection ~ 4100 2350
Wire Bus Line
	8450 2350 8450 4250
$Sheet
S 4200 3150 1050 200 
U 60691E71
F0 "Split Out SelB" 50
F1 "SplitOutSelB.sch" 50
F2 "Ins[0..10]" I L 4200 3250 50 
F3 "SelBOut[0..2]" O R 5250 3250 50 
$EndSheet
Wire Bus Line
	5250 3250 5600 3250
Wire Bus Line
	5600 3250 5600 4650
Wire Bus Line
	4200 3250 4100 3250
Connection ~ 4100 3250
Wire Bus Line
	4100 3250 4100 2850
Wire Bus Line
	4200 2850 4100 2850
Connection ~ 4100 2850
Wire Bus Line
	4100 2850 4100 2350
Wire Bus Line
	8450 4250 8450 7500
Connection ~ 8450 4250
Wire Bus Line
	8450 7500 11600 7500
Wire Bus Line
	4100 2350 8450 2350
Connection ~ 6400 6250
Wire Wire Line
	6400 6250 6400 8950
$Comp
L 74xx:74LS04 U?
U 3 1 5FD3C293
P 3900 6250
AR Path="/5D8005AF/5D800744/5FD3C293" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FD3C293" Ref="U?"  Part="3" 
AR Path="/5D2C07CD/5FD3C293" Ref="U?"  Part="3" 
AR Path="/60A72859/5FD3C293" Ref="U?"  Part="3" 
AR Path="/60906BCD/5FD3C293" Ref="U29"  Part="3" 
F 0 "U29" H 3900 6567 50  0000 C CNN
F 1 "74AHCT04" H 3900 6476 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 3900 6250 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 3900 6250 50  0001 C CNN
	3    3900 6250
	1    0    0    -1  
$EndComp
Wire Bus Line
	3750 850  9850 850 
$EndSCHEMATC
