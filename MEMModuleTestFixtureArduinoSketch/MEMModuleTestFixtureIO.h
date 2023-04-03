#pragma once

struct TestFixtureInputs {
  unsigned Ins_IF;
  unsigned StoreOp_WB;
  unsigned Y_WB;
  unsigned Ctl_WB;
  unsigned SelC_WB;
};

struct TestFixtureInputPorts {
  int PL;
  int SCK;
  int SO;
  
  void initializeHardware() const;
  TestFixtureInputs read() const;
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

  TestFixtureOutputs();
  TestFixtureOutputs ready(bool isActive) const;
  TestFixtureOutputs reset(bool isActive) const;
  TestFixtureOutputs tick(unsigned value) const;
  TestFixtureOutputs addr(unsigned value) const;
  TestFixtureOutputs storeOp(unsigned value) const;
  TestFixtureOutputs memLoad(bool isActive) const;
  TestFixtureOutputs memStore(bool isActive) const;
  TestFixtureOutputs selC(int index) const;
  TestFixtureOutputs ledState(unsigned value) const;
  TestFixtureOutputs pc(unsigned value) const;
  TestFixtureOutputs flushInstruction(bool isActive) const;
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
