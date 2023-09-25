#pragma once

#include <Arduino.h>

class LEDPatternExecutor {
public:
  // Step the animation internal state.
  virtual void step() = 0;

  // Run the animation forever.
  void runForever() {
    while(1) {
      step();
      delay(100);
    }
  }
};

// Produce a flashing LED pattern to indicate Test Failure.
template<typename OutputPorts, typename Outputs>
class ErrorFlasher : public LEDPatternExecutor {
  OutputPorts ports;
  Outputs outputs;
  int flashState;

public:
  ErrorFlasher(const OutputPorts &ports_) {
    ports = ports_;
    flashState = 0;
    memset(&outputs, 0xff, sizeof(outputs));
  }

  virtual void step() {
    flashState = (flashState + 1) % 8;
    switch (flashState) {
      case  0: outputs.led = 0b11111111; break;
      case  1: outputs.led = 0b00000000; break;
      case  2: outputs.led = 0b11111111; break;
      case  3: outputs.led = 0b00000000; break;
      case  4: outputs.led = 0b11111111; break;
      case  5: outputs.led = 0b11111111; break;
      case  6: outputs.led = 0b11111111; break;
      case  7: outputs.led = 0b11111111; break;
    }
    ports.set(outputs);
  }
};

// Produce a static LED pattern to indicate All Tests Passed.
template<typename OutputPorts, typename Outputs>
class SuccessFlasher : public LEDPatternExecutor {
public:
  OutputPorts ports;
  Outputs outputs;

public:
  SuccessFlasher(const OutputPorts &ports_) :
    ports(ports_)
  {
    memset(&outputs, 0xff, sizeof(outputs));
  }

  virtual void step() {
    outputs.led = 0b10101010; // This LED pattern represents a successful test run.
    ports.set(outputs);
  }
};

// Produce a chasing LED pattern to indicate that progress is being made.
template<typename OutputPorts, typename Outputs>
class Chaser : public LEDPatternExecutor {
  OutputPorts ports;
  Outputs outputs;
  int chaseState;

public:
  unsigned led;

  Chaser(const OutputPorts &ports_) :
    ports(ports_),
    chaseState(7),
    led(0)
  {
    memset(&outputs, 0xff, sizeof(outputs));
  }

  virtual void step() {
    chaseState = (chaseState + 1) % 14;
    switch (chaseState) {
      case  0: led = 0b00000001; break;
      case  1: led = 0b00000010; break;
      case  2: led = 0b00000100; break;
      case  3: led = 0b00001000; break;
      case  4: led = 0b00010000; break;
      case  5: led = 0b00100000; break;
      case  6: led = 0b01000000; break;
      case  7: led = 0b10000000; break;
      case  8: led = 0b01000000; break;
      case  9: led = 0b00100000; break;
      case 10: led = 0b00010000; break;
      case 11: led = 0b00001000; break;
      case 12: led = 0b00000100; break;
      case 13: led = 0b00000010; break;
    }
    outputs.led = led;
    ports.set(outputs);
  }
};