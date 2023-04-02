#include <stdio.h>
#include "TestFramework.h"
#include "ShiftRegisterIO.h"
#include "BusIO.h"
#include "MEMModuleTestFixtureIO.h"
#include "LEDPattern.h"

const BusInputPorts busInputPorts = {
  .PL = 18,
  .SCK = 19,
  .SO = 20
};

const BusOutputPorts busOutputPorts = {
  .SI = 17,
  .RCLK = 16,
  .SCK = 15,
  .CLR = 14
};

const TestFixtureInputPorts testFixtureInputPorts = {
  .PL = 8,
  .SCK = 7,
  .SO = 6
};

const TestFixtureOutputPorts testFixtureOutputPorts = {
  .SI = 2,
  .RCLK = 3,
  .SCK = 4,
  .CLR = 5
};

void testReset(unsigned ledState) {
  printf("%s: ", __FUNCTION__);
  printf("Testing reset function...");

  // Assert the reset line
  BusOutputs busOutputs = {
    .MemLoad = 1,
    .MemStore = 1,
    .Bank = 0,
    .Addr = 0,
    .IO = 0,
    .OE = ~0 // Do not assert any bits to the bus
  };
  TestFixtureOutputs testFixtureOutputs = {
    .PC_MEM = 0x0000,
    .Y_MEM = 0x0000,
    .StoreOp_MEM = 0x0000,
    .led = ledState,
    .Ctl_MEM = 0b1111111,
    .SelC_MEM = 0b000,
    .rdy = 1, // not ready
    .rst = 0, // Reset cycle
    .phi1 = 0,
    .phi2 = 0,
    .flush_if = 1,
  };
  busOutputPorts.set(busOutputs);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs.phi1 = 1;
  testFixtureOutputs.phi2 = 1;
  testFixtureOutputPorts.set(testFixtureOutputs);
  testFixtureOutputs.phi1 = 0;
  testFixtureOutputs.phi2 = 0;
  testFixtureOutputPorts.set(testFixtureOutputs);

  // De-assert the reset line
  testFixtureOutputs.rst = 1;
  testFixtureOutputPorts.set(testFixtureOutputs);
  
  BusInputs actualBusInputs = busInputPorts.read();
  assertEqual(0, actualBusInputs.Bank, "Expect that Bank is zero after reset.");
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0b1111, actualTestFixtureInputs.Ctl_WB, "Expect that no control signals are asserted.");

  printf("passed\n");
}

void testNop(unsigned ledState) {
  printf("%s: ", __FUNCTION__);
  printf("Put a NOP through the MEM stage and check what it outputs to the text fixture...");

  BusOutputs busOutputs = {
    .MemLoad = 1,
    .MemStore = 1,
    .Bank = 0,
    .Addr = 0,
    .IO = 0,
    .OE = ~0 // Do not assert any bits to the bus
  };
  TestFixtureOutputs testFixtureOutputs = {
    .PC_MEM = 0x0000,
    .Y_MEM = 0x0000,
    .StoreOp_MEM = 0x0000,
    .led = ledState,
    .Ctl_MEM = 0b1111111,
    .SelC_MEM = 0b111,
    .rdy = 0, // is ready
    .rst = 1,
    .phi1 = 1,
    .phi2 = 1,
    .flush_if = 1,
  };
  busOutputPorts.set(busOutputs);
  testFixtureOutputPorts.set(testFixtureOutputs);

  BusInputs actualBusInputs = busInputPorts.read();
  assertEqual(0, actualBusInputs.Bank, "Expect that bank was zero.");
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0b1111, actualTestFixtureInputs.Ctl_WB, "Expect that no control signals are asserted.");
  assertEqual(0b111, actualTestFixtureInputs.SelC_WB, "Expect that SelC is passed through unmodified.");

  printf("passed\n");
}

void testWriteRAM(unsigned ledState) {
  printf("%s: ", __FUNCTION__);
  printf("Store to RAM from the system memory bus while MEM is held in a wait state...");

  // Set signals to put MEM into a Wait state.
  // This ought to effectively disonnect MEM from the bus.
  TestFixtureOutputs testFixtureOutputs = {
    .PC_MEM = 0x0000,
    .Y_MEM = 0x0000,
    .StoreOp_MEM = 0x0000,
    .led = ledState,
    .Ctl_MEM = 0b1111111,
    .SelC_MEM = 0b111,
    .rdy = 1, // not ready
    .rst = 1,
    .phi1 = 0,
    .phi2 = 0,
    .flush_if = 1,
  };
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Bus transaction to Store a word to RAM.
  // Store 0xffff to RAM at address 0xfffe
  BusOutputs busOutputs = {
    .MemLoad = 1,
    .MemStore = 0, // active low
    .Bank = 0,
    .Addr = 0xfffe,
    .IO = 0xffff,
    .OE = 0b010000 // Assert {MemLoad,MemStore} and Address and IO
  };
  busOutputPorts.set(busOutputs);

  // Bus transaction to Store a word to RAM.
  // Store 0xabcd to RAM at address 0x1234
  busOutputs = {
    .MemLoad = 1,
    .MemStore = 0, // active low
    .Bank = 0,
    .Addr = 0x1234,
    .IO = 0xabcd,
    .OE = 0b010000 // Assert {MemLoad,MemStore} and Address and IO
  };
  busOutputPorts.set(busOutputs);

  // Bus transaction to Load a word from RAM.
  // Load from RAM at address 0xfffe
  busOutputs = (BusOutputs){
    .MemLoad = 0, // active low
    .MemStore = 1,
    .Bank = 0b111,
    .Addr = 0xfffe,
    .IO = 0,
    .OE = 0b010011 // Assert {MemLoad,MemStore} and Address
  };
  busOutputPorts.set(busOutputs);

  // Read the value from the bus.
  BusInputs actualBusInputs = busInputPorts.read();
  assertEqual(0, actualBusInputs.Bank, "Expect that bank was zero.");
  
  assertEqual(0xffff, actualBusInputs.IO, "Expect RAM to express a word to the bus in response.");
  assertEqual(busOutputs.Addr, actualBusInputs.Addr, "Expect to be able to drive Addr from the peripheral side of the bus.");
  assertEqual(0, actualBusInputs.Bank, "Expect the bank to still be zero.");
  assertEqual(busOutputs.MemLoad, actualBusInputs.MemLoad, "Expect to be able to drive MemLoad from the peripheral side of the bus.");
  assertEqual(busOutputs.MemStore, actualBusInputs.MemStore, "Expect to be able to drive MemLoad from the peripheral side of the bus.");

  // Bus transaction to Load a second word from RAM.
  // Load from RAM at address 0xfffe
  busOutputs = (BusOutputs){
    .MemLoad = 0, // active low
    .MemStore = 1,
    .Bank = 0b111,
    .Addr = 0x1234,
    .IO = 0,
    .OE = 0b010011 // Assert {MemLoad,MemStore} and Address
  };
  busOutputPorts.set(busOutputs);

  // Read the second value from the bus.
  actualBusInputs = busInputPorts.read();
  assertEqual(0, actualBusInputs.Bank, "Expect that bank was zero.");
  
  assertEqual(0xabcd, actualBusInputs.IO, "Expect RAM to express a word to the bus in response.");
  assertEqual(busOutputs.Addr, actualBusInputs.Addr, "Expect to be able to drive Addr from the peripheral side of the bus.");
  assertEqual(0, actualBusInputs.Bank, "Expect the bank to still be zero.");
  assertEqual(busOutputs.MemLoad, actualBusInputs.MemLoad, "Expect to be able to drive MemLoad from the peripheral side of the bus.");
  assertEqual(busOutputs.MemStore, actualBusInputs.MemStore, "Expect to be able to drive MemLoad from the peripheral side of the bus.");

  printf("passed\n");
}

void testLoadStore() {
  printf("%s: ", __FUNCTION__);
  printf("Store a word to memory and load it again...");
  assertEqual(0, 1, "unimplemented");
  printf("passed\n");
}

void testInstructionFetch() {
  printf("%s: ", __FUNCTION__);
  printf("Fetch an instruction from RAM..");
  assertEqual(0, 1, "unimplemented");
  printf("passed\n");
}

void testModifyBankRegister() {
  printf("%s: ", __FUNCTION__);
  printf("Check that we can memory-mapped bank register...");
  assertEqual(0, 1, "unimplemented");
  printf("passed\n");
}

void (*allTests[])(unsigned) = {
  testReset,
  testNop,
  testWriteRAM,
  // testLoadStore,
  // testInstructionFetch,
  // testModifyBankRegister,
};

void doAllTests() {
  // Setup the LED flasher which flashes an LED pattern to indicate test failure.
  static ErrorFlasher<TestFixtureOutputPorts, TestFixtureOutputs> errorFlasher(testFixtureOutputPorts);
  g_errorFlasher = &errorFlasher;

  // We update the chasing LED light pattern during test execution.
  Chaser<TestFixtureOutputPorts, TestFixtureOutputs> chaser(testFixtureOutputPorts);

  // Run all tests, one by one
  for (int i = 0, n = sizeof(allTests)/sizeof(*allTests); i < n; ++i) {
    chaser.step();
    allTests[i](chaser.led);
  }
  for (int i = 0; i < 8; ++i) {
    delay(100);
    chaser.step();
  }

  printf("All tests passed.\n");

  // Setup the LED flasher which flashes an LED pattern to indicate all tests passed.
  static SuccessFlasher<TestFixtureOutputPorts, TestFixtureOutputs> successFlasher(testFixtureOutputPorts);
  successFlasher.runForever();
}

int serial_putc(char c, FILE *) {
  Serial.write(c);
  return c;
}

void setup() {
  Serial.begin(9600);
  fdevopen(&serial_putc, 0);
  printf("Starting...\n");
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);
  testFixtureInputPorts.initializeHardware();
  testFixtureOutputPorts.initializeHardware();
  busInputPorts.initializeHardware();
  busOutputPorts.initializeHardware();
  doAllTests();
}