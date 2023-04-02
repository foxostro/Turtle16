#pragma once

#include "LEDPattern.h"

extern LEDPatternExecutor *g_errorFlasher;

void doAssertEqual(unsigned expected, unsigned actual, const char *path, int lineNumber, const char *message);

#define asssertEqual(expected, actual, message) do { doAssertEqual(expected, actual, __FILE__, __LINE__, message); } while(0)