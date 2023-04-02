#pragma once

struct BusInputs {
  unsigned MemLoad;
  unsigned MemStore;
  unsigned Bank;
  unsigned Addr;
  unsigned IO;
};

struct BusInputPorts {
  int PL;
  int SCK;
  int SO;
  
  void initializeHardware();
  BusInputs read();
};

struct BusOutputs {
  unsigned MemLoad;
  unsigned MemStore;
  unsigned Bank;
  unsigned Addr;
  unsigned IO;
  unsigned OE;
};

struct BusOutputPorts {
  int SI;
  int RCLK;
  int SCK;
  int CLR;

  void initializeHardware();
  void set(const BusOutputs &outputs);
};
