#!/usr/bin/env zsh
# setup_cleanup_example.zsh - Example of environment setup and cleanup
# 
# Version:       0.1.00 (2025-03-19)
# Origin:        https://github.com/ChristopherA/z_Utils
# Description:   Demonstrates how to use z_Setup_Environment and z_Cleanup with proper trap handling.
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

# Set output modes (also managed by z_Setup_Environment)
Output_Verbose_Mode=$TRUE
Output_Quiet_Mode=$FALSE
Output_Debug_Mode=$TRUE
Output_Prompt_Enabled=$TRUE

# Define a global variable to track script execution
# This is used by z_Cleanup to prevent recursive cleanup
typeset -g Script_Running=$TRUE

# Define a pattern for temporary files to be cleaned up
typeset -g Temp_Files_Pattern="z_utils_example_$$_*"

function create_Temp_Files() {
    z_Output info "Creating temporary files..."
    
    # Create 3 temporary files
    for i in {1..3}; do
        typeset TempFile="/tmp/${Temp_Files_Pattern/\*/$i}"
        echo "Temporary content $i" > "$TempFile"
        z_Output verbose "Created temporary file: $TempFile"
    done
    
    # List created files
    z_Output info "Created files:"
    find /tmp -type f -name "${Temp_Files_Pattern/\*/*}" -exec ls -la {} \;
    
    return $Exit_Status_Success
}

function simulate_Long_Process() {
    typeset ProcessTime=5
    
    z_Output info "Starting a long-running process (${ProcessTime} seconds)..."
    z_Output info "Press Ctrl+C to test interrupt handling..."
    
    # Simulate work with progress output
    for i in {1..${ProcessTime}}; do
        z_Output verbose "Processing step $i of $ProcessTime"
        sleep 1
    done
    
    z_Output success "Long process completed successfully"
    return $Exit_Status_Success
}

function process_User_Input() {
    typeset ShouldContinue ShouldFail
    
    # Ask the user if they want to continue
    ShouldContinue=$(z_Output prompt "Continue with the example?" Default="y")
    
    if [[ "$ShouldContinue" =~ ^[Nn] ]]; then
        z_Output warn "User chose to exit early"
        return $Exit_Status_General
    fi
    
    # Ask if they want to simulate a failure
    ShouldFail=$(z_Output prompt "Simulate script failure?" Default="n")
    
    if [[ "$ShouldFail" =~ ^[Yy] ]]; then
        z_Output error "Simulating script failure..."
        return $Exit_Status_General
    fi
    
    return $Exit_Status_Success
}

function main() {
    typeset Result=0
    
    # Initialize the environment
    z_Output info "Initializing script environment..."
    z_Setup_Environment || {
        z_Output error "Environment setup failed with status $?"
        exit $Exit_Status_Dependency
    }
    
    # Set up traps for cleanup
    # This ensures z_Cleanup runs whether the script exits normally or due to an error
    trap 'z_Cleanup $FALSE "Script interrupted by user"' INT TERM
    trap 'z_Cleanup $TRUE' EXIT
    
    z_Output info "Starting setup and cleanup example" Emoji="🔄"
    
    # Create some temporary resources that need cleanup
    create_Temp_Files || {
        z_Output error "Failed to create temporary files"
        return $?
    }
    
    # Process user input (may return early)
    process_User_Input
    Result=$?
    if (( Result != 0 )); then
        return $Result
    fi
    
    # Simulate a long-running process (can be interrupted)
    simulate_Long_Process || {
        z_Output error "Long process failed or was interrupted"
        return $?
    }
    
    z_Output success "Setup and cleanup example completed successfully" Emoji="✅"
    return $Exit_Status_Success
}

# Run the main function if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    main
    exit $?
fi