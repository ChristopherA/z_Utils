#!/usr/bin/env zsh
# z_Output_modular_FUNCTEST.sh - Comprehensive test for z_Output function
# 
# Version:       1.0.00 (2025-03-31)
# Origin:        https://github.com/ChristopherA/z_Utils
# Description:   Structured test suite for the z_Output function
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

# Ensure output directory exists
typeset OUTPUT_DIR="${SCRIPT_DIR}/output"
[[ -d "$OUTPUT_DIR" ]] || mkdir -p "$OUTPUT_DIR"

#----------------------------------------------------------------------#
# Function: save_Test_Output
#----------------------------------------------------------------------#
# Description:
#   Saves test output to a file in the output directory
#
# Parameters:
#   $1 - Test name suffix for the output file
#
# Returns:
#   None. Configures stdout to write to both console and file.
#
# Dependencies:
#   None
#----------------------------------------------------------------------#
function save_Test_Output() {
    typeset TestName=$1
    typeset OutputFile="${OUTPUT_DIR}/z_Output_${TestName}_FUNCTEST_output.txt"
    # Redirect output to both console and file using tee
    exec > >(tee "$OutputFile")
}

#----------------------------------------------------------------------#
# Function: save_Global_State
#----------------------------------------------------------------------#
# Description:
#   Saves current global state variables for later restoration
#
# Parameters:
#   None
#
# Returns:
#   None. Sets global variables with saved state.
#
# Dependencies:
#   None
#----------------------------------------------------------------------#
function save_Global_State() {
    typeset -g Saved_State_Verbose=$Output_Verbose_Mode
    typeset -g Saved_State_Quiet=$Output_Quiet_Mode
    typeset -g Saved_State_Debug=$Output_Debug_Mode
    typeset -g Saved_State_Prompt=$Output_Prompt_Enabled
}

#----------------------------------------------------------------------#
# Function: restore_Global_State
#----------------------------------------------------------------------#
# Description:
#   Restores global state variables from saved values
#
# Parameters:
#   None
#
# Returns:
#   None. Resets global variables to their saved values.
#
# Dependencies:
#   save_Global_State - Must be called first to save the state
#----------------------------------------------------------------------#
function restore_Global_State() {
    Output_Verbose_Mode=$Saved_State_Verbose
    Output_Quiet_Mode=$Saved_State_Quiet
    Output_Debug_Mode=$Saved_State_Debug
    Output_Prompt_Enabled=$Saved_State_Prompt
}

#----------------------------------------------------------------------#
# Function: run_Output_Basic_Tests
#----------------------------------------------------------------------#
# Description:
#   Tests basic message types and formatting of the z_Output function.
#
# Parameters:
#   None
#
# Returns:
#   0 on success, non-zero on test failure
#
# Dependencies:
#   save_Global_State - For saving state
#   restore_Global_State - For restoring state
#   z_Output - The function being tested
#----------------------------------------------------------------------#
function run_Output_Basic_Tests() {
    # Save global state
    save_Global_State
    
    # Reset to known state
    Output_Verbose_Mode=$FALSE
    Output_Quiet_Mode=$FALSE
    Output_Debug_Mode=$FALSE
    
    print "============================================================"
    print "z_Output Basic Tests"
    print "============================================================"
    
    # Test standard message types
    print "\n1. Basic message types:"
    z_Output print "Print message - basic text output"
    z_Output info "Info message - for informational notices"
    z_Output success "Success message - for operation completion"
    z_Output warn "Warning message - for potential issues"
    z_Output error "Error message - for error conditions"
    
    # Restore original state
    restore_Global_State
    
    return 0
}

#----------------------------------------------------------------------#
# Function: run_Output_Mode_Tests
#----------------------------------------------------------------------#
# Description:
#   Tests how z_Output responds to different mode settings (verbose,
#   debug, quiet) and their combinations.
#
# Parameters:
#   None
#
# Returns:
#   0 on success, non-zero on test failure
#----------------------------------------------------------------------#
function run_Output_Mode_Tests() {
    # Save initial state
    typeset -i Initial_Verbose=$Output_Verbose_Mode
    typeset -i Initial_Quiet=$Output_Quiet_Mode
    typeset -i Initial_Debug=$Output_Debug_Mode
    
    # Reset to known state
    Output_Verbose_Mode=$FALSE
    Output_Quiet_Mode=$FALSE
    Output_Debug_Mode=$FALSE
    
    print "============================================================"
    print "z_Output Mode Tests"
    print "============================================================"
    
    # Test verbose mode
    print "\n1. Verbose mode:"
    print "a. Default (verbose OFF):"
    z_Output verbose "This verbose message should NOT appear (verbose mode OFF)"
    print "b. Enabled (verbose ON):"
    Output_Verbose_Mode=$TRUE
    z_Output verbose "This verbose message SHOULD appear (verbose mode ON)"
    Output_Verbose_Mode=$FALSE
    
    # Test debug mode
    print "\n2. Debug mode:"
    print "a. Default (debug OFF):"
    z_Output debug "This debug message should NOT appear (debug mode OFF)"
    print "b. Enabled (debug ON):"
    Output_Debug_Mode=$TRUE
    z_Output debug "This debug message SHOULD appear (debug mode ON)"
    Output_Debug_Mode=$FALSE
    
    # Test quiet mode
    print "\n3. Quiet mode:"
    print "a. Default (quiet OFF):"
    z_Output print "This standard message SHOULD appear (quiet mode OFF)"
    print "b. Enabled (quiet ON):"
    Output_Quiet_Mode=$TRUE
    z_Output print "This standard message should NOT appear (quiet mode ON)"
    z_Output error "Error messages SHOULD appear even in quiet mode"
    Output_Quiet_Mode=$FALSE
    
    # Test mode combinations
    print "\n4. Mode combinations:"
    print "a. Verbose + Debug ON:"
    Output_Verbose_Mode=$TRUE
    Output_Debug_Mode=$TRUE
    z_Output verbose "Verbose message SHOULD appear"
    z_Output debug "Debug message SHOULD appear"
    z_Output vdebug "Verbose debug message SHOULD appear when both verbose and debug are ON"
    
    print "b. All modes ON + Force flag:"
    Output_Quiet_Mode=$TRUE
    z_Output print "This message should NOT appear due to quiet mode"
    z_Output print "This message SHOULD appear despite quiet mode" Force=1
    z_Output verbose "This verbose message SHOULD appear despite quiet mode" Force=1
    z_Output debug "This debug message SHOULD appear despite quiet mode" Force=1
    
    # Reset all modes
    Output_Verbose_Mode=$FALSE
    Output_Debug_Mode=$FALSE
    Output_Quiet_Mode=$FALSE
    
    # Restore original state
    Output_Verbose_Mode=$Initial_Verbose
    Output_Quiet_Mode=$Initial_Quiet
    Output_Debug_Mode=$Initial_Debug
    
    return 0
}

#----------------------------------------------------------------------#
# Function: run_Output_Format_Tests
#----------------------------------------------------------------------#
# Description:
#   Tests formatting options of z_Output including wrapping, indentation,
#   custom emojis, and colors.
#
# Parameters:
#   None
#
# Returns:
#   0 on success, non-zero on test failure
#----------------------------------------------------------------------#
function run_Output_Format_Tests() {
    # Save initial state
    typeset -i Initial_Verbose=$Output_Verbose_Mode
    typeset -i Initial_Quiet=$Output_Quiet_Mode
    typeset -i Initial_Debug=$Output_Debug_Mode
    
    # Test filler text for wrapping examples
    typeset Test_Filler="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    
    # Reset to known state
    Output_Verbose_Mode=$FALSE
    Output_Quiet_Mode=$FALSE
    Output_Debug_Mode=$FALSE
    
    print "============================================================"
    print "z_Output Format Tests"
    print "============================================================"
    
    # Test wrapping
    print "\n1. Text wrapping:"
    print "a. Default (no wrap):"
    z_Output print "This text has no wrapping applied. $Test_Filler"
    print "b. With wrapping (60 characters):"
    z_Output print "This text is wrapped at 60 characters. $Test_Filler" Wrap=60
    
    # Test indentation
    print "\n2. Indentation:"
    print "a. Default (no indent):"
    z_Output print "This text has no indentation applied."
    print "b. With indentation (4 spaces):"
    z_Output print "This text has 4 spaces of indentation." Indent=4
    
    # Test combined formatting
    print "\n3. Combined formatting:"
    print "a. Wrap + indent:"
    z_Output print "This text has both wrapping and indentation applied. $Test_Filler" Wrap=60 Indent=4
    
    # Test emoji customization
    print "\n4. Emoji customization:"
    print "a. Default (no emoji for print):"
    z_Output print "This is a standard print message without emoji."
    print "b. Custom emoji:"
    z_Output print "This print message has a custom emoji." Emoji="🚀"
    print "c. Custom emoji for info:"
    z_Output info "This info message has a custom emoji instead of the default." Emoji="📌"
    
    # Test color customization
    print "\n5. Color customization:"
    print "a. Default colors:"
    z_Output info "This info message uses the default color."
    print "b. Custom color:"
    z_Output info "This info message uses a custom color." Color="$Term_BrightYellow"
    
    # Test fully customized formatting
    print "\n6. Full customization:"
    z_Output print "This message uses all formatting options: emoji, color, indent, and wrap." Emoji="✨" Color="$Term_BrightMagenta" Indent=4 Wrap=60
    
    # Restore original state
    Output_Verbose_Mode=$Initial_Verbose
    Output_Quiet_Mode=$Initial_Quiet
    Output_Debug_Mode=$Initial_Debug
    
    return 0
}

#----------------------------------------------------------------------#
# Function: run_Output_Edge_Tests
#----------------------------------------------------------------------#
# Description:
#   Tests edge cases and boundary conditions for the z_Output function.
#
# Parameters:
#   None
#
# Returns:
#   0 on success, non-zero on test failure
#----------------------------------------------------------------------#
function run_Output_Edge_Tests() {
    # Save initial state
    typeset -i Initial_Verbose=$Output_Verbose_Mode
    typeset -i Initial_Quiet=$Output_Quiet_Mode
    typeset -i Initial_Debug=$Output_Debug_Mode
    
    # Reset to known state
    Output_Verbose_Mode=$FALSE
    Output_Quiet_Mode=$FALSE
    Output_Debug_Mode=$FALSE
    
    print "============================================================"
    print "z_Output Edge Case Tests"
    print "============================================================"
    
    # Test empty messages
    print "\n1. Empty content:"
    print "a. Empty string:"
    z_Output print ""
    print "b. Just spaces:"
    z_Output print "   "
    
    # Test special characters
    print "\n2. Special characters:"
    print "a. Special symbols:"
    z_Output print "Special characters: !@#$%^&*()_+-=[]{}|;:'\",.<>/?"
    print "b. Unicode text:"
    z_Output print "Unicode: 你好，世界! こんにちは、世界! Привет, мир!"
    print "c. Emoji characters:"
    z_Output print "Emoji: 😀 😃 😄 👋 👍 🎉 🚀 ✅ ⚠️ ❌"
    
    # Test extreme values
    print "\n3. Extreme values:"
    print "a. Very long word:"
    z_Output print "Supercalifragilisticexpialidocious"
    print "b. Very narrow wrap:"
    z_Output print "Testing very narrow wrap setting." Wrap=20
    print "c. Very deep indent:"
    z_Output print "Testing deep indentation." Indent=20
    
    # Test parameter combinations
    print "\n4. Parameter edge cases:"
    print "a. Empty parameters:"
    z_Output info "Testing with empty emoji parameter." Emoji=""
    z_Output info "Testing with empty color parameter." Color=""
    print "b. Zero values:"
    z_Output print "Testing with zero indent." Indent=0
    z_Output print "Testing with zero wrap." Wrap=0
    
    # Restore original state
    Output_Verbose_Mode=$Initial_Verbose
    Output_Quiet_Mode=$Initial_Quiet
    Output_Debug_Mode=$Initial_Debug
    
    return 0
}

#----------------------------------------------------------------------#
# Function: run_Output_All_Tests
#----------------------------------------------------------------------#
# Description:
#   Runs all z_Output test modules in sequence.
#
# Parameters:
#   None
#
# Returns:
#   0 on success, non-zero on test failure
#
# Dependencies:
#   save_Global_State - For saving state
#   restore_Global_State - For restoring state
#   run_Output_Basic_Tests - Basic function tests
#   run_Output_Mode_Tests - Mode functionality tests
#   run_Output_Format_Tests - Formatting tests
#   run_Output_Edge_Tests - Edge case tests
#----------------------------------------------------------------------#
function run_Output_All_Tests() {
    # Save global state
    save_Global_State
    
    print "============================================================"
    print "z_Output Complete Test Suite"
    print "============================================================"
    print "Testing all aspects of the z_Output function"
    print "Current terminal width: $(tput cols) columns"
    print "============================================================"
    print ""
    
    # Run each test module
    run_Output_Basic_Tests
    run_Output_Mode_Tests
    run_Output_Format_Tests
    run_Output_Edge_Tests
    
    print "\n============================================================"
    print "All z_Output tests completed successfully."
    print "============================================================"
    
    # Restore original state
    restore_Global_State
    
    return 0
}

# Run the test if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    # Save test output to file
    save_Test_Output "modular"
    
    # By default, run all tests
    run_Output_All_Tests
    
    # To run specific test modules, uncomment the desired line(s):
    # save_Test_Output "basic"
    # run_Output_Basic_Tests
    
    # save_Test_Output "mode"
    # run_Output_Mode_Tests
    
    # save_Test_Output "format"
    # run_Output_Format_Tests
    
    # save_Test_Output "edge"
    # run_Output_Edge_Tests
fi