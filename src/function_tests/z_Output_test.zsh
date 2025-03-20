#!/usr/bin/env zsh
# z_Output_test.zsh - Test functions for z_Output
# 
# Version:       0.1.00 (2025-03-19)
# Origin:        https://github.com/ChristopherA/z_Utils
# Description:   Tests for the z_Output function from the Z_Utils library.
# License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
# Copyright:     (c) 2025 Christopher Allen
# Attribution:   Authored by @ChristopherA <ChristopherA@LifeWithAlacrity.com>
#
# NOTE: This is a basic test for z_Output. A much more comprehensive test exists 
# in the source materials at 'untracked/source-material/z_output_demo.sh',
# which should be adapted and imported into this testing framework.

# Ensure we can find the Z_Utils library
SCRIPT_DIR="${0:a:h}"
LIB_DIR="${SCRIPT_DIR:h}"
source "${LIB_DIR}/_Z_Utils.zsh"

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options for strict error handling
setopt errexit nounset pipefail localoptions warncreateglobal

# Set up global variables
Output_Verbose_Mode=$TRUE
Output_Quiet_Mode=$FALSE
Output_Debug_Mode=$TRUE
Output_Prompt_Enabled=$TRUE

# Test various output types
function test_z_Output() {
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
}

# Run the test if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    test_z_Output
fi