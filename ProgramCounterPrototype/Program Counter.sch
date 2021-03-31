EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 2 2
Title "Program Counter"
Date "2021-03-31"
Rev "A (d3581256)"
Comp ""
Comment1 ""
Comment2 ""
Comment3 "sixteen-bit offset, or else reset to zero."
Comment4 "Sixteen-bit program counter will either increment on the clock, add a specified"
$EndDescr
Text HLabel 1500 5400 0    50   Input ~ 0
~RST
Text HLabel 1500 5500 0    50   Input ~ 0
~J
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
AR Path="/5FE35007/5FE3DA1C/5FBC5FD6" Ref="C73"  Part="1" 
AR Path="/606491BC/5FBC5FD6" Ref="C2"  Part="1" 
F 0 "C2" H 9665 6246 50  0000 L CNN
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
AR Path="/5FE35007/5FE3DA1C/5FBC5FDC" Ref="C74"  Part="1" 
AR Path="/606491BC/5FBC5FDC" Ref="C3"  Part="1" 
F 0 "C3" H 10165 6246 50  0000 L CNN
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
AR Path="/5FE35007/5FE3DA1C/5FBC5FE2" Ref="#PWR0465"  Part="1" 
AR Path="/606491BC/5FBC5FE2" Ref="#PWR0101"  Part="1" 
F 0 "#PWR0101" H 9550 5900 50  0001 C CNN
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
AR Path="/5FE35007/5FE3DA1C/5FBC5FEB" Ref="#PWR0466"  Part="1" 
AR Path="/606491BC/5FBC5FEB" Ref="#PWR0102"  Part="1" 
F 0 "#PWR0102" H 9550 6200 50  0001 C CNN
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
L ProgramCounterPrototype-rescue:IDT7381-CPU U?
U 1 1 5FBC5FF4
P 6050 3950
AR Path="/60A71BBF/5FBC5FF4" Ref="U?"  Part="1" 
AR Path="/5D2C07CD/5FBC5FF4" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FBC5FF4" Ref="U70"  Part="1" 
AR Path="/606491BC/5FBC5FF4" Ref="U2"  Part="1" 
F 0 "U2" H 6050 4000 50  0000 C CNN
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
AR Path="/5FE35007/5FE3DA1C/5FBC5FFA" Ref="#PWR0460"  Part="1" 
AR Path="/606491BC/5FBC5FFA" Ref="#PWR0103"  Part="1" 
F 0 "#PWR0103" H 6050 1450 50  0001 C CNN
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
AR Path="/5FE35007/5FE3DA1C/5FBC6012" Ref="#PWR0461"  Part="1" 
AR Path="/606491BC/5FBC6012" Ref="#PWR0104"  Part="1" 
F 0 "#PWR0104" H 6050 6050 50  0001 C CNN
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
AR Path="/5FE35007/5FE3DA1C/5FBC6096" Ref="#PWR0464"  Part="1" 
AR Path="/606491BC/5FBC6096" Ref="#PWR0105"  Part="1" 
F 0 "#PWR0105" H 7150 3400 50  0001 C CNN
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
$Comp
L power:VCC #PWR?
U 1 1 5FCF8BB3
P 3050 5100
AR Path="/5D2C0B92/5FCF8BB3" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FCF8BB3" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FCF8BB3" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FCF8BB3" Ref="#PWR0454"  Part="1" 
AR Path="/606491BC/5FCF8BB3" Ref="#PWR0106"  Part="1" 
F 0 "#PWR0106" H 3050 4950 50  0001 C CNN
F 1 "VCC" H 3067 5273 50  0000 C CNN
F 2 "" H 3050 5100 50  0001 C CNN
F 3 "" H 3050 5100 50  0001 C CNN
	1    3050 5100
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 5FCF8BB9
P 3050 6500
AR Path="/5D2C0B92/5FCF8BB9" Ref="#PWR?"  Part="1" 
AR Path="/5FED3839/5FCF8BB9" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FCF8BB9" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FCF8BB9" Ref="#PWR0455"  Part="1" 
AR Path="/606491BC/5FCF8BB9" Ref="#PWR0107"  Part="1" 
F 0 "#PWR0107" H 3050 6250 50  0001 C CNN
F 1 "GND" H 3055 6327 50  0000 C CNN
F 2 "" H 3050 6500 50  0001 C CNN
F 3 "" H 3050 6500 50  0001 C CNN
	1    3050 6500
	1    0    0    -1  
$EndComp
Wire Wire Line
	4950 5300 3550 5300
Wire Wire Line
	3550 5400 4950 5400
Wire Wire Line
	4950 5500 3550 5500
Wire Wire Line
	3550 5600 4950 5600
Wire Wire Line
	4950 5700 3550 5700
Wire Wire Line
	4950 5800 3550 5800
NoConn ~ 3550 5900
NoConn ~ 3550 6000
NoConn ~ 3550 6200
Wire Wire Line
	4950 5200 4000 5200
Wire Wire Line
	4000 5200 4000 4650
Wire Wire Line
	1500 5400 2550 5400
Wire Wire Line
	2550 5500 1500 5500
NoConn ~ 2550 5800
NoConn ~ 2550 5900
NoConn ~ 2550 6100
NoConn ~ 2550 6200
NoConn ~ 2550 6300
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
L ProgramCounterPrototype-rescue:ATF22V10C-Logic_Programmable U?
U 1 1 5FCC7BA1
P 3050 5750
AR Path="/5FED3839/5FCC7BA1" Ref="U?"  Part="1" 
AR Path="/5D2C07CD/5FCC7BA1" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FCC7BA1" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FD0D8DC/5FCC7BA1" Ref="U?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FCC7BA1" Ref="U69"  Part="1" 
AR Path="/606491BC/5FCC7BA1" Ref="U1"  Part="1" 
F 0 "U1" H 2700 6400 50  0000 C CNN
F 1 "ATF22V10C-7PX" H 2700 6300 50  0000 C CNN
F 2 "Package_DIP:DIP-24_W7.62mm_Socket" H 3900 5050 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/268/doc0735-1369018.pdf" H 3050 5800 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Microchip-Technology-Atmel/ATF22V10C-7PX?qs=%2Fha2pyFadugqFuTUlWvkuaZr7DXQ8Rnu3dOZcKuoHGuPC51te6MYUw%3D%3D" H 3050 5750 50  0001 C CNN "Mouser"
F 5 "https://www.mouser.com/ProductDetail/575-4462401" H 3050 5750 50  0001 C CNN "Mouser2"
	1    3050 5750
	1    0    0    -1  
$EndComp
Text HLabel 1500 5600 0    50   Input ~ 0
~JABS
Wire Wire Line
	2550 5600 1500 5600
$Comp
L power:GND #PWR?
U 1 1 5FD205DD
P 3550 6300
AR Path="/60A71BBF/5FD205DD" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FD205DD" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/5FD205DD" Ref="#PWR0456"  Part="1" 
AR Path="/606491BC/5FD205DD" Ref="#PWR0108"  Part="1" 
F 0 "#PWR0108" H 3550 6050 50  0001 C CNN
F 1 "GND" V 3555 6172 50  0000 R CNN
F 2 "" H 3550 6300 50  0001 C CNN
F 3 "" H 3550 6300 50  0001 C CNN
	1    3550 6300
	0    -1   -1   0   
$EndComp
Wire Wire Line
	2550 5300 2150 5300
Wire Wire Line
	2150 4650 1500 4650
Wire Wire Line
	4000 4650 2150 4650
Connection ~ 2150 4650
Wire Wire Line
	2150 5300 2150 4650
NoConn ~ 2550 5700
Text GLabel 1500 4650 0    50   Input ~ 0
Phi1b
$Comp
L power:GND #PWR?
U 1 1 606289F2
P 2550 6000
AR Path="/60A71BBF/606289F2" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/606289F2" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/606289F2" Ref="#PWR0487"  Part="1" 
AR Path="/606491BC/606289F2" Ref="#PWR0114"  Part="1" 
F 0 "#PWR0114" H 2550 5750 50  0001 C CNN
F 1 "GND" V 2555 5872 50  0000 R CNN
F 2 "" H 2550 6000 50  0001 C CNN
F 3 "" H 2550 6000 50  0001 C CNN
	1    2550 6000
	0    1    -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60629108
P 3550 6100
AR Path="/60A71BBF/60629108" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/60629108" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/60629108" Ref="#PWR0488"  Part="1" 
AR Path="/606491BC/60629108" Ref="#PWR0115"  Part="1" 
F 0 "#PWR0115" H 3550 5850 50  0001 C CNN
F 1 "GND" V 3555 5972 50  0000 R CNN
F 2 "" H 3550 6100 50  0001 C CNN
F 3 "" H 3550 6100 50  0001 C CNN
	1    3550 6100
	0    -1   -1   0   
$EndComp
Wire Bus Line
	7850 1350 7850 3200
Wire Bus Line
	4250 1350 4250 3200
Wire Bus Line
	4250 3300 4250 4900
$Comp
L power:VCC #PWR?
U 1 1 6064FC75
P 4950 5900
AR Path="/5D2C07CD/6064FC75" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/6064FC75" Ref="#PWR?"  Part="1" 
AR Path="/606491BC/6064FC75" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 4950 5750 50  0001 C CNN
F 1 "VCC" V 4965 6027 50  0000 L CNN
F 2 "" H 4950 5900 50  0001 C CNN
F 3 "" H 4950 5900 50  0001 C CNN
	1    4950 5900
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 606509C5
P 4950 6000
AR Path="/5D2C07CD/606509C5" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/606509C5" Ref="#PWR?"  Part="1" 
AR Path="/606491BC/606509C5" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 4950 5850 50  0001 C CNN
F 1 "VCC" V 4965 6127 50  0000 L CNN
F 2 "" H 4950 6000 50  0001 C CNN
F 3 "" H 4950 6000 50  0001 C CNN
	1    4950 6000
	0    -1   -1   0   
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 60650C8F
P 4950 6100
AR Path="/5D2C07CD/60650C8F" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/60650C8F" Ref="#PWR?"  Part="1" 
AR Path="/606491BC/60650C8F" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 4950 5950 50  0001 C CNN
F 1 "VCC" V 4965 6227 50  0000 L CNN
F 2 "" H 4950 6100 50  0001 C CNN
F 3 "" H 4950 6100 50  0001 C CNN
	1    4950 6100
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60651074
P 7150 3550
AR Path="/60A71BBF/60651074" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/60651074" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/60651074" Ref="#PWR?"  Part="1" 
AR Path="/606491BC/60651074" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 7150 3300 50  0001 C CNN
F 1 "GND" V 7155 3422 50  0000 R CNN
F 2 "" H 7150 3550 50  0001 C CNN
F 3 "" H 7150 3550 50  0001 C CNN
	1    7150 3550
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR?
U 1 1 60651397
P 7150 3450
AR Path="/60A71BBF/60651397" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/60651397" Ref="#PWR?"  Part="1" 
AR Path="/5FE35007/5FE3DA1C/60651397" Ref="#PWR?"  Part="1" 
AR Path="/606491BC/60651397" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H 7150 3200 50  0001 C CNN
F 1 "GND" V 7155 3322 50  0000 R CNN
F 2 "" H 7150 3450 50  0001 C CNN
F 3 "" H 7150 3450 50  0001 C CNN
	1    7150 3450
	0    -1   -1   0   
$EndComp
$EndSCHEMATC
