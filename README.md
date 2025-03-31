# Z_Utils: Zsh Utility Library

> - _did_: `did:repo:b0c5cd0d85b29543c604c093dd83a1a20eb17af1/blob/main/README.md`
> - _github_: [`z_Utils/README.md`](https://github.com/ChristopherA/z_Utils/blob/main/README.md)
> - _purpose_: Provide overview of the Z_Utils Zsh utility library
> - _copyright_: ©2025 by @ChristopherA, licensed under the [BSD 2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
> - _created_: 2025-03-19 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>
> - _last-updated_: 2025-03-31 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
[![Project Status: WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Version](https://img.shields.io/badge/version-0.1.01-blue.svg)](CHANGELOG.md)

## Project Overview

Z_Utils is a powerful, comprehensive collection of reusable Zsh utility functions that deliver professional-grade shell scripting capabilities. This library enables developers to create more reliable, maintainable, and efficient shell scripts through standardized patterns for common operations.

## Key Benefits

- **Improved Script Reliability**: Consistent error handling and environment validation
- **Professional Output**: Standardized user messaging with proper formatting
- **Development Efficiency**: Avoid rewriting common utility functions
- **Better Maintainability**: Standardized patterns for common operations
- **Reduced Errors**: Well-tested utility functions reduce script bugs

## Integration Patterns

Z_Utils offers multiple ways to leverage its functionality in your scripts:

### Direct Function Usage (Most Common)
Copy specific functions you need directly into your scripts:
```bash
# Example: Including z_Output in your script
function z_Output() {
  # Copy function implementation from src/_Z_Utils.zsh
}

# Then use it
z_Output info "Starting script execution..."
```

### Library Source (For Multiple Functions)
Source the library in your Zsh scripts when you need multiple functions:
```bash
# Option 1: Source with absolute path
source /path/to/_Z_Utils.zsh

# Option 2: Source with dynamic path detection (more portable)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "${SCRIPT_DIR}/path/to/_Z_Utils.zsh"

# Then use any function
z_Output info "Starting script execution..."
z_Ensure_Parent_Path_Exists "/path/to/output/file.txt"
```

### Individual Script Usage (For Specific Tools)
Run the example scripts directly when you need their specific functionality:
```bash
# Using a specific utility script
./src/examples/setup_git_inception_repo.sh /path/to/new/repo

# Using test verification functions
source ./src/function_tests/z_Output_test.sh
```

## Key Features

### Output Management *(v0.1.00+)*

The `z_Output` function provides standardized output with:
- Multiple message types (info, warning, error, debug)
- Consistent formatting with colors and emoji
- Verbosity levels and quiet mode support
- Text wrapping and indentation
- User prompts with defaults

```bash
# Basic output examples
z_Output info "Processing file: $filename"
z_Output warn "Disk space is low"
z_Output error "Failed to connect to server"
z_Output debug "Variable value: $value"

# Prompt example
UserInput=$(z_Output prompt "Enter your name" Default="User")
```

**Real-world example:** Standardizing user feedback in complex multi-stage scripts
```bash
# Problem: Inconsistent user feedback in complex scripts
# Solution: Centralized output management with z_Output

# Initialize output options
typeset -g Output_Color_Enabled=$TRUE
typeset -g Output_Verbose_Mode=$TRUE

# Process stages with consistent feedback
z_Output info "Stage 1: Validating inputs..."
z_Output debug "Input parameters: $@"

if [[ -z "$required_parameter" ]]; then
  z_Output error "Missing required parameter"
  exit 1
fi

z_Output success "Stage 1 complete"
z_Output info "Stage 2: Processing data..."

# Control verbosity for different environments
if [[ "$CI_MODE" == "true" ]]; then
  Output_Verbose_Mode=$FALSE  # Less output in CI environments
fi
```

### Error Handling *(v0.1.00+)*

The `z_Report_Error` function provides centralized error reporting:
- Consistent error formatting
- Integration with output system
- Support for exit codes
- Standard error propagation

```bash
if [[ ! -f "$config_file" ]]; then
  z_Report_Error "Configuration file not found: $config_file" $Exit_Status_IO
  return $?
fi
```

**Real-world example:** Managing errors in complex script hierarchies
```bash
# Problem: Error handling across multiple function calls is inconsistent
# Solution: Standardized error reporting and propagation

# Define error codes
typeset -gi Exit_Status_Success=0
typeset -gi Exit_Status_Error=1
typeset -gi Exit_Status_IO=2
typeset -gi Exit_Status_Invalid_Argument=3

function validate_input() {
  local input="$1"
  
  if [[ -z "$input" ]]; then
    z_Report_Error "Input cannot be empty" $Exit_Status_Invalid_Argument
    return $?  # Propagate error code
  fi
  
  if [[ ! -f "$input" ]]; then
    z_Report_Error "Input file does not exist: $input" $Exit_Status_IO
    return $?  # Propagate error code
  fi
  
  return $Exit_Status_Success
}

# Calling function with error propagation
validate_input "$user_input"
if [[ $? -ne $Exit_Status_Success ]]; then
  # Error already reported by z_Report_Error
  exit $?
fi
```

### Environment Setup *(v0.1.00+)*

The `z_Setup_Environment` function initializes script environments:
- Safe shell options
- Terminal capability detection
- Environment variable initialization
- Version compatibility checks

```bash
# Initialize script environment
z_Setup_Environment || exit $?
```

**Real-world example:** Ensuring consistent environment across different systems
```bash
# Problem: Scripts behave differently across various environments
# Solution: Standardized environment setup with safety measures

#!/usr/bin/env zsh
# My script that needs to work consistently

# Source Z_Utils for environment setup
source "$(dirname "$0")/_Z_Utils.zsh"

# Initialize environment with safety settings
z_Setup_Environment || exit $?
# Now we have:
# - set -e (exit on error)
# - set -u (error on undefined variables) 
# - IFS standardized
# - PATH sanitized
# - Terminal capabilities detected
# - Color support identified
# - Core environment variables defined

# Script can now run with consistent behavior
process_files "$@"
```

### Dependency Checking *(v0.1.00+)*

The `z_Check_Dependencies` function verifies required external tools:
- Check for mandatory dependencies
- Optional dependency support
- User-friendly error reporting

```bash
# Define required tools
typeset -a RequiredTools=("git" "ssh" "jq")
typeset -a OptionalTools=("gh" "fzf")

# Check dependencies
z_Check_Dependencies "RequiredTools" "OptionalTools" || exit $?
```

**Real-world example:** Avoiding runtime failures due to missing tools
```bash
# Problem: Scripts fail in unpredictable ways when dependencies aren't available
# Solution: Upfront dependency verification with clear error messages

#!/usr/bin/env zsh
# Script that relies on external tools

# Source Z_Utils
source "$(dirname "$0")/_Z_Utils.zsh"

# Define dependencies with descriptive names
typeset -a RequiredTools=(
  "git:Required for repository operations"
  "ssh:Required for secure connections"
  "gpg:Required for signing commits"
)

typeset -a OptionalTools=(
  "gh:GitHub CLI for enhanced GitHub integration"
  "fzf:Interactive selection capabilities"
)

# Check dependencies - providing array names, not values
z_Check_Dependencies "RequiredTools" "OptionalTools" || exit $?

# Now we can safely use dependencies, and know which optional tools are available
if [[ $HAS_fzf -eq $TRUE ]]; then
  # Use interactive selection with fzf
  SELECTED_FILE=$(find . -type f | fzf --prompt="Select file: ")
else
  # Fallback to basic selection
  echo "Available files:"
  find . -type f | nl
  echo "Enter number: "
  read file_number
  SELECTED_FILE=$(find . -type f | sed -n "${file_number}p")
fi
```

### Path Management *(v0.1.00+)*

Path utility functions include:
- `z_Ensure_Parent_Path_Exists`: Create directories as needed
- `z_Convert_Path_To_Relative`: User-friendly path conversion

```bash
# Ensure directory exists before writing file
z_Ensure_Parent_Path_Exists "/path/to/output/file.txt" || exit $?

# Get user-friendly path
RelativePath=$(z_Convert_Path_To_Relative "/long/absolute/path/file.txt")
```

**Real-world example:** Safe file operations with path management
```bash
# Problem: File operations fail inconsistently due to missing directories
# Solution: Integrated path validation and creation

#!/usr/bin/env zsh
# Script that writes log files to nested directories

# Source Z_Utils
source "$(dirname "$0")/_Z_Utils.zsh"

# Define log file path with nested directories
LOG_DIR="${HOME}/logs/$(date +%Y)/$(date +%m)/$(date +%d)"
LOG_FILE="${LOG_DIR}/process.log"

# Safely ensure parent directories exist
z_Ensure_Parent_Path_Exists "$LOG_FILE" || exit $?
# Now we can safely write to the log file, knowing all parent directories exist

# For user-friendly output, convert to relative path
DISPLAY_PATH=$(z_Convert_Path_To_Relative "$LOG_FILE")
z_Output info "Writing log to $DISPLAY_PATH"

# Write the log file
echo "Log entry: $(date)" >> "$LOG_FILE"
```

### Resource Cleanup *(v0.1.00+)*

The `z_Cleanup` function provides automatic resource cleanup:
- Temporary file management
- Trap-based cleanup on script exit
- Error state handling

```bash
# Set up cleanup trap
typeset -g Script_Running=$TRUE
trap 'z_Cleanup $FALSE "Script interrupted"' INT TERM
trap 'z_Cleanup $TRUE' EXIT
```

**Real-world example:** Ensuring cleanup even when scripts fail
```bash
# Problem: Scripts leave behind temporary files when interrupted
# Solution: Robust trap-based cleanup mechanism

#!/usr/bin/env zsh
# Script that creates temporary resources

# Source Z_Utils
source "$(dirname "$0")/_Z_Utils.zsh"

# Initialize cleanup tracking
typeset -g Script_Running=$TRUE
typeset -a Temp_Files=()

# Register cleanup handlers
trap 'z_Cleanup $FALSE "Script interrupted"' INT TERM
trap 'z_Cleanup $TRUE' EXIT

# Create temporary file that will be automatically cleaned up
TEMP_CONFIG=$(mktemp)
Temp_Files+=("$TEMP_CONFIG")

# Create temporary directory
TEMP_DIR=$(mktemp -d)
Temp_Files+=("$TEMP_DIR")

# Even if the script fails here, cleanup will still happen
process_data "$TEMP_CONFIG" "$TEMP_DIR"

# Define cleanup function that z_Cleanup will call
function cleanup_Handler() {
  local success=$1
  
  # Custom cleanup logic
  if [[ -n "$DB_CONNECTION" ]]; then
    close_database_connection "$DB_CONNECTION"
  fi
  
  # Return success status
  return $success
}
```

## Documentation

Comprehensive documentation is available in the repository:

- Function specifications: `requirements/project/functions/`
- General guidelines: `requirements/shared/zsh_scripting/`
- Example scripts: `src/examples/`
- Function tests: `src/function_tests/`
- Developer workflows: [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md)

## Compatibility

- Requires Zsh 5.8+ *(core functionality)*
- Git functions require Git 2.28+ *(for initial branch setting)*
- Tested on macOS and Linux
- Terminal-aware with fallbacks for limited environments
- Minimal external dependencies
- All functions include fallback implementations when possible

## Additional Capabilities

Z_Utils includes specialized functionality for:

### Git Operations *(v0.1.01+)*
- Repository initialization with proper signatures
- DID (Decentralized Identifier) generation
- SSH key fingerprint extraction
- Allowed signers configuration
- Commit signature verification
- First commit hash extraction
- Git configuration validation

### Testing Framework *(v0.1.00+)*
- Comprehensive test environment setup
- Test result validation functions
- ANSI color handling in test output
- Test suite organization tools
- Automated test reporting
- Sandbox isolation for Git tests

### Filesystem Operations *(v0.1.00+)*
- Safe directory creation
- Path normalization and validation
- Path conversion (absolute/relative)
- Path existence verification
- Consistent error handling for path operations

## Developer Resources

For developers interested in contributing to Z_Utils:

- [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) - Detailed development workflows
- [WORK_STREAM_TASKS.md](WORK_STREAM_TASKS.md) - Current project status and task tracking

Z_Utils maintains comprehensive documentation:
- Function specifications in `requirements/project/functions/`
- Scripting guidelines in `requirements/shared/zsh_scripting/`
- Working examples in `src/examples/`
- Function tests in `src/function_tests/`

## License

This project is licensed under the [BSD 2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html).

## Contributing

Contributions are welcome! Z_Utils follows a structured development process with focus on quality and maintainability. Please see the project workflow guides in `requirements/guides/` for more information on the development process.