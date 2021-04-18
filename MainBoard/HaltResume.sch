EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 3 39
Title ""
Date "2021-04-18"
Rev "A (ff236685)"
Comp ""
Comment1 ""
Comment2 ""
Comment3 "Resume execution when the button is pressed, and also on reset."
Comment4 "Pulls the RDY shared line low when the HLT control signal is active."
$EndDescr
Text Notes 4650 3450 0    50   ~ 0
Generate a 22ns negative pulse when the\nResume button is pressed. The debounce\non the button prevents this pulse from\noccurring more frequently than every\n10ms.
$Comp
L power:VCC #PWR?
U 1 1 611BE4DB
P 3600 3400
AR Path="/5D2C07CD/611BE4DB" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611BE4DB" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE4DB" Ref="#PWR038"  Part="1" 
F 0 "#PWR038" H 3600 3250 50  0001 C CNN
F 1 "VCC" H 3617 3573 50  0000 C CNN
F 2 "" H 3600 3400 50  0001 C CNN
F 3 "" H 3600 3400 50  0001 C CNN
	1    3600 3400
	1    0    0    -1  
$EndComp
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
U 1 1 611BE51F
P 3350 3900
AR Path="/5D2C0761/611BE51F" Ref="C?"  Part="1" 
AR Path="/5D2C0720/611BE51F" Ref="C?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE51F" Ref="C13"  Part="1" 
F 0 "C13" V 3100 3850 50  0000 L CNN
F 1 "22pF" V 3200 3850 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric_Pad1.08x0.95mm_HandSolder" H 3388 3750 50  0001 C CNN
F 3 "~" H 3350 3900 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Walsin/0603N220F500CT?qs=ZrPdAQfJ6DPO1aiYBnCCBw%3D%3D" H 3350 3900 50  0001 C CNN "Mouser"
	1    3350 3900
	0    1    1    0   
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
L Device:R_Small R?
U 1 1 611BE540
P 3600 3600
AR Path="/5D2C0720/611BE540" Ref="R?"  Part="1" 
AR Path="/5D2C0720/611B6311/611BE540" Ref="R4"  Part="1" 
F 0 "R4" H 3750 3650 50  0000 C CNN
F 1 "1kΩ" H 3750 3550 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric_Pad0.98x0.95mm_HandSolder" H 3600 3600 50  0001 C CNN
F 3 "~" H 3600 3600 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/652-CR0603FX-1001ELF" V 3600 3600 50  0001 C CNN "Mouser"
	1    3600 3600
	1    0    0    -1  
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
Text HLabel 1700 5300 0    50   Input ~ 0
~RST
Text HLabel 1700 2650 0    50   Input ~ 0
~HLT
Wire Wire Line
	9100 3200 9200 3200
Wire Wire Line
	9200 3200 9200 3450
Wire Wire Line
	9200 3450 8400 3450
Wire Wire Line
	8400 3450 8400 3800
Wire Wire Line
	8400 3800 8500 3800
Wire Wire Line
	8500 3300 8500 3500
Wire Wire Line
	8500 3500 9200 3500
Wire Wire Line
	9200 3500 9200 3900
Wire Wire Line
	9200 3900 9100 3900
Text Notes 8400 3100 0    50   ~ 0
~S
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
Wire Wire Line
	1700 2650 6950 2650
$Comp
L power:VCC #PWR?
U 1 1 607080D9
P -2150 6550
AR Path="/5D2C0761/607080D9" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/607080D9" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/607080D9" Ref="#PWR0482"  Part="1" 
F 0 "#PWR0482" H -2150 6400 50  0001 C CNN
F 1 "VCC" H -2133 6723 50  0000 C CNN
F 2 "" H -2150 6550 50  0001 C CNN
F 3 "" H -2150 6550 50  0001 C CNN
	1    -2150 6550
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR?
U 1 1 6072482A
P -2150 7950
AR Path="/5D2C0720/6072482A" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/6072482A" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/6072482A" Ref="#PWR0483"  Part="1" 
F 0 "#PWR0483" H -2150 7700 50  0001 C CNN
F 1 "GND" H -2145 7777 50  0000 C CNN
F 2 "" H -2150 7950 50  0001 C CNN
F 3 "" H -2150 7950 50  0001 C CNN
	1    -2150 7950
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-2150 7800 -2150 7950
Text Notes 9200 3100 0    50   ~ 0
Q
Text Notes 9200 4100 0    50   ~ 0
~Q
Text Notes 8400 4100 0    50   ~ 0
~R
Wire Wire Line
	6950 3100 6950 2650
Wire Wire Line
	6950 3100 8500 3100
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
	-2150 6550 -2150 6800
Connection ~ 9200 3200
Wire Wire Line
	9200 3200 9800 3200
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
Wire Wire Line
	10400 3200 10500 3200
Text HLabel 10500 3200 2    50   BiDi ~ 0
RDY
$Comp
L 74xx:74LS00 U1
U 5 1 606FD270
P -2150 7300
F 0 "U1" H -1920 7346 50  0000 L CNN
F 1 "74AHCT00" H -1920 7255 50  0000 L CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -2150 7300 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct00" H -2150 7300 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT00PWR?qs=6aLkNDRfRUb50dwtpfIEew%3D%3D" H -2150 7300 50  0001 C CNN "Mouser"
	5    -2150 7300
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS00 U1
U 2 1 606F825C
P 8800 3900
F 0 "U1" H 8800 4225 50  0000 C CNN
F 1 "74AHCT00" H 8800 4134 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 8800 3900 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct00" H 8800 3900 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT00PWR?qs=6aLkNDRfRUb50dwtpfIEew%3D%3D" H 8800 3900 50  0001 C CNN "Mouser"
	2    8800 3900
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS00 U1
U 1 1 606D5A7A
P 8800 3200
F 0 "U1" H 8800 3525 50  0000 C CNN
F 1 "74AHCT00" H 8800 3434 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 8800 3200 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct00" H 8800 3200 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT00PWR?qs=6aLkNDRfRUb50dwtpfIEew%3D%3D" H 8800 3200 50  0001 C CNN "Mouser"
	1    8800 3200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS00 U1
U 3 1 606FA9FD
P 6650 4000
F 0 "U1" H 6650 4325 50  0000 C CNN
F 1 "74AHCT00" H 6650 4234 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 6650 4000 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct00" H 6650 4000 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT00PWR?qs=6aLkNDRfRUb50dwtpfIEew%3D%3D" H 6650 4000 50  0001 C CNN "Mouser"
	3    6650 4000
	1    0    0    -1  
$EndComp
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
$Comp
L 74xx:74LS02 U6
U 1 1 608D9442
P 2850 3900
F 0 "U6" H 2850 4225 50  0000 C CNN
F 1 "74AHCT02" H 2850 4134 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 2850 3900 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT02-1597343.pdf" H 2850 3900 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74AHCT02PW118?qs=P62ublwmbi%252BYbHI0i%2F5Fsw%3D%3D" H 2850 3900 50  0001 C CNN "Mouser"
	1    2850 3900
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS02 U6
U 3 1 608DFCE8
P 4950 3900
F 0 "U6" H 4950 4225 50  0000 C CNN
F 1 "74AHCT02" H 4950 4134 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 4950 3900 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT02-1597343.pdf" H 4950 3900 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74AHCT02PW118?qs=P62ublwmbi%252BYbHI0i%2F5Fsw%3D%3D" H 4950 3900 50  0001 C CNN "Mouser"
	3    4950 3900
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS02 U6
U 4 1 608E2768
P -3950 6500
F 0 "U6" H -3950 6825 50  0000 C CNN
F 1 "74AHCT02" H -3950 6734 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -3950 6500 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT02-1597343.pdf" H -3950 6500 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74AHCT02PW118?qs=P62ublwmbi%252BYbHI0i%2F5Fsw%3D%3D" H -3950 6500 50  0001 C CNN "Mouser"
	4    -3950 6500
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS02 U6
U 5 1 608E53D3
P -4250 7300
F 0 "U6" H -4020 7346 50  0000 L CNN
F 1 "74AHCT02" H -4020 7255 50  0000 L CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H -4250 7300 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT02-1597343.pdf" H -4250 7300 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74AHCT02PW118?qs=P62ublwmbi%252BYbHI0i%2F5Fsw%3D%3D" H -4250 7300 50  0001 C CNN "Mouser"
	5    -4250 7300
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR?
U 1 1 608E76D6
P -4250 4100
AR Path="/5D2C0761/608E76D6" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/608E76D6" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/608E76D6" Ref="#PWR0484"  Part="1" 
F 0 "#PWR0484" H -4250 3950 50  0001 C CNN
F 1 "VCC" H -4233 4273 50  0000 C CNN
F 2 "" H -4250 4100 50  0001 C CNN
F 3 "" H -4250 4100 50  0001 C CNN
	1    -4250 4100
	1    0    0    -1  
$EndComp
Wire Wire Line
	-4250 6400 -4250 6600
Connection ~ -4250 6400
Wire Wire Line
	-4250 6600 -4250 6800
Connection ~ -4250 6600
Wire Wire Line
	-4250 7800 -4250 7950
$Comp
L power:GND #PWR?
U 1 1 608FAAA1
P -4250 7950
AR Path="/5D2C0720/608FAAA1" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/608FAAA1" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/611B6311/608FAAA1" Ref="#PWR0485"  Part="1" 
F 0 "#PWR0485" H -4250 7700 50  0001 C CNN
F 1 "GND" H -4245 7777 50  0000 C CNN
F 2 "" H -4250 7950 50  0001 C CNN
F 3 "" H -4250 7950 50  0001 C CNN
	1    -4250 7950
	-1   0    0    -1  
$EndComp
NoConn ~ -3650 6500
Wire Wire Line
	2550 4000 2500 4000
Wire Wire Line
	2550 3800 2150 3800
Connection ~ 2150 3800
Wire Wire Line
	3150 3900 3200 3900
Wire Wire Line
	2500 4300 4500 4300
Wire Wire Line
	2500 4000 2500 4300
Wire Wire Line
	3600 3700 3600 3900
Wire Wire Line
	3600 3900 3500 3900
Wire Wire Line
	3850 3800 3800 3800
Wire Wire Line
	3800 3800 3800 3900
Wire Wire Line
	3800 4000 3850 4000
Wire Wire Line
	3600 3900 3800 3900
Connection ~ 3600 3900
Connection ~ 3800 3900
Wire Wire Line
	3800 3900 3800 4000
$Comp
L 74xx:74LS02 U6
U 2 1 608DD565
P 4150 3900
F 0 "U6" H 4150 4225 50  0000 C CNN
F 1 "74AHCT02" H 4150 4134 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 4150 3900 50  0001 C CNN
F 3 "https://www.mouser.com/datasheet/2/916/74AHC_AHCT02-1597343.pdf" H 4150 3900 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Nexperia/74AHCT02PW118?qs=P62ublwmbi%252BYbHI0i%2F5Fsw%3D%3D" H 4150 3900 50  0001 C CNN "Mouser"
	2    4150 3900
	1    0    0    -1  
$EndComp
Wire Wire Line
	4500 3900 4450 3900
Wire Wire Line
	4500 3900 4500 4300
Wire Wire Line
	3600 3400 3600 3500
Wire Wire Line
	4500 3900 4600 3900
Wire Wire Line
	4600 3900 4600 3800
Wire Wire Line
	4600 3800 4650 3800
Wire Wire Line
	-4250 4100 -4250 6400
Connection ~ 4500 3900
Wire Wire Line
	4600 3900 4600 4000
Wire Wire Line
	4600 4000 4650 4000
Connection ~ 4600 3900
$Comp
L 74xx:74LS00 U1
U 4 1 606FB718
P 5900 4000
F 0 "U1" H 5900 4325 50  0000 C CNN
F 1 "74AHCT00" H 5900 4234 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 5900 4000 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct00" H 5900 4000 50  0001 C CNN
F 4 "https://www.mouser.com/ProductDetail/Texas-Instruments/SN74AHCT00PWR?qs=6aLkNDRfRUb50dwtpfIEew%3D%3D" H 5900 4000 50  0001 C CNN "Mouser"
	4    5900 4000
	1    0    0    -1  
$EndComp
Wire Wire Line
	5600 3900 5250 3900
Wire Wire Line
	6350 3900 6300 3900
Wire Wire Line
	6300 3900 6300 4000
Wire Wire Line
	6300 4100 6350 4100
Wire Wire Line
	6200 4000 6300 4000
Connection ~ 6300 4000
Wire Wire Line
	6300 4000 6300 4100
Wire Wire Line
	8500 4000 6950 4000
Wire Wire Line
	1700 5300 5350 5300
Wire Wire Line
	5350 5300 5350 4100
Wire Wire Line
	5350 4100 5600 4100
$EndSCHEMATC
