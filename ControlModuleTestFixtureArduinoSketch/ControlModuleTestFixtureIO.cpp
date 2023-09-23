#include <Arduino.h>
#include <stdio.h>
#include "ShiftRegisterIO.h"
#include "ControlModuleTestFixtureIO.h"

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
  unsigned fwd_mem_to_b = readInputBit(inputPorts);
  unsigned fwd_ex_to_b = readInputBit(inputPorts);
  unsigned fwd_b = readInputBit(inputPorts);
  unsigned fwd_mem_to_a = readInputBit(inputPorts);
  unsigned fwd_ex_to_a = readInputBit(inputPorts);
  unsigned fwd_a = readInputBit(inputPorts);
  unsigned stall = readInputBit(inputPorts);
  unsigned Ctl_EX = readInputWord(21, inputPorts);
  unsigned Ins_EX = readInputWord(11, inputPorts);

  TestFixtureInputs testFixtureInputs = {
    .Ins_EX = Ins_EX,
    .Ctl_EX = Ctl_EX,
    .stall = stall,
    .fwd_a = fwd_a,
    .fwd_ex_to_a = fwd_ex_to_a,
    .fwd_mem_to_a = fwd_mem_to_a,
    .fwd_b = fwd_b,
    .fwd_ex_to_b = fwd_ex_to_b,
    .fwd_mem_to_b = fwd_mem_to_b
  };

  return testFixtureInputs;
}

TestFixtureInputs TestFixtureInputPorts::read() const {
  return updateTestFixtureInputs(*this);
}

TestFixtureOutputs::TestFixtureOutputs() :
  SelC_MEM(0),
  Ctl_MEM(0b1111111),
  Ins_ID(0),
  c(0),
  z(0),
  v(0),
  n(0),
  phi1(0),
  phi2(0),
  rst(1) {
}

TestFixtureOutputs TestFixtureOutputs::selC(int index) const {
  TestFixtureOutputs result = *this;
  result.SelC_MEM = index;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::ctl(unsigned value) const {
  TestFixtureOutputs result = *this;
  result.Ctl_MEM = value;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::ins(unsigned value) const {
  TestFixtureOutputs result = *this;
  result.Ins_ID = value;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::carry(bool isActive) const {
  TestFixtureOutputs result = *this;
  result.c = isActive ? 1 : 0;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::zero(bool isActive) const {
  TestFixtureOutputs result = *this;
  result.z = isActive ? 1 : 0;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::overflow(bool isActive) const {
  TestFixtureOutputs result = *this;
  result.v = isActive ? 1 : 0;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::negative(bool isActive) const {
  TestFixtureOutputs result = *this;
  result.n = isActive ? 1 : 0;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::tick(unsigned value) const {
  TestFixtureOutputs result = *this;
  result.phi1 = value;
  result.phi2 = value;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::reset(bool isActive) const {
  TestFixtureOutputs result = *this;
  result.rst = isActive ? 0 : 1;
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
  int RST = outputs.rst & 1;
  int Phi2 = outputs.phi2 & 1;
  int Phi1 = outputs.phi1 & 1;
  int n = outputs.n & 1;
  int v = outputs.v & 1;
  int z = outputs.z & 1;
  int c = outputs.c & 1;
  int Ins_ID15 = (outputs.Ins_ID >> 15) & 1;
  int Ins_ID14 = (outputs.Ins_ID >> 14) & 1;
  int Ins_ID13 = (outputs.Ins_ID >> 13) & 1;
  int Ins_ID12 = (outputs.Ins_ID >> 12) & 1;
  int Ins_ID11 = (outputs.Ins_ID >> 11) & 1;
  int Ins_ID10 = (outputs.Ins_ID >> 10) & 1;
  int Ins_ID9  = (outputs.Ins_ID >>  9) & 1;
  int Ins_ID8  = (outputs.Ins_ID >>  8) & 1;
  int Ins_ID7  = (outputs.Ins_ID >>  7) & 1;
  int Ins_ID6  = (outputs.Ins_ID >>  6) & 1;
  int Ins_ID5  = (outputs.Ins_ID >>  5) & 1;
  int Ins_ID4  = (outputs.Ins_ID >>  4) & 1;
  int Ins_ID3  = (outputs.Ins_ID >>  3) & 1;
  int Ins_ID2  = (outputs.Ins_ID >>  2) & 1;
  int Ins_ID1  = (outputs.Ins_ID >>  1) & 1;
  int Ins_ID0  = (outputs.Ins_ID >>  0) & 1;
  int Ctl_MEM20 = (outputs.Ctl_MEM >> 6) & 1;
  int Ctl_MEM19 = (outputs.Ctl_MEM >> 5) & 1;
  int Ctl_MEM18 = (outputs.Ctl_MEM >> 4) & 1;
  int Ctl_MEM17 = (outputs.Ctl_MEM >> 3) & 1;
  int Ctl_MEM16 = (outputs.Ctl_MEM >> 2) & 1;
  int Ctl_MEM15 = (outputs.Ctl_MEM >> 1) & 1;
  int Ctl_MEM14 = (outputs.Ctl_MEM >> 0) & 1;
  int SelC_MEM2 = (outputs.SelC_MEM >> 2) & 1;
  int SelC_MEM1 = (outputs.SelC_MEM >> 1) & 1;
  int SelC_MEMO = (outputs.SelC_MEM >> 0) & 1;

  int bits[] = {
    RST,
    Phi2,
    Phi1,
    n,
    v,
    z,
    c,
    Ins_ID15,
    Ins_ID14,
    Ins_ID13,
    Ins_ID12,
    Ins_ID11,
    Ins_ID10,
    Ins_ID9,
    Ins_ID8,
    Ins_ID7,
    Ins_ID6,
    Ins_ID5,
    Ins_ID4,
    Ins_ID3,
    Ins_ID2,
    Ins_ID1,
    Ins_ID0,
    Ctl_MEM20,
    Ctl_MEM19,
    Ctl_MEM18,
    Ctl_MEM17,
    Ctl_MEM16,
    Ctl_MEM15,
    Ctl_MEM14,
    SelC_MEM2,
    SelC_MEM1,
    SelC_MEMO
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
  testFixtureOutputs = testFixtureOutputs.tick(1);
  set(testFixtureOutputs);
  testFixtureOutputs = testFixtureOutputs.tick(0);
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
