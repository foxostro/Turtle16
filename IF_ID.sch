EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 9 89
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text HLabel 4400 3500 0    50   Input ~ 0
PCIn[0..15]
Text HLabel 6550 3500 2    50   Output ~ 0
PCOut[0..15]
Text HLabel 4400 4250 0    50   Input ~ 0
InsIn[0..15]
Text HLabel 6550 4250 2    50   Output ~ 0
InsOut[0..15]
$Sheet
S 4900 3300 1150 500 
U 5FC6FC04
F0 "sheet5FC6FBFF" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 4900 3500 50 
F3 "Q[0..15]" O R 6050 3500 50 
F4 "CP" I L 4900 3400 50 
$EndSheet
Wire Bus Line
	4900 3500 4400 3500
Text HLabel 1900 3400 0    50   Input ~ 0
Phi1
Wire Wire Line
	1900 3400 2400 3400
Wire Bus Line
	6550 3500 6050 3500
$Sheet
S 4900 4050 1150 500 
U 5FC806D1
F0 "sheet5FC806CA" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 4900 4250 50 
F3 "Q[0..15]" O R 6050 4250 50 
F4 "CP" I L 4900 4150 50 
$EndSheet
Wire Bus Line
	4900 4250 4400 4250
Wire Bus Line
	6550 4250 6050 4250
NoConn ~ -400 3100
NoConn ~ -400 4600
NoConn ~ -400 5100
$Comp
L 74xx:74LS04 U?
U 7 1 5FC18B04
P -1000 5900
AR Path="/5D2C0761/5FC18B04" Ref="U?"  Part="7" 
AR Path="/5D2C0720/5FC18B04" Ref="U?"  Part="7" 
AR Path="/5D2C07CD/5FC18B04" Ref="U?"  Part="7" 
AR Path="/5FE8EB3D/5FC18B04" Ref="U?"  Part="7" 
F 0 "U?" H -1000 5950 50  0000 C CNN
F 1 "74AHCT04" H -1000 5850 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -1000 5900 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -1000 5900 50  0001 C CNN
	7    -1000 5900
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 6 1 5FC18B0A
P -700 5100
AR Path="/5D8005AF/5D800744/5FC18B0A" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC18B0A" Ref="U?"  Part="6" 
AR Path="/5D2C07CD/5FC18B0A" Ref="U?"  Part="6" 
AR Path="/5FE8EB3D/5FC18B0A" Ref="U?"  Part="6" 
F 0 "U?" H -700 5417 50  0000 C CNN
F 1 "74AHCT04" H -700 5326 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -700 5100 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -700 5100 50  0001 C CNN
	6    -700 5100
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 2 1 5FC18B10
P -700 3100
AR Path="/5D8005AF/5D800744/5FC18B10" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC18B10" Ref="U?"  Part="2" 
AR Path="/5D2C07CD/5FC18B10" Ref="U?"  Part="2" 
AR Path="/5FE8EB3D/5FC18B10" Ref="U?"  Part="2" 
F 0 "U?" H -700 3417 50  0000 C CNN
F 1 "74AHCT04" H -700 3326 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -700 3100 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -700 3100 50  0001 C CNN
	2    -700 3100
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 5 1 5FC18B16
P -700 4600
AR Path="/5D8005AF/5D800744/5FC18B16" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC18B16" Ref="U?"  Part="5" 
AR Path="/5D2C07CD/5FC18B16" Ref="U?"  Part="5" 
AR Path="/5FE8EB3D/5FC18B16" Ref="U?"  Part="5" 
F 0 "U?" H -700 4917 50  0000 C CNN
F 1 "74AHCT04" H -700 4826 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -700 4600 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -700 4600 50  0001 C CNN
	5    -700 4600
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 4 1 5FC18B1C
P -700 4100
AR Path="/5D8005AF/5D800744/5FC18B1C" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC18B1C" Ref="U?"  Part="4" 
AR Path="/5D2C07CD/5FC18B1C" Ref="U?"  Part="4" 
AR Path="/5FE8EB3D/5FC18B1C" Ref="U?"  Part="4" 
F 0 "U?" H -700 4417 50  0000 C CNN
F 1 "74AHCT04" H -700 4326 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -700 4100 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -700 4100 50  0001 C CNN
	4    -700 4100
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 3 1 5FC18B22
P -700 3600
AR Path="/5D8005AF/5D800744/5FC18B22" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC18B22" Ref="U?"  Part="3" 
AR Path="/5D2C07CD/5FC18B22" Ref="U?"  Part="3" 
AR Path="/5FE8EB3D/5FC18B22" Ref="U?"  Part="3" 
F 0 "U?" H -700 3917 50  0000 C CNN
F 1 "74AHCT04" H -700 3826 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -700 3600 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -700 3600 50  0001 C CNN
	3    -700 3600
	1    0    0    -1  
$EndComp
NoConn ~ -400 3600
NoConn ~ -400 4100
$Comp
L power:VCC #PWR?
U 1 1 5FC18B2A
P -1000 2200
AR Path="/5D2C0761/5FC18B2A" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5FC18B2A" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FC18B2A" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/5FC18B2A" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H -1000 2050 50  0001 C CNN
F 1 "VCC" H -983 2373 50  0000 C CNN
F 2 "" H -1000 2200 50  0001 C CNN
F 3 "" H -1000 2200 50  0001 C CNN
	1    -1000 2200
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1000 3100 -1000 3600
Connection ~ -1000 3100
Connection ~ -1000 3600
Wire Wire Line
	-1000 3600 -1000 4100
Connection ~ -1000 4100
Wire Wire Line
	-1000 4100 -1000 4600
Connection ~ -1000 4600
Wire Wire Line
	-1000 4600 -1000 5100
$Comp
L power:GND #PWR?
U 1 1 5FC18B38
P -1000 6550
AR Path="/5D2C0720/5FC18B38" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/5FC18B38" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FC18B38" Ref="#PWR?"  Part="1" 
AR Path="/5FE8EB3D/5FC18B38" Ref="#PWR?"  Part="1" 
F 0 "#PWR?" H -1000 6300 50  0001 C CNN
F 1 "GND" H -995 6377 50  0000 C CNN
F 2 "" H -1000 6550 50  0001 C CNN
F 3 "" H -1000 6550 50  0001 C CNN
	1    -1000 6550
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-1000 6400 -1000 6550
Wire Wire Line
	-1000 5100 -1000 5400
Connection ~ -1000 5100
$Comp
L 74xx:74LS04 U?
U 1 1 5FC18B42
P 2700 3400
AR Path="/5D8005AF/5D800744/5FC18B42" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC18B42" Ref="U?"  Part="2" 
AR Path="/5D2C07CD/5FC18B42" Ref="U?"  Part="1" 
AR Path="/5FE8EB3D/5FC18B42" Ref="U?"  Part="1" 
F 0 "U?" H 2700 3717 50  0000 C CNN
F 1 "74AHCT04" H 2700 3626 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 2700 3400 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 2700 3400 50  0001 C CNN
	1    2700 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1000 2200 -1000 3100
Wire Wire Line
	3000 3400 4800 3400
Wire Wire Line
	4800 3400 4800 4150
Connection ~ 4800 3400
Wire Wire Line
	4800 3400 4900 3400
Wire Wire Line
	4800 4150 4900 4150
$EndSCHEMATC
