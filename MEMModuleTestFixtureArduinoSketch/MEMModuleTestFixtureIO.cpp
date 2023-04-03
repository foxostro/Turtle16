#include <Arduino.h>
#include <stdio.h>
#include "ShiftRegisterIO.h"
#include "MEMModuleTestFixtureIO.h"

void TestFixtureInputPorts::initializeHardware() const {
  pinMode(PL,  OUTPUT);
  pinMode(SCK, OUTPUT);
  pinMode(SO,  INPUT);

  digitalWrite(PL, HIGH);
  digitalWrite(SCK, HIGH);
}

static TestFixtureInputs updateTestFixtureInputs(const TestFixtureInputPorts &inputPorts) {
  strobeLow(inputPorts.PL);

  // Rev A Hardware Requires the Input bits to be read in this order.
  // These are named after the corresponding nets in the KiCad schematic:
  unsigned unused = readInputBit(inputPorts);
  unsigned SelC_WB = readInputWord(3, inputPorts);
  unsigned Ctl_WB = readInputWord(4, inputPorts);
  unsigned StoreOp_WB = readInputWord(16, inputPorts);
  unsigned Ins_IF = readInputWord(16, inputPorts);
  unsigned Y_WB = readInputWord(16, inputPorts);

  TestFixtureInputs testFixtureInputs = {
    .Ins_IF = Ins_IF,
    .StoreOp_WB = StoreOp_WB,
    .Y_WB = Y_WB,
    .Ctl_WB = Ctl_WB,
    .SelC_WB = SelC_WB,
  };

  return testFixtureInputs;
}

TestFixtureInputs TestFixtureInputPorts::read() const {
  return updateTestFixtureInputs(*this);
}

void TestFixtureOutputPorts::initializeHardware() const {
  pinMode(SI,   OUTPUT);
  pinMode(RCLK, OUTPUT);
  pinMode(SCK,  OUTPUT);
  pinMode(CLR,  OUTPUT);

  digitalWrite(SI, HIGH);
  digitalWrite(SCK, HIGH);
  digitalWrite(RCLK, HIGH);
  digitalWrite(CLR, HIGH);

  clearOutputs(*this);
}

static void updateTestFixtureOutputs(const TestFixtureOutputPorts &outputPorts, const TestFixtureOutputs &outputs) {
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

void TestFixtureOutputPorts::set(const TestFixtureOutputs &outputs) const {
  updateTestFixtureOutputs(*this, outputs);
}
