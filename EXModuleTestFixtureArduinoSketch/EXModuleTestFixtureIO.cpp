#include <Arduino.h>
#include <stdio.h>
#include "ShiftRegisterIO.h"
#include "EXModuleTestFixtureIO.h"

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
  unsigned unused = readInputWord(2, inputPorts);
  unsigned SelC_MEM = readInputWord(3, inputPorts);
  unsigned N = readInputBit(inputPorts);
  unsigned V = readInputBit(inputPorts);
  unsigned Z = readInputBit(inputPorts);
  unsigned C = readInputBit(inputPorts);
  unsigned Ctl_MEM = readInputWord(7, inputPorts);
  unsigned StoreOp_MEM = readInputWord(16, inputPorts);
  unsigned Y_MEM = readInputWord(16, inputPorts);
  unsigned Y_EX = readInputWord(16, inputPorts);

  TestFixtureInputs testFixtureInputs = {
    .SelC_MEM = SelC_MEM,
    .N = N,
    .V = V,
    .Z = Z,
    .C = C,
    .Ctl_MEM = Ctl_MEM,
    .StoreOp_MEM = StoreOp_MEM,
    .Y_MEM = Y_MEM,
    .Y_EX = Y_EX
  };

  return testFixtureInputs;
}

TestFixtureInputs TestFixtureInputPorts::read() const {
  return updateTestFixtureInputs(*this);
}

TestFixtureOutputs::TestFixtureOutputs() :
  phi1_(0),
  PC_EX_(0),
  B_(0),
  A_(0),
  Ins_EX_(0),
  Ctl_EX_(0b111111111111111111111) {
}

TestFixtureOutputs TestFixtureOutputs::phi1(unsigned value) const{
  TestFixtureOutputs result = *this;
  result.phi1_ = value;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::pc(unsigned value) const{
  TestFixtureOutputs result = *this;
  result.PC_EX_ = value;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::b(unsigned value) const{
  TestFixtureOutputs result = *this;
  result.B_ = value;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::a(unsigned value) const{
  TestFixtureOutputs result = *this;
  result.A_ = value;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::ins(unsigned value) const {
  TestFixtureOutputs result = *this;
  result.Ins_EX_ = value;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::ctl(unsigned value) const {
  TestFixtureOutputs result = *this;
  result.Ctl_EX_ = value;
  return result;
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
  // Rev A Hardware Requires the Input bits to be read in this order.
  // These are named after the corresponding nets in the KiCad schematic:
  int Phi1 = outputs.phi1_ & 1;
  int PC_EX15 = (outputs.PC_EX_ >> 15) & 1;
  int PC_EX14 = (outputs.PC_EX_ >> 14) & 1;
  int PC_EX13 = (outputs.PC_EX_ >> 13) & 1;
  int PC_EX12 = (outputs.PC_EX_ >> 12) & 1;
  int PC_EX11 = (outputs.PC_EX_ >> 11) & 1;
  int PC_EX10 = (outputs.PC_EX_ >> 10) & 1;
  int PC_EX9  = (outputs.PC_EX_ >>  9) & 1;
  int PC_EX8  = (outputs.PC_EX_ >>  8) & 1;
  int PC_EX7  = (outputs.PC_EX_ >>  7) & 1;
  int PC_EX6  = (outputs.PC_EX_ >>  6) & 1;
  int PC_EX5  = (outputs.PC_EX_ >>  5) & 1;
  int PC_EX4  = (outputs.PC_EX_ >>  4) & 1;
  int PC_EX3  = (outputs.PC_EX_ >>  3) & 1;
  int PC_EX2  = (outputs.PC_EX_ >>  2) & 1;
  int PC_EX1  = (outputs.PC_EX_ >>  1) & 1;
  int PC_EX0  = (outputs.PC_EX_ >>  0) & 1;
  int B15 = (outputs.B_ >> 15) & 1;
  int B14 = (outputs.B_ >> 14) & 1;
  int B13 = (outputs.B_ >> 13) & 1;
  int B12 = (outputs.B_ >> 12) & 1;
  int B11 = (outputs.B_ >> 11) & 1;
  int B10 = (outputs.B_ >> 10) & 1;
  int B9  = (outputs.B_ >>  9) & 1;
  int B8  = (outputs.B_ >>  8) & 1;
  int B7  = (outputs.B_ >>  7) & 1;
  int B6  = (outputs.B_ >>  6) & 1;
  int B5  = (outputs.B_ >>  5) & 1;
  int B4  = (outputs.B_ >>  4) & 1;
  int B3  = (outputs.B_ >>  3) & 1;
  int B2  = (outputs.B_ >>  2) & 1;
  int B1  = (outputs.B_ >>  1) & 1;
  int B0  = (outputs.B_ >>  0) & 1;
  int A15 = (outputs.A_ >> 15) & 1;
  int A14 = (outputs.A_ >> 14) & 1;
  int A13 = (outputs.A_ >> 13) & 1;
  int A12 = (outputs.A_ >> 12) & 1;
  int A11 = (outputs.A_ >> 11) & 1;
  int A10 = (outputs.A_ >> 10) & 1;
  int A9  = (outputs.A_ >>  9) & 1;
  int A8  = (outputs.A_ >>  8) & 1;
  int A7  = (outputs.A_ >>  7) & 1;
  int A6  = (outputs.A_ >>  6) & 1;
  int A5  = (outputs.A_ >>  5) & 1;
  int A4  = (outputs.A_ >>  4) & 1;
  int A3  = (outputs.A_ >>  3) & 1;
  int A2  = (outputs.A_ >>  2) & 1;
  int A1  = (outputs.A_ >>  1) & 1;
  int A0  = (outputs.A_ >>  0) & 1;
  int Ins_EX10 = (outputs.Ins_EX_ >> 10) & 1;
  int Ins_EX9  = (outputs.Ins_EX_ >>  9) & 1;
  int Ins_EX8  = (outputs.Ins_EX_ >>  8) & 1;
  int Ins_EX7  = (outputs.Ins_EX_ >>  7) & 1;
  int Ins_EX6  = (outputs.Ins_EX_ >>  6) & 1;
  int Ins_EX5  = (outputs.Ins_EX_ >>  5) & 1;
  int Ins_EX4  = (outputs.Ins_EX_ >>  4) & 1;
  int Ins_EX3  = (outputs.Ins_EX_ >>  3) & 1;
  int Ins_EX2  = (outputs.Ins_EX_ >>  2) & 1;
  int Ins_EX1  = (outputs.Ins_EX_ >>  1) & 1;
  int Ins_EX0  = (outputs.Ins_EX_ >>  0) & 1;
  int Ctl_EX20 = (outputs.Ctl_EX_ >> 20) & 1;
  int Ctl_EX19 = (outputs.Ctl_EX_ >> 19) & 1;
  int Ctl_EX18 = (outputs.Ctl_EX_ >> 18) & 1;
  int Ctl_EX17 = (outputs.Ctl_EX_ >> 17) & 1;
  int Ctl_EX16 = (outputs.Ctl_EX_ >> 16) & 1;
  int Ctl_EX15 = (outputs.Ctl_EX_ >> 15) & 1;
  int Ctl_EX14 = (outputs.Ctl_EX_ >> 14) & 1;
  int Ctl_EX13 = (outputs.Ctl_EX_ >> 13) & 1;
  int Ctl_EX12 = (outputs.Ctl_EX_ >> 12) & 1;
  int Ctl_EX11 = (outputs.Ctl_EX_ >> 11) & 1;
  int Ctl_EX10 = (outputs.Ctl_EX_ >> 10) & 1;
  int Ctl_EX9  = (outputs.Ctl_EX_ >>  9) & 1;
  int Ctl_EX8  = (outputs.Ctl_EX_ >>  8) & 1;
  int Ctl_EX7  = (outputs.Ctl_EX_ >>  7) & 1;
  int Ctl_EX6  = (outputs.Ctl_EX_ >>  6) & 1;
  int Ctl_EX5  = (outputs.Ctl_EX_ >>  5) & 1;
  int Ctl_EX4  = (outputs.Ctl_EX_ >>  4) & 1;
  int Ctl_EX3  = (outputs.Ctl_EX_ >>  3) & 1;
  int Ctl_EX2  = (outputs.Ctl_EX_ >>  2) & 1;
  int Ctl_EX1  = (outputs.Ctl_EX_ >>  1) & 1;
  int Ctl_EX0  = (outputs.Ctl_EX_ >>  0) & 1;

  int bits[] = {
    Phi1,
    PC_EX15,
    PC_EX14,
    PC_EX13,
    PC_EX12,
    PC_EX11,
    PC_EX10,
    PC_EX9,
    PC_EX8,
    PC_EX7,
    PC_EX6,
    PC_EX5,
    PC_EX4,
    PC_EX3,
    PC_EX2,
    PC_EX1,
    PC_EX0,
    B15,
    B14,
    B13,
    B12,
    B11,
    B10,
    B9,
    B8,
    B7,
    B6,
    B5,
    B4,
    B3,
    B2,
    B1,
    B0,
    A15,
    A14,
    A13,
    A12,
    A11,
    A10,
    A9,
    A8,
    A7,
    A6,
    A5,
    A4,
    A3,
    A2,
    A1,
    A0,
    Ins_EX10,
    Ins_EX9,
    Ins_EX8,
    Ins_EX7,
    Ins_EX6,
    Ins_EX5,
    Ins_EX4,
    Ins_EX3,
    Ins_EX2,
    Ins_EX1,
    Ins_EX0,
    Ctl_EX20,
    Ctl_EX19,
    Ctl_EX18,
    Ctl_EX17,
    Ctl_EX16,
    Ctl_EX15,
    Ctl_EX14,
    Ctl_EX13,
    Ctl_EX12,
    Ctl_EX11,
    Ctl_EX10,
    Ctl_EX9,
    Ctl_EX8,
    Ctl_EX7,
    Ctl_EX6,
    Ctl_EX5,
    Ctl_EX4,
    Ctl_EX3,
    Ctl_EX2,
    Ctl_EX1,
    Ctl_EX0,
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

TestFixtureOutputs TestFixtureOutputPorts::tick(const TestFixtureOutputs &testFixtureOutputs_) const {
  TestFixtureOutputs testFixtureOutputs = testFixtureOutputs_;
  testFixtureOutputs = testFixtureOutputs
    .phi1(0);
  set(testFixtureOutputs);
  testFixtureOutputs = testFixtureOutputs
    .phi1(1);
  set(testFixtureOutputs);
  testFixtureOutputs = testFixtureOutputs
    .phi1(0);
  set(testFixtureOutputs);
  return testFixtureOutputs;
}

LEDOutputs::LEDOutputs() :
  led(0) {
}

LEDOutputs LEDOutputs::ledState(unsigned value) const {
  LEDOutputs result = *this;
  result.led = value;
  return result;
}

void LEDOutputPorts::initializeHardware() const {
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

static void updateLEDOutputs(const LEDOutputPorts &outputPorts, const LEDOutputs &outputs) {
  // Rev A Hardware Requires the Input bits to be read in this order.
  // These are named after the corresponding nets in the KiCad schematic:
  int D8 = (outputs.led >> 7) & 1;
  int D7 = (outputs.led >> 6) & 1;
  int D6 = (outputs.led >> 5) & 1;
  int D5 = (outputs.led >> 4) & 1;
  int D4 = (outputs.led >> 3) & 1;
  int D3 = (outputs.led >> 2) & 1;
  int D2 = (outputs.led >> 1) & 1;
  int D1 = (outputs.led >> 0) & 1;

  int bits[] = {
    D8,
    D7,
    D6,
    D5,
    D4,
    D3,
    D2,
    D1
  };

  for (int i = 0, n = sizeof(bits)/sizeof(bits[0]); i < n; ++i) {
    digitalWrite(outputPorts.SI, bits[i]==0 ? LOW : HIGH);
    strobeHigh(outputPorts.SCK);
  }

  strobeHigh(outputPorts.RCLK);
}

void LEDOutputPorts::set(const LEDOutputs &outputs) const {
  updateLEDOutputs(*this, outputs);
}
