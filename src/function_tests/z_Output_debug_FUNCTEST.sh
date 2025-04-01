#!/usr/bin/env zsh
# z_Output_debug_FUNCTEST.sh - Simple debug test for z_Output function
# 
# Version:       1.0.00 (2025-03-31)
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
#   save_Global_State - For saving state
#   restore_Global_State - For restoring state
#   z_Output - The function being tested
#----------------------------------------------------------------------#
function run_Simple_Debug() {
    # Save global state
    save_Global_State
    
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
    restore_Global_State
    
    return 0
}

# Run the test if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    # Save test output to file
    save_Test_Output "debug"
    
    # Run the test
    run_Simple_Debug
fi