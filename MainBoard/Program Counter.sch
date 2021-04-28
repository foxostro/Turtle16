EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 38 39
Title "Program Counter"
Date "2021-04-28"
Rev "A (c8cebf3f)"
Comp ""
Comment1 ""
Comment2 ""
Comment3 "sixteen-bit offset, or else reset to zero."
Comment4 "Sixteen-bit program counter will either increment on the clock, add a specified"
$EndDescr
Text HLabel 8500 1350 2    50   Output ~ 0
PC[0..15]
$Comp
L Device:C C?
U 1 1 5FBC5FD6
P 9550 6200
AR Path="/5D8005AF/5D833E4B/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/5FE21410/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/5FE8EB3D/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FBDE54D/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC2B5F4/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC56568/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FCDD090/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD148F1/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD202DF/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD2B946/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD447EB/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD44E3D/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45108/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45557/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45834/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD47CBA/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/600400AF/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60040306/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60040791/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60044374/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/6004437C/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/6004F414/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FCF2/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FCFB/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FD06/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FD11/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/60A71BBF/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/5D2C07CD/5FBC5FD6" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FBC5FD6" Ref="C62"  Part="1" 
F 0 "C62" H 9665 6246 50  0000 L CNN
F 1 "100nF" H 9665 6155 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 9588 6050 50  0001 C CNN
F 3 "~" H 9550 6200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 9550 6200 50  0001 C CNN "Mouser"
	1    9550 6200
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 5FBC5FDC
P 10050 6200
AR Path="/5D8005AF/5D833E4B/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/5FE21410/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/5FE8EB3D/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FBDE54D/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC2B5F4/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60906BCD/5FC56568/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FCDD090/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD148F1/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD202DF/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60153F0B/5FD2B946/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD447EB/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD44E3D/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45108/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45557/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD45834/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60A72859/5FD47CBA/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/600400AF/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60040306/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60040791/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/60044374/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/6004437C/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60A8EF0C/6004F414/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FCF2/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FCFB/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FD06/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/5FF41DF6/6005FD11/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/60A71BBF/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/5D2C07CD/5FBC5FDC" Ref="C?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FBC5FDC" Ref="C63"  Part="1" 
F 0 "C63" H 10165 6246 50  0000 L CNN
F 1 "100nF" H 10165 6155 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 10088 6050 50  0001 C CNN
F 3 "~" H 10050 6200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 10050 6200 50  0001 C CNN "Mouser"
	1    10050 6200
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FBC5FE2
P 9550 6050
AR Path="/5D8005AF/5D833E4B/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/5FE21410/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FBDE54D/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC2B5F4/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC56568/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FCDD090/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD148F1/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD202DF/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD2B946/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD447EB/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD44E3D/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45108/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45557/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45834/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD47CBA/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/600400AF/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040306/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040791/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60044374/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/6004437C/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/6004F414/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCF2/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCFB/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FD06/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FD11/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/60A71BBF/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FBC5FE2" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FBC5FE2" Ref="#PWR0449"  Part="1" 
F 0 "#PWR0449" H 9550 5900 50  0001 C CNN
F 1 "VCC" H 9567 6223 50  0000 C CNN
F 2 "" H 9550 6050 50  0001 C CNN
F 3 "" H 9550 6050 50  0001 C CNN
	1    9550 6050
	1    0    0    -1  
$EndComp
Wire Wire Line
	9550 6050 10050 6050
Connection ~ 9550 6050
Wire Wire Line
	10050 6350 9550 6350
$Comp
L power:GND #PWR?
U 1 1 5FBC5FEB
P 9550 6450
AR Path="/5D8005AF/5D833E4B/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/5FE21410/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FBDE54D/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC2B5F4/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60906BCD/5FC56568/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FCDD090/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD148F1/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD202DF/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60153F0B/5FD2B946/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD447EB/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD44E3D/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45108/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45557/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD45834/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60A72859/5FD47CBA/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/600400AF/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040306/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60040791/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/60044374/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/6004437C/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60A8EF0C/6004F414/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCF2/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FCFB/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FD06/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/5FF41DF6/6005FD11/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/60A71BBF/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FBC5FEB" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FBC5FEB" Ref="#PWR0450"  Part="1" 
F 0 "#PWR0450" H 9550 6200 50  0001 C CNN
F 1 "GND" H 9555 6277 50  0000 C CNN
F 2 "" H 9550 6450 50  0001 C CNN
F 3 "" H 9550 6450 50  0001 C CNN
	1    9550 6450
	1    0    0    -1  
$EndComp
Wire Wire Line
	9550 6450 9550 6350
Connection ~ 9550 6350
$Comp
L MainBoard-rescue:IDT7381-CPU U?
U 1 1 5FBC5FF4
P 6050 3950
AR Path="/60A71BBF/5FBC5FF4" Ref="U?"  Part="1" 
AR Path="/5D2C07CD/5FBC5FF4" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FBC5FF4" Ref="U60"  Part="1" 
F 0 "U60" H 6050 4000 50  0000 C CNN
F 1 "IDT7381" H 6050 3900 50  0000 C CNN
F 2 "Package_LCC:PLCC-68_24.2x24.2mm_P1.27mm" H 6050 5200 50  0001 C CNN
F 3 "https://www.digchip.com/datasheets/download_datasheet.php?id=419696&part-number=IDT7381" H 6050 5200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/3M-Electronic-Solutions-Division/8468-21B1-RK-TP?qs=WZRMhwwaLl%2FJN6Bcf7US3Q%3D%3D" H 6050 3950 50  0001 C CNN "Mouser"
	1    6050 3950
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 5FBC5FFA
P 6050 1600
AR Path="/5D2C0CE4/5FBC5FFA" Ref="#PWR?"  Part="1" 
AR Path="/60A71BBF/5FBC5FFA" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FBC5FFA" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FBC5FFA" Ref="#PWR0445"  Part="1" 
F 0 "#PWR0445" H 6050 1450 50  0001 C CNN
F 1 "VCC" H 6067 1773 50  0000 C CNN
F 2 "" H 6050 1600 50  0001 C CNN
F 3 "" H 6050 1600 50  0001 C CNN
	1    6050 1600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FBC6012
P 6050 6300
AR Path="/5D2C0CE4/5FBC6012" Ref="#PWR?"  Part="1" 
AR Path="/60A71BBF/5FBC6012" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FBC6012" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FBC6012" Ref="#PWR0446"  Part="1" 
F 0 "#PWR0446" H 6050 6050 50  0001 C CNN
F 1 "GND" H 6055 6127 50  0000 C CNN
F 2 "" H 6050 6300 50  0001 C CNN
F 3 "" H 6050 6300 50  0001 C CNN
	1    6050 6300
	1    0    0    -1  
$EndComp
Text Label 7700 2100 2    50   ~ 0
PC3
Wire Wire Line
	7750 2100 7150 2100
Entry Wire Line
	7750 2100 7850 2000
Text Label 7700 2000 2    50   ~ 0
PC2
Wire Wire Line
	7750 2000 7150 2000
Entry Wire Line
	7750 2000 7850 1900
Text Label 7700 1900 2    50   ~ 0
PC1
Wire Wire Line
	7750 1900 7150 1900
Entry Wire Line
	7750 1900 7850 1800
Text Label 7700 1800 2    50   ~ 0
PC0
Wire Wire Line
	7750 1800 7150 1800
Entry Wire Line
	7750 1800 7850 1700
Text Label 7700 2200 2    50   ~ 0
PC4
Wire Wire Line
	7750 2200 7150 2200
Entry Wire Line
	7750 2200 7850 2100
Text Label 7700 2300 2    50   ~ 0
PC5
Wire Wire Line
	7750 2300 7150 2300
Entry Wire Line
	7750 2300 7850 2200
Wire Wire Line
	7750 2400 7150 2400
Entry Wire Line
	7750 2400 7850 2300
Text Label 7700 2500 2    50   ~ 0
PC7
Wire Wire Line
	7750 2500 7150 2500
Entry Wire Line
	7750 2500 7850 2400
Text Label 7700 2600 2    50   ~ 0
PC8
Wire Wire Line
	7750 2600 7150 2600
Entry Wire Line
	7750 2600 7850 2500
Text Label 7700 2700 2    50   ~ 0
PC9
Wire Wire Line
	7750 2700 7150 2700
Entry Wire Line
	7750 2700 7850 2600
Text Label 7700 2800 2    50   ~ 0
PC10
Wire Wire Line
	7750 2800 7150 2800
Entry Wire Line
	7750 2800 7850 2700
Text Label 7700 2900 2    50   ~ 0
PC11
Wire Wire Line
	7750 2900 7150 2900
Entry Wire Line
	7750 2900 7850 2800
Text Label 7700 3000 2    50   ~ 0
PC12
Wire Wire Line
	7750 3000 7150 3000
Entry Wire Line
	7750 3000 7850 2900
Text Label 7700 3100 2    50   ~ 0
PC13
Wire Wire Line
	7750 3100 7150 3100
Entry Wire Line
	7750 3100 7850 3000
Text Label 7700 3200 2    50   ~ 0
PC14
Wire Wire Line
	7750 3200 7150 3200
Entry Wire Line
	7750 3200 7850 3100
Text Label 7700 3300 2    50   ~ 0
PC15
Wire Wire Line
	7750 3300 7150 3300
Entry Wire Line
	7750 3300 7850 3200
Text Label 7700 2400 2    50   ~ 0
PC6
$Comp
L power:GND #PWR?
U 1 1 5FBC6096
P 7150 3650
AR Path="/60A71BBF/5FBC6096" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FBC6096" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FBC6096" Ref="#PWR0448"  Part="1" 
F 0 "#PWR0448" H 7150 3400 50  0001 C CNN
F 1 "GND" V 7155 3522 50  0000 R CNN
F 2 "" H 7150 3650 50  0001 C CNN
F 3 "" H 7150 3650 50  0001 C CNN
	1    7150 3650
	0    -1   -1   0   
$EndComp
NoConn ~ 7150 3900
NoConn ~ 7150 4000
Wire Bus Line
	8500 1350 7850 1350
Text Label 7900 1350 0    50   ~ 0
PC[0..15]
NoConn ~ 7150 3800
NoConn ~ 7150 4100
NoConn ~ 7150 4200
Text HLabel 1750 3300 0    50   Input ~ 0
Y_EX[0..15]
Text Notes 900  2450 0    50   ~ 0
Configure the ALU for FTAB=1 and FTF=0. This causes the A and B registers\nto by bypassed entirely. The F output updates on the next rising edge of the\nclock.\n\nDuring reset, set the ALU to I2=0, I1=0, I0=0. This causes the ALU to\ncompute a zero and latch it in A on the rising edge of the clock regardless\nof the value of the A and B inputs. This resets the program counter\nto zero.\n\nWhen incrementing, set the ALU to RS1=0, RS0=1, I2=0, I1=1, I0=1, C0=1.\nThe ALU computes F = A + 0 + C0. Since output is wired to feedback to\ninput port A, this computes PC = PC + 1.\n\nWhen performing a relative jump, set the ALU to RS1=1, RS0=1, I2=0, I1=1,\nI0=1, C0=0. The ALU computes F = A + B. Since the B port gets its value\nfrom the Y result of the the EX stage, this computes PC = PC + offset.\n\nWhen performing an absolute jump, set the ALU to RS1=1, RS0=0, I2=0, I1=1,\nI0=1, C0=0. The ALU computes F = 0 + B. Since the B port gets its value\nfrom the Y result of the the EX stage, this computes PC = target.
Text Label 4400 3500 0    50   ~ 0
Y_EX0
Text Label 4400 3600 0    50   ~ 0
Y_EX1
Wire Bus Line
	4250 3300 1750 3300
Entry Wire Line
	4350 5000 4250 4900
Wire Wire Line
	4350 5000 4950 5000
Text Label 4400 5000 0    50   ~ 0
Y_EX15
Entry Wire Line
	4350 4900 4250 4800
Wire Wire Line
	4350 4900 4950 4900
Text Label 4400 4900 0    50   ~ 0
Y_EX14
Entry Wire Line
	4350 4800 4250 4700
Wire Wire Line
	4350 4800 4950 4800
Text Label 4400 4800 0    50   ~ 0
Y_EX13
Entry Wire Line
	4350 4700 4250 4600
Wire Wire Line
	4350 4700 4950 4700
Text Label 4400 4700 0    50   ~ 0
Y_EX12
Entry Wire Line
	4350 4600 4250 4500
Wire Wire Line
	4350 4600 4950 4600
Text Label 4400 4600 0    50   ~ 0
Y_EX11
Entry Wire Line
	4350 4500 4250 4400
Wire Wire Line
	4350 4500 4950 4500
Text Label 4400 4500 0    50   ~ 0
Y_EX10
Entry Wire Line
	4350 4400 4250 4300
Wire Wire Line
	4350 4400 4950 4400
Text Label 4400 4400 0    50   ~ 0
Y_EX9
Entry Wire Line
	4350 4300 4250 4200
Wire Wire Line
	4350 4300 4950 4300
Text Label 4400 4300 0    50   ~ 0
Y_EX8
Entry Wire Line
	4350 4200 4250 4100
Wire Wire Line
	4350 4200 4950 4200
Text Label 4400 4200 0    50   ~ 0
Y_EX7
Entry Wire Line
	4350 4100 4250 4000
Wire Wire Line
	4350 4100 4950 4100
Text Label 4400 4100 0    50   ~ 0
Y_EX6
Entry Wire Line
	4350 4000 4250 3900
Wire Wire Line
	4350 4000 4950 4000
Text Label 4400 4000 0    50   ~ 0
Y_EX5
Entry Wire Line
	4350 3900 4250 3800
Wire Wire Line
	4350 3900 4950 3900
Text Label 4400 3900 0    50   ~ 0
Y_EX4
Entry Wire Line
	4350 3500 4250 3400
Wire Wire Line
	4350 3500 4950 3500
Entry Wire Line
	4350 3600 4250 3500
Wire Wire Line
	4350 3600 4950 3600
Entry Wire Line
	4350 3700 4250 3600
Wire Wire Line
	4350 3700 4950 3700
Text Label 4400 3700 0    50   ~ 0
Y_EX2
Entry Wire Line
	4350 3800 4250 3700
Wire Wire Line
	4350 3800 4950 3800
Text Label 4400 3800 0    50   ~ 0
Y_EX3
Text Label 4400 2100 0    50   ~ 0
PC3
Wire Wire Line
	4350 2100 4950 2100
Entry Wire Line
	4350 2100 4250 2000
Text Label 4400 2000 0    50   ~ 0
PC2
Wire Wire Line
	4350 2000 4950 2000
Entry Wire Line
	4350 2000 4250 1900
Text Label 4400 1900 0    50   ~ 0
PC1
Wire Wire Line
	4350 1900 4950 1900
Entry Wire Line
	4350 1900 4250 1800
Text Label 4400 1800 0    50   ~ 0
PC0
Wire Wire Line
	4350 1800 4950 1800
Entry Wire Line
	4350 1800 4250 1700
Text Label 4400 2200 0    50   ~ 0
PC4
Wire Wire Line
	4350 2200 4950 2200
Entry Wire Line
	4350 2200 4250 2100
Text Label 4400 2300 0    50   ~ 0
PC5
Wire Wire Line
	4350 2300 4950 2300
Entry Wire Line
	4350 2300 4250 2200
Wire Wire Line
	4350 2400 4950 2400
Entry Wire Line
	4350 2400 4250 2300
Text Label 4400 2500 0    50   ~ 0
PC7
Wire Wire Line
	4350 2500 4950 2500
Entry Wire Line
	4350 2500 4250 2400
Text Label 4400 2600 0    50   ~ 0
PC8
Wire Wire Line
	4350 2600 4950 2600
Entry Wire Line
	4350 2600 4250 2500
Text Label 4400 2700 0    50   ~ 0
PC9
Wire Wire Line
	4350 2700 4950 2700
Entry Wire Line
	4350 2700 4250 2600
Text Label 4400 2800 0    50   ~ 0
PC10
Wire Wire Line
	4350 2800 4950 2800
Entry Wire Line
	4350 2800 4250 2700
Text Label 4400 2900 0    50   ~ 0
PC11
Wire Wire Line
	4350 2900 4950 2900
Entry Wire Line
	4350 2900 4250 2800
Text Label 4400 3000 0    50   ~ 0
PC12
Wire Wire Line
	4350 3000 4950 3000
Entry Wire Line
	4350 3000 4250 2900
Text Label 4400 3100 0    50   ~ 0
PC13
Wire Wire Line
	4350 3100 4950 3100
Entry Wire Line
	4350 3100 4250 3000
Text Label 4400 3200 0    50   ~ 0
PC14
Wire Wire Line
	4350 3200 4950 3200
Entry Wire Line
	4350 3200 4250 3100
Text Label 4400 3300 0    50   ~ 0
PC15
Wire Wire Line
	4350 3300 4950 3300
Entry Wire Line
	4350 3300 4250 3200
Text Label 4400 2400 0    50   ~ 0
PC6
Wire Bus Line
	4250 1350 7850 1350
Connection ~ 7850 1350
$Comp
L power:VCC #PWR?
U 1 1 5FE5D391
P 4950 5900
AR Path="/5D2C07CD/5FE5D391" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FE5D391" Ref="#PWR0442"  Part="1" 
F 0 "#PWR0442" H 4950 5750 50  0001 C CNN
F 1 "VCC" V 4965 6027 50  0000 L CNN
F 2 "" H 4950 5900 50  0001 C CNN
F 3 "" H 4950 5900 50  0001 C CNN
	1    4950 5900
	0    -1   -1   0   
$EndComp
Text GLabel 4350 5200 0    50   Input ~ 0
Phi1a
$Comp
L power:VCC #PWR?
U 1 1 60653810
P 4950 6000
AR Path="/5D2C07CD/60653810" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/60653810" Ref="#PWR0443"  Part="1" 
F 0 "#PWR0443" H 4950 5850 50  0001 C CNN
F 1 "VCC" V 4965 6127 50  0000 L CNN
F 2 "" H 4950 6000 50  0001 C CNN
F 3 "" H 4950 6000 50  0001 C CNN
	1    4950 6000
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 60653B0E
P 4950 6100
AR Path="/5D2C07CD/60653B0E" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/60653B0E" Ref="#PWR0444"  Part="1" 
F 0 "#PWR0444" H 4950 5950 50  0001 C CNN
F 1 "VCC" V 4965 6227 50  0000 L CNN
F 2 "" H 4950 6100 50  0001 C CNN
F 3 "" H 4950 6100 50  0001 C CNN
	1    4950 6100
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60653E30
P 7150 3550
AR Path="/60A71BBF/60653E30" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/60653E30" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/60653E30" Ref="#PWR0447"  Part="1" 
F 0 "#PWR0447" H 7150 3300 50  0001 C CNN
F 1 "GND" V 7155 3422 50  0000 R CNN
F 2 "" H 7150 3550 50  0001 C CNN
F 3 "" H 7150 3550 50  0001 C CNN
	1    7150 3550
	0    -1   -1   0   
$EndComp
Text HLabel 7750 3450 2    50   Input ~ 0
STALL
Wire Wire Line
	7150 3450 7750 3450
Text Notes 8150 3550 0    50   ~ 0
Stall the program counter by disabling\nthe update of the IDT7381’s F register.
Text HLabel 3600 6050 2    50   Output ~ 0
FLUSH_IF
$Comp
L 74xx:74LS04 U?
U 7 1 606F182D
P -1150 7350
AR Path="/5D2C0761/606F182D" Ref="U?"  Part="7" 
AR Path="/5D2C0720/606F182D" Ref="U?"  Part="7" 
AR Path="/5FE35007/5FE3DA1C/606F182D" Ref="U59"  Part="7" 
F 0 "U59" H -1150 7400 50  0000 C CNN
F 1 "74AHCT04" H -1150 7300 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -1150 7350 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -1150 7350 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -1150 7350 50  0001 C CNN "Mouser"
	7    -1150 7350
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 606F1833
P -1150 3700
AR Path="/5D2C0761/606F1833" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/606F1833" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/606F1833" Ref="#PWR0439"  Part="1" 
F 0 "#PWR0439" H -1150 3550 50  0001 C CNN
F 1 "VCC" H -1133 3873 50  0000 C CNN
F 2 "" H -1150 3700 50  0001 C CNN
F 3 "" H -1150 3700 50  0001 C CNN
	1    -1150 3700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 606F1839
P -1150 7900
AR Path="/5D2C0720/606F1839" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/606F1839" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/606F1839" Ref="#PWR0440"  Part="1" 
F 0 "#PWR0440" H -1150 7650 50  0001 C CNN
F 1 "GND" H -1145 7727 50  0000 C CNN
F 2 "" H -1150 7900 50  0001 C CNN
F 3 "" H -1150 7900 50  0001 C CNN
	1    -1150 7900
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-1150 7850 -1150 7900
Wire Wire Line
	-1150 3700 -1150 4550
$Comp
L 74xx:74LS04 U?
U 2 1 606FE21F
P -850 4550
AR Path="/5D2C0761/606FE21F" Ref="U?"  Part="7" 
AR Path="/5D2C0720/606FE21F" Ref="U?"  Part="7" 
AR Path="/5FE35007/5FE3DA1C/606FE21F" Ref="U59"  Part="2" 
F 0 "U59" H -850 4850 50  0000 C CNN
F 1 "74AHCT04" H -850 4750 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -850 4550 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -850 4550 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -850 4550 50  0001 C CNN "Mouser"
	2    -850 4550
	1    0    0    -1  
$EndComp
Connection ~ -1150 4550
Wire Wire Line
	-1150 4550 -1150 5100
NoConn ~ -550 4550
$Comp
L 74xx:74LS04 U?
U 3 1 607073BC
P -850 5100
AR Path="/5D2C0761/607073BC" Ref="U?"  Part="7" 
AR Path="/5D2C0720/607073BC" Ref="U?"  Part="7" 
AR Path="/5FE35007/5FE3DA1C/607073BC" Ref="U59"  Part="3" 
F 0 "U59" H -850 5400 50  0000 C CNN
F 1 "74AHCT04" H -850 5300 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -850 5100 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -850 5100 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -850 5100 50  0001 C CNN "Mouser"
	3    -850 5100
	1    0    0    -1  
$EndComp
NoConn ~ -550 5100
$Comp
L 74xx:74LS04 U?
U 4 1 6070B365
P -850 5650
AR Path="/5D2C0761/6070B365" Ref="U?"  Part="7" 
AR Path="/5D2C0720/6070B365" Ref="U?"  Part="7" 
AR Path="/5FE35007/5FE3DA1C/6070B365" Ref="U59"  Part="4" 
F 0 "U59" H -850 5950 50  0000 C CNN
F 1 "74AHCT04" H -850 5850 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -850 5650 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -850 5650 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -850 5650 50  0001 C CNN "Mouser"
	4    -850 5650
	1    0    0    -1  
$EndComp
NoConn ~ -550 5650
$Comp
L 74xx:74LS04 U?
U 5 1 6070EECA
P -850 6200
AR Path="/5D2C0761/6070EECA" Ref="U?"  Part="7" 
AR Path="/5D2C0720/6070EECA" Ref="U?"  Part="7" 
AR Path="/5FE35007/5FE3DA1C/6070EECA" Ref="U59"  Part="5" 
F 0 "U59" H -850 6500 50  0000 C CNN
F 1 "74AHCT04" H -850 6400 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -850 6200 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -850 6200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -850 6200 50  0001 C CNN "Mouser"
	5    -850 6200
	1    0    0    -1  
$EndComp
NoConn ~ -550 6200
$Comp
L 74xx:74LS04 U?
U 1 1 60715C9B
P 2950 5800
AR Path="/5D2C0761/60715C9B" Ref="U?"  Part="7" 
AR Path="/5D2C0720/60715C9B" Ref="U?"  Part="7" 
AR Path="/5FE35007/5FE3DA1C/60715C9B" Ref="U59"  Part="1" 
F 0 "U59" H 2950 6100 50  0000 C CNN
F 1 "74AHCT04" H 2950 6000 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 2950 5800 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 2950 5800 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H 2950 5800 50  0001 C CNN "Mouser"
	1    2950 5800
	1    0    0    -1  
$EndComp
NoConn ~ -550 4050
Connection ~ -1150 5100
Wire Wire Line
	-1150 5100 -1150 5650
Connection ~ -1150 5650
Wire Wire Line
	-1150 5650 -1150 6200
Connection ~ -1150 6200
Wire Wire Line
	-1150 6200 -1150 6750
$Comp
L 74xx:74LS04 U?
U 6 1 60721233
P -850 6750
AR Path="/5D2C0761/60721233" Ref="U?"  Part="7" 
AR Path="/5D2C0720/60721233" Ref="U?"  Part="7" 
AR Path="/5FE35007/5FE3DA1C/60721233" Ref="U59"  Part="6" 
F 0 "U59" H -850 7050 50  0000 C CNN
F 1 "74AHCT04" H -850 6950 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -850 6750 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -850 6750 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -850 6750 50  0001 C CNN "Mouser"
	6    -850 6750
	1    0    0    -1  
$EndComp
NoConn ~ -550 6750
Connection ~ -1150 6750
Wire Wire Line
	-1150 6750 -1150 6850
Text HLabel 4600 5300 0    50   Input ~ 0
~J
Wire Wire Line
	4600 5300 4950 5300
Text HLabel 2300 5800 0    50   Input ~ 0
~J
Wire Wire Line
	2300 5800 2650 5800
Wire Wire Line
	3250 5800 3450 5800
Text HLabel 4600 5700 0    50   Input ~ 0
~JABS
Wire Wire Line
	4600 5700 4950 5700
Text HLabel 4600 5500 0    50   Input ~ 0
~RST
Wire Wire Line
	4600 5500 4950 5500
Text HLabel 4600 5400 0    50   Input ~ 0
~RST
Wire Wire Line
	4600 5400 4950 5400
Wire Wire Line
	3600 6050 3450 6050
Wire Wire Line
	3450 6050 3450 5800
Connection ~ 3450 5800
Wire Wire Line
	4350 5200 4950 5200
$Comp
L power:GND #PWR?
U 1 1 60776392
P 4900 5600
AR Path="/60A71BBF/60776392" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/60776392" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/60776392" Ref="#PWR0441"  Part="1" 
F 0 "#PWR0441" H 4900 5350 50  0001 C CNN
F 1 "GND" V 4905 5472 50  0000 R CNN
F 2 "" H 4900 5600 50  0001 C CNN
F 3 "" H 4900 5600 50  0001 C CNN
	1    4900 5600
	0    1    -1   0   
$EndComp
Wire Wire Line
	4950 5600 4900 5600
Wire Wire Line
	3450 5800 4950 5800
Wire Bus Line
	7850 1350 7850 3200
Wire Bus Line
	4250 1350 4250 3200
Wire Bus Line
	4250 3300 4250 4900
$EndSCHEMATC
