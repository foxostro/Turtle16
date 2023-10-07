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
  unsigned value = digitalRead(inputPorts.SO)==LOW ? 0 : 1;
  strobeHigh(inputPorts.SCK);
  return value;
}

template<typename InputPorts>
uint32_t readInputWord(int numBits, const InputPorts &inputPorts) {
  uint32_t value = 0;
  for (int i = 0; i < numBits; ++i) {
    uint32_t bit = digitalRead(inputPorts.SO);
    value <<= 1;
    value |= bit;
    strobeHigh(inputPorts.SCK);
  }
  return value;
}

template<typename OutputPorts>
void clearOutputs(const OutputPorts &outputPorts) {
  strobeLow(outputPorts.CLR);
}