#include <stdio.h>
#include "TestFramework.h"
#include "ShiftRegisterIO.h"
#include "EXModuleTestFixtureIO.h"
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

void testSelC() {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Check that bits of the instruction word are extracted to SelC_MEM...");

  testFixtureOutputs = TestFixtureOutputs().ins(0b11100000000);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);  
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0b111, actualTestFixtureInputs.SelC_MEM, "Expect that three bits of the instruction bits are extracted to SelC_MEM");

  printf("passed\n");
}

void testControlWordCopiedToNextPipelineStage() {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Check that bits of the control word are copied to the next pipeline stage...");

  testFixtureOutputs = TestFixtureOutputs()
    .ctl(0b111111111111111111111);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);  
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0b1111111, actualTestFixtureInputs.Ctl_MEM, "Expect that the top seven bits of the control word are passed forward");

  printf("passed\n");
}

static const int kSelStoreOpShift = 1;

void testStoreOp_RegisterB() {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("SelStoreOp=0 -> Select RegisterB...");

  testFixtureOutputs = TestFixtureOutputs()
    .b(0xcafe)
    .ctl(0 << kSelStoreOpShift);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);  
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0xcafe, actualTestFixtureInputs.StoreOp_MEM, "Expect that StoreOp_MEM contains the value of register B");

  printf("passed\n");
}

void testStoreOp_PCPlusOne() {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("SelStoreOp=1 -> Select PC...");

  testFixtureOutputs = TestFixtureOutputs()
    .pc(0xcafe)
    .ctl(1 << kSelStoreOpShift);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);  
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0xcafe, actualTestFixtureInputs.StoreOp_MEM, "Expect that StoreOp_MEM contains the value of PC");

  printf("passed\n");
}

void testStoreOp_Imm() {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("SelStoreOp=2 -> Select signed eight-bit immediate value...");

  testFixtureOutputs = TestFixtureOutputs()
    .ins(0xab) // 0b10101011, so high bit is set, and we expect the result to be sign-extended
    .ctl(2 << kSelStoreOpShift);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);  
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0xffab, actualTestFixtureInputs.StoreOp_MEM, "Expect that StoreOp_MEM contains the value of the signed eight-bit immediate value");

  printf("passed\n");
}

void testStoreOp_ImmUpper() {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("SelStoreOp=3 -> Select signed eight-bit immediate value, shifted left...");

  testFixtureOutputs = TestFixtureOutputs()
    .ins(0xab)
    .ctl(3 << kSelStoreOpShift);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);  
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0xab00, actualTestFixtureInputs.StoreOp_MEM, "Expect that StoreOp_MEM contains the value of the signed eight-bit immediate value, shift left");

  printf("passed\n");
}

void testAdd() {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Add one and one...");

  testFixtureOutputs = TestFixtureOutputs()
    .ins(0)
    .a(1)
    .b(1)
    .ctl(0b110110<<6);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);  
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(2, actualTestFixtureInputs.Y_EX, "Expect that Y_EX==2");
  assertEqual(0, actualTestFixtureInputs.N, "Expect that N==0");
  assertEqual(0, actualTestFixtureInputs.C, "Expect that C==0");
  assertEqual(0, actualTestFixtureInputs.Z, "Expect that Z==0");
  assertEqual(0, actualTestFixtureInputs.V, "Expect that V==0");
  printf("passed\n");
}

void testAddWithCarryOutput() {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Add with carry output...");

  testFixtureOutputs = TestFixtureOutputs()
    .ins(0)
    .a(0xffff)
    .b(1)
    .ctl(0b110110<<6);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);  
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0, actualTestFixtureInputs.Y_EX, "Expect that Y_EX==0");
  assertEqual(0, actualTestFixtureInputs.N, "Expect that N==0");
  assertEqual(1, actualTestFixtureInputs.C, "Expect that C==1");
  assertEqual(1, actualTestFixtureInputs.Z, "Expect that Z==1");
  assertEqual(0, actualTestFixtureInputs.V, "Expect that V==0");
  printf("passed\n");
}

void testAddWithSignedOverflow() {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Add with signed overflow...");

  testFixtureOutputs = TestFixtureOutputs()
    .ins(0)
    .a(0x7fff)
    .b(1)
    .ctl(0b110110<<6);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);  
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0x8000, actualTestFixtureInputs.Y_EX, "Expect that Y_EX==0x8000");
  assertEqual(1, actualTestFixtureInputs.N, "Expect that N==1");
  assertEqual(0, actualTestFixtureInputs.C, "Expect that C==0");
  assertEqual(0, actualTestFixtureInputs.Z, "Expect that Z==0");
  assertEqual(1, actualTestFixtureInputs.V, "Expect that V==1");
  printf("passed\n");
}

void (*allTests[])(void) = {
  testSelC,
  testControlWordCopiedToNextPipelineStage,
  testStoreOp_RegisterB,
  testStoreOp_PCPlusOne,
  testStoreOp_Imm,
  testStoreOp_ImmUpper,
  testAdd,
  testAddWithCarryOutput,
  testAddWithSignedOverflow,
  // #error("TODO: Write a test for something which passes the right op through unmodified and exercise all options for SelRightOp")
  // #error("TODO: Write tests for all the arithmetic operations")
  // #error("TODO: Write tests for the status bits")
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
    allTests[i]();
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