#!/usr/bin/env zsh
# z_Output_comprehensive_FUNCTEST.sh - Comprehensive tests for z_Output
# 
# Version:       0.2.00 (2025-03-31)
# Origin:        https://github.com/ChristopherA/z_Utils
# Description:   Comprehensive tests for the z_Output function from the Z_Utils library.
#                Adapted from the more extensive z_output_demo.sh in source materials.
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

# Ensure output directory exists
typeset OUTPUT_DIR="${SCRIPT_DIR}/output"
[[ -d "$OUTPUT_DIR" ]] || mkdir -p "$OUTPUT_DIR"

# Helper function to display section headers
function display_header() {
    typeset Title="$1"
    typeset Width=60
    typeset Separator="$(printf '%*s' $Width | tr ' ' '=')"
    
    print "\n$Separator"
    print "$Title"
    print "$Separator"
}

# Helper function to reset modes before tests
function reset_modes() {
    # Reset to default test configuration
    Output_Verbose_Mode=$FALSE
    Output_Quiet_Mode=$FALSE
    Output_Debug_Mode=$FALSE
    Output_Prompt_Enabled=$TRUE
    
    # Validate reset
    typeset -i FailureCount=0
    
    if (( Output_Verbose_Mode != FALSE )); then
        print "ERROR: Failed to reset verbose mode"
        (( FailureCount++ ))
    fi
    
    if (( Output_Quiet_Mode != FALSE )); then
        print "ERROR: Failed to reset quiet mode"
        (( FailureCount++ ))
    fi
    
    if (( Output_Debug_Mode != FALSE )); then
        print "ERROR: Failed to reset debug mode"
        (( FailureCount++ ))
    fi
    
    if (( Output_Prompt_Enabled != TRUE )); then
        print "ERROR: Failed to reset prompt mode"
        (( FailureCount++ ))
    fi
    
    return $(( FailureCount ? 1 : 0 ))
}

# Test basic message types
function run_Basic_Tests() {
    # Save global state
    z_Save_Global_Test_State
    
    display_header "TEST: Basic Message Types"
    
    # Reset to default modes
    reset_modes
    
    # Test all message types
    print "\n1. Print Message:"
    z_Output print "Standard print message"
    
    print "\n2. Info Message:"
    z_Output info "Standard info message"
    
    print "\n3. Success Message:"
    z_Output success "Success message"
    
    print "\n4. Warning Message:"
    z_Output warn "Warning message"
    
    print "\n5. Error Message:"
    z_Output error "Error message"
    
    print "\n6. Verbose Message (should NOT show with verbose OFF):"
    z_Output verbose "This verbose message should not be displayed"
    
    print "\n7. Debug Message (should NOT show with debug OFF):"
    z_Output debug "This debug message should not be displayed"
    
    print "\n8. Verbose Debug Message (should NOT show with verbose AND debug OFF):"
    z_Output vdebug "This verbose debug message should not be displayed"
    
    # Restore global state
    z_Restore_Global_Test_State
}

# Test verbose mode
function run_Verbose_Tests() {
    # Save global state
    z_Save_Global_Test_State
    
    display_header "TEST: Verbose Mode"
    
    # Reset and enable verbose mode
    reset_modes
    Output_Verbose_Mode=$TRUE
    
    print "\n1. Print with Verbose ON:"
    z_Output print "Print messages always show regardless of verbose mode"
    
    print "\n2. Info with Verbose ON:"
    z_Output info "Info messages always show regardless of verbose mode"
    
    print "\n3. Verbose Message (should show with verbose ON):"
    z_Output verbose "This verbose message SHOULD be displayed with Output_Verbose_Mode=$Output_Verbose_Mode"
    
    print "\n4. Debug with Verbose ON (should NOT show without debug ON):"
    z_Output debug "This debug message should NOT be displayed with Output_Debug_Mode=$Output_Debug_Mode"
    
    print "\n5. Verbose Debug with Verbose ON (should NOT show without debug ON):"
    z_Output vdebug "This verbose debug message should NOT be displayed without debug mode"
    
    # Restore global state
    z_Restore_Global_Test_State
}

# Test debug mode
function run_Debug_Tests() {
    # Save global state
    z_Save_Global_Test_State
    
    display_header "TEST: Debug Mode"
    
    # Reset and enable debug mode
    reset_modes
    Output_Debug_Mode=$TRUE
    
    print "\n1. Debug Message (should show with debug ON):"
    z_Output debug "This debug message SHOULD be displayed with Output_Debug_Mode=$Output_Debug_Mode"
    
    print "\n2. Verbose Debug with Debug ON (should NOT show without verbose ON):"
    z_Output vdebug "This verbose debug message should NOT be displayed without verbose mode"
    
    # Enable both debug and verbose
    Output_Verbose_Mode=$TRUE
    print "\n3. Verbose Debug with both Verbose and Debug ON (should show):"
    z_Output vdebug "This verbose debug message SHOULD be displayed with Output_Verbose_Mode=$Output_Verbose_Mode and Output_Debug_Mode=$Output_Debug_Mode"
    
    # Restore global state
    z_Restore_Global_Test_State
}

# Test quiet mode
function run_Quiet_Tests() {
    # Save global state
    z_Save_Global_Test_State
    
    display_header "TEST: Quiet Mode"
    
    # Reset and enable quiet mode
    reset_modes
    Output_Quiet_Mode=$TRUE
    
    print "\n1. Print in Quiet Mode (should NOT show):"
    z_Output print "This print message should NOT be displayed in quiet mode"
    
    print "\n2. Info in Quiet Mode (should NOT show):"
    z_Output info "This info message should NOT be displayed in quiet mode"
    
    print "\n3. Success in Quiet Mode (should NOT show):"
    z_Output success "This success message should NOT be displayed in quiet mode"
    
    print "\n4. Warning in Quiet Mode (should NOT show):"
    z_Output warn "This warning message should NOT be displayed in quiet mode"
    
    print "\n5. Error in Quiet Mode (should ALWAYS show):"
    z_Output error "Error messages ALWAYS show - even in quiet mode"
    
    print "\n6. Error with Force in Quiet Mode:"
    z_Output error "Errors with Force=1 always show - not that Force isn't needed for errors" Force=1
    
    print "\n7. Print with Force in Quiet Mode (should show):"
    z_Output print "This print message SHOULD show in quiet mode with Force=1" Force=1
    
    # Restore global state
    z_Restore_Global_Test_State
}

# Test text wrapping and indentation
function run_Format_Tests() {
    # Save global state
    z_Save_Global_Test_State
    
    display_header "TEST: Text Wrapping and Indentation"
    
    # Reset modes
    reset_modes
    
    # Prepare test content
    typeset TestFiller="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Curabitur convallis."
    typeset TerminalWidth=$(tput cols)
    typeset HalfTerminalWidth=$(( TerminalWidth / 2 ))
    
    print "\n1. Default (no wrapping):"
    z_Output print "Without wrap or indent parameters: $TestFiller"
    
    print "\n2. With Wrapping (half terminal width):"
    z_Output print "With Wrap=$HalfTerminalWidth parameter: $TestFiller" Wrap=$HalfTerminalWidth
    
    print "\n3. With Indentation (no wrapping):"
    z_Output print "With Indent=4 parameter: $TestFiller" Indent=4
    
    print "\n4. With Indentation AND Wrapping:"
    z_Output print "With both Indent=8 and Wrap=$HalfTerminalWidth parameters: $TestFiller" Indent=8 Wrap=$HalfTerminalWidth
    
    print "\n5. Nested Indentation:"
    z_Output print "Level 0 text with no indentation"
    z_Output print "Level 1 text with 4 spaces" Indent=4
    z_Output print "Level 2 text with 8 spaces" Indent=8
    z_Output print "Level 3 text with 12 spaces" Indent=12
    z_Output print "Back to level 0 with no indentation"
    
    # Restore global state
    z_Restore_Global_Test_State
}

# Test emoji customization
function run_Emoji_Tests() {
    # Save global state
    z_Save_Global_Test_State
    
    display_header "TEST: Emoji Customization"
    
    # Reset modes
    reset_modes
    
    print "\n1. Default Emojis:"
    z_Output print "Print has no emoji by default"
    z_Output info "Info has an info emoji by default"
    z_Output success "Success has a check emoji by default"
    z_Output warn "Warning has a warning emoji by default"
    z_Output error "Error has an error emoji by default"
    
    print "\n2. Custom Emojis:"
    z_Output print "Adding a custom emoji to print" Emoji="🔄"
    z_Output info "Changing info emoji" Emoji="📝"
    z_Output success "Changing success emoji" Emoji="🎉"
    z_Output warn "Changing warning emoji" Emoji="⚡"
    z_Output error "Changing error emoji" Emoji="🛑"
    
    print "\n3. No Emojis:"
    z_Output info "Removing info emoji" Emoji=""
    z_Output success "Removing success emoji" Emoji=""
    
    # Restore global state
    z_Restore_Global_Test_State
}

# Test prompt functionality
function run_Prompt_Tests() {
    # Save global state
    z_Save_Global_Test_State
    
    display_header "TEST: Prompt Functionality"
    
    # Reset modes
    reset_modes
    
    # Test non-interactive prompts
    print "\n1. Non-Interactive Prompts (with Output_Prompt_Enabled=$FALSE):"
    Output_Prompt_Enabled=$FALSE
    
    print "a. Basic Prompt with Default:"
    typeset Response=$(z_Output prompt "Enter your name:" Default="Default User")
    print "Response: $Response"
    
    print "b. Prompt without Default:"
    typeset Response=$(z_Output prompt "Enter a value (should return empty):")
    print "Response: ${Response:-(empty)}"
    
    # Reset for interactive prompts
    reset_modes
    
    # Test interactive prompts if enabled
    print "\n2. Interactive Prompts (with Output_Prompt_Enabled=$TRUE):"
    print "These will wait for input, so they are commented out in the test."
    print "To test interactive prompts, uncomment the code in the source file."
    
    # Commented out to avoid blocking automated testing
    # print "a. Basic Prompt with Default:"
    # typeset Response=$(z_Output prompt "Enter your name:" Default="Default User")
    # print "Response: $Response"
    
    # print "b. Prompt without Default:"
    # typeset Response=$(z_Output prompt "Enter a value:")
    # print "Response: ${Response:-(empty)}"
    
    # Restore global state
    z_Restore_Global_Test_State
}

# Function to run all tests
function run_All_Tests() {
    print "\n=== z_Output Comprehensive Test Suite ==="
    print "Tests multiple features of the z_Output function"
    
    # Run all test modules
    run_Basic_Tests
    run_Verbose_Tests
    run_Debug_Tests
    run_Quiet_Tests
    run_Format_Tests
    run_Emoji_Tests
    run_Prompt_Tests
    
    print "\n=== Test Suite Complete ==="
}

# Run the tests if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    # Parse command line arguments
    z_Parse_Test_Args "$@"
    
    # Check for help flag
    if (( Test_Show_Help == 1 )); then
        print "\nUsage: $0 [OPTIONS]"
        print "Options:"
        print "  -s, --save      Save output to file (default: terminal only)"
        print "  --basic         Test basic message types"
        print "  --verbose       Test verbose mode"
        print "  --debug         Test debug mode"
        print "  --quiet         Test quiet mode"
        print "  --format        Test text formatting (wrap, indent)"
        print "  --emoji         Test emoji customization"
        print "  --prompt        Test prompt functionality"
        print "  -h, --help      Display this help message"
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
                verbose)
                    run_Verbose_Tests
                    ;;
                debug)
                    run_Debug_Tests
                    ;;
                quiet)
                    run_Quiet_Tests
                    ;;
                format)
                    run_Format_Tests
                    ;;
                emoji)
                    run_Emoji_Tests
                    ;;
                prompt)
                    run_Prompt_Tests
                    ;;
                *)
                    print "Unknown test module: $module"
                    ;;
            esac
        done
    fi
fi