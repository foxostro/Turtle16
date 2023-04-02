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
  
  void initializeHardware();
  TestFixtureInputs read();
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

struct TestFixtureOutputPorts {
  int SI;
  int RCLK;
  int SCK;
  int CLR;

  void initializeHardware();
  void set(const TestFixtureOutputs &outputs);
};
