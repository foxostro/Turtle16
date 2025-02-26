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
  BusOutputs busOutputs;
  TestFixtureOutputs testFixtureOutputs = TestFixtureOutputs()
    .ready(false)
    .reset(true)
    .ledState(ledState);
  busOutputPorts.set(busOutputs);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);

  // De-assert the reset line
  testFixtureOutputs = testFixtureOutputs.reset(false);
  testFixtureOutputPorts.set(testFixtureOutputs);
  
  BusInputs actualBusInputs = busInputPorts.read();
  assertEqual(0, actualBusInputs.Bank, "Expect that Bank is zero after reset.");
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0b1111, actualTestFixtureInputs.Ctl_WB, "Expect that no control signals are asserted.");

  printf("passed\n");
}

void testNop(unsigned ledState) {
  printf("%s: ", __FUNCTION__);
  printf("Put a NOP through the MEM stage and check what it outputs to the test fixture...");

  BusOutputs busOutputs;
  TestFixtureOutputs testFixtureOutputs = TestFixtureOutputs()
    .ledState(ledState);
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
  // This ought to effectively disconnect MEM from the bus.
  TestFixtureOutputs testFixtureOutputs = TestFixtureOutputs()
    .ready(false)
    .ledState(ledState);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Bus transaction to Store a word to RAM.
  // Store 0xffff to RAM at address 0xfffe
  BusOutputs busOutputs = BusOutputs()
    .memStore(true)
    .addr(0xfffe)
    .data(0xffff)
    .assertMemLoadStoreLines()
    .assertAddrLines()
    .assertDataLines();
  busOutputPorts.set(busOutputs);
  // printf("BREAKPOINT\n"); while(true){};

  // Bus transaction to Store a word to RAM.
  // Store 0xabcd to RAM at address 0x1234
  busOutputs = BusOutputs()
    .memStore(true)
    .addr(0x1234)
    .data(0xabcd)
    .assertMemLoadStoreLines()
    .assertAddrLines()
    .assertDataLines();
  busOutputPorts.set(busOutputs);

  // Bus transaction to Load a word from RAM.
  // Load from RAM at address 0xfffe
  busOutputs = BusOutputs()
    .memLoad(true)
    .addr(0xfffe)
    .assertMemLoadStoreLines()
    .assertAddrLines();
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
  // Load from RAM at address 0x1234
  busOutputs = BusOutputs()
    .memLoad(true)
    .addr(0x1234)
    .assertMemLoadStoreLines()
    .assertAddrLines();
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

void testLoad(unsigned ledState) {
  printf("%s: ", __FUNCTION__);
  printf("Simulate a LOAD instruction...");

  // Set signals to put MEM into a Wait state.
  // This ought to effectively disconnect MEM from the bus.
  testFixtureOutputPorts.set(TestFixtureOutputs()
    .ready(false)
    .ledState(ledState));

  // Bus transaction to Store a word to RAM and then release the bus.
  busOutputPorts.set(BusOutputs()
    .memStore(true)
    .addr(0x1234)
    .data(0xffff)
    .assertMemLoadStoreLines()
    .assertAddrLines()
    .assertDataLines());
  busOutputPorts.set(BusOutputs());

  // Simulate the control signals of a LOAD instruction as it passes through
  // the MEM stage of the pipeline.
  auto testFixtureOutputs = TestFixtureOutputs()
    .ready(true)
    .addr(0x1234)
    .memLoad(true)
    .selC(0b111)
    .ledState(ledState);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Tick the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);
  
  // Read the MEM module output signals
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0b1111, actualTestFixtureInputs.Ctl_WB, "Expect that no control signals are asserted.");
  assertEqual(0b111, actualTestFixtureInputs.SelC_WB, "Expect that SelC is passed through unmodified.");
  assertEqual(0x1234, actualTestFixtureInputs.Y_WB, "Expect that the memory address is passed through unmodified.");
  assertEqual(0xffff, actualTestFixtureInputs.StoreOp_WB, "Expect that the word read is the same the one placed in RAM.");

  printf("passed\n");
}

void testStore(unsigned ledState) {
  printf("%s: ", __FUNCTION__);
  printf("Simulate a STORE instruction...");

  // Simulate the control signals of a STORE instruction as it passes through
  // the MEM stage of the pipeline.
  auto testFixtureOutputs = TestFixtureOutputs()
    .ready(true)
    .addr(0xcafe)
    .storeOp(0xbeef)
    .selC(0b111)
    .memStore(true)
    .ledState(ledState);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Tick the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);
  
  // Read the MEM module output signals
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0b1111, actualTestFixtureInputs.Ctl_WB, "Expect that no control signals are asserted.");
  assertEqual(0b111, actualTestFixtureInputs.SelC_WB, "Expect that SelC is passed through unmodified.");
  assertEqual(0xcafe, actualTestFixtureInputs.Y_WB, "Expect that the memory address is passed through unmodified.");
  assertEqual(0xbeef, actualTestFixtureInputs.StoreOp_WB, "Expect that the word read is the same the one placed in RAM.");

  // Set signals to put MEM into a Wait state.
  // This ought to effectively disconnect MEM from the bus.
  testFixtureOutputPorts.set(TestFixtureOutputs()
    .ready(false)
    .ledState(ledState));

  // Read the RAM to verify that it contains the expected value.
  auto busOutputs = BusOutputs()
    .memLoad(true)
    .addr(0xcafe)
    .assertMemLoadStoreLines()
    .assertAddrLines();
  busOutputPorts.set(busOutputs);

  // Read the value from the bus.
  BusInputs actualBusInputs = busInputPorts.read();
  assertEqual(0xbeef, actualBusInputs.IO, "Expect to find the value in RAM");

  printf("passed\n");
}

void testModifyBankRegister(unsigned ledState) {
  printf("%s: ", __FUNCTION__);
  printf("Check that we can modify the memory-mapped bank register...");

  // Set signals to put MEM into a Wait state.
  // This ought to effectively disconnect MEM from the bus.
  TestFixtureOutputs testFixtureOutputs = TestFixtureOutputs()
    .ready(false)
    .ledState(ledState);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // The bank register is memory-mapped at 0xffff.
  BusOutputs busOutputs = BusOutputs()
    .memStore(true)
    .addr(0xffff)
    .data(0b111)
    .assertMemLoadStoreLines()
    .assertAddrLines()
    .assertDataLines();
  busOutputPorts.set(busOutputs);

  // Tick the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);

  // Release the bus.
  busOutputPorts.set(BusOutputs());

  // Read the the bus.
  BusInputs actualBusInputs = busInputPorts.read();
  assertEqual(0b111, actualBusInputs.Bank, "Expect that the bank has been modified.");
  
  printf("passed\n");
}

void testInstructionFetchFromROM(unsigned ledState) {
  printf("%s: ", __FUNCTION__);
  printf("Fetch an instruction from ROM...");

  // Set signals to put MEM into a Wait state.
  // This ought to effectively disconnect MEM from the bus.
  auto testFixtureOutputs = TestFixtureOutputs()
    .ready(false)
    .ledState(ledState);
    testFixtureOutputPorts.tick(testFixtureOutputs);

  // The bank register is memory-mapped at 0xffff.
  BusOutputs busOutputs = BusOutputs()
    .memStore(true)
    .addr(0xffff)
    .data(0) // IF will fetch from ROM when bank is set to zero.
    .assertMemLoadStoreLines()
    .assertAddrLines()
    .assertDataLines();
  busOutputPorts.set(busOutputs);

  // Tick the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);

  // Fetch an instruction
  testFixtureOutputs = testFixtureOutputs
    .ready(true)
    .pc(0xabab);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Tick the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);
  
  // Read the MEM module output signals
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0xffff, actualTestFixtureInputs.Ins_IF, "Expect that we fetch 0xffff from ROM");

  printf("passed\n");
}

void testInstructionFetchFromRAM(unsigned ledState) {
  printf("%s: ", __FUNCTION__);
  printf("Fetch an instruction from RAM...");

  // Set signals to put MEM into a Wait state.
  // This ought to effectively disconnect MEM from the bus.
  auto testFixtureOutputs = TestFixtureOutputs()
    .ready(false)
    .ledState(ledState);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // The bank register is memory-mapped at 0xffff.
  BusOutputs busOutputs = BusOutputs()
    .memStore(true)
    .addr(0xffff)
    .data(1) // IF will fetch from RAM when bank is set to one.
    .assertMemLoadStoreLines()
    .assertAddrLines()
    .assertDataLines();
  busOutputPorts.set(busOutputs);

  // Tick the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);

  // Bus transaction to Store a word to RAM and then release the bus.
  busOutputPorts.set(BusOutputs()
    .memStore(true)
    .addr(0xabab)
    .data(0xcdcd)
    .assertMemLoadStoreLines()
    .assertAddrLines()
    .assertDataLines());
  busOutputPorts.set(BusOutputs());

  // Fetch an instruction
  testFixtureOutputs = testFixtureOutputs
    .ready(true)
    .pc(0xabab)
    .ledState(ledState);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Tick the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);
  
  // Read the MEM module output signals
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0xcdcd, actualTestFixtureInputs.Ins_IF, "Expect that we fetch the same instruction as written to RAM.");

  printf("passed\n");
}

void testInstructionFlushInstruction(unsigned ledState) {
  printf("%s: ", __FUNCTION__);
  printf("Flush the instruction being fetched this clock...");

  // Fetch an instruction
  auto testFixtureOutputs = TestFixtureOutputs()
    .ready(true)
    .pc(0xabab)
    .flushInstruction(true)
    .ledState(ledState);
  testFixtureOutputPorts.set(testFixtureOutputs);
  assertEqual(0, 1, "BREAK");

  // Tick the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);
  
  // Read the MEM module output signals
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0, actualTestFixtureInputs.Ins_IF, "Expect to fetch a NOP instruction this clock.");

  printf("passed\n");
}

void (*allTests[])(unsigned) = {
  testReset,
  testNop,
  testWriteRAM,
  testLoad,
  testStore,
  testModifyBankRegister,
  testInstructionFetchFromROM,
  testInstructionFetchFromRAM,
  // testInstructionFlushInstruction,
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
  Serial.begin(115200);
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