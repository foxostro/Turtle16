#!/bin/bash

# Script to build and run SnapBenchmark with configurable build configuration

set -e

# Get script directory for sourcing common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Usage information
usage() {
    cat << EOF
Usage: $0 [--debug|--release] <benchmark-args...>

Build and run SnapBenchmark with the specified configuration.

Options:
  --debug     Build and run Debug configuration
  --release   Build and run Release configuration (default)

Examples:
  $0 Examples/benchmarks/fibonacci.snap
  $0 --release Examples/benchmarks/micro.snap
  $0 --debug --cache Examples/benchmarks/pathological.snap
  $0 --release --help

Common SnapBenchmark options:
  --cache     Enable type checking cache (disabled by default)
  <file.snap> Benchmark file to run

EOF
}

# Check for help or no arguments
if [ $# -eq 0 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    usage
    exit 0
fi

# Parse configuration
config=$(parse_config "$1")
if [ "$1" = "--debug" ] || [ "$1" = "--release" ]; then
    shift
fi

# Get remaining arguments for SnapBenchmark
benchmark_args=("$@")

# Validate we have at least one argument for SnapBenchmark
if [ ${#benchmark_args[@]} -eq 0 ]; then
    error "No arguments provided for SnapBenchmark"
    usage
    exit 1
fi

# Find DerivedData directory
info "Locating TurtleTools DerivedData directory..."
derived_data_dir=$(find_derived_data)
if [ $? -ne 0 ]; then
    exit 1
fi

# Build SnapBenchmark if needed
info "Ensuring SnapBenchmark is built..."
if ! build_scheme "SnapBenchmark" "$config"; then
    exit 1
fi

# Find build products directory
products_dir=$(find_build_products "$config" "$derived_data_dir")
if [ $? -ne 0 ]; then
    exit 1
fi

# Set up DYLD framework path
setup_dyld_path "$products_dir"

# Validate SnapBenchmark executable exists
benchmark_executable="$products_dir/SnapBenchmark"
if ! validate_executable "$benchmark_executable" "SnapBenchmark"; then
    exit 1
fi

# Run SnapBenchmark with provided arguments
info "Running SnapBenchmark..."
info "Command: $benchmark_executable ${benchmark_args[*]}"
echo

exec "$benchmark_executable" "${benchmark_args[@]}"