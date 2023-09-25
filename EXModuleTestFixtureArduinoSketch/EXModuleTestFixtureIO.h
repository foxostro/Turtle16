#pragma once

struct TestFixtureInputs {
  unsigned SelC_MEM;
  unsigned N;
  unsigned V;
  unsigned Z;
  unsigned C;
  unsigned Ctl_MEM;
  unsigned StoreOp_MEM;
  unsigned Y_MEM;
  unsigned Y_EX;
};

struct TestFixtureInputPorts {
  int PL;
  int SCK;
  int SO;
  
  void initializeHardware() const;
  TestFixtureInputs read() const;
};

struct TestFixtureOutputs {
  unsigned phi1_;
  unsigned PC_EX_;
  unsigned B_;
  unsigned A_;
  unsigned Ins_EX_;
  unsigned Ctl_EX_;

  TestFixtureOutputs();
  TestFixtureOutputs phi1(unsigned value) const;
  TestFixtureOutputs pc(unsigned value) const;
  TestFixtureOutputs b(unsigned value) const;
  TestFixtureOutputs a(unsigned value) const;
  TestFixtureOutputs ins(unsigned value) const;
  TestFixtureOutputs ctl(unsigned value) const;
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
