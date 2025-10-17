#!/bin/bash

# Script to build and run the TackCompilerValidationSuite tool with configurable build configuration

set -e

# Get script directory for sourcing common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Usage information
usage() {
    cat << EOF
Usage: $0 [--debug|--release] [test-args...] [test-name...]

Build and run the TackCompilerValidationSuite tool with the specified configuration.

Options:
  --debug     Build and run Debug configuration
  --release   Build and run Release configuration (default)

Test Arguments:
  --list-tests        List all available test names
  --jobs, -j N        Number of concurrent jobs to use
  --log-level LEVEL   Log level (trace, debug, info, notice, warning, error, critical)
  --help              Show TackCompilerValidationSuite help
  test-name...        Test names to run (e.g., tackADDB tackMULW). Omit to run all tests.

Examples:
  $0                              # Run all tests
  $0 tackADDB                     # Run single test
  $0 tackADDB tackMULW            # Run multiple tests
  $0 --list-tests                 # List available tests
  $0 --debug tackNEGB             # Run test in Debug configuration
  $0 --jobs 4 tackADDB tackMULW   # Run tests with 4 concurrent jobs

EOF
}

# Check for help
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    usage
    exit 0
fi

# Parse configuration
config=$(parse_config "$1")
if [ "$1" = "--debug" ] || [ "$1" = "--release" ]; then
    shift
fi

# Get remaining arguments for ExhaustiveTackTests
test_args=("$@")

# Find DerivedData directory
info "Locating TurtleTools DerivedData directory..."
derived_data_dir=$(find_derived_data)
if [ $? -ne 0 ]; then
    exit 1
fi

# Build TackCompilerValidationSuite if needed
info "Ensuring TackCompilerValidationSuite is built..."
if ! build_scheme "TackCompilerValidationSuite" "$config"; then
    exit 1
fi

# Find build products directory
products_dir=$(find_build_products "$config" "$derived_data_dir")
if [ $? -ne 0 ]; then
    exit 1
fi

# Set up DYLD framework path
setup_dyld_path "$products_dir"

# Validate TackCompilerValidationSuite executable exists
test_executable="$products_dir/TackCompilerValidationSuite"
if ! validate_executable "$test_executable" "TackCompilerValidationSuite"; then
    exit 1
fi

# Run TackCompilerValidationSuite with provided arguments
if [ ${#test_args[@]} -eq 0 ]; then
    info "Running all Tack compiler validation tests..."
    info "Command: $test_executable"
else
    info "Running TackCompilerValidationSuite..."
    info "Command: $test_executable ${test_args[*]}"
fi
echo

exec "$test_executable" "${test_args[@]}"
