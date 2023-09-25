#include <stdio.h>
#include "TestFramework.h"
#include "ShiftRegisterIO.h"
#include "ControlModuleTestFixtureIO.h"
#include "LEDPattern.h"

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

const LEDOutputPorts ledPorts = {
  .SI = 17,
  .RCLK = 16,
  .SCK = 15,
  .CLR = 14
};

void testInstructionWordCopiedOver(unsigned ledState) {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Check that the lower eleven bits of the instruction word are copied to the next pipeline stage...");

  // Assert the reset line
  testFixtureOutputs = TestFixtureOutputs().ins(0b1111111111111111);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0b11111111111, actualTestFixtureInputs.Ins_EX, "Expect Ins_EX contains the lower eleven bits of the instruction word");

  printf("passed\n");
}

void testHlt(unsigned ledState) {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Put a HLT through the Control unit and check what it outputs to the text fixture...");

  // Assert the reset line
  testFixtureOutputs = TestFixtureOutputs().ins(1 << 11);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0, actualTestFixtureInputs.Ctl_EX & 1, "Expect HLT control line is active");

  printf("passed\n");
}

void testReset(unsigned ledState) {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Testing reset function...");

  // Assert the reset line
  testFixtureOutputs = TestFixtureOutputs().reset(true);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0b111111111111111111111, actualTestFixtureInputs.Ctl_EX, "Expect that no control signals are asserted.");
  assertEqual(0, actualTestFixtureInputs.Ins_EX, "Expect Ins_EX==0");
  assertEqual(0, actualTestFixtureInputs.stall, "Expect stall==0");
  assertEqual(0, actualTestFixtureInputs.fwd_a, "Expect fwd_a==0");
  assertEqual(0, actualTestFixtureInputs.fwd_ex_to_a, "Expect fwd_ex_to_a==0");
  assertEqual(0, actualTestFixtureInputs.fwd_mem_to_a, "Expect fwd_mem_to_a==0");
  assertEqual(0, actualTestFixtureInputs.fwd_b, "Expect fwd_b==0");
  assertEqual(0, actualTestFixtureInputs.fwd_ex_to_b, "Expect fwd_ex_to_b==0");
  assertEqual(0, actualTestFixtureInputs.fwd_mem_to_b, "Expect fwd_mem_to_b==0");

  printf("passed\n");
}

void testNop(unsigned ledState) {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Put a NOP through the Control unit and check what it outputs to the text fixture...");

  // Assert NOP instruction as input
  testFixtureOutputs = TestFixtureOutputs().ins(0);
  testFixtureOutputPorts.set(testFixtureOutputs);

  assertEqual(0, 1, "Break");
  // Pulse the clock
  //testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);  
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0, actualTestFixtureInputs.Ins_EX, "Expect Ins_EX==0");
  assertEqual(0, actualTestFixtureInputs.stall, "Expect stall==0");
  assertEqual(0b111111111111111111111, actualTestFixtureInputs.Ctl_EX, "Expect that no control signals are asserted.");

  printf("passed\n");
}

void (*allTests[])(unsigned) = {
  testInstructionWordCopiedOver,
  testHlt,
  // testReset,
  testNop,
};

void doAllTests() {
  // Setup the LED flasher which flashes an LED pattern to indicate test failure.
  static ErrorFlasher<LEDOutputPorts, LEDOutputs> errorFlasher(ledPorts);
  g_errorFlasher = &errorFlasher;

  // We update the chasing LED light pattern during test execution.
  Chaser<LEDOutputPorts, LEDOutputs> chaser(ledPorts);

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
  static SuccessFlasher<LEDOutputPorts, LEDOutputs> successFlasher(ledPorts);
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
  ledPorts.initializeHardware();
  doAllTests();
}

void loop() {
  // do nothing
}