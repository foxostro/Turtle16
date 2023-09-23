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

// void testReset(unsigned ledState) {
//   printf("%s: ", __FUNCTION__);
//   printf("Testing reset function...");

//   // Assert the reset line
//   BusOutputs busOutputs;
//   TestFixtureOutputs testFixtureOutputs = TestFixtureOutputs()
//     .ready(false)
//     .reset(true)
//     .ledState(ledState);
//   busOutputPorts.set(busOutputs);
//   testFixtureOutputPorts.set(testFixtureOutputs);

//   // Pulse the clock
//   testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);

//   // De-assert the reset line
//   testFixtureOutputs = testFixtureOutputs.reset(false);
//   testFixtureOutputPorts.set(testFixtureOutputs);
  
//   BusInputs actualBusInputs = busInputPorts.read();
//   assertEqual(0, actualBusInputs.Bank, "Expect that Bank is zero after reset.");
  
//   TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
//   assertEqual(0b1111, actualTestFixtureInputs.Ctl_WB, "Expect that no control signals are asserted.");

//   printf("passed\n");
// }

// void testNop(unsigned ledState) {
//   printf("%s: ", __FUNCTION__);
//   printf("Put a NOP through the MEM stage and check what it outputs to the text fixture...");

//   BusOutputs busOutputs;
//   TestFixtureOutputs testFixtureOutputs = TestFixtureOutputs()
//     .ledState(ledState);
//   busOutputPorts.set(busOutputs);
//   testFixtureOutputPorts.set(testFixtureOutputs);

//   BusInputs actualBusInputs = busInputPorts.read();
//   assertEqual(0, actualBusInputs.Bank, "Expect that bank was zero.");
  
//   TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
//   assertEqual(0b1111, actualTestFixtureInputs.Ctl_WB, "Expect that no control signals are asserted.");
//   assertEqual(0b111, actualTestFixtureInputs.SelC_WB, "Expect that SelC is passed through unmodified.");

//   printf("passed\n");
// }

void (*allTests[])(unsigned) = {
  // testReset,
  // testNop
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