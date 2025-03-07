# Z_Utils Test Scripts

This directory contains test scripts for the z_Utils library functions and example implementations.

## Test Files

- **TEST-audit_inception_commit.sh** - Regression tests for audit_inception_commit-POC.sh
- **TEST-create_inception_commit.sh** - Regression tests for create_inception_commit.sh

## Test Standards

All test scripts follow the standards defined in:
- `requirements/REQUIREMENTS-Regression_Test_Scripts.md`
- `requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md`
- `requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md`

## Running Tests

To run a test script:

```bash
cd src/tests
./TEST-script-name.sh
```

Test scripts should be self-contained and provide clear output on test success or failure.

## Creating New Tests

When creating new tests for z_Utils functions, follow these guidelines:

1. Name test scripts with the prefix `TEST-` followed by the name of the script being tested
2. Include comprehensive test cases covering normal operation and edge cases
3. Provide clear output indicating test success or failure
4. Follow the regression testing requirements specified in the project documentation