#include <Arduino.h>
#include <stdio.h>
#include "ShiftRegisterIO.h"
#include "BusIO.h"

void BusInputPorts::initializeHardware() const {
  pinMode(PL,  OUTPUT);
  pinMode(SCK, OUTPUT);
  pinMode(SO,  INPUT);

  digitalWrite(PL, HIGH);
  digitalWrite(SCK, HIGH);
}

static BusInputs updateBusInputs(const BusInputPorts &inputPorts) {
  strobeLow(inputPorts.PL);

  // Rev A Hardware Requires the bus Input bits to be read in this order.
  // These are named after the corresponding nets in the KiCad schematic:
  unsigned dontCare0 = readInputBit(inputPorts);
  unsigned dontCare1 = readInputBit(inputPorts);
  unsigned dontCare2 = readInputBit(inputPorts);
  unsigned MemLoad = readInputBit(inputPorts);
  unsigned MemStore = readInputBit(inputPorts);
  unsigned Bank = readInputWord(3, inputPorts);
  unsigned Addr = readInputWord(16, inputPorts);
  unsigned IO = readInputWord(16, inputPorts);

  BusInputs busInputs = {
    .MemLoad = MemLoad,
    .MemStore = MemStore,
    .Bank = Bank,
    .Addr = Addr,
    .IO = IO
  };

  return busInputs;
}

BusInputs BusInputPorts::read() const {
  return updateBusInputs(*this);
}

BusOutputs::BusOutputs() :
  MemLoad(1),
  MemStore(1),
  Bank(0),
  Addr(0),
  IO(0),
  OE(0b111111) {
}

BusOutputs BusOutputs::memStore(bool isActive) {
  BusOutputs result = *this;
  result.MemStore = isActive ? 0 : 1; // active low
  return result;
}

BusOutputs BusOutputs::memLoad(bool isActive) {
  BusOutputs result = *this;
  result.MemLoad = isActive ? 0 : 1; // active low
  return result;
}

BusOutputs BusOutputs::addr(unsigned value) {
  BusOutputs result = *this;
  result.Addr = value;
  return result;
}

BusOutputs BusOutputs::data(unsigned value) {
  BusOutputs result = *this;
  result.IO = value;
  return result;
}

BusOutputs BusOutputs::assertMemLoadStoreLines() {
  BusOutputs result = *this;
  result.OE &= 0b011111;
  return result;
}

BusOutputs BusOutputs::assertBankLines() {
  BusOutputs result = *this;
  result.OE &= 0b101111;
  return result;
}

BusOutputs BusOutputs::assertAddrLines() {
  BusOutputs result = *this;
  result.OE &= 0b110011;
  return result;
}

BusOutputs BusOutputs::assertDataLines() {
  BusOutputs result = *this;
  result.OE &= 0b111100;
  return result;
}

void BusOutputPorts::initializeHardware() const {
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

static void updateBusOutputs(const BusOutputPorts &outputPorts, const BusOutputs &outputs) {
  // Rev A Hardware Requires the Output bits to be pushed in this order.
  // These are named after the corresponding nets in the KiCad schematic:
  int bits[] = {
    0,
    0,
    (outputs.OE >> 6) & 1,
    (outputs.OE >> 5) & 1,
    (outputs.OE >> 4) & 1,
    (outputs.OE >> 3) & 1,
    (outputs.OE >> 2) & 1,
    (outputs.OE >> 1) & 1,
    (outputs.OE >> 0) & 1,
    0,
    0,
    0,
    0,
    0,
    0,
    outputs.MemStore & 1,
    outputs.MemLoad & 1,
    0,
    0,
    0,
    0,
    0,
    (outputs.Bank >> 2) & 1,
    (outputs.Bank >> 1) & 1,
    (outputs.Bank >> 0) & 1,
    (outputs.Addr >> 15) & 1,
    (outputs.Addr >> 14) & 1,
    (outputs.Addr >> 13) & 1,
    (outputs.Addr >> 12) & 1,
    (outputs.Addr >> 11) & 1,
    (outputs.Addr >> 10) & 1,
    (outputs.Addr >> 9) & 1,
    (outputs.Addr >> 8) & 1,
    (outputs.Addr >> 7) & 1,
    (outputs.Addr >> 6) & 1,
    (outputs.Addr >> 5) & 1,
    (outputs.Addr >> 4) & 1,
    (outputs.Addr >> 3) & 1,
    (outputs.Addr >> 2) & 1,
    (outputs.Addr >> 1) & 1,
    (outputs.Addr >> 0) & 1,
    (outputs.IO >> 15) & 1,
    (outputs.IO >> 14) & 1,
    (outputs.IO >> 13) & 1,
    (outputs.IO >> 12) & 1,
    (outputs.IO >> 11) & 1,
    (outputs.IO >> 10) & 1,
    (outputs.IO >> 9) & 1,
    (outputs.IO >> 8) & 1,
    (outputs.IO >> 7) & 1,
    (outputs.IO >> 6) & 1,
    (outputs.IO >> 5) & 1,
    (outputs.IO >> 4) & 1,
    (outputs.IO >> 3) & 1,
    (outputs.IO >> 2) & 1,
    (outputs.IO >> 1) & 1,
    (outputs.IO >> 0) & 1
  };

  for (int i = 0, n = sizeof(bits)/sizeof(bits[0]); i < n; ++i) {
    digitalWrite(outputPorts.SI, bits[i]==0 ? LOW : HIGH);
    strobeHigh(outputPorts.SCK);
  }

  strobeHigh(outputPorts.RCLK);
}

void BusOutputPorts::set(const BusOutputs &outputs) const {
  updateBusOutputs(*this, outputs);
}