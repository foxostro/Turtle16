#!/bin/bash

# Script to build and run the Snap compiler with configurable build configuration

set -e

# Get script directory for sourcing common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Usage information
usage() {
    cat << EOF
Usage: $0 [--debug|--release] <snap-file> [snap-args...]

Build and run the Snap compiler with the specified configuration.

Options:
  --debug     Build and run Debug configuration
  --release   Build and run Release configuration (default)

Examples:
  $0 Examples/hello.snap
  $0 --release Examples/fibonacci.snap
  $0 --debug --help
  $0 --release Examples/programs/calculator.snap --output calculator.tack

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

# Get remaining arguments for Snap
snap_args=("$@")

# Validate we have at least one argument for Snap
if [ ${#snap_args[@]} -eq 0 ]; then
    error "No arguments provided for Snap compiler"
    usage
    exit 1
fi

# Find DerivedData directory
info "Locating TurtleTools DerivedData directory..."
derived_data_dir=$(find_derived_data)
if [ $? -ne 0 ]; then
    exit 1
fi

# Build Snap if needed
info "Ensuring Snap is built..."
if ! build_scheme "Snap" "$config"; then
    exit 1
fi

# Find build products directory
products_dir=$(find_build_products "$config" "$derived_data_dir")
if [ $? -ne 0 ]; then
    exit 1
fi

# Set up DYLD framework path
setup_dyld_path "$products_dir"

# Validate Snap executable exists
snap_executable="$products_dir/Snap"
if ! validate_executable "$snap_executable" "Snap"; then
    exit 1
fi

# Run Snap with provided arguments
info "Running Snap compiler..."
info "Command: $snap_executable ${snap_args[*]}"
echo

exec "$snap_executable" "${snap_args[@]}"