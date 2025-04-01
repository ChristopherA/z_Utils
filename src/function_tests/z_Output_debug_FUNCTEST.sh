#!/usr/bin/env zsh
# z_Output_debug_FUNCTEST.sh - Simple debug test for z_Output function
# 
# Version:       1.0.01 (2025-03-31)
# Origin:        https://github.com/ChristopherA/z_Utils
# Description:   Simple debug test for the z_Output function
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

# Test script filename without extension (for output files)
typeset SCRIPT_NAME="${${(%):-%N}:r}"

#----------------------------------------------------------------------#
# Function: run_Simple_Debug
#----------------------------------------------------------------------#
# Description:
#   Simple debug function for testing z_Output functionality
#
# Parameters:
#   None
#
# Returns:
#   0 on success
#
# Dependencies:
#   z_Save_Global_Test_State - For saving state
#   z_Restore_Global_Test_State - For restoring state
#   z_Output - The function being tested
#----------------------------------------------------------------------#
function run_Simple_Debug() {
    # Save global state
    z_Save_Global_Test_State
    
    print "Starting simple debug test..."
    
    # Test basic message types
    print "\n1. Basic message types:"
    z_Output print "Print message"
    z_Output info "Info message"
    z_Output success "Success message"
    z_Output warn "Warning message"
    z_Output error "Error message"
    
    # Test verbose mode
    print "\n2. Verbose mode:"
    print "Default (should not show):"
    z_Output verbose "Verbose message (should NOT show with Output_Verbose_Mode=$Output_Verbose_Mode)"
    
    Output_Verbose_Mode=$TRUE
    print "Enabled (should show):"
    z_Output verbose "Verbose message (SHOULD show with Output_Verbose_Mode=$Output_Verbose_Mode)"
    Output_Verbose_Mode=$FALSE
    
    # Test debug mode
    print "\n3. Debug mode:"
    print "Default (should not show):"
    z_Output debug "Debug message (should NOT show with Output_Debug_Mode=$Output_Debug_Mode)"
    
    Output_Debug_Mode=$TRUE
    print "Enabled (should show):"
    z_Output debug "Debug message (SHOULD show with Output_Debug_Mode=$Output_Debug_Mode)"
    Output_Debug_Mode=$FALSE
    
    print "\nSimple debug test completed"
    
    # Restore global state
    z_Restore_Global_Test_State
    
    return 0
}

#----------------------------------------------------------------------#
# Function: run_All_Tests
#----------------------------------------------------------------------#
# Description:
#   Main test function that runs all test modules
#
# Parameters:
#   None
#
# Returns:
#   0 on success, non-zero on test failure
#
# Dependencies:
#   run_Simple_Debug - Debug functionality test
#----------------------------------------------------------------------#
function run_All_Tests() {
    print "============================================================"
    print "z_Output Debug Test Suite"
    print "============================================================"
    print "Testing basic function behavior"
    print "============================================================"
    print ""
    
    # Run all test modules
    run_Simple_Debug
    
    # Print footer
    print ""
    print "============================================================"
    print "All tests completed successfully."
    print "============================================================"
    
    return 0
}

# Run the test if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    # Parse command line arguments
    z_Parse_Test_Args "$@"
    
    # Check for help flag
    if (( Test_Show_Help == 1 )); then
        print "\nUsage: $0 [OPTIONS]"
        print "Options:"
        print "  -s, --save      Save output to file (default: terminal only)"
        print "  --simple        Run only simple debug test"
        print "  -h, --help      Display this help message"
        exit 0
    fi
    
    # Ensure output directory exists
    typeset OUTPUT_DIR="${SCRIPT_DIR}/output"
    [[ -d "$OUTPUT_DIR" ]] || mkdir -p "$OUTPUT_DIR"
    
    # Configure test output
    typeset SIMPLE_SCRIPT_NAME=$(basename "$SCRIPT_NAME")
    z_Handle_Test_Output "$SIMPLE_SCRIPT_NAME" "FUNCTEST" "$Test_Save_Output"
    
    # Determine which tests to run
    if (( Test_Run_All == 1 )); then
        # Run all tests
        run_All_Tests
    else
        # Run specific modules based on command line arguments
        for module in "${Test_Specific_Modules[@]}"; do
            case "$module" in
                simple)
                    run_Simple_Debug
                    ;;
                *)
                    print "Unknown test module: $module"
                    ;;
            esac
        done
    fi
fi