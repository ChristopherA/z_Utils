#!/usr/bin/env zsh
# z_Ensure_Parent_Path_Exists_test.zsh - Tests for z_Ensure_Parent_Path_Exists
# 
# Version:       0.1.00 (2025-03-19)
# Origin:        https://github.com/ChristopherA/z_Utils
# Description:   Tests for the z_Ensure_Parent_Path_Exists function from the Z_Utils library.
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

# Helper function to display section headers
function display_header() {
    typeset Title="$1"
    typeset Width=60
    typeset Separator="$(printf '%*s' $Width | tr ' ' '=')"
    
    print "\n$Separator"
    print "$Title"
    print "$Separator"
}

# Set up test directory
typeset TEST_DIR="/tmp/z_utils_path_test_$$"
typeset CLEANUP_ON_EXIT=$TRUE

# Test creating simple directory
function test_simple_directory_creation() {
    display_header "TEST: Simple Directory Creation"
    
    typeset TestPath="${TEST_DIR}/simple_dir/file.txt"
    print "\n1. Creating parent path for: $TestPath"
    
    typeset Result=0
    if z_Ensure_Parent_Path_Exists "$TestPath"; then
        print "Success: Parent directory created"
        if [[ -d "${TEST_DIR}/simple_dir" ]]; then
            print "Directory exists: ${TEST_DIR}/simple_dir"
        else
            print "ERROR: Directory was not created: ${TEST_DIR}/simple_dir"
        fi
    else
        Result=$?
        print "Failed to create directory with exit code: $Result"
    fi
    
    # Verify permissions
    if [[ -d "${TEST_DIR}/simple_dir" ]]; then
        typeset Perms=$(ls -ld "${TEST_DIR}/simple_dir" | awk '{print $1}')
        print "Directory permissions: $Perms (should be drwxr-xr-x or similar)"
    fi
}

# Test creating nested directory structure
function test_nested_directory_creation() {
    display_header "TEST: Nested Directory Creation"
    
    typeset NestedPath="${TEST_DIR}/level1/level2/level3/file.txt"
    print "\n1. Creating deeply nested path: $NestedPath"
    
    typeset Result=0
    if z_Ensure_Parent_Path_Exists "$NestedPath"; then
        print "Success: Nested directory structure created"
        
        # Verify each level was created
        typeset -a Levels=(
            "${TEST_DIR}/level1"
            "${TEST_DIR}/level1/level2"
            "${TEST_DIR}/level1/level2/level3"
        )
        
        for Dir in "${Levels[@]}"; do
            if [[ -d "$Dir" ]]; then
                print "Directory exists: $Dir"
            else
                print "ERROR: Directory was not created: $Dir"
            fi
        done
    else
        Result=$?
        print "Failed to create nested directories with exit code: $Result"
    fi
}

# Test creating directory with custom permissions
function test_custom_permissions() {
    display_header "TEST: Custom Directory Permissions"
    
    typeset SecurePath="${TEST_DIR}/secure_dir/"
    print "\n1. Creating directory with custom permissions (700): $SecurePath"
    
    typeset Result=0
    if z_Ensure_Parent_Path_Exists "$SecurePath" "700"; then
        print "Success: Directory created with custom permissions"
        
        if [[ -d "$SecurePath" ]]; then
            typeset Perms=$(ls -ld "$SecurePath" | awk '{print $1}')
            print "Directory permissions: $Perms (should be drwx------)"
            
            # Verify permission octal value
            if [[ "$Perms" == "drwx------"* ]]; then
                print "Permissions set correctly"
            else
                print "ERROR: Permissions not set correctly"
            fi
        else
            print "ERROR: Directory was not created: $SecurePath"
        fi
    else
        Result=$?
        print "Failed to create directory with exit code: $Result"
    fi
}

# Test existing directory handling
function test_existing_directory() {
    display_header "TEST: Existing Directory Handling"
    
    # Create a test directory first
    typeset ExistingDir="${TEST_DIR}/existing"
    mkdir -p "$ExistingDir"
    
    print "\n1. Using z_Ensure_Parent_Path_Exists on existing directory: $ExistingDir/file.txt"
    
    typeset Result=0
    if z_Ensure_Parent_Path_Exists "$ExistingDir/file.txt"; then
        print "Success: Function handled existing directory correctly"
    else
        Result=$?
        print "Failed with exit code: $Result (unexpected failure)"
    fi
    
    print "\n2. Verifying directory was not recreated:"
    typeset DirMTime1=$(stat -f "%m" "$ExistingDir" 2>/dev/null || stat -c "%Y" "$ExistingDir")
    
    # Wait 1 second to ensure different timestamps if dir is recreated
    sleep 1
    
    # Try again with the existing directory
    z_Ensure_Parent_Path_Exists "$ExistingDir/another_file.txt"
    
    typeset DirMTime2=$(stat -f "%m" "$ExistingDir" 2>/dev/null || stat -c "%Y" "$ExistingDir")
    
    if [[ "$DirMTime1" == "$DirMTime2" ]]; then
        print "Directory was not recreated (good)"
    else
        print "WARNING: Directory appears to have been recreated"
    fi
}

# Clean up test directories
function cleanup_test_directories() {
    if [[ "$CLEANUP_ON_EXIT" == "$TRUE" ]]; then
        print "\nCleaning up test directories..."
        rm -rf "$TEST_DIR"
        print "Cleanup complete"
    else
        print "\nSkipping cleanup. Test directories remain at: $TEST_DIR"
    fi
}

# Function to run all tests
function run_all_tests() {
    print "\n=== z_Ensure_Parent_Path_Exists Test Suite ==="
    print "Testing directory creation functionality"
    
    # Create base test directory
    mkdir -p "$TEST_DIR"
    
    # Run all test sections
    test_simple_directory_creation
    test_nested_directory_creation
    test_custom_permissions
    test_existing_directory
    
    # Clean up
    cleanup_test_directories
    
    print "\n=== Test Suite Complete ==="
}

# Set up trap to ensure cleanup on exit
trap 'cleanup_test_directories' EXIT INT TERM

# Run the tests if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    run_all_tests
fi