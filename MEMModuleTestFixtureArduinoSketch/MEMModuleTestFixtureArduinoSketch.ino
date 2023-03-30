#include <stdio.h>

struct BusInputPorts {
  int PL;
  int SCK;
  int SO;
};

struct BusInputs {
  unsigned MemLoad;
  unsigned MemStore;
  unsigned Bank;
  unsigned Addr;
  unsigned IO;
};

struct BusOutputPorts {
  int SI;
  int RCLK;
  int SCK;
  int CLR;
};

struct BusOutputs {
  unsigned MemLoad;
  unsigned MemStore;
  unsigned Bank;
  unsigned Addr;
  unsigned IO;
  unsigned OE;
};

struct TestFixtureInputPorts {
  int PL;
  int SCK;
  int SO;
};

struct TestFixtureInputs {
  unsigned Ins_IF;
  unsigned StoreOp_WB;
  unsigned Y_WB;
  unsigned Ctl_WB;
  unsigned SelC_WB;
};

struct TestFixtureOutputPorts {
  int SI;
  int RCLK;
  int SCK;
  int CLR;
};

struct TestFixtureOutputs {
  unsigned PC_MEM;
  unsigned Y_MEM;
  unsigned StoreOp_MEM;
  unsigned led;
  unsigned Ctl_MEM;
  unsigned SelC_MEM;
  unsigned rdy;
  unsigned rst;
  unsigned phi1;
  unsigned phi2;
  unsigned flush_if;
};

void strobeLow(int pin) {
  digitalWrite(pin, HIGH);
  digitalWrite(pin, LOW);
  digitalWrite(pin, HIGH);
}

void strobeHigh(int pin) {
  digitalWrite(pin, LOW);
  digitalWrite(pin, HIGH);
  digitalWrite(pin, LOW);
}

template<typename InputPorts>
unsigned readInputBit(const InputPorts &inputPorts) {
  strobeHigh(inputPorts.SCK);
  unsigned value = digitalRead(inputPorts.SO)==LOW ? 0 : 1;
  printf("readInputBit: %d\n", value);
  return value;
}

template<typename InputPorts>
unsigned readInputWord(int numBits, const InputPorts &inputPorts) {
  printf("readInputWord\n");
  unsigned value = 0;
  for (int i = 0; i < numBits; ++i) {
    strobeHigh(inputPorts.SCK);
    unsigned bit = digitalRead(inputPorts.SO);
    printf("bit: %x\n", bit);
    value <<= 1;
    value |= bit;
  }
  printf("value: %x\n", value);
  return value;
}

template<typename OutputPorts>
void clearOutputs(const OutputPorts &outputPorts) {
  strobeLow(outputPorts.CLR);
}

void initializeBusInputsAndOutputs(const BusInputPorts &inputPorts, const BusOutputPorts &outputPorts) {
  pinMode(inputPorts.PL,  OUTPUT);
  pinMode(inputPorts.SCK, OUTPUT);
  pinMode(inputPorts.SO,  INPUT);

  digitalWrite(inputPorts.PL, HIGH);
  digitalWrite(inputPorts.SCK, HIGH);
  
  pinMode(outputPorts.SI,   OUTPUT);
  pinMode(outputPorts.RCLK, OUTPUT);
  pinMode(outputPorts.SCK,  OUTPUT);
  pinMode(outputPorts.CLR,  OUTPUT);

  digitalWrite(outputPorts.SI, HIGH);
  digitalWrite(outputPorts.SCK, HIGH);
  digitalWrite(outputPorts.RCLK, HIGH);
  digitalWrite(outputPorts.CLR, HIGH);

  clearOutputs(outputPorts);
}

BusInputs updateBusInputs(const BusInputPorts &inputPorts) {
  strobeLow(inputPorts.PL);

  // Rev A Hardware Requires the bus Input bits to be read in this order.
  // These are named after the corresponding nets in the KiCad schematic:
  unsigned dontCare0 = readInputBit(inputPorts);
  unsigned dontCare1 = readInputBit(inputPorts);
  unsigned dontCare2 = readInputBit(inputPorts);
  unsigned MemLoad = readInputBit(inputPorts);
  unsigned MemStore = readInputBit(inputPorts);
  unsigned Bank = readInputWord(3, inputPorts);
  unsigned Addr = readInputWord(16, inputPorts);
  unsigned IO = readInputWord(16, inputPorts);

  BusInputs busInputs = {
    .MemLoad = MemLoad,
    .MemStore = MemStore,
    .Bank = Bank,
    .Addr = Addr,
    .IO = IO
  };

  return busInputs;
}

void updateBusOutputs(const BusOutputPorts &outputPorts, const BusOutputs &outputs) {
  // Rev A Hardware Requires the Output bits to be pushed in this order.
  // These are named after the corresponding nets in the KiCad schematic:
  int bits[] = {
    0,
    0,
    (outputs.OE >> 6) & 1,
    (outputs.OE >> 5) & 1,
    (outputs.OE >> 4) & 1,
    (outputs.OE >> 3) & 1,
    (outputs.OE >> 2) & 1,
    (outputs.OE >> 1) & 1,
    (outputs.OE >> 0) & 1,
    0,
    0,
    0,
    0,
    0,
    0,
    outputs.MemStore & 1,
    outputs.MemLoad & 1,
    0,
    0,
    0,
    0,
    0,
    (outputs.Bank >> 2) & 1,
    (outputs.Bank >> 1) & 1,
    (outputs.Bank >> 0) & 1,
    (outputs.Addr >> 15) & 1,
    (outputs.Addr >> 14) & 1,
    (outputs.Addr >> 13) & 1,
    (outputs.Addr >> 12) & 1,
    (outputs.Addr >> 11) & 1,
    (outputs.Addr >> 10) & 1,
    (outputs.Addr >> 9) & 1,
    (outputs.Addr >> 8) & 1,
    (outputs.Addr >> 7) & 1,
    (outputs.Addr >> 6) & 1,
    (outputs.Addr >> 5) & 1,
    (outputs.Addr >> 4) & 1,
    (outputs.Addr >> 3) & 1,
    (outputs.Addr >> 2) & 1,
    (outputs.Addr >> 1) & 1,
    (outputs.Addr >> 0) & 1,
    (outputs.IO >> 15) & 1,
    (outputs.IO >> 14) & 1,
    (outputs.IO >> 13) & 1,
    (outputs.IO >> 12) & 1,
    (outputs.IO >> 11) & 1,
    (outputs.IO >> 10) & 1,
    (outputs.IO >> 9) & 1,
    (outputs.IO >> 8) & 1,
    (outputs.IO >> 7) & 1,
    (outputs.IO >> 6) & 1,
    (outputs.IO >> 5) & 1,
    (outputs.IO >> 4) & 1,
    (outputs.IO >> 3) & 1,
    (outputs.IO >> 2) & 1,
    (outputs.IO >> 1) & 1,
    (outputs.IO >> 0) & 1
  };

  for (int i = 0, n = sizeof(bits)/sizeof(bits[0]); i < n; ++i) {
    digitalWrite(outputPorts.SI, bits[i]==0 ? LOW : HIGH);
    strobeHigh(outputPorts.SCK);
  }

  strobeHigh(outputPorts.RCLK);
}

void initializeTestFixtureInputs(const TestFixtureInputPorts &inputPorts) {
  pinMode(inputPorts.PL,  OUTPUT);
  pinMode(inputPorts.SCK, OUTPUT);
  pinMode(inputPorts.SO,  INPUT);

  digitalWrite(inputPorts.PL, HIGH);
  digitalWrite(inputPorts.SCK, HIGH);
}

TestFixtureInputs updateTestFixtureInputs(const TestFixtureInputPorts &inputPorts) {
  printf("\nupdateTestFixtureInputs...\n");
  strobeLow(inputPorts.PL);

  // Rev A Hardware Requires the Input bits to be read in this order.
  // These are named after the corresponding nets in the KiCad schematic:
  //unsigned unused = readInputBit(inputPorts);
  //printf("unused: %x\n", unused);
  unsigned SelC_WB = readInputWord(3, inputPorts);
  printf("SelC_WB: %x\n", SelC_WB);
  unsigned Ctl_WB = readInputWord(4, inputPorts);
  printf("Ctl_WB: %x\n", Ctl_WB);
  unsigned StoreOp_WB = readInputWord(16, inputPorts);
  printf("StoreOp_WB: %x\n", StoreOp_WB);
  unsigned Ins_IF = readInputWord(16, inputPorts);
  printf("Ins_IF: %x\n", Ins_IF);
  unsigned Y_WB = readInputWord(16, inputPorts);
  printf("Y_WB: %x\n", Y_WB);

  TestFixtureInputs testFixtureInputs = {
    .Ins_IF = Ins_IF,
    .StoreOp_WB = StoreOp_WB,
    .Y_WB = Y_WB,
    .Ctl_WB = Ctl_WB,
    .SelC_WB = SelC_WB,
  };

  return testFixtureInputs;
}

void initializeTestFixtureOutputs(const TestFixtureOutputPorts &outputPorts) {
  pinMode(outputPorts.SI,   OUTPUT);
  pinMode(outputPorts.RCLK, OUTPUT);
  pinMode(outputPorts.SCK,  OUTPUT);
  pinMode(outputPorts.CLR,  OUTPUT);

  digitalWrite(outputPorts.SI, HIGH);
  digitalWrite(outputPorts.SCK, HIGH);
  digitalWrite(outputPorts.RCLK, HIGH);
  digitalWrite(outputPorts.CLR, HIGH);

  clearOutputs(outputPorts);
}

void updateTestFixtureOutputs(const TestFixtureOutputPorts &outputPorts, const TestFixtureOutputs &outputs) {
  // Rev A Hardware Requires the Output bits to be pushed in this order.
  // These are named after the corresponding nets in the KiCad schematic:
  int D8 = (outputs.led >> 7) & 1;
  int D7 = (outputs.led >> 6) & 1;
  int D6 = (outputs.led >> 5) & 1;
  int D5 = (outputs.led >> 4) & 1;
  int D4 = (outputs.led >> 3) & 1;
  int D3 = (outputs.led >> 2) & 1;
  int D2 = (outputs.led >> 1) & 1;
  int D1 = (outputs.led >> 0) & 1;
  int SelC_MEM2 = (outputs.SelC_MEM >> 2) & 1;
  int SelC_MEM1 = (outputs.SelC_MEM >> 1) & 1;
  int SelC_MEM0 = (outputs.SelC_MEM >> 0) & 1;
  int RST = outputs.rst & 1;
  int RDY = outputs.rdy & 1;
  int Phi1 = outputs.phi1 & 1;
  int Phi2 = outputs.phi2 & 1;
  int Flush_IF = outputs.flush_if & 1;
  // The bit after Flush_IF is unused. Don't care.
  int Ctl_MEM20 = (outputs.Ctl_MEM >> 6) & 1;
  int Ctl_MEM19 = (outputs.Ctl_MEM >> 5) & 1;
  int Ctl_MEM18 = (outputs.Ctl_MEM >> 4) & 1;
  int Ctl_MEM17 = (outputs.Ctl_MEM >> 3) & 1;
  int Ctl_MEM16 = (outputs.Ctl_MEM >> 2) & 1;
  int Ctl_MEM15 = (outputs.Ctl_MEM >> 1) & 1;
  int Ctl_MEM14 = (outputs.Ctl_MEM >> 0) & 1;
  int StoreOp_MEM15 = (outputs.StoreOp_MEM >> 15) & 1;
  int StoreOp_MEM14 = (outputs.StoreOp_MEM >> 14) & 1;
  int StoreOp_MEM13 = (outputs.StoreOp_MEM >> 13) & 1;
  int StoreOp_MEM12 = (outputs.StoreOp_MEM >> 12) & 1;
  int StoreOp_MEM11 = (outputs.StoreOp_MEM >> 11) & 1;
  int StoreOp_MEM10 = (outputs.StoreOp_MEM >> 10) & 1;
  int StoreOp_MEM9 = (outputs.StoreOp_MEM >> 9) & 1;
  int StoreOp_MEM8 = (outputs.StoreOp_MEM >> 8) & 1;
  int StoreOp_MEM7 = (outputs.StoreOp_MEM >> 7) & 1;
  int StoreOp_MEM6 = (outputs.StoreOp_MEM >> 6) & 1;
  int StoreOp_MEM5 = (outputs.StoreOp_MEM >> 5) & 1;
  int StoreOp_MEM4 = (outputs.StoreOp_MEM >> 4) & 1;
  int StoreOp_MEM3 = (outputs.StoreOp_MEM >> 3) & 1;
  int StoreOp_MEM2 = (outputs.StoreOp_MEM >> 2) & 1;
  int StoreOp_MEM1 = (outputs.StoreOp_MEM >> 1) & 1;
  int StoreOp_MEM0 = (outputs.StoreOp_MEM >> 0) & 1;
  int Y_MEM15 = (outputs.Y_MEM >> 15) & 1;
  int Y_MEM14 = (outputs.Y_MEM >> 14) & 1;
  int Y_MEM13 = (outputs.Y_MEM >> 13) & 1;
  int Y_MEM12 = (outputs.Y_MEM >> 12) & 1;
  int Y_MEM11 = (outputs.Y_MEM >> 11) & 1;
  int Y_MEM10 = (outputs.Y_MEM >> 10) & 1;
  int Y_MEM9 = (outputs.Y_MEM >> 9) & 1;
  int Y_MEM8 = (outputs.Y_MEM >> 8) & 1;
  int Y_MEM7 = (outputs.Y_MEM >> 7) & 1;
  int Y_MEM6 = (outputs.Y_MEM >> 6) & 1;
  int Y_MEM5 = (outputs.Y_MEM >> 5) & 1;
  int Y_MEM4 = (outputs.Y_MEM >> 4) & 1;
  int Y_MEM3 = (outputs.Y_MEM >> 3) & 1;
  int Y_MEM2 = (outputs.Y_MEM >> 2) & 1;
  int Y_MEM1 = (outputs.Y_MEM >> 1) & 1;
  int Y_MEM0 = (outputs.Y_MEM >> 0) & 1;
  int PC_MEM15 = (outputs.PC_MEM >> 15) & 1;
  int PC_MEM14 = (outputs.PC_MEM >> 14) & 1;
  int PC_MEM13 = (outputs.PC_MEM >> 13) & 1;
  int PC_MEM12 = (outputs.PC_MEM >> 12) & 1;
  int PC_MEM11 = (outputs.PC_MEM >> 11) & 1;
  int PC_MEM10 = (outputs.PC_MEM >> 10) & 1;
  int PC_MEM9 = (outputs.PC_MEM >> 9) & 1;
  int PC_MEM8 = (outputs.PC_MEM >> 8) & 1;
  int PC_MEM7 = (outputs.PC_MEM >> 7) & 1;
  int PC_MEM6 = (outputs.PC_MEM >> 6) & 1;
  int PC_MEM5 = (outputs.PC_MEM >> 5) & 1;
  int PC_MEM4 = (outputs.PC_MEM >> 4) & 1;
  int PC_MEM3 = (outputs.PC_MEM >> 3) & 1;
  int PC_MEM2 = (outputs.PC_MEM >> 2) & 1;
  int PC_MEM1 = (outputs.PC_MEM >> 1) & 1;
  int PC_MEM0 = (outputs.PC_MEM >> 0) & 1;

  int bits[] = {
    D8,
    D7,
    D6,
    D5,
    D4,
    D3,
    D2,
    D1,
    SelC_MEM2,
    SelC_MEM1,
    SelC_MEM0,
    RST,
    RDY,
    Phi1,
    Phi2,
    Flush_IF,
    0, // Don't care, unused
    Ctl_MEM20,
    Ctl_MEM19,
    Ctl_MEM18,
    Ctl_MEM17,
    Ctl_MEM16,
    Ctl_MEM15,
    Ctl_MEM14,
    StoreOp_MEM15,
    StoreOp_MEM14,
    StoreOp_MEM13,
    StoreOp_MEM12,
    StoreOp_MEM11,
    StoreOp_MEM10,
    StoreOp_MEM9,
    StoreOp_MEM8,
    StoreOp_MEM7,
    StoreOp_MEM6,
    StoreOp_MEM5,
    StoreOp_MEM4,
    StoreOp_MEM3,
    StoreOp_MEM2,
    StoreOp_MEM1,
    StoreOp_MEM0,
    Y_MEM15,
    Y_MEM14,
    Y_MEM13,
    Y_MEM12,
    Y_MEM11,
    Y_MEM10,
    Y_MEM9,
    Y_MEM8,
    Y_MEM7,
    Y_MEM6,
    Y_MEM5,
    Y_MEM4,
    Y_MEM3,
    Y_MEM2,
    Y_MEM1,
    Y_MEM0,
    PC_MEM15,
    PC_MEM14,
    PC_MEM13,
    PC_MEM12,
    PC_MEM11,
    PC_MEM10,
    PC_MEM9,
    PC_MEM8,
    PC_MEM7,
    PC_MEM6,
    PC_MEM5,
    PC_MEM4,
    PC_MEM3,
    PC_MEM2,
    PC_MEM1,
    PC_MEM0
  };

  for (int i = 0, n = sizeof(bits)/sizeof(bits[0]); i < n; ++i) {
    digitalWrite(outputPorts.SI, bits[i]==0 ? LOW : HIGH);
    strobeHigh(outputPorts.SCK);
  }

  strobeHigh(outputPorts.RCLK);
}

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

void nextChaseState(int &chaseState, TestFixtureOutputs &outputs) {
  chaseState = (chaseState + 1) % 14;
  switch (chaseState) {
    case  0: outputs.led = 0b00000001; break;
    case  1: outputs.led = 0b00000010; break;
    case  2: outputs.led = 0b00000100; break;
    case  3: outputs.led = 0b00001000; break;
    case  4: outputs.led = 0b00010000; break;
    case  5: outputs.led = 0b00100000; break;
    case  6: outputs.led = 0b01000000; break;
    case  7: outputs.led = 0b10000000; break;
    case  8: outputs.led = 0b01000000; break;
    case  9: outputs.led = 0b00100000; break;
    case 10: outputs.led = 0b00010000; break;
    case 11: outputs.led = 0b00001000; break;
    case 12: outputs.led = 0b00000100; break;
    case 13: outputs.led = 0b00000010; break;
  }
}

void nextFlashState(int &flashState, TestFixtureOutputs &outputs) {
  flashState = (flashState + 1) % 8;
  switch (flashState) {
    case  0: outputs.led = 0b11111111; break;
    case  1: outputs.led = 0b00000000; break;
    case  2: outputs.led = 0b11111111; break;
    case  3: outputs.led = 0b00000000; break;
    case  4: outputs.led = 0b11111111; break;
    case  5: outputs.led = 0b11111111; break;
    case  6: outputs.led = 0b11111111; break;
    case  7: outputs.led = 0b11111111; break;
  }
}

void check(unsigned expected, unsigned actual, const char *path, int lineNumber, const char *message) {
  if (expected == actual) {
    return;
  }

  const char *fileName = strrchr(path, '/') ? strrchr(path, '/') + 1 : path;

  printf("\nFAILED: %s:%d: %s\n", fileName, lineNumber, message);
  printf("\texpected: $%x\n", expected);
  printf("\tactual:   $%x\n\n\n", actual);
  TestFixtureOutputs testFixtureOutputs = {
    .PC_MEM = 0xffff,
    .Y_MEM = 0xffff,
    .StoreOp_MEM = 0xffff,
    .led = 0b11111111,
    .Ctl_MEM = 0b1111111,
    .SelC_MEM = 0b111,
    .rdy = 1,
    .rst = 1,
    .phi1 = 1,
    .phi2 = 1,
    .flush_if = 1,
  };

  int flashState = 0;
  
  while (true) {
    nextFlashState(flashState, testFixtureOutputs);
    updateTestFixtureOutputs(testFixtureOutputPorts, testFixtureOutputs);
    delay(100);
  }
}

#define CHECK(expected, actual, message) do { check(expected, actual, __FILE__, __LINE__, message); } while(0)

void testReset(int &chaseState) {
  printf("%s: ", __FUNCTION__);
  printf("Test reset function");

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
    .led = 0,
    .Ctl_MEM = 0b1111111,
    .SelC_MEM = 0b000,
    .rdy = 1,
    .rst = 0, // Reset cycle
    .phi1 = 0,
    .phi2 = 0,
    .flush_if = 1,
  };
  updateBusOutputs(busOutputPorts, busOutputs);
  nextChaseState(chaseState, testFixtureOutputs);
  updateTestFixtureOutputs(testFixtureOutputPorts, testFixtureOutputs);

  // Pulse the clock
  testFixtureOutputs.phi1 = 1;
  testFixtureOutputs.phi2 = 1;
  nextChaseState(chaseState, testFixtureOutputs);
  updateTestFixtureOutputs(testFixtureOutputPorts, testFixtureOutputs);
  testFixtureOutputs.phi1 = 0;
  testFixtureOutputs.phi2 = 0;
  nextChaseState(chaseState, testFixtureOutputs);
  updateTestFixtureOutputs(testFixtureOutputPorts, testFixtureOutputs);

  // De-assert the reset line
  testFixtureOutputs.rst = 1;
  nextChaseState(chaseState, testFixtureOutputs);
  updateTestFixtureOutputs(testFixtureOutputPorts, testFixtureOutputs);
  
  BusInputs actualBusInputs = updateBusInputs(busInputPorts);
  CHECK(0, actualBusInputs.Bank, "Expect that Bank is zero after reset.");
  
  TestFixtureInputs actualTestFixtureInputs = updateTestFixtureInputs(testFixtureInputPorts);
  printf("a\n");
  CHECK(0b1111, actualTestFixtureInputs.Ctl_WB, "Expect that no control signals are asserted.");

  printf("\n");
}

void testNop(int &chaseState) {
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
    .led = 0,
    .Ctl_MEM = 0b1111111,
    .SelC_MEM = 0b111,
    .rdy = 1,
    .rst = 1,
    .phi1 = 1,
    .phi2 = 1,
    .flush_if = 1,
  };
  updateBusOutputs(busOutputPorts, busOutputs);
  nextChaseState(chaseState, testFixtureOutputs);
  updateTestFixtureOutputs(testFixtureOutputPorts, testFixtureOutputs);

  BusInputs actualBusInputs = updateBusInputs(busInputPorts);
  CHECK(0, actualBusInputs.Bank, "Expect that bank was zero.");
  
  TestFixtureInputs actualTestFixtureInputs = updateTestFixtureInputs(testFixtureInputPorts);
  CHECK(0b1111, actualTestFixtureInputs.Ctl_WB, "Expect that no control signals are asserted.");
  CHECK(0b111, actualTestFixtureInputs.SelC_WB, "Expect that SelC is passed through unmodified.");

  printf("\n");
}

void doAllTests() {
  int chaseState = 7; // we update the chasing LED light pattern during test execution
  testReset(chaseState);
  //testNop(chaseState);
  printf("All tests passed.\n");
}

int serial_putc(char c, FILE *) {
  Serial.write(c);
  return c;
}

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  fdevopen(&serial_putc, 0);
  printf("Starting...\n");
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, HIGH);
  initializeTestFixtureInputs(testFixtureInputPorts);
  initializeTestFixtureOutputs(testFixtureOutputPorts);
  initializeBusInputsAndOutputs(busInputPorts, busOutputPorts);
  doAllTests();
}

void loop() {
  // put your main code here, to run repeatedly:
  TestFixtureOutputs outputs = {
    .PC_MEM = 0xffff,
    .Y_MEM = 0xffff,
    .StoreOp_MEM = 0xffff,
    .led = 0b10101010, // This LED pattern represents a successful test run.
    .Ctl_MEM = 0b1111111,
    .SelC_MEM = 0b111,
    .rdy = 1,
    .rst = 1,
    .phi1 = 1,
    .phi2 = 1,
    .flush_if = 1,
  };
  updateTestFixtureOutputs(testFixtureOutputPorts, outputs);
}
