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
  SelC_MEM_(0),
  Ctl_MEM_(0b1111111),
  Ins_ID_(0),
  carry_(0),
  zero_(0),
  overflow_(0),
  negative_(0),
  phi1_(0),
  phi2_(1),
  rst_(1) {
}

TestFixtureOutputs TestFixtureOutputs::selC(int index) const {
  TestFixtureOutputs result = *this;
  result.SelC_MEM_ = index;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::ctl(unsigned value) const {
  TestFixtureOutputs result = *this;
  result.Ctl_MEM_ = value;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::ins(unsigned value) const {
  TestFixtureOutputs result = *this;
  result.Ins_ID_ = value;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::carry(bool isActive) const {
  TestFixtureOutputs result = *this;
  result.carry_ = isActive ? 1 : 0;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::zero(bool isActive) const {
  TestFixtureOutputs result = *this;
  result.zero_ = isActive ? 1 : 0;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::overflow(bool isActive) const {
  TestFixtureOutputs result = *this;
  result.overflow_ = isActive ? 1 : 0;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::negative(bool isActive) const {
  TestFixtureOutputs result = *this;
  result.negative_ = isActive ? 1 : 0;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::phi1(unsigned value) const {
  TestFixtureOutputs result = *this;
  result.phi1_ = value;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::phi2(unsigned value) const {
  TestFixtureOutputs result = *this;
  result.phi2_ = value;
  return result;
}

TestFixtureOutputs TestFixtureOutputs::reset(bool isActive) const {
  TestFixtureOutputs result = *this;
  result.rst_ = isActive ? 0 : 1;
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
  int RST = outputs.rst_ & 1;
  int Phi2 = outputs.phi2_ & 1;
  int Phi1 = outputs.phi1_ & 1;
  int n = outputs.negative_ & 1;
  int v = outputs.overflow_ & 1;
  int z = outputs.zero_ & 1;
  int c = outputs.carry_ & 1;
  int Ins_ID15 = (outputs.Ins_ID_ >> 15) & 1;
  int Ins_ID14 = (outputs.Ins_ID_ >> 14) & 1;
  int Ins_ID13 = (outputs.Ins_ID_ >> 13) & 1;
  int Ins_ID12 = (outputs.Ins_ID_ >> 12) & 1;
  int Ins_ID11 = (outputs.Ins_ID_ >> 11) & 1;
  int Ins_ID10 = (outputs.Ins_ID_ >> 10) & 1;
  int Ins_ID9  = (outputs.Ins_ID_ >>  9) & 1;
  int Ins_ID8  = (outputs.Ins_ID_ >>  8) & 1;
  int Ins_ID7  = (outputs.Ins_ID_ >>  7) & 1;
  int Ins_ID6  = (outputs.Ins_ID_ >>  6) & 1;
  int Ins_ID5  = (outputs.Ins_ID_ >>  5) & 1;
  int Ins_ID4  = (outputs.Ins_ID_ >>  4) & 1;
  int Ins_ID3  = (outputs.Ins_ID_ >>  3) & 1;
  int Ins_ID2  = (outputs.Ins_ID_ >>  2) & 1;
  int Ins_ID1  = (outputs.Ins_ID_ >>  1) & 1;
  int Ins_ID0  = (outputs.Ins_ID_ >>  0) & 1;
  int Ctl_MEM20 = (outputs.Ctl_MEM_ >> 6) & 1;
  int Ctl_MEM19 = (outputs.Ctl_MEM_ >> 5) & 1;
  int Ctl_MEM18 = (outputs.Ctl_MEM_ >> 4) & 1;
  int Ctl_MEM17 = (outputs.Ctl_MEM_ >> 3) & 1;
  int Ctl_MEM16 = (outputs.Ctl_MEM_ >> 2) & 1;
  int Ctl_MEM15 = (outputs.Ctl_MEM_ >> 1) & 1;
  int Ctl_MEM14 = (outputs.Ctl_MEM_ >> 0) & 1;
  int SelC_MEM2 = (outputs.SelC_MEM_ >> 2) & 1;
  int SelC_MEM1 = (outputs.SelC_MEM_ >> 1) & 1;
  int SelC_MEMO = (outputs.SelC_MEM_ >> 0) & 1;

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
  testFixtureOutputs = testFixtureOutputs
    .phi1(0)
    .phi2(1);
  set(testFixtureOutputs);
  testFixtureOutputs = testFixtureOutputs
    .phi1(1)
    .phi2(0);
  set(testFixtureOutputs);
  testFixtureOutputs = testFixtureOutputs
    .phi1(0)
    .phi2(1);
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
