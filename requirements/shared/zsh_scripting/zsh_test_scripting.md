# Z_Utils Test Scripts Requirements
> - _did: `did:repo:b0c5cd0d85b29543c604c093dd83a1a20eb17af1/blob/main/requirements/shared/zsh_scripting/zsh_test_scripting.md`_
> - _github: [`z_Utils/requirements/shared/zsh_scripting/zsh_test_scripting.md`](https://github.com/ChristopherA/z_Utils/blob/main/requirements/shared/zsh_scripting/zsh_test_scripting.md)_
> - _Updated: 2025-03-31 by Christopher Allen <ChristopherA@LifeWithAlacrity.com> Github/Twitter/Bluesky: @ChristopherA_
> - _Original: [`did:repo:69c8659959f1a6aa281bdc1b8653b381e741b3f6/src/requirements/REQUIREMENTS-Regression_Test_Scripts.md`](https://github.com/OpenIntegrityProject/core/blob/main/src/requirements/REQUIREMENTS-Regression_Test_Scripts.md)_

[![License](https://img.shields.io/badge/License-BSD_2--Clause--Patent-blue.svg)](https://spdx.org/licenses/BSD-2-Clause-Patent.html)  
[![Project Status: Active](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)  
[![Version](https://img.shields.io/badge/version-0.3.0-blue.svg)](CHANGELOG.md)

# Introduction
Z_Utils includes two distinct types of test scripts - **function tests** and **regression tests**. Both are **lightweight, targeted tests** designed to verify different aspects of our Zsh scripts. All tests should remain **concise and focused** on relevant verification needs.

- **Function Tests**: Focus on verifying individual functions within the Z_Utils library, with detailed testing of parameters, options, behavior, and edge cases.
- **Regression Tests**: Focus on verifying complete scripts and their behavior, ensuring they handle parameters correctly and maintain expected functionality over time.

## File Organization and Naming Conventions

Test files should follow a consistent organization and naming convention:

### Function Tests
- **Location**: `/src/function_tests/`
- **Basic Function Test Naming**: `z_FunctionName_FUNCTEST.sh`
- **Specialized Function Tests**: `z_FunctionName_purpose_FUNCTEST.sh` (e.g., `z_Output_debug_FUNCTEST.sh`)
- **Comprehensive Tests**: `z_FunctionName_comprehensive_FUNCTEST.sh`
- **Modular Tests**: `z_FunctionName_modular_FUNCTEST.sh` (when using modular approach)
- **Output Files**: `/src/function_tests/output/z_FunctionName_FUNCTEST_output.txt`
- **Template Files**: `function_test_template.sh`

### Regression Tests
- **Location**: `/src/examples/tests/`
- **Naming Convention**: `ScriptName_REGRESSION.sh`
- **Output Reference Files**: `ScriptName_REGRESSION_output.txt`
- **Test Data Directory**: `/src/examples/tests/data/`

This organization ensures that tests are easily discoverable and maintainable, with a clear separation between function tests and regression tests.

This document outlines the **requirements and best practices** for both function tests and regression tests. If testing needs become more extensive—requiring complex mocking, full test suites, or structured test frameworks—consider refactoring into a **broader testing strategy** aligned with the Zsh Framework Scripting Best Practices.

All test scripts must follow:
- **[Zsh Core Scripting Best Practices](zsh_core_scripting.md)**
- **[Zsh Snippet Script Best Practices](zsh_snippet_scripting.md)**

This document covers considerations specific to both types of test scripts.

## Key Differences Between Function Tests and Regression Tests

| Aspect | Function Tests | Regression Tests |
|--------|---------------|-----------------|
| **Purpose** | Test individual functions within the Z_Utils library | Test complete scripts and their behavior |
| **Location** | `/src/function_tests/` | `/src/examples/tests/` |
| **Naming** | `z_FunctionName_test.sh` | `ScriptName_REGRESSION.sh` |
| **Focus** | Function parameters, options, edge cases | Script CLI arguments, workflows, integration |
| **Testing Level** | Unit testing | Integration testing |
| **Test Coverage** | Detailed coverage of all function features | Coverage of key user workflows |
| **Output** | Detailed output showing function behavior | Comparison to expected reference output |
| **Success Criteria** | All test cases pass with expected behavior | Output matches reference files or patterns |

# Standardized Test Functions

Z_Utils provides a set of standardized test functions to ensure consistent test structure, output handling, and state management across all test files. These functions are available in `_Z_Utils.zsh` and should be used in all new test scripts and when updating existing test scripts.

## Core Standardized Test Functions

### z_Handle_Test_Output

Controls where test output is sent - to the terminal only or both terminal and file.

```zsh
z_Handle_Test_Output "test_name" "FUNCTEST|REGRESSION" ["save"]
```

- **Parameters:**
  - `$1` - Test name for the output file
  - `$2` - Test type (FUNCTEST or REGRESSION)
  - `$3` - (Optional) Set to "save" to save output to a file (defaults to "terminal")

### z_Save_Global_Test_State

Saves the global state variables before test execution for later restoration.

```zsh
z_Save_Global_Test_State
```

- Saves output mode state (verbose, quiet, debug)
- Preserves other global variables that might be modified during testing

### z_Restore_Global_Test_State

Restores global state variables from saved state after test execution.

```zsh
z_Restore_Global_Test_State
```

- Restores output mode state
- Returns global environment to pre-test condition

### z_Parse_Test_Args

Parses command-line arguments for test scripts with standardized options.

```zsh
z_Parse_Test_Args "$@"
```

- **Sets global variables:**
  - `Test_Save_Output` - "terminal" or "save" based on `-s` or `--save` flag
  - `Test_Show_Help` - 1 if `-h` or `--help` flag present, 0 otherwise
  - `Test_Run_All` - 1 if no specific test modules specified, 0 otherwise
  - `Test_Specific_Modules` - Array of test modules to run when specified with `--module`

## Using Standardized Test Functions

All new test scripts should use these standardized functions. Here's how to implement them:

```zsh
#!/usr/bin/env zsh
# z_FunctionName_FUNCTEST.sh - Test suite for z_FunctionName function

# Basic setup
SCRIPT_DIR="${0:a:h}"
LIB_DIR="${SCRIPT_DIR:h}"
source "${LIB_DIR}/_Z_Utils.zsh"

# Script filename without extension (for output files)
typeset SCRIPT_NAME="${${(%):-%N}:r}"

# Define test modules...
function run_Basic_Tests() {
    # Save global state
    z_Save_Global_Test_State
    
    # Test code...
    
    # Restore global state
    z_Restore_Global_Test_State
}

# Run the test if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    # Parse command line arguments
    z_Parse_Test_Args "$@"
    
    # Check for help flag
    if (( Test_Show_Help == 1 )); then
        print "Usage: $0 [OPTIONS]"
        print "  -s, --save      Save output to file (default: terminal only)"
        print "  --basic         Run only basic functionality tests"
        print "  -h, --help      Display this help message"
        exit 0
    fi
    
    # Configure test output
    z_Handle_Test_Output "$SCRIPT_NAME" "FUNCTEST" "$Test_Save_Output"
    
    # Determine which tests to run
    if (( Test_Run_All == 1 )); then
        # Run all tests
        run_All_Tests
    else
        # Run specific modules
        for module in "${Test_Specific_Modules[@]}"; do
            case "$module" in
                basic)
                    run_Basic_Tests
                    ;;
                # Additional test modules...
            esac
        done
    fi
fi
```

# Function Test Requirements

Function tests focus on thoroughly testing individual functions within the Z_Utils library. They're designed to verify that each function works correctly under various conditions, with different parameters, and in edge cases.

## Purpose and Scope of Function Tests

Function tests serve as unit tests for the Z_Utils library components. Their primary purposes are:

1. **Function Verification**: Ensure each function behaves as expected with valid inputs
2. **Parameter Testing**: Verify that all parameters and options work correctly
3. **Edge Case Handling**: Test boundary conditions and unusual inputs
4. **Mode Interaction**: Verify behavior when system modes change (verbose, debug, quiet)
5. **Documentation by Example**: Provide clear usage examples for developers

These tests are crucial for maintaining the stability and reliability of core library functions. They serve as both verification tools and documentation, showing how functions should be used in different contexts.

## Function Test Structure

Z_Utils function tests should follow a modular, incremental structure that promotes both maintainability and thorough testing. This approach breaks testing into logical modules that can be run independently or together.

### Basic Test Structure

A well-structured function test follows this organization:

```zsh
#!/usr/bin/env zsh
# z_FunctionName_test.sh - Test suite for z_FunctionName function
# 
# Version:       1.0.00 (YYYY-MM-DD)
# Origin:        https://github.com/ChristopherA/z_Utils
# Description:   Test suite for the z_FunctionName function
# License:       BSD-2-Clause-Patent
# Copyright:     (c) YYYY Christopher Allen
# Attribution:   Authored by @ChristopherA <ChristopherA@LifeWithAlacrity.com>

# Ensure we can find the Z_Utils library
SCRIPT_DIR="${0:a:h}"
LIB_DIR="${SCRIPT_DIR:h}"
source "${LIB_DIR}/_Z_Utils.zsh"

# Reset the shell environment to a known state
emulate -LR zsh
setopt errexit nounset pipefail localoptions warncreateglobal

# Main test function
function run_FunctionName_Tests() {
    print "Testing z_FunctionName..."
    
    # Test case 1: Basic functionality
    print "\n1. Basic functionality:"
    # Test code...
    
    # Test case 2: Parameter variations
    print "\n2. Parameter variations:"
    # Test code...
    
    # Additional test cases...
    
    print "\nAll z_FunctionName tests completed successfully"
    return 0
}

# Run the test if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    run_FunctionName_Tests
fi
```

### Modular, Incremental Test Structure

For more complex functions, use a modular structure that separates tests into logical units:

```zsh
#!/usr/bin/env zsh
# z_FunctionName_test.sh - Test suite for z_FunctionName function
# 
# Version:       1.0.00 (YYYY-MM-DD)
# Origin:        https://github.com/ChristopherA/z_Utils
# Description:   Test suite for the z_FunctionName function
# License:       BSD-2-Clause-Patent
# Copyright:     (c) YYYY Christopher Allen
# Attribution:   Authored by @ChristopherA <ChristopherA@LifeWithAlacrity.com>

# Ensure we can find the Z_Utils library
SCRIPT_DIR="${0:a:h}"
LIB_DIR="${SCRIPT_DIR:h}"
source "${LIB_DIR}/_Z_Utils.zsh"

# Reset the shell environment to a known state
emulate -LR zsh
setopt errexit nounset pipefail localoptions warncreateglobal

# Basic functionality tests
function run_FunctionName_Basic_Tests() {
    # Save initial state
    typeset -i Initial_State=$Some_Global_Variable
    
    print "============================================================"
    print "z_FunctionName Basic Tests"
    print "============================================================"
    
    # Test basic functionality
    print "\n1. Basic operations:"
    # Basic test code...
    
    # Restore state
    Some_Global_Variable=$Initial_State
    return 0
}

# Parameter variation tests
function run_FunctionName_Parameter_Tests() {
    # Save initial state
    typeset -i Initial_State=$Some_Global_Variable
    
    print "============================================================"
    print "z_FunctionName Parameter Tests"
    print "============================================================"
    
    # Test parameter variations
    print "\n1. Required parameters:"
    # Parameter test code...
    
    # Restore state
    Some_Global_Variable=$Initial_State
    return 0
}

# Additional test modules...

# Run all tests in sequence
function run_FunctionName_All_Tests() {
    print "============================================================"
    print "z_FunctionName Complete Test Suite"
    print "============================================================"
    
    # Run each test module
    run_FunctionName_Basic_Tests
    run_FunctionName_Parameter_Tests
    # Additional test modules...
    
    print "\n============================================================"
    print "All z_FunctionName tests completed successfully."
    print "============================================================"
    
    return 0
}

# Run the test if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    # By default, run all tests
    run_FunctionName_All_Tests
    
    # To run specific test modules, uncomment the desired line(s):
    # run_FunctionName_Basic_Tests
    # run_FunctionName_Parameter_Tests
}
```

This modular approach provides several advantages:
1. Tests can be run individually during development
2. Test failure is isolated to specific modules
3. Each test module can properly manage state
4. The structure scales well for complex functions

## Incremental Testing Approach

For complex functions, an incremental testing approach is recommended:

1. **Start with a simple test**: Begin with basic functionality tests that verify core behavior
2. **Add test cases incrementally**: Gradually add more complex test cases once basics work
3. **Build up to edge cases**: After core functionality is verified, test boundary conditions
4. **Test mode interactions**: Verify behavior under different system mode settings
5. **Document results clearly**: Ensure test output clearly shows what's being tested

This approach helps isolate issues and makes tests more maintainable and debuggable.

# Regression Test Requirements

Regression test scripts focus on verifying the correctness and robustness of complete Zsh scripts, particularly in handling different CLI arguments and error scenarios. The goal is to catch regressions early by systematically exercising all defined options and variations in script execution.

## Purpose and Scope of Regression Tests

Regression tests are especially useful when scripts accept user input, interact with the environment, or manipulate files. By checking both expected behaviors and edge cases, they help maintain reliability over time. While not required for the smaller Zsh Snippet scripts (50 - 200 lines of code), they are still recommended to ensure ongoing script stability.

These regression tests are designed to be simple and efficient. They should not introduce unnecessary complexity, require large mock environments, or involve detailed performance benchmarking. Instead, they should focus on ensuring scripts handle valid and invalid inputs as expected, with clear error messages and predictable behavior.

## Handling Changes to Expected Exit Codes

When architectural decisions change the expected exit code behavior of scripts, regression tests must be updated carefully to maintain accuracy while preserving the history of these changes.

### Requirements for Exit Code Changes

1. **Documentation of Exit Code Changes**
   - When expected exit codes change due to architectural decisions, the reason MUST be documented in:
     - The script's ISSUES document (e.g., ISSUES-script_name.md)
     - The script's CHANGELOG entry
     - The test script itself as a clear comment

2. **Test Script Updates**
   - When updating test expectations for exit codes:
     - Add comments explaining the architectural change and its date
     - Update all affected test cases with consistent exit code expectations
     - Update any patterns that match output containing exit code information

3. **Reference Output File Updates**
   - When exit code changes require updating reference output files:
     - Include the update as a separate commit from code changes
     - Document the specific exit code changes in the commit message
     - Include before/after examples in the commit message

4. **Transition Period Handling**
   - For major exit code behavior changes, consider:
     - Adding temporary compatibility test modes
     - Documenting the deprecation timeline
     - Providing migration examples

### Example Documentation for Exit Code Changes

```zsh
# The following test now expects exit code 0 (success) instead of 1 (failure)
# ARCHITECTURAL CHANGE (2025-03-04): Non-zero exit codes now only represent 
# issues with local verification phases (1-3). Issues with remote phases (4-5)
# are reported as warnings but don't affect the exit code.
run_test "GitHub compliance" \
  "$SCRIPT_PATH --no-prompt -C $TEST_REPO_PATH" \
  0 \  # Previously expected 1
  "Audit Complete: Git repo .* in compliance with Open Integrity specification"
```

## Security Considerations

When creating regression test scripts, consider the following security guidelines:
- Never use real sensitive data in test cases
- Avoid executing commands with elevated privileges
- Sanitize and validate all test inputs
- Use temporary directories with restricted permissions
- Ensure test scripts cannot modify system-critical files or configurations
- Implement input validation to prevent potential injection risks
- Log test activities securely, avoiding exposure of sensitive information

## Performance and Efficiency

Regression test scripts should:
- Execute quickly, typically completing within seconds
- Minimize system resource consumption
- Avoid creating large temporary files
- Use lightweight command execution methods
- Prioritize test coverage over exhaustive testing
- Minimize external dependencies
- Use built-in Zsh utilities instead of external commands when possible

Performance anti-patterns to avoid:
- Extensive file I/O operations
- Complex nested loops
- Unnecessary command substitutions
- Repeated invocations of the same test logic
- Large-scale data generation
- Network or resource-intensive validation

## Error Handling and Reporting

Effective error handling is crucial for regression test scripts:

### Error Reporting Principles
- Provide clear, actionable error messages
- Include context about the failed test scenario
- Report both the expected and actual outcomes
- Use consistent error reporting mechanisms

### Error Handling Strategies
- Validate all input parameters
- Check command execution status
- Handle edge cases and unexpected inputs
- Implement graceful error recovery
- Ensure tests can continue after individual test failures

### Utility Functions for Error Management

#### z_Run_Test
Executes a single test case with comprehensive error tracking and reporting. Key features include:
- Detailed failure reporting
- Capturing and analyzing command output
- Tracking total tests, passed tests, and failures
- Supporting both successful and error scenarios

#### z_Error_Report
Provides a standardized method for generating detailed error messages:
- Captures test context
- Formats error information consistently
- Supports different verbosity levels
- Allows for optional logging of error details

#### z_Validate_Input
Offers robust input validation for test scenarios:
- Checks input types and ranges
- Validates command-line argument combinations
- Prevents invalid test configurations
- Provides clear feedback on input issues

## How Regression Tests Work

A well-structured regression test script follows a clear and repeatable pattern. Each test case exercises a specific command scenario, verifies the expected output, and ensures that failure cases return appropriate error codes. 

A typical test case follows this structure:

```zsh
test_CLI_Behavior() {
    z_Run_Test "Scenario Description" \
        "command_to_test --option value" \
        ExpectedExitCode \
        "Optional output pattern"
}
```

Each test case should be designed to check one specific behavior—whether it's checking a correct input, handling an invalid flag, or confirming a script's response to missing arguments.

## Making Tests Reusable

A good regression test suite is modular and reusable. Instead of writing repetitive code, it's best to use shared test functions that handle common patterns. Z_Utils provides standardized test functions that ensure test results are formatted consistently and failures are easy to debug.

Key functions include:
- **Standardized Test Functions** (added to _Z_Utils.zsh)
  - **`z_Handle_Test_Output`** – Configures output to terminal or file based on test options
  - **`z_Save_Global_Test_State`** – Saves global state variables before test execution
  - **`z_Restore_Global_Test_State`** – Restores global state variables after test execution
  - **`z_Parse_Test_Args`** – Parses test command-line arguments with standard options

- **Common Regression Test Functions** (implemented in test scripts)
  - **`run_Script_Test`** – Runs a test case, verifies the exit code, and optionally checks output
  - **`cleanup_Test_Directories`** – Cleans up any test artifacts left behind
  - **`print_Test_Summary`** – Displays test results, summarizing total tests, passed tests, and failures
  - **`begin_Test_Suite`** / **`end_Test_Suite`** – Marks the beginning and end of a test suite

Here's an example of how to integrate standardized functions in a regression test:

```zsh
#!/usr/bin/env zsh
# script_name_REGRESSION.sh - Regression test for script_name.sh

# Ensure we can find the Z_Utils library
SCRIPT_DIR="${0:A:h}"
LIB_DIR="${SCRIPT_DIR:h:h}"
source "${LIB_DIR}/_Z_Utils.zsh"

# Script filename without extension (for output files)
typeset SCRIPT_NAME="${${(%):-%N}:r}"

# At the end of the script, update the execution block:
if [[ "${(%):-%N}" == "$0" ]]; then
    # Parse command line arguments using standardized function
    z_Parse_Test_Args "$@"
    
    # Handle help flag using standardized parameter
    if (( Test_Show_Help == 1 )); then
        display_Script_Usage
        exit 0
    fi
    
    # Configure test output using standardized function
    z_Handle_Test_Output "$SCRIPT_NAME" "REGRESSION" "$Test_Save_Output"
    
    # Call main function with all arguments
    main "$@"
}
```

Using these standardized functions ensures test scripts are easy to maintain and extend as new test scenarios arise.

### Managing the Test Environment

To keep tests clean and repeatable, regression test scripts should avoid leaving behind files, directories, or altered configurations. Any temporary files should be created only when necessary and cleaned up immediately after the test completes. Tests should always restore the system state so they can be run multiple times without side effects.

When creating test environments:
- Use the `z_Save_Global_Test_State` and `z_Restore_Global_Test_State` functions to preserve and restore global state
- Implement a `cleanup_Test_Directories` function to ensure test files and directories are removed after execution
- Create temporary directories with unique names using timestamp and random values
- Set up trap handlers to ensure cleanup even if the test script is interrupted

By using these practices, test scripts remain consistent and avoid interfering with the user's environment.

# Conclusion

Z_Utils provides a robust, standardized approach to testing through both function tests and regression tests. The addition of standardized test functions in `_Z_Utils.zsh` ensures consistent test structure, output handling, and state management across all test files.

By using these standardized functions (`z_Handle_Test_Output`, `z_Save_Global_Test_State`, `z_Restore_Global_Test_State`, and `z_Parse_Test_Args`), developers can create consistent, maintainable test scripts that provide reliable verification of both individual functions and complete scripts.

The test scripts remain lightweight and focused, while gaining the benefits of standardization:
- Consistent command-line interface across all tests
- Uniform output handling and formatting
- Proper state management for test isolation
- Modular test structure that supports incremental testing
- Clear distinction between function tests and regression tests

This approach balances simplicity with robustness, ensuring that Z_Utils remains reliable and well-tested as it evolves.
