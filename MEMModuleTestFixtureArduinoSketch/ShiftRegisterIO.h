#pragma once

#include <Arduino.h>

static inline void strobeLow(int pin) {
  digitalWrite(pin, HIGH);
  digitalWrite(pin, LOW);
  digitalWrite(pin, HIGH);
}

static inline void strobeHigh(int pin) {
  digitalWrite(pin, LOW);
  digitalWrite(pin, HIGH);
  digitalWrite(pin, LOW);
}

template<typename InputPorts>
unsigned readInputBit(const InputPorts &inputPorts) {
  strobeHigh(inputPorts.SCK);
  unsigned value = digitalRead(inputPorts.SO)==LOW ? 0 : 1;
  printf("readInputBit: %d\n", value);
  return value;
}

template<typename InputPorts>
unsigned readInputWord(int numBits, const InputPorts &inputPorts) {
  unsigned value = 0;
  for (int i = 0; i < numBits; ++i) {
    strobeHigh(inputPorts.SCK);
    unsigned bit = digitalRead(inputPorts.SO);
    value <<= 1;
    value |= bit;
  }
  return value;
}

template<typename OutputPorts>
void clearOutputs(const OutputPorts &outputPorts) {
  strobeLow(outputPorts.CLR);
}