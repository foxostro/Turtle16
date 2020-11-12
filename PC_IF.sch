EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr USLetter 11000 8500
encoding utf-8
Sheet 4 89
Title "PC/IF"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 "and the control clock."
Comment3 "This alleviates timing constraints related to the phase shift between the register clock"
Comment4 "The PC/IF register sits between the program counter and the Instruction Fetch stage."
$EndDescr
Text HLabel 3350 4000 0    50   Input ~ 0
PC[0..15]
Text HLabel 6500 4000 2    50   Output ~ 0
PC_IF[0..15]
$Sheet
S 4800 3800 1150 500 
U 5FC6A49F
F0 "sheet5FC6A49A" 50
F1 "SixteenBitPipelineRegister.sch" 50
F2 "D[0..15]" I L 4800 4000 50 
F3 "Q[0..15]" O R 5950 4000 50 
F4 "CP" I L 4800 3900 50 
$EndSheet
Wire Bus Line
	4800 4000 3350 4000
Text HLabel 3350 3650 0    50   Input ~ 0
Phi1
Wire Wire Line
	3350 3650 3850 3650
Wire Bus Line
	6500 4000 5950 4000
NoConn ~ -600 3200
NoConn ~ -600 4700
NoConn ~ -600 5200
$Comp
L 74xx:74LS04 U?
U 7 1 5FC12414
P -1200 6000
AR Path="/5D2C0761/5FC12414" Ref="U?"  Part="7" 
AR Path="/5D2C0720/5FC12414" Ref="U?"  Part="7" 
AR Path="/5D2C07CD/5FC12414" Ref="U?"  Part="7" 
AR Path="/5FE21410/5FC12414" Ref="U96"  Part="7" 
F 0 "U96" H -1200 6050 50  0000 C CNN
F 1 "74AHCT04" H -1200 5950 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -1200 6000 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -1200 6000 50  0001 C CNN
	7    -1200 6000
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 6 1 5FC1241A
P -900 5200
AR Path="/5D8005AF/5D800744/5FC1241A" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC1241A" Ref="U?"  Part="6" 
AR Path="/5D2C07CD/5FC1241A" Ref="U?"  Part="6" 
AR Path="/5FE21410/5FC1241A" Ref="U96"  Part="6" 
F 0 "U96" H -900 5517 50  0000 C CNN
F 1 "74AHCT04" H -900 5426 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -900 5200 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -900 5200 50  0001 C CNN
	6    -900 5200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 2 1 5FC12420
P -900 3200
AR Path="/5D8005AF/5D800744/5FC12420" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC12420" Ref="U?"  Part="2" 
AR Path="/5D2C07CD/5FC12420" Ref="U?"  Part="2" 
AR Path="/5FE21410/5FC12420" Ref="U96"  Part="2" 
F 0 "U96" H -900 3517 50  0000 C CNN
F 1 "74AHCT04" H -900 3426 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -900 3200 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -900 3200 50  0001 C CNN
	2    -900 3200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 5 1 5FC12426
P -900 4700
AR Path="/5D8005AF/5D800744/5FC12426" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC12426" Ref="U?"  Part="5" 
AR Path="/5D2C07CD/5FC12426" Ref="U?"  Part="5" 
AR Path="/5FE21410/5FC12426" Ref="U96"  Part="5" 
F 0 "U96" H -900 5017 50  0000 C CNN
F 1 "74AHCT04" H -900 4926 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -900 4700 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -900 4700 50  0001 C CNN
	5    -900 4700
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 4 1 5FC1242C
P -900 4200
AR Path="/5D8005AF/5D800744/5FC1242C" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC1242C" Ref="U?"  Part="4" 
AR Path="/5D2C07CD/5FC1242C" Ref="U?"  Part="4" 
AR Path="/5FE21410/5FC1242C" Ref="U96"  Part="4" 
F 0 "U96" H -900 4517 50  0000 C CNN
F 1 "74AHCT04" H -900 4426 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -900 4200 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -900 4200 50  0001 C CNN
	4    -900 4200
	1    0    0    -1  
$EndComp
$Comp
L 74xx:74LS04 U?
U 3 1 5FC12432
P -900 3700
AR Path="/5D8005AF/5D800744/5FC12432" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC12432" Ref="U?"  Part="3" 
AR Path="/5D2C07CD/5FC12432" Ref="U?"  Part="3" 
AR Path="/5FE21410/5FC12432" Ref="U96"  Part="3" 
F 0 "U96" H -900 4017 50  0000 C CNN
F 1 "74AHCT04" H -900 3926 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H -900 3700 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H -900 3700 50  0001 C CNN
	3    -900 3700
	1    0    0    -1  
$EndComp
NoConn ~ -600 3700
NoConn ~ -600 4200
$Comp
L power:VCC #PWR?
U 1 1 5FC1243A
P -1200 2300
AR Path="/5D2C0761/5FC1243A" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0720/5FC1243A" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FC1243A" Ref="#PWR?"  Part="1" 
AR Path="/5FE21410/5FC1243A" Ref="#PWR0529"  Part="1" 
F 0 "#PWR0529" H -1200 2150 50  0001 C CNN
F 1 "VCC" H -1183 2473 50  0000 C CNN
F 2 "" H -1200 2300 50  0001 C CNN
F 3 "" H -1200 2300 50  0001 C CNN
	1    -1200 2300
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1200 3200 -1200 3700
Connection ~ -1200 3200
Connection ~ -1200 3700
Wire Wire Line
	-1200 3700 -1200 4200
Connection ~ -1200 4200
Wire Wire Line
	-1200 4200 -1200 4700
Connection ~ -1200 4700
Wire Wire Line
	-1200 4700 -1200 5200
$Comp
L power:GND #PWR?
U 1 1 5FC12448
P -1200 6650
AR Path="/5D2C0720/5FC12448" Ref="#PWR?"  Part="1" 
AR Path="/5D2C0761/5FC12448" Ref="#PWR?"  Part="1" 
AR Path="/5D2C07CD/5FC12448" Ref="#PWR?"  Part="1" 
AR Path="/5FE21410/5FC12448" Ref="#PWR0530"  Part="1" 
F 0 "#PWR0530" H -1200 6400 50  0001 C CNN
F 1 "GND" H -1195 6477 50  0000 C CNN
F 2 "" H -1200 6650 50  0001 C CNN
F 3 "" H -1200 6650 50  0001 C CNN
	1    -1200 6650
	-1   0    0    -1  
$EndComp
Wire Wire Line
	-1200 6500 -1200 6650
Wire Wire Line
	-1200 5200 -1200 5500
Connection ~ -1200 5200
$Comp
L 74xx:74LS04 U?
U 1 1 5FC12452
P 4150 3650
AR Path="/5D8005AF/5D800744/5FC12452" Ref="U?"  Part="6" 
AR Path="/5D2C0720/5FC12452" Ref="U?"  Part="2" 
AR Path="/5D2C07CD/5FC12452" Ref="U?"  Part="1" 
AR Path="/5FE21410/5FC12452" Ref="U96"  Part="1" 
F 0 "U96" H 4150 3967 50  0000 C CNN
F 1 "74AHCT04" H 4150 3876 50  0000 C CNN
F 2 "Package_SO:SOIC-14_3.9x8.7mm_P1.27mm" H 4150 3650 50  0001 C CNN
F 3 "http://www.ti.com/general/docs/suppproductinfo.tsp?distId=26&gotoUrl=http%3A%2F%2Fwww.ti.com%2Flit%2Fgpn%2Fsn74ahct04" H 4150 3650 50  0001 C CNN
	1    4150 3650
	1    0    0    -1  
$EndComp
Wire Wire Line
	-1200 2300 -1200 3200
Wire Wire Line
	4450 3650 4650 3650
Wire Wire Line
	4650 3650 4650 3900
Wire Wire Line
	4650 3900 4800 3900
$EndSCHEMATC
