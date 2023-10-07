#pragma once

#include "LEDPattern.h"

extern LEDPatternExecutor *g_errorFlasher;

void doAssertEqual(uint32_t expected, uint32_t actual, const char *path, int lineNumber, const char *message);

#define assertEqual(expected, actual, message) do { doAssertEqual(expected, actual, __FILE__, __LINE__, message); } while(0)