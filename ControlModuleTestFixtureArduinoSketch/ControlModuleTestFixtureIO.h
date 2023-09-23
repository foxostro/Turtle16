#pragma once

struct TestFixtureInputs {
  unsigned Ins_EX;
  unsigned Ctl_EX;
  unsigned stall;
  unsigned fwd_a;
  unsigned fwd_ex_to_a;
  unsigned fwd_mem_to_a;
  unsigned fwd_b;
  unsigned fwd_ex_to_b;
  unsigned fwd_mem_to_b;
};

struct TestFixtureInputPorts {
  int PL;
  int SCK;
  int SO;
  
  void initializeHardware() const;
  TestFixtureInputs read() const;
};

struct TestFixtureOutputs {
  unsigned SelC_MEM;
  unsigned Ctl_MEM;
  unsigned Ins_ID;
  unsigned c;
  unsigned z;
  unsigned v;
  unsigned n;
  unsigned phi1;
  unsigned phi2;
  unsigned rst;

  TestFixtureOutputs();
  TestFixtureOutputs selC(int index) const;
  TestFixtureOutputs ctl(unsigned value) const;
  TestFixtureOutputs ins(unsigned value) const;
  TestFixtureOutputs carry(bool isActive) const;
  TestFixtureOutputs zero(bool isActive) const;
  TestFixtureOutputs overflow(bool isActive) const;
  TestFixtureOutputs negative(bool isActive) const;
  TestFixtureOutputs tick(unsigned value) const;
  TestFixtureOutputs reset(bool isActive) const;
};

struct TestFixtureOutputPorts {
  int SI;
  int RCLK;
  int SCK;
  int CLR;

  void initializeHardware() const;
  void set(const TestFixtureOutputs &outputs) const;
  TestFixtureOutputs tick(const TestFixtureOutputs &testFixtureOutputs) const;
};

struct LEDOutputs {
  unsigned led;

  LEDOutputs();
  LEDOutputs ledState(unsigned value) const;
};

struct LEDOutputPorts {
  int SI;
  int RCLK;
  int SCK;
  int CLR;

  void initializeHardware() const;
  void set(const LEDOutputs &outputs) const;
};
