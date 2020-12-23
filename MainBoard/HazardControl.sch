EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 31 35
Title "Hazard Control"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 "Currently, this stalls the pipeline on a hazard."
Comment4 "Control logic for dealing with pipeline hazards"
$EndDescr
$Comp
L power:VCC #PWR?
U 1 1 5FDA9CD1
P 6800 3350
AR Path="/5D2C0B92/5FDA9CD1" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDA9CD1" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FDA9CD1" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FDA9CD1" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDA967F/5FDA9CD1" Ref="#PWR0455"  Part="1" 
F 0 "#PWR0455" H 6800 3200 50  0001 C CNN
F 1 "VCC" H 6817 3523 50  0000 C CNN
F 2 "" H 6800 3350 50  0001 C CNN
F 3 "" H 6800 3350 50  0001 C CNN
	1    6800 3350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDA9CD7
P 6800 4750
AR Path="/5D2C0B92/5FDA9CD7" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDA9CD7" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FDA9CD7" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FDA9CD7" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDA967F/5FDA9CD7" Ref="#PWR0456"  Part="1" 
F 0 "#PWR0456" H 6800 4500 50  0001 C CNN
F 1 "GND" H 6805 4577 50  0000 C CNN
F 2 "" H 6800 4750 50  0001 C CNN
F 3 "" H 6800 4750 50  0001 C CNN
	1    6800 4750
	1    0    0    -1  
$EndComp
$Comp
L MainBoard-rescue:ATF22V10C-Logic_Programmable U?
U 1 1 5FDA9CDF
P 6800 4000
AR Path="/5FED3839/5FDA9CDF" Ref="U?"  Part="1" 
AR Path="/5D2C07CD/5FDA9CDF" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FDA9CDF" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FDA9CDF" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FDA9CDF" Ref="U?"  Part="1" 
AR Path="/5FED3839/5FDA967F/5FDA9CDF" Ref="U70"  Part="1" 
F 0 "U70" H 6450 4650 50  0000 C CNN
F 1 "ATF22V10C-7PX" H 6450 4550 50  0000 C CNN
F 2 "Package_DIP:DIP-24_W8.89mm_SMDSocket_LongPads" H 7650 3300 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/268/doc0735-1369018.pdf" H 6800 4050 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Microchip-Technology-Atmel/ATF22V10C-7PX?qs=%2Fha2pyFadugqFuTUlWvkuaZr7DXQ8Rnu3dOZcKuoHGuPC51te6MYUw%3D%3D" H 6800 4000 50  0001 C CNN "Mouser"
F 5 "https://www.mouser.com/ProductDetail/575-4462401" H 6800 4000 50  0001 C CNN "Mouser2"
	1    6800 4000
	1    0    0    -1  
$EndComp
Text HLabel 7450 3550 2    50   Output ~ 0
~STALL_ID
Wire Wire Line
	7300 3550 7450 3550
$Comp
L Device:C C?
U 1 1 5FDAF804
P 650 7500
AR Path="/5D8005AF/5D833E4B/5FDAF804" Ref="C?"  Part="1" 
AR Path="/5FE21410/5FDAF804" Ref="C?"  Part="1" 
AR Path="/5FE8EB3D/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FBDE54D/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC2B5F4/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC56568/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FCDD090/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD148F1/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD202DF/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD2B946/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD447EB/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD44E3D/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45108/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45557/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45834/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD47CBA/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/600400AF/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60040306/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60040791/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60044374/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/6004437C/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/6004F414/5FDAF804" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FCF2/5FDAF804" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FCFB/5FDAF804" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FD06/5FDAF804" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FD11/5FDAF804" Ref="C?"  Part="1" 
AR Path="/60A71BBF/5FDAF804" Ref="C?"  Part="1" 
AR Path="/5D2C07CD/5FDAF804" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FDAF804" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FDA967F/5FDAF804" Ref="C77"  Part="1" 
F 0 "C77" H 765 7546 50  0000 L CNN
F 1 "100nF" H 765 7455 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 688 7350 50  0001 C CNN
F 3 "~" H 650 7500 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 650 7500 50  0001 C CNN "Mouser"
	1    650  7500
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FDAF811
P 900 7200
AR Path="/5D8005AF/5D833E4B/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/5FE21410/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FBDE54D/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC2B5F4/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC56568/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FCDD090/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD148F1/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD202DF/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD2B946/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD447EB/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD44E3D/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45108/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45557/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45834/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD47CBA/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/600400AF/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040306/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040791/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60044374/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/6004437C/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/6004F414/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCF2/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCFB/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FD06/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FD11/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/60A71BBF/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FDAF811" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDA967F/5FDAF811" Ref="#PWR0453"  Part="1" 
F 0 "#PWR0453" H 900 7050 50  0001 C CNN
F 1 "VCC" H 917 7373 50  0000 C CNN
F 2 "" H 900 7200 50  0001 C CNN
F 3 "" H 900 7200 50  0001 C CNN
	1    900  7200
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FDAF81A
P 900 7800
AR Path="/5D8005AF/5D833E4B/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/5FE21410/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FBDE54D/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC2B5F4/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC56568/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FCDD090/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD148F1/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD202DF/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD2B946/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD447EB/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD44E3D/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45108/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45557/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45834/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD47CBA/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/600400AF/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040306/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040791/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60044374/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/6004437C/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/6004F414/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCF2/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCFB/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FD06/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FD11/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/60A71BBF/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FDAF81A" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDA967F/5FDAF81A" Ref="#PWR0454"  Part="1" 
F 0 "#PWR0454" H 900 7550 50  0001 C CNN
F 1 "GND" H 905 7627 50  0000 C CNN
F 2 "" H 900 7800 50  0001 C CNN
F 3 "" H 900 7800 50  0001 C CNN
	1    900  7800
	1    0    0    -1  
$EndComp
Wire Wire Line
	900  7800 900  7700
Wire Wire Line
	900  7200 900  7300
Wire Wire Line
	6300 3950 5650 3950
Entry Wire Line
	5650 3950 5550 4050
Wire Wire Line
	6300 4050 5650 4050
Entry Wire Line
	5650 4050 5550 4150
Wire Wire Line
	6300 4150 5650 4150
Entry Wire Line
	5650 4150 5550 4250
Wire Wire Line
	6300 4250 5750 4250
Entry Wire Line
	5750 4250 5650 4350
Wire Wire Line
	6300 4350 5750 4350
Entry Wire Line
	5750 4350 5650 4450
Wire Wire Line
	6300 4450 5750 4450
Entry Wire Line
	5750 4450 5650 4550
Wire Wire Line
	7300 4350 7850 4350
Entry Wire Line
	7850 4350 7950 4450
Wire Wire Line
	7300 4450 7850 4450
Entry Wire Line
	7850 4450 7950 4550
Wire Wire Line
	7300 4550 7850 4550
Entry Wire Line
	7850 4550 7950 4650
Text Label 5750 3950 0    50   ~ 0
SelA0
Text Label 5750 4050 0    50   ~ 0
SelA1
Text Label 5750 4150 0    50   ~ 0
SelA2
Text Label 5750 4250 0    50   ~ 0
SelB0
Text Label 5750 4350 0    50   ~ 0
SelB1
Text Label 5750 4450 0    50   ~ 0
SelB2
Wire Bus Line
	5550 4250 4850 4250
Text HLabel 4850 4250 0    50   Input ~ 0
SelA[0..2]
Wire Bus Line
	5650 4550 4850 4550
Text HLabel 4850 4550 0    50   Input ~ 0
SelB[0..2]
Text HLabel 9800 3950 2    50   Input ~ 0
Ins_EX[0..10]
Wire Bus Line
	7950 4650 9800 4650
Text HLabel 9800 4650 2    50   Input ~ 0
SelC_MEM[0..2]
Text Label 7400 4050 0    50   ~ 0
SelC_EX0
Text Label 7400 4150 0    50   ~ 0
SelC_EX1
Text Label 7400 4250 0    50   ~ 0
SelC_EX2
Text Label 7400 4350 0    50   ~ 0
SelC_MEM0
Text Label 7400 4450 0    50   ~ 0
SelC_MEM1
Text Label 7400 4550 0    50   ~ 0
SelC_MEM2
Text Label 9150 4250 2    50   ~ 0
Ins_EX10
Wire Bus Line
	9800 3950 9250 3950
Entry Wire Line
	9250 3950 9150 4050
Entry Wire Line
	9250 4050 9150 4150
Entry Wire Line
	9250 4150 9150 4250
Text Label 9150 4150 2    50   ~ 0
Ins_EX9
Text Label 9150 4050 2    50   ~ 0
Ins_EX8
Wire Wire Line
	7300 4050 9150 4050
Wire Wire Line
	7300 4150 9150 4150
Wire Wire Line
	7300 4250 9150 4250
Text Label 4550 3850 0    50   ~ 0
Ctl_MEM20
Text HLabel 4350 3750 0    50   Input ~ 0
Ctl_MEM[14..20]
Wire Bus Line
	4350 3750 4450 3750
Entry Wire Line
	4450 3750 4550 3850
Wire Wire Line
	4550 3850 6300 3850
Text Label 4550 3750 0    50   ~ 0
Ctl_EX20
Text HLabel 4350 3550 0    50   Input ~ 0
Ctl_EX[0..20]
Wire Bus Line
	4350 3550 4450 3550
Wire Wire Line
	4550 3750 6300 3750
Text Notes 950  2050 0    50   ~ 0
Hazard Control detects several types of hazards and stalls the pipeline to\nresolve each one.\n\nOn a jump, the program counter must be allowed to load a new value. At the\nsame time, the ID and IF stages must both be flushed. Control signals are\ngenerated for all three effects.\n\nIf the Ra or Rb registers refer to the destination register in the EX or MEM\nstage, and the instructions in the EX or MEM stage want to write back to that\nregister, then there is a RAW error. In this case, stall the pipeline for one\ncycle.\n\nIf the instruction in EX wants to update the Flags register, and the opcode in\nID is determined to be one that wants to make use of the flags, then there is\na Flags hazard. In this case, stall the pipeline for one cycle.
Text HLabel 7450 3750 2    50   Output ~ 0
~STALL_IF
Wire Wire Line
	7300 3750 7450 3750
Text HLabel 4850 4650 0    50   Input ~ 0
~J
Text HLabel 7450 3650 2    50   Output ~ 0
STALL_PC
Wire Wire Line
	7300 3650 7450 3650
Text Label 5750 3750 0    50   ~ 0
WBEN_EX
Text Label 5750 3850 0    50   ~ 0
WBEN_MEM
Text HLabel 1550 3050 0    50   Input ~ 0
Ins_ID[11..15]
Text Label 5750 3550 0    50   ~ 0
FlagsNeeded
$Comp
L MainBoard-rescue:ATF22V10C-Logic_Programmable U?
U 1 1 5FD893E9
P 2950 3700
AR Path="/5FED3839/5FD893E9" Ref="U?"  Part="1" 
AR Path="/5D2C07CD/5FD893E9" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FD893E9" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FD893E9" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FD893E9" Ref="U?"  Part="1" 
AR Path="/5FED3839/5FDA967F/5FD893E9" Ref="U79"  Part="1" 
F 0 "U79" H 2600 4350 50  0000 C CNN
F 1 "ATF22V10C-7PX" H 2600 4250 50  0000 C CNN
F 2 "Package_DIP:DIP-24_W8.89mm_SMDSocket_LongPads" H 3800 3000 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/268/doc0735-1369018.pdf" H 2950 3750 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Microchip-Technology-Atmel/ATF22V10C-7PX?qs=%2Fha2pyFadugqFuTUlWvkuaZr7DXQ8Rnu3dOZcKuoHGuPC51te6MYUw%3D%3D" H 2950 3700 50  0001 C CNN "Mouser"
F 5 "https://www.mouser.com/ProductDetail/575-4462401" H 2950 3700 50  0001 C CNN "Mouser2"
	1    2950 3700
	1    0    0    -1  
$EndComp
Wire Wire Line
	6300 3550 4850 3550
Wire Wire Line
	4850 3550 4850 3250
Wire Wire Line
	4850 3250 3450 3250
$Comp
L power:VCC #PWR?
U 1 1 5FD9161F
P 2950 3050
AR Path="/5D2C0B92/5FD9161F" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FD9161F" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FD9161F" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FD9161F" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDA967F/5FD9161F" Ref="#PWR0499"  Part="1" 
F 0 "#PWR0499" H 2950 2900 50  0001 C CNN
F 1 "VCC" H 2967 3223 50  0000 C CNN
F 2 "" H 2950 3050 50  0001 C CNN
F 3 "" H 2950 3050 50  0001 C CNN
	1    2950 3050
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FD91D4E
P 2950 4450
AR Path="/5D2C0B92/5FD91D4E" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FD91D4E" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FD91D4E" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FD91D4E" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FDA967F/5FD91D4E" Ref="#PWR0500"  Part="1" 
F 0 "#PWR0500" H 2950 4200 50  0001 C CNN
F 1 "GND" H 2955 4277 50  0000 C CNN
F 2 "" H 2950 4450 50  0001 C CNN
F 3 "" H 2950 4450 50  0001 C CNN
	1    2950 4450
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0501
U 1 1 5FD92644
P 7300 3850
F 0 "#PWR0501" H 7300 3600 50  0001 C CNN
F 1 "GND" V 7305 3722 50  0000 R CNN
F 2 "" H 7300 3850 50  0001 C CNN
F 3 "" H 7300 3850 50  0001 C CNN
	1    7300 3850
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR0502
U 1 1 5FD93111
P 7300 3950
F 0 "#PWR0502" H 7300 3700 50  0001 C CNN
F 1 "GND" V 7305 3822 50  0000 R CNN
F 2 "" H 7300 3950 50  0001 C CNN
F 3 "" H 7300 3950 50  0001 C CNN
	1    7300 3950
	0    -1   -1   0   
$EndComp
Wire Wire Line
	2450 3250 1900 3250
Entry Wire Line
	1900 3650 1800 3550
Wire Wire Line
	2450 3350 1900 3350
Entry Wire Line
	1900 3550 1800 3450
Wire Wire Line
	2450 3450 1900 3450
Entry Wire Line
	1900 3450 1800 3350
Text Label 1900 3250 0    50   ~ 0
Ins_ID11
Text Label 1900 3350 0    50   ~ 0
Ins_ID12
Text Label 1900 3450 0    50   ~ 0
Ins_ID13
Wire Wire Line
	2450 3550 1900 3550
Entry Wire Line
	1900 3350 1800 3250
Wire Wire Line
	2450 3650 1900 3650
Entry Wire Line
	1900 3250 1800 3150
Text Label 1900 3550 0    50   ~ 0
Ins_ID14
Text Label 1900 3650 0    50   ~ 0
Ins_ID15
Wire Bus Line
	1550 3050 1800 3050
NoConn ~ 2450 3750
NoConn ~ 2450 3850
NoConn ~ 2450 3950
NoConn ~ 2450 4050
NoConn ~ 2450 4150
NoConn ~ 2450 4250
NoConn ~ 3450 3350
NoConn ~ 3450 3450
NoConn ~ 3450 3550
NoConn ~ 3450 3650
NoConn ~ 3450 3750
NoConn ~ 3450 3850
NoConn ~ 3450 3950
NoConn ~ 3450 4050
NoConn ~ 3450 4150
NoConn ~ 3450 4250
Entry Wire Line
	4450 3650 4550 3750
Text Label 4550 3650 0    50   ~ 0
Ctl_EX5
Entry Wire Line
	4450 3550 4550 3650
Wire Wire Line
	6300 3650 4550 3650
Wire Bus Line
	4450 3650 4450 3550
Text Label 5750 3650 0    50   ~ 0
~FI
Wire Wire Line
	6300 4550 5950 4550
Wire Wire Line
	5950 4550 5950 4650
Wire Wire Line
	5950 4650 4850 4650
$Comp
L Device:C C?
U 1 1 5FE3AF3C
P 1150 7500
AR Path="/5D8005AF/5D833E4B/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/5FE21410/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/5FE8EB3D/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FBDE54D/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC2B5F4/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC56568/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FCDD090/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD148F1/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD202DF/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD2B946/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD447EB/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD44E3D/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45108/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45557/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45834/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD47CBA/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/600400AF/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60040306/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60040791/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60044374/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/6004437C/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/6004F414/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FCF2/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FCFB/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FD06/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FD11/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/60A71BBF/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/5D2C07CD/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FE3AF3C" Ref="C?"  Part="1" 
AR Path="/5FED3839/5FDA967F/5FE3AF3C" Ref="C86"  Part="1" 
F 0 "C86" H 1265 7546 50  0000 L CNN
F 1 "100nF" H 1265 7455 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 1188 7350 50  0001 C CNN
F 3 "~" H 1150 7500 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 1150 7500 50  0001 C CNN "Mouser"
	1    1150 7500
	1    0    0    -1  
$EndComp
Wire Wire Line
	650  7350 650  7300
Wire Wire Line
	650  7300 900  7300
Wire Wire Line
	1150 7300 1150 7350
Wire Wire Line
	650  7650 650  7700
Wire Wire Line
	650  7700 900  7700
Wire Wire Line
	1150 7700 1150 7650
Connection ~ 900  7300
Wire Wire Line
	900  7300 1150 7300
Connection ~ 900  7700
Wire Wire Line
	900  7700 1150 7700
Wire Bus Line
	5550 4050 5550 4250
Wire Bus Line
	5650 4350 5650 4550
Wire Bus Line
	7950 4450 7950 4650
Wire Bus Line
	9250 3950 9250 4150
Wire Bus Line
	1800 3050 1800 3550
$EndSCHEMATC
