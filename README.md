# Z_Utils: Zsh Utility Library

> - _did_: `did:repo:b0c5cd0d85b29543c604c093dd83a1a20eb17af1/blob/main/README.md`
> - _github_: [`z_Utils/README.md`](https://github.com/ChristopherA/z_Utils/blob/main/README.md)
> - _purpose_: Provide overview of the Z_Utils Zsh utility library
> - _copyright_: ©2025 by @ChristopherA, licensed under the [BSD 2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
> - _created_: 2025-03-19 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>
> - _last-updated_: 2025-03-21 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
[![Project Status: WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Version](https://img.shields.io/badge/version-0.1.00-blue.svg)](CHANGELOG.md)

## Project Overview

Z_Utils is a collection of reusable Zsh utility functions designed to provide consistent, robust, and efficient scripting capabilities. This library helps maintain high-quality shell scripting practices across projects.

## Purpose

Z_Utils serves two main purposes:

1. **Consistent Scripting**: Provide reusable functions for reliable shell scripting
2. **Best Practices**: Implement shell scripting best practices in a reusable format

## Getting Started

1. Clone this repository
2. Source the library in your Zsh scripts: `source /path/to/_Z_Utils.zsh`
3. Use Z_Utils functions in your scripts: `z_Output info "Hello, World!"`

## Key Features

- **Output Management**: Standardized output with formatting, colors, and emoji support
- **Error Handling**: Consistent error reporting and propagation
- **Environment Setup**: Script environment initialization and validation
- **Dependency Checking**: Verify required tools and commands
- **Path Management**: Utilities for handling file paths
- **Resource Cleanup**: Automatic cleanup of temporary resources

## Utility Functions

The library includes several core utility functions:

- `z_Output`: Standardized formatted output with multiple message types
- `z_Report_Error`: Centralized error reporting
- `z_Check_Dependencies`: Verify required external commands
- `z_Ensure_Parent_Path_Exists`: Create parent directories as needed
- `z_Setup_Environment`: Initialize script environment
- `z_Cleanup`: Handle script termination cleanup
- `z_Convert_Path_To_Relative`: Convert paths to user-friendly formats

## Development Workflow

The Z_Utils project follows a structured development process with:

- Detailed requirements documentation
- Function-level tests
- Comprehensive example scripts
- Task tracking in WORK_STREAM_TASKS.md

## Requirements and Documentation

- Detailed function requirements are in `requirements/project/functions/`
- General Zsh scripting requirements are in `requirements/shared/zsh_scripting/`
- Example scripts showing usage are in `src/examples/`
- Function tests are in `src/function_tests/`

## Compatibility

- Requires Zsh 5.8+
- Tested on macOS and Linux
- Minimal external dependencies

## License

This project is licensed under the [BSD 2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html).

## Contributing

Contributions are welcome. Please see the project workflow guides in `requirements/guides/` for more information.