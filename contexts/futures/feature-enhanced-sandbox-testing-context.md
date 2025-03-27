# Context: Enhanced Sandbox Testing and Test Infrastructure

> - _created: 2025-03-29_
> - _last-updated: 2025-03-29_
> - _status: Future Feature - Planning_

## Purpose and Goal

This future branch will focus on enhancing the testing infrastructure and sandbox testing capabilities of the Z_Utils library. The primary goals are:

1. Create comprehensive integration tests for the ANSI stripping functions
2. Standardize the pattern matching approach across all regression tests
3. Investigate and fix test_new_functions.sh hanging in sandbox environment
4. Organize and integrate all function test files
5. Improve test organization and documentation

## Current Status

This feature is in the planning phase. It contains work items that were identified during the refactoring of the inception scripts but were separated to maintain focus on the core refactoring tasks.

## Files Not Included in Current Branch

The following files were developed during the refactoring work but are being deferred to this future branch:

### Function Test Files
- `src/function_tests/z_Create_Inception_Repository_test.sh`
- `src/function_tests/z_Ensure_Allowed_Signers_test.sh`
- `src/function_tests/z_Extract_SSH_Key_Fingerprint_test.sh`
- `src/function_tests/z_Get_First_Commit_Hash_test.sh`
- `src/function_tests/z_Get_Git_Config_test.sh`
- `src/function_tests/z_Get_Repository_DID_test.sh`
- `src/function_tests/z_Setup_Git_Environment_test.sh`
- `src/function_tests/z_Verify_Commit_Signature_test.sh`
- `src/function_tests/z_Verify_Git_Config_test.sh`
- `src/function_tests/z_Verify_Git_Repository_test.sh`

### Test Infrastructure Files
- `src/tests/README.md`
- `src/tests/ansi_test.sh`
- `src/tests/basic_test.sh`
- `src/tests/minimal_test.sh`
- `src/tests/setup_test_environment.sh`
- `src/tests/simple_sandbox_test.sh`
- `src/tests/simple_test.sh`
- `src/tests/simple_test_helpers.zsh`
- `src/tests/test_new_functions.sh`
- `src/tests/test_sandbox_environment.sh`
- `src/tests/z_test_helpers.zsh`

### Documentation Files
- `requirements/shared/zsh_scripting/zsh_library_scripting.md`

## Identified Issues

### 1. ANSI Stripping Inconsistencies

During the refactoring of the inception scripts, we observed inconsistent behavior in how ANSI color codes are stripped in different test environments. While basic functionality works, there are edge cases that require more robust handling:

- Terminal control sequences beyond basic color codes may not be handled correctly
- Different environments (macOS, Linux) may require different stripping techniques
- Pattern matching that relies on stripped output needs to be more flexible

### 2. Test Hanging in Sandbox Mode

The `test_new_functions.sh` script currently hangs when run in sandbox mode. Initial investigation suggests this could be related to:

- Process isolation in the sandbox environment
- Potential infinite loops or deadlocks when specific environment variables are set
- Resource limitations or timeouts that occur only in sandboxed execution

### 3. Pattern Matching Standardization Needed

Different regression tests currently use slightly different approaches to pattern matching:

- Some use exact string matching
- Others use pipe-delimited OR syntax
- Some include case sensitivity while others don't
- Error message matching can be brittle when implementation details change

### 4. Function Test Integration

The individual function tests need to be integrated into a comprehensive test suite:

- Standardize test reporting across all function tests
- Create a consistent approach to fixture setup and teardown
- Enable both individual and suite-based test execution
- Add CI/CD integration for automated testing

### 5. Documentation Standardization

Need to standardize documentation across all test files:

- Create consistent header documentation
- Document test approach and methodology
- Provide usage examples for running tests in different modes
- Create a standard test report format

## Proposed Enhancements

### 1. Comprehensive ANSI Handling

- Create a dedicated test suite for ANSI stripping functionality
- Implement environment detection to choose the optimal stripping method automatically
- Add support for all common terminal control sequences
- Create documentation with examples of proper ANSI handling

### 2. Fix Hanging Tests

- Implement proper timeouts for all test operations
- Add debugging capabilities to trace execution flow in sandbox mode
- Address resource constraints in sandbox environments
- Create a test harness that can detect and report hanging tests

### 3. Standardize Pattern Matching

- Create a unified pattern matching framework
- Support for exact matches, regex, and fuzzy matching
- Document best practices for creating maintainable test assertions
- Add helpers for common matching scenarios (error messages, success indicators)

### 4. Test Suite Organization

- Create a master test runner that can run all tests
- Add categorization (unit, integration, regression) for test selection
- Implement parallel test execution where appropriate
- Create a standard test report format for all tests

### 5. Test Infrastructure Documentation

- Document test environment setup requirements
- Create a guide for writing new tests
- Provide troubleshooting information for common test failures
- Establish best practices for test-driven development with Z_Utils

## Implementation Plan

### Phase 1: Test Infrastructure Standardization
1. Create a standard test framework architecture
2. Refactor existing test helpers into a cohesive library
3. Standardize test reporting across all tests
4. Document the test infrastructure

### Phase 2: Function Test Integration
1. Organize function tests into logical groups
2. Create a unified test runner
3. Standardize all function test interfaces
4. Add comprehensive test reports

### Phase 3: Sandbox Improvements
1. Fix hanging test issues
2. Enhance ANSI handling
3. Improve pattern matching
4. Create robust sandbox environment detection

### Phase 4: Documentation and Examples
1. Create comprehensive test documentation
2. Provide examples of test creation
3. Document testing best practices
4. Add CI/CD integration examples

## Related Tasks

This work is an extension of the improvements made in the following branches:
- feature/refactor-inception-script
- feature/test-fixes

## Branch Information

- **Future Branch:** feature/enhanced-sandbox-testing
- **Create from:** main
- **Merge to:** main