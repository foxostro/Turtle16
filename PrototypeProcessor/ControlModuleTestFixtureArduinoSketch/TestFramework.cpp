#include <stdio.h>
#include <string.h>
#include "TestFramework.h"

LEDPatternExecutor *g_errorFlasher;

void doAssertEqual(uint32_t expected, uint32_t actual, const char *path, int lineNumber, const char *message) {
  if (expected == actual) {
    return;
  }

  const char *fileName = strrchr(path, '/') ? strrchr(path, '/') + 1 : path;

  printf("\nFAILED: %s:%d: %s\n", fileName, lineNumber, message);
  printf("\texpected: $%lx\n", expected);
  printf("\tactual:   $%lx\n\n\n", actual);
  g_errorFlasher->runForever();
}