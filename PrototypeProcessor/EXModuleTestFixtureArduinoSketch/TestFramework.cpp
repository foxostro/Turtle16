#include <stdio.h>
#include <string.h>
#include "TestFramework.h"

LEDPatternExecutor *g_errorFlasher;

void doAssertEqual(unsigned expected, unsigned actual, const char *path, int lineNumber, const char *message) {
  if (expected == actual) {
    return;
  }

  const char *fileName = strrchr(path, '/') ? strrchr(path, '/') + 1 : path;

  printf("\nFAILED: %s:%d: %s\n", fileName, lineNumber, message);
  printf("\texpected: $%x\n", expected);
  printf("\tactual:   $%x\n\n\n", actual);
  g_errorFlasher->runForever();
}