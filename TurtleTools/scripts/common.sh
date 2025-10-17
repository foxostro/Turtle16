#!/bin/bash

# Common utilities for TurtleTools CLI scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored messages
error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

success() {
    echo -e "${GREEN}$1${NC}"
}

warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

info() {
    echo "$1"
}

# Find TurtleTools DerivedData directory
find_derived_data() {
    local derived_data_dir
    derived_data_dir=$(find ~/Library/Developer/Xcode/DerivedData -name "TurtleTools-*" -type d 2>/dev/null | head -1)

    if [ -z "$derived_data_dir" ]; then
        error "Could not find TurtleTools DerivedData directory"
        error "Please build the project in Xcode first"
        return 1
    fi

    echo "$derived_data_dir"
    return 0
}

# Find build products directory for given configuration
find_build_products() {
    local config="$1"
    local derived_data_dir="$2"
    local products_dir

    # Look specifically for Build/Products (not Index.noindex/Build/Products)
    products_dir=$(find "$derived_data_dir" -path "*/Build/Products/$config" -not -path "*/Index.noindex/*" -type d 2>/dev/null | head -1)

    if [ -z "$products_dir" ]; then
        error "Could not find $config build products directory"
        error "Please build the project with configuration $config first"
        return 1
    fi

    echo "$products_dir"
    return 0
}

# Set up DYLD framework path
setup_dyld_path() {
    local products_dir="$1"
    # Include both the products directory and PackageFrameworks subdirectory
    export DYLD_FRAMEWORK_PATH="$products_dir:$products_dir/PackageFrameworks"
    info "Set DYLD_FRAMEWORK_PATH=$products_dir:$products_dir/PackageFrameworks"
}

# Check if xcbeautify is available
has_xcbeautify() {
    command -v xcbeautify >/dev/null 2>&1
}

# Build scheme with specified configuration
build_scheme() {
    local scheme="$1"
    local config="$2"

    info "Building $scheme in $config configuration..."

    # Get the TurtleTools project directory (parent of scripts directory)
    local project_dir="$(cd "$SCRIPT_DIR/.." && pwd)"
    local build_cmd="cd \"$project_dir\" && xcodebuild -scheme \"$scheme\" -configuration \"$config\" build"

    if has_xcbeautify; then
        if ! eval "$build_cmd" | xcbeautify; then
            error "Failed to build $scheme"
            return 1
        fi
    else
        warning "xcbeautify not found - install with: brew install xcbeautify"
        if ! eval "$build_cmd" -quiet; then
            error "Failed to build $scheme"
            return 1
        fi
    fi

    success "Successfully built $scheme ($config)"
    return 0
}

# Validate that executable exists
validate_executable() {
    local executable_path="$1"
    local tool_name="$2"

    if [ ! -f "$executable_path" ]; then
        error "$tool_name executable not found at: $executable_path"
        error "Please build the project first"
        return 1
    fi

    if [ ! -x "$executable_path" ]; then
        error "$tool_name executable is not executable: $executable_path"
        return 1
    fi

    return 0
}

# Parse configuration argument
parse_config() {
    local config="Release" # Default

    if [ "$1" = "--debug" ]; then
        config="Debug"
        shift
    elif [ "$1" = "--release" ]; then
        config="Release"
        shift
    fi

    echo "$config"
}

# Get remaining arguments after config parsing
get_remaining_args() {
    local config_arg="$1"
    shift

    if [ "$config_arg" = "--debug" ] || [ "$config_arg" = "--release" ]; then
        echo "$@"
    else
        echo "$config_arg" "$@"
    fi
}