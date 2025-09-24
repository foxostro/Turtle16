#!/bin/bash

# Test script for Examples directory
# Uses --debug flag for better error diagnostics

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/common.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
COMPILE_PASS=0
COMPILE_FAIL=0
RUN_PASS=0
RUN_FAIL=0
TEST_PASS=0
TEST_FAIL=0

echo -e "${BLUE}=== Testing Example Programs ===${NC}"
echo ""

# Function to test compilation only
test_compile() {
    local file="$1"
    local basename_file=$(basename "$file")

    echo -n "Compile $basename_file: "
    if ./scripts/snap-run.sh --debug -q "$file" -S -o /tmp/test.asm &>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
        ((COMPILE_PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((COMPILE_FAIL++))
        return 1
    fi
}

# Function to test program execution (for programs without tests)
test_run() {
    local file="$1"
    local basename_file=$(basename "$file")

    echo -n "Run $basename_file: "
    if timeout 5 ./scripts/snap-run.sh --debug run "$file" &>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
        ((RUN_PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((RUN_FAIL++))
        return 1
    fi
}

# Function to test program tests (for programs with test blocks)
test_tests() {
    local file="$1"
    local basename_file=$(basename "$file")

    echo -n "Test $basename_file: "
    if timeout 10 ./scripts/snap-run.sh --debug test "$file" &>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
        ((TEST_PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((TEST_FAIL++))
        return 1
    fi
}

cd "$PROJECT_DIR"

echo -e "${YELLOW}--- Compilation Tests ---${NC}"
find ./Examples -name "*.snap" -type f ! -path "*/old/*" | sort | while read -r file; do
    test_compile "$file"
done

echo ""
echo -e "${YELLOW}--- Execution Tests (programs without tests) ---${NC}"
for file in Examples/hello.snap Examples/fib.snap; do
    if test_compile "$file"; then
        test_run "$file"
    fi
done

echo ""
echo -e "${YELLOW}--- Test Suite Execution ---${NC}"
for file in Examples/SnapLanguageTests.snap Examples/malloc.snap Examples/ReceiveFile.snap Examples/printU8.snap; do
    if test_compile "$file"; then
        test_tests "$file"
    fi
done

echo ""
echo -e "${YELLOW}--- Benchmark Programs ---${NC}"
for file in Examples/benchmarks/*.snap; do
    if test_compile "$file"; then
        test_run "$file"
    fi
done

echo ""
echo -e "${BLUE}=== Summary ===${NC}"
echo "Compilation: ${GREEN}$COMPILE_PASS passed${NC}, ${RED}$COMPILE_FAIL failed${NC}"
echo "Execution: ${GREEN}$RUN_PASS passed${NC}, ${RED}$RUN_FAIL failed${NC}"
echo "Test Suites: ${GREEN}$TEST_PASS passed${NC}, ${RED}$TEST_FAIL failed${NC}"

total_pass=$((COMPILE_PASS + RUN_PASS + TEST_PASS))
total_fail=$((COMPILE_FAIL + RUN_FAIL + TEST_FAIL))
echo "Total: ${GREEN}$total_pass passed${NC}, ${RED}$total_fail failed${NC}"

if [ $total_fail -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi