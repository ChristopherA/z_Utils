#!/usr/bin/env zsh
# z_Output_FUNCTEST.sh - Test functions for z_Output
# 
# Version:       0.2.00 (2025-03-31)
# Origin:        https://github.com/ChristopherA/z_Utils
# Description:   Tests for the z_Output function from the Z_Utils library.
# License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
# Copyright:     (c) 2025 Christopher Allen
# Attribution:   Authored by @ChristopherA <ChristopherA@LifeWithAlacrity.com>
#
# NOTE: This is a basic test for z_Output. More comprehensive tests exist in:
# - z_Output_debug_FUNCTEST.sh
# - z_Output_comprehensive_FUNCTEST.sh
# - z_Output_modular_FUNCTEST.sh

# Ensure we can find the Z_Utils library
SCRIPT_DIR="${0:a:h}"
LIB_DIR="${SCRIPT_DIR:h}"
source "${LIB_DIR}/_Z_Utils.zsh"

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options for strict error handling
setopt errexit nounset pipefail localoptions warncreateglobal

# Test script filename without extension (for output files)
typeset SCRIPT_NAME="${${(%):-%N}:r}"

# Ensure output directory exists
typeset OUTPUT_DIR="${SCRIPT_DIR}/output"
[[ -d "$OUTPUT_DIR" ]] || mkdir -p "$OUTPUT_DIR"

# Test various output types
function run_Basic_Tests() {
    # Save global state
    z_Save_Global_Test_State
    
    # Enable all output modes for testing
    Output_Verbose_Mode=$TRUE
    Output_Quiet_Mode=$FALSE
    Output_Debug_Mode=$TRUE
    Output_Prompt_Enabled=$TRUE
    
    print "\n=== Testing z_Output Function ==="
    print "\n--- Basic Message Types ---"
    
    print "\nPrint:"
    z_Output print "Standard print message"
    z_Output print "Print with emoji" Emoji="📝"
    
    print "\nInfo:"
    z_Output info "Standard info message"
    z_Output info "Info with custom emoji" Emoji="ℹ️"
    
    print "\nVerbose (should show because verbose mode is enabled):"
    z_Output verbose "Verbose message"
    
    print "\nSuccess:"
    z_Output success "Success message"
    
    print "\nWarning:"
    z_Output warn "Warning message"
    
    print "\nError:"
    z_Output error "Error message"
    
    print "\nDebug (should show because debug mode is enabled):"
    z_Output debug "Debug message"
    
    print "\nVerbose Debug (should show because both verbose and debug modes are enabled):"
    z_Output vdebug "Verbose debug message"
    
    print "\n--- Test Complete ---"
    
    # Restore global state
    z_Restore_Global_Test_State
}

# Function to run all tests
function run_All_Tests() {
    print "\n=== z_Output Basic Test Suite ==="
    print "Testing output function behavior"
    
    # Run all test modules
    run_Basic_Tests
    
    print "\n=== All Tests Completed Successfully ==="
}

# Run the test if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    # Parse command line arguments
    z_Parse_Test_Args "$@"
    
    # Check for help flag
    if (( Test_Show_Help == 1 )); then
        print "\nUsage: $0 [OPTIONS]"
        print "Options:"
        print "  -s, --save     Save output to file (default: terminal only)"
        print "  --basic        Run only basic tests"
        print "  -h, --help     Display this help message"
        exit 0
    fi
    
    # Configure test output
    z_Handle_Test_Output "$SCRIPT_NAME" "FUNCTEST" "$Test_Save_Output"
    
    # Determine which tests to run
    if (( Test_Run_All == 1 )); then
        # Run all tests
        run_All_Tests
    else
        # Run specific modules based on command line arguments
        for module in "${Test_Specific_Modules[@]}"; do
            case "$module" in
                basic)
                    run_Basic_Tests
                    ;;
                *)
                    print "Unknown test module: $module"
                    ;;
            esac
        done
    fi
fi