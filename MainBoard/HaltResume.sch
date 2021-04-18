EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 3 39
Title ""
Date "2021-04-18"
Rev "A (34c8551e)"
Comp ""
Comment1 ""
Comment2 ""
Comment3 "Resume execution when the button is pressed, and also on reset."
Comment4 "Pulls the RDY shared line low when the HLT control signal is active."
$EndDescr
$Comp
L power:GND #PWR?
U 1 1 611BE4E1
P 1950 4350
AR Path="/5D2C0761/611BE4E1" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611BE4E1" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE4E1" Ref="#PWR039"  Part="1" 
F 0 "#PWR039" H 1950 4100 50  0001 C CNN
F 1 "GND" H 1955 4177 50  0000 C CNN
F 2 "" H 1950 4350 50  0001 C CNN
F 3 "" H 1950 4350 50  0001 C CNN
	1    1950 4350
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 611BE4EA
P 1150 3800
AR Path="/5D2C0720/611BE4EA" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE4EA" Ref="#PWR037"  Part="1" 
F 0 "#PWR037" H 1150 3650 50  0001 C CNN
F 1 "VCC" V 1168 3927 50  0000 L CNN
F 2 "" H 1150 3800 50  0001 C CNN
F 3 "" H 1150 3800 50  0001 C CNN
	1    1150 3800
	0    -1   -1   0   
$EndComp
Wire Wire Line
	1150 3800 1200 3800
Wire Wire Line
	1950 4300 1950 4350
$Comp
L Device:R_Small R?
U 1 1 611BE516
P 1750 4050
AR Path="/5D2C0720/611BE516" Ref="R?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE516" Ref="R6"  Part="1" 
F 0 "R6" H 1809 4096 50  0000 L CNN
F 1 "1kΩ" H 1809 4005 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 1750 4050 50  0001 C CNN
F 3 "~" H 1750 4050 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1001ELF" H 1750 4050 50  0001 C CNN "Mouser"
	1    1750 4050
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 611BE533
P 2150 4050
AR Path="/5D2C0761/611BE533" Ref="C?"  Part="1" 
AR Path="/5D2C0720/611BE533" Ref="C?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE533" Ref="C9"  Part="1" 
F 0 "C9" H 1900 4100 50  0000 L CNN
F 1 "10uF" H 1850 4000 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 2188 3900 50  0001 C CNN
F 3 "~" H 2150 4050 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Walsin/0603X106K100CT?qs=ZrPdAQfJ6DPmkZ8840O9Sg%3D%3D" H 2150 4050 50  0001 C CNN "Mouser"
	1    2150 4050
	-1   0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW?
U 1 1 611BE548
P 1400 3800
AR Path="/5D2C0761/611BE548" Ref="SW?"  Part="1" 
AR Path="/5D2C0720/611BE548" Ref="SW?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE548" Ref="SW2"  Part="1" 
F 0 "SW2" H 1450 4150 50  0000 R CNN
F 1 "Resume" H 1500 4050 50  0000 R CNN
F 2 "Button_Switch_THT:SW_PUSH_6mm_H5mm" H 1400 4000 50  0001 C CNN
F 3 "~" H 1400 4000 50  0001 C CNN
	1    1400 3800
	1    0    0    -1  
$EndComp
Text HLabel 1700 2250 0    50   Input ~ 0
~RST
Text HLabel 1700 2650 0    50   Input ~ 0
~HLT
$Comp
L power:GND #PWR?
U 1 1 604BDFE5
P 900 7350
AR Path="/5D2C0761/604BDFE5" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/604BDFE5" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/604BDFE5" Ref="#PWR036"  Part="1" 
F 0 "#PWR036" H 900 7100 50  0001 C CNN
F 1 "GND" H 905 7177 50  0000 C CNN
F 2 "" H 900 7350 50  0001 C CNN
F 3 "" H 900 7350 50  0001 C CNN
	1    900  7350
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 604BDFEB
P 900 6850
AR Path="/5D2C0761/604BDFEB" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/604BDFEB" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/604BDFEB" Ref="#PWR035"  Part="1" 
F 0 "#PWR035" H 900 6700 50  0001 C CNN
F 1 "VCC" H 917 7023 50  0000 C CNN
F 2 "" H 900 6850 50  0001 C CNN
F 3 "" H 900 6850 50  0001 C CNN
	1    900  6850
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 604BDFF9
P 1900 7100
AR Path="/5D2C0761/604BDFF9" Ref="C?"  Part="1" 
AR Path="/5D2C0720/604BDFF9" Ref="C?"  Part="1" 
AR Path="/5D2C0720/611B6311/604BDFF9" Ref="C8"  Part="1" 
F 0 "C8" H 2015 7146 50  0000 L CNN
F 1 "100nF" H 2015 7055 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 1938 6950 50  0001 C CNN
F 3 "~" H 1900 7100 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 1900 7100 50  0001 C CNN "Mouser"
	1    1900 7100
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 604BE004
P 1400 7100
AR Path="/5D2C0761/604BE004" Ref="C?"  Part="1" 
AR Path="/5D2C0720/604BE004" Ref="C?"  Part="1" 
AR Path="/5D2C0720/611B6311/604BE004" Ref="C7"  Part="1" 
F 0 "C7" H 1515 7146 50  0000 L CNN
F 1 "100nF" H 1515 7055 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 1438 6950 50  0001 C CNN
F 3 "~" H 1400 7100 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 1400 7100 50  0001 C CNN "Mouser"
	1    1400 7100
	1    0    0    -1  
$EndComp
Wire Wire Line
	1400 6950 1900 6950
Wire Wire Line
	1900 7250 1400 7250
$Comp
L Device:C C?
U 1 1 604BE00D
P 900 7100
AR Path="/5D2C0761/604BE00D" Ref="C?"  Part="1" 
AR Path="/5D2C0720/604BE00D" Ref="C?"  Part="1" 
AR Path="/5D2C0720/611B6311/604BE00D" Ref="C6"  Part="1" 
F 0 "C6" H 1015 7146 50  0000 L CNN
F 1 "100nF" H 1015 7055 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 938 6950 50  0001 C CNN
F 3 "~" H 900 7100 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 900 7100 50  0001 C CNN "Mouser"
	1    900  7100
	1    0    0    -1  
$EndComp
Wire Wire Line
	900  6950 1400 6950
Wire Wire Line
	1400 7250 900  7250
Wire Wire Line
	900  6850 900  6950
Connection ~ 900  6950
Wire Wire Line
	900  7250 900  7350
Connection ~ 900  7250
Connection ~ 1400 6950
Connection ~ 1400 7250
$Comp
L 74xx:74LS05 U5
U 7 1 605F9382
P -3200 7300
F 0 "U5" H -2970 7346 50  0000 L CNN
F 1 "74AHCT05" H -2970 7255 50  0000 L CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -3200 7300 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/308/MM74HCT05-D-1811504.pdf" H -3200 7300 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/ON-Semiconductor-Fairchild/MM74HCT05MTC?qs=7qg%2FUSZkK84HVNk73cLWQw%3D%3D" H -3200 7300 50  0001 C CNN "Mouser"
	7    -3200 7300
	1    0    0    -1  
$EndComp
Wire Wire Line
	-3200 7800 -3200 7950
$Comp
L power:GND #PWR?
U 1 1 605F9350
P -3200 7950
AR Path="/5D2C0720/605F9350" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/605F9350" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/605F9350" Ref="#PWR028"  Part="1" 
F 0 "#PWR028" H -3200 7700 50  0001 C CNN
F 1 "GND" H -3195 7777 50  0000 C CNN
F 2 "" H -3200 7950 50  0001 C CNN
F 3 "" H -3200 7950 50  0001 C CNN
	1    -3200 7950
	-1   0    0    -1  
$EndComp
NoConn ~ -2600 4550
NoConn ~ -2600 5050
NoConn ~ -2600 5550
NoConn ~ -2600 6100
NoConn ~ -2600 6600
$Comp
L power:VCC #PWR?
U 1 1 605F9388
P -3200 4150
AR Path="/5D2C0761/605F9388" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/605F9388" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/605F9388" Ref="#PWR027"  Part="1" 
F 0 "#PWR027" H -3200 4000 50  0001 C CNN
F 1 "VCC" H -3183 4323 50  0000 C CNN
F 2 "" H -3200 4150 50  0001 C CNN
F 3 "" H -3200 4150 50  0001 C CNN
	1    -3200 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	-3200 6600 -3200 6800
Connection ~ -3200 6600
$Comp
L 74xx:74LS05 U5
U 6 1 605F937B
P -2900 6600
F 0 "U5" H -2900 6917 50  0000 C CNN
F 1 "74AHCT05" H -2900 6826 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -2900 6600 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/308/MM74HCT05-D-1811504.pdf" H -2900 6600 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/ON-Semiconductor-Fairchild/MM74HCT05MTC?qs=7qg%2FUSZkK84HVNk73cLWQw%3D%3D" H -2900 6600 50  0001 C CNN "Mouser"
	6    -2900 6600
	1    0    0    -1  
$EndComp
Wire Wire Line
	-3200 6100 -3200 6600
Connection ~ -3200 6100
$Comp
L 74xx:74LS05 U5
U 5 1 605F9374
P -2900 6100
F 0 "U5" H -2900 6417 50  0000 C CNN
F 1 "74AHCT05" H -2900 6326 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -2900 6100 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/308/MM74HCT05-D-1811504.pdf" H -2900 6100 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/ON-Semiconductor-Fairchild/MM74HCT05MTC?qs=7qg%2FUSZkK84HVNk73cLWQw%3D%3D" H -2900 6100 50  0001 C CNN "Mouser"
	5    -2900 6100
	1    0    0    -1  
$EndComp
Wire Wire Line
	-3200 5550 -3200 6100
Connection ~ -3200 5550
$Comp
L 74xx:74LS05 U5
U 4 1 605F936D
P -2900 5550
F 0 "U5" H -2900 5867 50  0000 C CNN
F 1 "74AHCT05" H -2900 5776 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -2900 5550 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/308/MM74HCT05-D-1811504.pdf" H -2900 5550 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/ON-Semiconductor-Fairchild/MM74HCT05MTC?qs=7qg%2FUSZkK84HVNk73cLWQw%3D%3D" H -2900 5550 50  0001 C CNN "Mouser"
	4    -2900 5550
	1    0    0    -1  
$EndComp
Wire Wire Line
	-3200 5050 -3200 5550
Connection ~ -3200 5050
$Comp
L 74xx:74LS05 U5
U 3 1 605F9366
P -2900 5050
F 0 "U5" H -2900 5367 50  0000 C CNN
F 1 "74AHCT05" H -2900 5276 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -2900 5050 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/308/MM74HCT05-D-1811504.pdf" H -2900 5050 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/ON-Semiconductor-Fairchild/MM74HCT05MTC?qs=7qg%2FUSZkK84HVNk73cLWQw%3D%3D" H -2900 5050 50  0001 C CNN "Mouser"
	3    -2900 5050
	1    0    0    -1  
$EndComp
Wire Wire Line
	-3200 4150 -3200 4550
Wire Wire Line
	-3200 4550 -3200 5050
Connection ~ -3200 4550
$Comp
L 74xx:74LS05 U5
U 2 1 605F935F
P -2900 4550
F 0 "U5" H -2900 4867 50  0000 C CNN
F 1 "74AHCT05" H -2900 4776 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -2900 4550 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/308/MM74HCT05-D-1811504.pdf" H -2900 4550 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/ON-Semiconductor-Fairchild/MM74HCT05MTC?qs=7qg%2FUSZkK84HVNk73cLWQw%3D%3D" H -2900 4550 50  0001 C CNN "Mouser"
	2    -2900 4550
	1    0    0    -1  
$EndComp
Wire Wire Line
	10400 3200 10500 3200
Text HLabel 10500 3200 2    50   BiDi ~ 0
RDY
Wire Wire Line
	1600 3800 1750 3800
Wire Wire Line
	2150 3800 2150 3900
Wire Wire Line
	1750 3950 1750 3800
Wire Wire Line
	1750 3800 2150 3800
Wire Wire Line
	2150 4200 2150 4300
Wire Wire Line
	2150 4300 1950 4300
Wire Wire Line
	1750 4300 1750 4150
Wire Wire Line
	1950 4300 1750 4300
Connection ~ 1750 3800
Connection ~ 1950 4300
Wire Wire Line
	3200 3800 2150 3800
Connection ~ 2150 3800
$Comp
L 74xx:74LS574 U58
U 1 1 607D640B
P 3700 4300
F 0 "U58" H 3950 5100 50  0000 C CNN
F 1 "74AHCT574" H 3950 5000 50  0000 C CNN
F 2 "Package_SO:TSSOP-20_4.4x6.5mm_P0.65mm" H 3700 4300 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT574-1597535.pdf" H 3700 4300 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT5PW112" H 3700 4300 50  0001 C CNN "Mouser"
	1    3700 4300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS05 U5
U 1 1 605F9358
P 10100 3200
F 0 "U5" H 10100 3517 50  0000 C CNN
F 1 "74AHCT05" H 10100 3426 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 10100 3200 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/308/MM74HCT05-D-1811504.pdf" H 10100 3200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/ON-Semiconductor-Fairchild/MM74HCT05MTC?qs=7qg%2FUSZkK84HVNk73cLWQw%3D%3D" H 10100 3200 50  0001 C CNN "Mouser"
	1    10100 3200
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 607F0ADE
P -2050 6000
AR Path="/5D2C0761/607F0ADE" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/607F0ADE" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/607F0ADE" Ref="#PWR0424"  Part="1" 
F 0 "#PWR0424" H -2050 5850 50  0001 C CNN
F 1 "VCC" H -2033 6173 50  0000 C CNN
F 2 "" H -2050 6000 50  0001 C CNN
F 3 "" H -2050 6000 50  0001 C CNN
	1    -2050 6000
	1    0    0    -1  
$EndComp
Wire Wire Line
	-2050 6000 -2050 6400
$Comp
L power:GND #PWR?
U 1 1 607F2455
P -2050 7950
AR Path="/5D2C0720/607F2455" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/607F2455" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/607F2455" Ref="#PWR0425"  Part="1" 
F 0 "#PWR0425" H -2050 7700 50  0001 C CNN
F 1 "GND" H -2045 7777 50  0000 C CNN
F 2 "" H -2050 7950 50  0001 C CNN
F 3 "" H -2050 7950 50  0001 C CNN
	1    -2050 7950
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-2050 7800 -2050 7950
Text HLabel 3000 4700 0    50   Input ~ 0
Phi1_0
$Comp
L power:VCC #PWR?
U 1 1 6080978E
P 3700 3450
AR Path="/5D2C0761/6080978E" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/6080978E" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/6080978E" Ref="#PWR0426"  Part="1" 
F 0 "#PWR0426" H 3700 3300 50  0001 C CNN
F 1 "VCC" H 3717 3623 50  0000 C CNN
F 2 "" H 3700 3450 50  0001 C CNN
F 3 "" H 3700 3450 50  0001 C CNN
	1    3700 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	3700 3450 3700 3500
$Comp
L power:GND #PWR?
U 1 1 60809E2A
P 3700 5250
AR Path="/5D2C0720/60809E2A" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/60809E2A" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/60809E2A" Ref="#PWR0427"  Part="1" 
F 0 "#PWR0427" H 3700 5000 50  0001 C CNN
F 1 "GND" H 3705 5077 50  0000 C CNN
F 2 "" H 3700 5250 50  0001 C CNN
F 3 "" H 3700 5250 50  0001 C CNN
	1    3700 5250
	-1   0    0    -1  
$EndComp
Wire Wire Line
	3700 5100 3700 5250
$Comp
L power:GND #PWR0428
U 1 1 6080B5EA
P 3050 4800
F 0 "#PWR0428" H 3050 4550 50  0001 C CNN
F 1 "GND" V 3055 4672 50  0000 R CNN
F 2 "" H 3050 4800 50  0001 C CNN
F 3 "" H 3050 4800 50  0001 C CNN
	1    3050 4800
	0    1    1    0   
$EndComp
Wire Wire Line
	3200 4800 3050 4800
Wire Wire Line
	3200 4700 3000 4700
Text Label 4300 3800 0    50   ~ 0
Button1
Text Label 2800 3900 0    50   ~ 0
Button1
Wire Wire Line
	3200 3900 2800 3900
Wire Wire Line
	4200 3900 4650 3900
Wire Wire Line
	4650 3900 4650 4200
Wire Wire Line
	4650 4200 4750 4200
Wire Wire Line
	3200 4000 3150 4000
Wire Wire Line
	3150 4000 3150 4100
Wire Wire Line
	3150 4500 3200 4500
Wire Wire Line
	3200 4400 3150 4400
Connection ~ 3150 4400
Wire Wire Line
	3150 4400 3150 4500
Wire Wire Line
	3200 4300 3150 4300
Connection ~ 3150 4300
Wire Wire Line
	3150 4300 3150 4400
Wire Wire Line
	3200 4200 3150 4200
Connection ~ 3150 4200
Wire Wire Line
	3150 4200 3150 4300
Wire Wire Line
	3200 4100 3150 4100
Connection ~ 3150 4100
Wire Wire Line
	3150 4100 3150 4200
$Comp
L power:GND #PWR0429
U 1 1 6081A4BE
P 3000 4200
F 0 "#PWR0429" H 3000 3950 50  0001 C CNN
F 1 "GND" V 3005 4072 50  0000 R CNN
F 2 "" H 3000 4200 50  0001 C CNN
F 3 "" H 3000 4200 50  0001 C CNN
	1    3000 4200
	0    1    1    0   
$EndComp
Wire Wire Line
	3150 4200 3000 4200
NoConn ~ 4200 4000
NoConn ~ 4200 4100
NoConn ~ 4200 4200
NoConn ~ 4200 4300
NoConn ~ 4200 4400
NoConn ~ 4200 4500
Wire Wire Line
	5350 4200 5450 4200
Wire Wire Line
	5450 4200 5450 4100
Wire Wire Line
	5450 4100 5550 4100
Wire Wire Line
	5450 3800 5450 3900
Wire Wire Line
	5450 3900 5550 3900
Wire Wire Line
	4200 3800 5450 3800
Wire Wire Line
	6150 4000 6300 4000
Wire Wire Line
	1700 2650 2150 2650
Wire Wire Line
	2750 2650 4300 2650
Wire Wire Line
	4300 2650 4300 2550
Wire Wire Line
	4300 2550 4350 2550
Wire Wire Line
	4300 2250 4300 2350
Wire Wire Line
	4300 2350 4350 2350
Wire Wire Line
	1700 2250 4300 2250
Wire Wire Line
	6900 4000 7750 4000
Wire Wire Line
	7750 4000 7750 3300
Wire Wire Line
	7750 3300 7950 3300
Wire Wire Line
	7950 3100 7750 3100
Wire Wire Line
	7750 3100 7750 2450
Wire Wire Line
	7750 2450 4950 2450
Wire Wire Line
	8550 3200 9800 3200
$Comp
L 74xx:74LS08 U1
U 1 1 60856190
P 4650 2450
F 0 "U1" H 4650 2775 50  0000 C CNN
F 1 "74AHCT08" H 4650 2684 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 4650 2450 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct08" H 4650 2450 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/595-SN74AHCT08PW" H 4650 2450 50  0001 C CNN "Mouser"
	1    4650 2450
	1    0    0    -1  
$EndComp
Wire Wire Line
	-2000 6400 -2050 6400
Connection ~ -2050 6400
Wire Wire Line
	-2050 6400 -2050 6600
Wire Wire Line
	-2000 6600 -2050 6600
Connection ~ -2050 6600
Wire Wire Line
	-2050 6600 -2050 6800
NoConn ~ -1400 6500
$Comp
L 74xx:74LS08 U1
U 5 1 60853B63
P -2050 7300
F 0 "U1" H -1820 7346 50  0000 L CNN
F 1 "74AHCT08" H -1820 7255 50  0000 L CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -2050 7300 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct08" H -2050 7300 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/595-SN74AHCT08PW" H -2050 7300 50  0001 C CNN "Mouser"
	5    -2050 7300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U1
U 2 1 60856C2F
P 8250 3200
F 0 "U1" H 8250 3525 50  0000 C CNN
F 1 "74AHCT08" H 8250 3434 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 8250 3200 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct08" H 8250 3200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/595-SN74AHCT08PW" H 8250 3200 50  0001 C CNN "Mouser"
	2    8250 3200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U1
U 3 1 60857C47
P 5850 4000
F 0 "U1" H 5850 4325 50  0000 C CNN
F 1 "74AHCT08" H 5850 4234 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 5850 4000 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct08" H 5850 4000 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/595-SN74AHCT08PW" H 5850 4000 50  0001 C CNN "Mouser"
	3    5850 4000
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS08 U1
U 4 1 60858D26
P -1700 6500
F 0 "U1" H -1700 6825 50  0000 C CNN
F 1 "74AHCT08" H -1700 6734 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -1700 6500 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct08" H -1700 6500 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/595-SN74AHCT08PW" H -1700 6500 50  0001 C CNN "Mouser"
	4    -1700 6500
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U6
U 1 1 607CE4F3
P 2450 2650
F 0 "U6" H 2450 2967 50  0000 C CNN
F 1 "74AHCT04" H 2450 2876 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 2450 2650 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT04-1597573.pdf" H 2450 2650 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H 2450 2650 50  0001 C CNN "Mouser"
	1    2450 2650
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U6
U 2 1 607D3CE3
P 5050 4200
F 0 "U6" H 5050 4517 50  0000 C CNN
F 1 "74AHCT04" H 5050 4426 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 5050 4200 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT04-1597573.pdf" H 5050 4200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H 5050 4200 50  0001 C CNN "Mouser"
	2    5050 4200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U6
U 3 1 607D4986
P 6600 4000
F 0 "U6" H 6600 4317 50  0000 C CNN
F 1 "74AHCT04" H 6600 4226 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 6600 4000 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT04-1597573.pdf" H 6600 4000 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H 6600 4000 50  0001 C CNN "Mouser"
	3    6600 4000
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U6
U 4 1 607D5343
P -700 5550
F 0 "U6" H -700 5867 50  0000 C CNN
F 1 "74AHCT04" H -700 5776 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -700 5550 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT04-1597573.pdf" H -700 5550 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -700 5550 50  0001 C CNN "Mouser"
	4    -700 5550
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U6
U 5 1 607D5B2A
P -700 6100
F 0 "U6" H -700 6417 50  0000 C CNN
F 1 "74AHCT04" H -700 6326 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -700 6100 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT04-1597573.pdf" H -700 6100 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -700 6100 50  0001 C CNN "Mouser"
	5    -700 6100
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U6
U 6 1 607D60B5
P -700 6650
F 0 "U6" H -700 6967 50  0000 C CNN
F 1 "74AHCT04" H -700 6876 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -700 6650 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT04-1597573.pdf" H -700 6650 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -700 6650 50  0001 C CNN "Mouser"
	6    -700 6650
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U6
U 7 1 607D6562
P -1050 7350
F 0 "U6" H -600 7450 50  0000 C CNN
F 1 "74AHCT04" H -600 7350 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -1050 7350 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT04-1597573.pdf" H -1050 7350 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/771-AHCT04PW112" H -1050 7350 50  0001 C CNN "Mouser"
	7    -1050 7350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 607D8274
P -1050 8000
AR Path="/5D2C0720/607D8274" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/607D8274" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/607D8274" Ref="#PWR0430"  Part="1" 
F 0 "#PWR0430" H -1050 7750 50  0001 C CNN
F 1 "GND" H -1045 7827 50  0000 C CNN
F 2 "" H -1050 8000 50  0001 C CNN
F 3 "" H -1050 8000 50  0001 C CNN
	1    -1050 8000
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-1050 7850 -1050 8000
$Comp
L power:VCC #PWR?
U 1 1 607DB29D
P -1050 5050
AR Path="/5D2C0761/607DB29D" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/607DB29D" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/607DB29D" Ref="#PWR0431"  Part="1" 
F 0 "#PWR0431" H -1050 4900 50  0001 C CNN
F 1 "VCC" H -1033 5223 50  0000 C CNN
F 2 "" H -1050 5050 50  0001 C CNN
F 3 "" H -1050 5050 50  0001 C CNN
	1    -1050 5050
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1050 5050 -1050 5550
Wire Wire Line
	-1000 5550 -1050 5550
Connection ~ -1050 5550
Wire Wire Line
	-1050 5550 -1050 6100
Wire Wire Line
	-1000 6100 -1050 6100
Connection ~ -1050 6100
Wire Wire Line
	-1050 6100 -1050 6650
Wire Wire Line
	-1000 6650 -1050 6650
Connection ~ -1050 6650
Wire Wire Line
	-1050 6650 -1050 6850
NoConn ~ -400 5550
NoConn ~ -400 6100
NoConn ~ -400 6650
$Comp
L Device:C C?
U 1 1 607F4A72
P 2400 7100
AR Path="/5D2C0761/607F4A72" Ref="C?"  Part="1" 
AR Path="/5D2C0720/607F4A72" Ref="C?"  Part="1" 
AR Path="/5D2C0720/611B6311/607F4A72" Ref="C13"  Part="1" 
F 0 "C13" H 2515 7146 50  0000 L CNN
F 1 "100nF" H 2515 7055 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 2438 6950 50  0001 C CNN
F 3 "~" H 2400 7100 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/963-EMK107B7104KAHT" H 2400 7100 50  0001 C CNN "Mouser"
	1    2400 7100
	1    0    0    -1  
$EndComp
Wire Wire Line
	1900 6950 2400 6950
Wire Wire Line
	2400 7250 1900 7250
$EndSCHEMATC
