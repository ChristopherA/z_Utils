# Z_Utils: Zsh Utility Library

> - _did_: `did:repo:b0c5cd0d85b29543c604c093dd83a1a20eb17af1/blob/main/README.md`
> - _github_: [`z_Utils/README.md`](https://github.com/ChristopherA/z_Utils/blob/main/README.md)
> - _purpose_: Provide overview of the Z_Utils Zsh utility library
> - _copyright_: ©2025 by @ChristopherA, licensed under the [BSD 2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
> - _created_: 2025-03-19 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>
> - _last-updated_: 2025-03-22 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
[![Project Status: WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Version](https://img.shields.io/badge/version-0.1.00-blue.svg)](CHANGELOG.md)

## Project Overview

Z_Utils is a comprehensive collection of reusable Zsh utility functions designed to provide consistent, robust, and efficient scripting capabilities. This library helps maintain high-quality shell scripting practices across projects by implementing standardized approaches to common operations.

## Key Benefits

- **Improved Script Reliability**: Consistent error handling and environment validation
- **Professional Output**: Standardized user messaging with proper formatting
- **Development Efficiency**: Avoid rewriting common utility functions
- **Better Maintainability**: Standardized patterns for common operations
- **Reduced Errors**: Well-tested utility functions reduce script bugs

## Getting Started

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/ChristopherA/z_Utils.git
   ```

2. Source the library in your Zsh scripts:
   ```bash
   source /path/to/_Z_Utils.zsh
   ```

3. Start using Z_Utils functions in your scripts:
   ```bash
   z_Output info "Starting script execution..."
   ```

## Key Features

### Output Management

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

### Error Handling

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

### Environment Setup

The `z_Setup_Environment` function initializes script environments:
- Safe shell options
- Terminal capability detection
- Environment variable initialization
- Version compatibility checks

```bash
# Initialize script environment
z_Setup_Environment || exit $?
```

### Dependency Checking

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

### Path Management

Path utility functions include:
- `z_Ensure_Parent_Path_Exists`: Create directories as needed
- `z_Convert_Path_To_Relative`: User-friendly path conversion

```bash
# Ensure directory exists before writing file
z_Ensure_Parent_Path_Exists "/path/to/output/file.txt" || exit $?

# Get user-friendly path
RelativePath=$(z_Convert_Path_To_Relative "/long/absolute/path/file.txt")
```

### Resource Cleanup

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

## Documentation

Comprehensive documentation is available in the repository:

- Function specifications: `requirements/project/functions/`
- General guidelines: `requirements/shared/zsh_scripting/`
- Example scripts: `src/examples/`
- Function tests: `src/function_tests/`

## Compatibility

- Requires Zsh 5.8+
- Tested on macOS and Linux
- Minimal external dependencies
- Terminal-aware with fallbacks for limited environments

## Development

Z_Utils follows a structured development process:

1. Requirements documentation in `requirements/`
2. Implementation in `src/_Z_Utils.zsh`
3. Function-specific tests in `src/function_tests/`
4. Example scripts in `src/examples/`
5. Comprehensive test suite in `src/tests/`

See [PROJECT_GUIDE.md](PROJECT_GUIDE.md) for development workflow details and [WORK_STREAM_TASKS.md](WORK_STREAM_TASKS.md) for current project status.

## License

This project is licensed under the [BSD 2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html).

## Contributing

Contributions are welcome. Please see the project workflow guides in `requirements/guides/` for more information on the development process.