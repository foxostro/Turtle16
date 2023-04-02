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

  BusOutputs();
  BusOutputs memStore(bool isActive);
  BusOutputs memLoad(bool isActive);
  BusOutputs addr(unsigned addr);
  BusOutputs data(unsigned data);
  BusOutputs assertMemLoadStoreLines();
  BusOutputs assertBankLines();
  BusOutputs assertAddrLines();
  BusOutputs assertDataLines();
};

struct BusOutputPorts {
  int SI;
  int RCLK;
  int SCK;
  int CLR;

  void initializeHardware();
  void set(const BusOutputs &outputs);
};
