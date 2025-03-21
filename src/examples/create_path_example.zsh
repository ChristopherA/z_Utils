#!/usr/bin/env zsh
# create_path_example.zsh - Example of using z_Ensure_Parent_Path_Exists
# 
# Version:       0.1.00 (2025-03-19)
# Origin:        https://github.com/ChristopherA/z_Utils
# Description:   Demonstrates how to use the z_Ensure_Parent_Path_Exists function.
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
Output_Verbose_Mode=$TRUE
Output_Quiet_Mode=$FALSE
Output_Debug_Mode=$FALSE
Output_Prompt_Enabled=$TRUE

function main() {
    z_Output info "Starting path creation example" Emoji="📁"
    
    # Generate a unique ID for this run to avoid conflicts
    typeset UniqueId="$$_$(date +%s)"
    
    # Example 1: Create a simple nested path for a file
    typeset ExamplePath="/tmp/z_utils_example/${UniqueId}/test_file.txt"
    z_Output info "Ensuring parent path exists for: $ExamplePath"
    
    if z_Ensure_Parent_Path_Exists "$ExamplePath"; then
        z_Output success "Successfully created parent directories"
        echo "Test content" > "$ExamplePath"
        z_Output verbose "Created file: $ExamplePath"
    else
        z_Output error "Failed to create parent directories"
        return $Exit_Status_IO
    fi
    
    # Example 2: Create a path with custom permissions
    typeset SecurePath="/tmp/z_utils_example/${UniqueId}/secure_dir/"
    z_Output info "Creating secure directory with custom permissions: $SecurePath"
    
    if z_Ensure_Parent_Path_Exists "$SecurePath" "700"; then
        z_Output success "Successfully created secure directory"
        # Show the permissions
        ls -ld "$SecurePath"
    else
        z_Output error "Failed to create secure directory"
        return $Exit_Status_IO
    fi
    
    # Example 3: Let user specify a custom path
    z_Output info "Let's create a custom path..."
    typeset CustomPath=$(z_Output prompt "Enter a path to create:" Default="/tmp/z_utils_example/${UniqueId}/custom_path/")
    
    if z_Ensure_Parent_Path_Exists "$CustomPath"; then
        z_Output success "Successfully created: $CustomPath"
        z_Output info "Directory details:"
        ls -ld "$CustomPath"
    else
        z_Output error "Failed to create: $CustomPath"
        return $Exit_Status_IO
    fi
    
    # Clean up (optional, for demo purposes)
    typeset CleanUp=$(z_Output prompt "Clean up created directories? (y/n)" Default="y")
    if [[ "$CleanUp" =~ ^[Yy] ]]; then
        z_Output info "Cleaning up created directories..."
        rm -rf "/tmp/z_utils_example/${UniqueId}"
        z_Output success "Cleanup completed"
    else
        z_Output info "Leaving directories intact at: /tmp/z_utils_example/${UniqueId}"
    fi
    
    z_Output success "Path creation example completed" Emoji="✅"
    return $Exit_Status_Success
}

# Run the main function if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    main
fi