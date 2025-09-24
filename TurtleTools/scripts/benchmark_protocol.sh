#!/bin/bash
# Performance Measurement Protocol for Compiler Benchmarking
# Usage: ./benchmark_protocol.sh

set -e

# Get script directory and source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

echo "=== Compiler Performance Baseline Measurement Protocol ==="
echo "Timestamp: $(date)"
echo "Build Configuration: RELEASE mode"
echo "Iterations per benchmark: 1000"
echo

# Find DerivedData and build products
derived_data_dir=$(find_derived_data)
if [ $? -ne 0 ]; then
    exit 1
fi

products_dir=$(find_build_products "Release" "$derived_data_dir")
if [ $? -ne 0 ]; then
    exit 1
fi

# Build SnapBenchmark in Release mode
if ! build_scheme "SnapBenchmark" "Release"; then
    exit 1
fi

# Set up DYLD and validate executable
setup_dyld_path "$products_dir"
benchmark_executable="$products_dir/SnapBenchmark"
if ! validate_executable "$benchmark_executable" "SnapBenchmark"; then
    exit 1
fi

echo "Running standardized benchmark suite..."
echo

for run in {1..5}; do
    echo "=== Run $run ==="

    echo "Fibonacci (baseline):"
    "$benchmark_executable" Examples/benchmarks/fibonacci.snap | grep "Compile took"

    echo "Micro (function calls):"
    "$benchmark_executable" Examples/benchmarks/micro.snap | grep "Compile took"

    echo "Macro (complex calculations):"
    "$benchmark_executable" Examples/benchmarks/macro.snap | grep "Compile took"

    echo "Pathological (deep nesting):"
    "$benchmark_executable" Examples/benchmarks/pathological.snap | grep "Compile took"

    echo
done

echo "=== Measurement Protocol Complete ==="
echo "Note: Each benchmark compiles the program 1000 times and reports average compilation time"
echo "This protocol should be run before and after cache implementation for comparison"