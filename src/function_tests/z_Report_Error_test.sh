#!/usr/bin/env zsh
# z_Report_Error_test.zsh - Tests for z_Report_Error
# 
# Version:       0.1.00 (2025-03-19)
# Origin:        https://github.com/ChristopherA/z_Utils
# Description:   Tests for the z_Report_Error function from the Z_Utils library.
# License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
# Copyright:     (c) 2025 Christopher Allen
# Attribution:   Authored by @ChristopherA <ChristopherA@LifeWithAlacrity.com>

# Ensure we can find the Z_Utils library
SCRIPT_DIR="${0:a:h}"
LIB_DIR="${SCRIPT_DIR:h}"
source "${LIB_DIR}/_Z_Utils.zsh"

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options for strict error handling
setopt errexit nounset pipefail localoptions warncreateglobal

# Override errexit for controlled testing
setopt noerrexit

# Helper function to display section headers
function display_header() {
    typeset Title="$1"
    typeset Width=60
    typeset Separator="$(printf '%*s' $Width | tr ' ' '=')"
    
    print "\n$Separator"
    print "$Title"
    print "$Separator"
}

# Test basic error reporting
function test_basic_error_reporting() {
    display_header "TEST: Basic Error Reporting"
    
    print "\n1. Basic Error Message:"
    typeset Result=0
    z_Report_Error "This is a basic error message"
    Result=$?
    print "Return code: $Result (expected $Exit_Status_General)"
    
    print "\n2. Error Message with Custom Exit Code:"
    z_Report_Error "Error with custom exit code (5)" 5
    Result=$?
    print "Return code: $Result (expected 5)"
}

# Test error reporting with different output modes
function test_error_reporting_with_output_modes() {
    display_header "TEST: Error Reporting with Different Output Modes"
    
    # Save initial settings
    typeset -i InitialVerbose=$Output_Verbose_Mode
    typeset -i InitialQuiet=$Output_Quiet_Mode
    
    print "\n1. Error in Normal Mode:"
    Output_Verbose_Mode=0
    Output_Quiet_Mode=0
    z_Report_Error "Error in normal mode"
    
    print "\n2. Error in Verbose Mode:"
    Output_Verbose_Mode=1
    Output_Quiet_Mode=0
    z_Report_Error "Error in verbose mode"
    
    print "\n3. Error in Quiet Mode (should still show):"
    Output_Verbose_Mode=0
    Output_Quiet_Mode=1
    z_Report_Error "Error in quiet mode"
    
    print "\n4. Error in Both Verbose and Quiet Mode:"
    Output_Verbose_Mode=1
    Output_Quiet_Mode=1
    z_Report_Error "Error in verbose and quiet mode"
    
    # Restore initial settings
    Output_Verbose_Mode=$InitialVerbose
    Output_Quiet_Mode=$InitialQuiet
}

# Test error handling in functions
function test_error_handling_in_functions() {
    display_header "TEST: Error Handling in Functions"
    
    function test_function_with_error() {
        typeset CustomMessage="${1:-Default error message}"
        typeset CustomCode="${2:-$Exit_Status_General}"
        
        # Simulate some work before an error
        print "Function doing some work..."
        
        # Report an error and return
        z_Report_Error "$CustomMessage" $CustomCode
        return $?
    }
    
    print "\n1. Function with Default Error:"
    typeset Result=0
    test_function_with_error
    Result=$?
    print "Function returned: $Result"
    
    print "\n2. Function with Custom Error Message and Code:"
    test_function_with_error "Custom error in function" $Exit_Status_IO
    Result=$?
    print "Function returned: $Result (expected $Exit_Status_IO)"
    
    print "\n3. Error Propagation in Nested Functions:"
    function outer_function() {
        print "Outer function calling inner function..."
        inner_function "$@"
        typeset InnerResult=$?
        print "Inner function returned: $InnerResult"
        return $InnerResult
    }
    
    function inner_function() {
        print "Inner function reporting error..."
        z_Report_Error "Error from inner function" $Exit_Status_Config
        return $?
    }
    
    outer_function
    Result=$?
    print "Outer function returned: $Result (expected $Exit_Status_Config)"
}

# Function to run all tests
function run_all_tests() {
    # Record initial values
    typeset -i InitialVerbose=$Output_Verbose_Mode
    typeset -i InitialQuiet=$Output_Quiet_Mode
    
    print "\n=== z_Report_Error Test Suite ==="
    print "Testing error reporting functionality"
    
    # Run all test sections
    test_basic_error_reporting
    test_error_reporting_with_output_modes
    test_error_handling_in_functions
    
    # Restore original settings
    Output_Verbose_Mode=$InitialVerbose
    Output_Quiet_Mode=$InitialQuiet
    
    print "\n=== Test Suite Complete ==="
}

# Run the tests if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    run_all_tests
fi