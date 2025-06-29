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

static const unsigned kOpcodeShift = 11;
static const unsigned kOpcodeHLT = 1;
static const unsigned kOpcodeADD = 7;
static const unsigned kOpcodeJMP = 20;

void testHlt(unsigned ledState) {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Put a HLT through the Control unit and check what it outputs to the text fixture...");

  // Assert the reset line
  testFixtureOutputs = TestFixtureOutputs()
    .ins(kOpcodeHLT << kOpcodeShift)
    .phi1(1)
    .phi2(0);
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
  testFixtureOutputs = TestFixtureOutputs()
    .reset(true)
    .phi1(1)
    .phi2(0);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0b111111111111111111111, actualTestFixtureInputs.Ctl_EX, "Expect that no control signals are asserted.");
  assertEqual(0, actualTestFixtureInputs.Ins_EX, "Expect Ins_EX==0");
  assertEqual(0, actualTestFixtureInputs.stall, "Expect stall==0");
  assertEqual(0, actualTestFixtureInputs.fwd_a, "Expect fwd_a==0");
  assertEqual(1, actualTestFixtureInputs.fwd_ex_to_a, "Expect fwd_ex_to_a==1");
  assertEqual(1, actualTestFixtureInputs.fwd_mem_to_a, "Expect fwd_mem_to_a==1");
  assertEqual(0, actualTestFixtureInputs.fwd_b, "Expect fwd_b==0");
  assertEqual(1, actualTestFixtureInputs.fwd_ex_to_b, "Expect fwd_ex_to_b==1");
  assertEqual(1, actualTestFixtureInputs.fwd_mem_to_b, "Expect fwd_mem_to_b==1");

  printf("passed\n");
}

void testNop(unsigned ledState) {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Put a NOP through the Control unit and check what it outputs to the text fixture...");

  // Assert NOP instruction as input
  testFixtureOutputs = TestFixtureOutputs()
    .ins(0)
    .phi1(1)
    .phi2(0);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);  
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0, actualTestFixtureInputs.Ins_EX, "Expect Ins_EX==0");
  assertEqual(0, actualTestFixtureInputs.stall, "Expect stall==0");
  assertEqual(0b111111111111111111111, actualTestFixtureInputs.Ctl_EX, "Expect that no control signals are asserted.");

  printf("passed\n");
}

void testAdd(unsigned ledState) {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Put an ADD through the Control unit and check what it outputs to the text fixture...");

  // Assert ADD instruction as input
  testFixtureOutputs = TestFixtureOutputs()
    .selC(3)                 // SelC_MEM
    .ctl(0b1111111)          // Ctl_MEM holds a NOP
    .ins(0b0011100000101000) // opcode=7, c=0, a=1, b=2
    .carry(false)
    .zero(false)
    .overflow(false)
    .negative(false)
    .reset(false)
    .phi1(1)
    .phi2(0);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0, actualTestFixtureInputs.stall, "Expect stall==0");
  assertEqual(0b000011111110110000111, actualTestFixtureInputs.Ctl_EX, "Expect appropriate control signals for ADD");
  
  printf("passed\n");
}

void testBypassFromMEMtoA(unsigned ledState) {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Bypass MEM to operand A...");

  // Assert ADD instruction as input
  testFixtureOutputs = TestFixtureOutputs()
    .selC(1)                 // SelC_MEM
    .ctl(0b0000001)          // Ctl_MEM has a value that it wants to write back to register 1
    .ins(0b0011100000101000) // opcode=7, c=0, a=1, b=2
    .carry(false)
    .zero(false)
    .overflow(false)
    .negative(false)
    .reset(false)
    .phi1(1)
    .phi2(0);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0, actualTestFixtureInputs.stall, "Expect stall==0");
  assertEqual(0b000011111110110000111, actualTestFixtureInputs.Ctl_EX, "Expect appropriate control signals for ADD");
  assertEqual(0, actualTestFixtureInputs.stall, "Expect stall==0");
  assertEqual(1, actualTestFixtureInputs.fwd_a, "Expect fwd_a==1");
  assertEqual(1, actualTestFixtureInputs.fwd_ex_to_a, "Expect fwd_ex_to_a==1");
  assertEqual(0, actualTestFixtureInputs.fwd_mem_to_a, "Expect fwd_mem_to_a==0");
  assertEqual(0, actualTestFixtureInputs.fwd_b, "Expect fwd_b==0");
  assertEqual(1, actualTestFixtureInputs.fwd_ex_to_b, "Expect fwd_ex_to_b==1");
  assertEqual(1, actualTestFixtureInputs.fwd_mem_to_b, "Expect fwd_mem_to_b==1");
  
  printf("passed\n");
}

void testBypassFromMEMtoB(unsigned ledState) {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Bypass MEM to operand B...");

  // Assert ADD instruction as input
  testFixtureOutputs = TestFixtureOutputs()
    .selC(1)                 // SelC_MEM
    .ctl(0b0000001)          // Ctl_MEM has a value that it wants to write back to register 1
    .ins(0b0011100001000100) // opcode=7, c=0, a=2, b=1
    .carry(false)
    .zero(false)
    .overflow(false)
    .negative(false)
    .reset(false)
    .phi1(1)
    .phi2(0);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0, actualTestFixtureInputs.stall, "Expect stall==0");
  assertEqual(0b000011111110110000111, actualTestFixtureInputs.Ctl_EX, "Expect appropriate control signals for ADD");
  assertEqual(0, actualTestFixtureInputs.stall, "Expect stall==0");
  assertEqual(0, actualTestFixtureInputs.fwd_a, "Expect fwd_a==0");
  assertEqual(1, actualTestFixtureInputs.fwd_ex_to_a, "Expect fwd_ex_to_a==1");
  assertEqual(1, actualTestFixtureInputs.fwd_mem_to_a, "Expect fwd_mem_to_a==1");
  assertEqual(1, actualTestFixtureInputs.fwd_b, "Expect fwd_b==1");
  assertEqual(1, actualTestFixtureInputs.fwd_ex_to_b, "Expect fwd_ex_to_b==1");
  assertEqual(0, actualTestFixtureInputs.fwd_mem_to_b, "Expect fwd_mem_to_b==0");
  
  printf("passed\n");
}

void testBypassFromEXtoA(unsigned ledState) {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Bypass EX to operand A...");

  // As part of test setup we have to process an instruction
  // and latch the interstage registers headed to the EX stage.
  // Once we set this state, we check that it is used to
  // correctly command a bypass on the next instruction.
  testFixtureOutputs = TestFixtureOutputs()
    .selC(0)                 // SelC_MEM
    .ctl(0b1111111)          // Ctl_MEM is NOP
    .ins(0b0011100000101000) // opcode=7, c=0, a=1, b=2
    .carry(false)
    .zero(false)
    .overflow(false)
    .negative(false)
    .reset(false)
    .phi1(1)
    .phi2(0);
  testFixtureOutputPorts.set(testFixtureOutputs);
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);

  // Assert ADD instruction as input
  testFixtureOutputs = TestFixtureOutputs()
    .selC(0)                 // SelC_MEM
    .ctl(0b1111111)          // Ctl_MEM is NOP
    .ins(0b0011100000001000) // opcode=7, c=0, a=0, b=2
    .carry(false)
    .zero(false)
    .overflow(false)
    .negative(false)
    .reset(false)
    .phi1(1)
    .phi2(0);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0, actualTestFixtureInputs.stall, "Expect stall==0");
  assertEqual(0b000011111110110000111, actualTestFixtureInputs.Ctl_EX, "Expect appropriate control signals for ADD");
  assertEqual(0, actualTestFixtureInputs.stall, "Expect stall==0");
  assertEqual(1, actualTestFixtureInputs.fwd_a, "Expect fwd_a==1");
  assertEqual(0, actualTestFixtureInputs.fwd_ex_to_a, "Expect fwd_ex_to_a==0");
  assertEqual(1, actualTestFixtureInputs.fwd_mem_to_a, "Expect fwd_mem_to_a==1");
  assertEqual(0, actualTestFixtureInputs.fwd_b, "Expect fwd_b==0");
  assertEqual(1, actualTestFixtureInputs.fwd_ex_to_b, "Expect fwd_ex_to_b==1");
  assertEqual(1, actualTestFixtureInputs.fwd_mem_to_b, "Expect fwd_mem_to_b==1");
  
  printf("passed\n");
}

void testBypassFromEXtoB(unsigned ledState) {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Bypass EX to operand B...");

  // As part of test setup we have to process an instruction
  // and latch the interstage registers headed to the EX stage.
  // Once we set this state, we check that it is used to
  // correctly command a bypass on the next instruction.
  testFixtureOutputs = TestFixtureOutputs()
    .selC(0)                 // SelC_MEM
    .ctl(0b1111111)          // Ctl_MEM is NOP
    .ins(0b0011100000101000) // opcode=7, c=0, a=1, b=2
    .carry(false)
    .zero(false)
    .overflow(false)
    .negative(false)
    .reset(false)
    .phi1(1)
    .phi2(0);
  testFixtureOutputPorts.set(testFixtureOutputs);
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);

  // Assert ADD instruction as input
  testFixtureOutputs = TestFixtureOutputs()
    .selC(0)                 // SelC_MEM
    .ctl(0b1111111)          // Ctl_MEM is NOP
    .ins(0b0011100001000000) // opcode=7, c=0, a=2, b=0
    .carry(false)
    .zero(false)
    .overflow(false)
    .negative(false)
    .reset(false)
    .phi1(1)
    .phi2(0);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0, actualTestFixtureInputs.stall, "Expect stall==0");
  assertEqual(0b000011111110110000111, actualTestFixtureInputs.Ctl_EX, "Expect appropriate control signals for ADD");
  assertEqual(0, actualTestFixtureInputs.stall, "Expect stall==0");
  assertEqual(0, actualTestFixtureInputs.fwd_a, "Expect fwd_a==0");
  assertEqual(1, actualTestFixtureInputs.fwd_ex_to_a, "Expect fwd_ex_to_a==1");
  assertEqual(1, actualTestFixtureInputs.fwd_mem_to_a, "Expect fwd_mem_to_a==1");
  assertEqual(1, actualTestFixtureInputs.fwd_b, "Expect fwd_b==1");
  assertEqual(0, actualTestFixtureInputs.fwd_ex_to_b, "Expect fwd_ex_to_b==0");
  assertEqual(1, actualTestFixtureInputs.fwd_mem_to_b, "Expect fwd_mem_to_b==1");
  
  printf("passed\n");
}

void testFlushOnStoreOp(unsigned ledState) {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Flush due to dependency on a LOAD instruction...");

  // Assert ADD instruction as input
  // The ADD instruction operands depend on a register
  // value which is being loaded in the MEM stage and
  // so the instruction must stall.
  testFixtureOutputs = TestFixtureOutputs()
    .selC(0)                 // SelC_MEM
    .ctl(0b0001000)          // Ctl_MEM is loading a value into the register that the ADD depends on.
    .ins(0b0011100000000000) // opcode=7, c=0, a=0, b=0
    .carry(false)
    .zero(false)
    .overflow(false)
    .negative(false)
    .reset(false)
    .phi1(0)
    .phi2(1);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // The ID stage is stalling the pipeline this clock cycle.
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(1, actualTestFixtureInputs.stall, "RAW hazards should stall the pipeline");

  // Tick the clock so Ctl_EX updates.
  testFixtureOutputs = testFixtureOutputs
    .phi1(1)
    .phi2(0);
  testFixtureOutputPorts.set(testFixtureOutputs);
  
  // Ensure the ID stage did emit a NOP during the stall.
  actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0b111111111111111111111, actualTestFixtureInputs.Ctl_EX, "During a flush, the control signals should be equivalent to NOP.");
  
  printf("passed\n");
}

void testStallOnFlagsHazard(unsigned ledState) {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Stall to avoid a flags hazard...");

  // Put control signals into Ctl_EX to indicate that flags are
  // being updated in the EX stage in this clock cycle.
  testFixtureOutputs = TestFixtureOutputs()
    .selC(0)
    .ctl(0b1111111)
    .ins(0b0011100000000000)
    .carry(false)
    .zero(false)
    .overflow(false)
    .negative(false)
    .reset(false)
    .phi1(0)
    .phi2(1);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Tick the clock so Ctl_EX updates.
  testFixtureOutputs = testFixtureOutputs
    .phi1(1)
    .phi2(0);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // The BEQ instruction depends on flags generated by the ALU.
  // If we depend on the immediately previous instruction to
  // generate these flags then the pipeline will stall for one
  // cycle.
  testFixtureOutputs = TestFixtureOutputs()
    .selC(0)                 // SelC_MEM
    .ctl(0b0001000)          // Ctl_MEM is loading a value into the register that the ADD depends on.
    .ins(0b1100000000000000) // opcode=24 (BEQ)
    .carry(false)
    .zero(false)
    .overflow(false)
    .negative(false)
    .reset(false)
    .phi1(0)
    .phi2(1);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // The pipeline is stalling this clock cycle because of the flags hazard.
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(1, actualTestFixtureInputs.stall, "Flags hazards should stall the pipeline");

  // Tick the clock so Ctl_EX updates.
  testFixtureOutputs = testFixtureOutputs
    .phi1(1)
    .phi2(0);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Ensure Ctl_EX indicates the ID stage did emit a NOP during the stall.
  actualTestFixtureInputs = testFixtureInputPorts.read();
  assertEqual(0b111111111111111111111, actualTestFixtureInputs.Ctl_EX, "During a flush, the control signals should be equivalent to NOP.");
  
  printf("passed\n");
}

void testJmp(unsigned ledState) {
  TestFixtureOutputs testFixtureOutputs;

  printf("%s: ", __FUNCTION__);
  printf("Put an JMP through the Control unit and check what it outputs to the text fixture...");

  // Assert JMP instruction as input
  testFixtureOutputs = TestFixtureOutputs()
    .ins(kOpcodeJMP << kOpcodeShift)
    .phi1(1)
    .phi2(0);
  testFixtureOutputPorts.set(testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs = testFixtureOutputPorts.tick(testFixtureOutputs);
  
  TestFixtureInputs actualTestFixtureInputs = testFixtureInputPorts.read();

  // A branch triggers a flush of the pipeline IF stage, but
  // that's not visible from the control unit test fixture.
  // All we can see is that it does not stall the pipeline.
  assertEqual(0, actualTestFixtureInputs.stall, "Expect stall==0");

  // The control signals for this JMP instruction indicate
  // to the EX unit to use the ALU to compute the target and
  // to jump to it. This is why we must set the ALU mode and
  // we must set the CarryIn bit.
  assertEqual(0b111111110101010111111, actualTestFixtureInputs.Ctl_EX, "Expect appropriate control signals for JMP");
  
  printf("passed\n");
}

void (*allTests[])(unsigned) = {
  testInstructionWordCopiedOver,
  testHlt,
  testReset,
  testNop,
  testAdd,
  testBypassFromMEMtoA,
  testBypassFromMEMtoB,
  testBypassFromEXtoA,
  testBypassFromEXtoB,
  testFlushOnStoreOp,
  testStallOnFlagsHazard,
  testJmp,
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