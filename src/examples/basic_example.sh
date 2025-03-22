#!/usr/bin/env zsh
# basic_example.zsh - Basic example of using Z_Utils library
# 
# Version:       0.1.00 (2025-03-19)
# Origin:        https://github.com/ChristopherA/z_Utils
# Description:   A simple script demonstrating how to use the Z_Utils library.
# License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
# Copyright:     (c) 2025 Christopher Allen
# Attribution:   Authored by @ChristopherA <ChristopherA@LifeWithAlacrity.com>

# Find and source the Z_Utils library
SCRIPT_DIR="${0:a:h}"
LIB_DIR="${SCRIPT_DIR:h}"
source "${LIB_DIR}/_Z_Utils.zsh"

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options for strict error handling
setopt errexit nounset pipefail localoptions warncreateglobal

# Exit status constants are provided by the library
typeset -r Exit_Status_Success=0
typeset -r Exit_Status_General=1

# Set output modes
Output_Verbose_Mode=$TRUE   # Show verbose messages
Output_Quiet_Mode=$FALSE    # Show all non-error messages
Output_Debug_Mode=$FALSE    # Don't show debug messages
Output_Prompt_Enabled=$TRUE # Allow interactive prompts

# Example of using z_Output function for different message types
function main() {
    z_Output info "Starting example script" Wrap=60
    
    # Use z_Convert_Path_To_Relative for displaying paths
    typeset ScriptPath="$0"
    typeset RelativePath=$(z_Convert_Path_To_Relative "$ScriptPath")
    z_Output success "Running script: $RelativePath"
    
    # Example of verbose output (will only display if Output_Verbose_Mode is TRUE)
    z_Output verbose "This message only appears in verbose mode"
    
    # Example of debug output (will only display if Output_Debug_Mode is TRUE)
    z_Output debug "This debug message won't appear unless debug mode is enabled"
    
    # Example of prompting the user for input
    typeset UserInput=$(z_Output prompt "Would you like to continue? (y/n)" Default="y")
    
    if [[ "$UserInput" =~ ^[Yy] ]]; then
        z_Output success "You chose to continue!"
    else
        z_Output warn "You chose not to continue."
    fi
    
    # Example of error handling
    if [[ "$UserInput" =~ ^[Nn] ]]; then
        z_Output error "Operation cancelled by user"
        return $Exit_Status_General
    fi
    
    z_Output info "Example completed successfully" Emoji="🎉"
    return $Exit_Status_Success
}

# Run the main function if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    main
fi