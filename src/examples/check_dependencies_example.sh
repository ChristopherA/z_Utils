#!/usr/bin/env zsh
# check_dependencies_example.zsh - Example of using z_Check_Dependencies
# 
# Version:       0.1.00 (2025-03-19)
# Origin:        https://github.com/ChristopherA/z_Utils
# Description:   Demonstrates how to use the z_Check_Dependencies function from Z_Utils.
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

# Set output modes
Output_Verbose_Mode=$TRUE   # Show verbose messages
Output_Quiet_Mode=$FALSE    # Show all non-error messages
Output_Debug_Mode=$FALSE    # Don't show debug messages
Output_Prompt_Enabled=$TRUE # Allow interactive prompts

function main() {
    z_Output info "Starting dependency check example" Emoji="🔍"
    
    # Define an array of required commands
    typeset -a RequiredCmds=("git" "printf" "zsh")
    
    # Define an array of optional commands
    typeset -a OptionalCmds=("gh" "gpg" "jq")
    
    # Example 1: Check only required dependencies
    z_Output verbose "Checking required dependencies..."
    if z_Check_Dependencies "RequiredCmds"; then
        z_Output success "All required dependencies are available"
    else
        z_Output error "Missing required dependencies, cannot continue"
        return $Exit_Status_Dependency
    fi
    
    # Example 2: Check both required and optional dependencies
    z_Output verbose "Checking both required and optional dependencies..."
    if z_Check_Dependencies "RequiredCmds" "OptionalCmds"; then
        z_Output success "All required dependencies are available"
        z_Output info "Optional dependencies may have warnings but don't cause failure"
    fi
    
    # Example 3: Custom dependency check with user prompt
    z_Output info "Let's check for a custom dependency..."
    typeset CustomDep=$(z_Output prompt "Enter a command to check for:" Default="ls")
    
    typeset -a CustomCmds=("$CustomDep")
    if z_Check_Dependencies "CustomCmds"; then
        z_Output success "Command '$CustomDep' is available"
    else
        z_Output error "Command '$CustomDep' is not available"
    fi
    
    z_Output success "Dependency check example completed" Emoji="✅"
    return $Exit_Status_Success
}

# Run the main function if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    main
fi