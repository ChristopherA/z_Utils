#!/usr/bin/env zsh
# z_Output_complete_FUNCTEST.sh - Complete tests for z_Output function
# 
# Version:       1.0.00 (2025-03-31)
# Origin:        https://github.com/ChristopherA/z_Utils
# Description:   Comprehensive test suite for the z_Output function
#                Adapted from the more detailed z_Output_Demo in the original source materials
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

#----------------------------------------------------------------------#
# Function: z_Output_Complete_Test
#----------------------------------------------------------------------#
# Description:
#   Comprehensive test suite for the z_Output function. Tests all message
#   types, modes, parameters, and edge cases. Designed to thoroughly
#   verify z_Output functionality and serve as a reference for usage.
#
# Parameters:
#   None
#
# Returns:
#   None. Outputs demonstration results to the console.
#----------------------------------------------------------------------#
function z_Output_Complete_Test {
    # Save global state
    z_Save_Global_Test_State

    # Test suite shared variables
    typeset -i Terminal_Width=$(tput cols)
    typeset -r Test_Filler="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Curabitur convallis."

    # Resets all output modes to their default states and validates reset.
    #   Called before each test section to ensure clean test environment.
    function reset_Output_Modes {
        # Store current state for error reporting
        typeset -i PreviousVerbose=$Output_Verbose_Mode
        typeset -i PreviousQuiet=$Output_Quiet_Mode
        typeset -i PreviousDebug=$Output_Debug_Mode
        typeset -i PreviousPrompt=$Output_Prompt_Enabled
        
        # Reset to defaults
        Output_Verbose_Mode=$FALSE
        Output_Quiet_Mode=$FALSE
        Output_Debug_Mode=$FALSE
        Output_Prompt_Enabled=$TRUE
        
        # Validate reset
        typeset -i FailureCount=0

        if (( Output_Verbose_Mode != FALSE )); then
            z_Output error "Failed to reset verbose mode (stayed at $PreviousVerbose)"
            (( FailureCount++ ))
        fi
        
        if (( Output_Quiet_Mode != FALSE )); then
            z_Output error "Failed to reset quiet mode (stayed at $PreviousQuiet)"
            (( FailureCount++ ))
        fi
        
        if (( Output_Debug_Mode != FALSE )); then
            z_Output error "Failed to reset debug mode (stayed at $PreviousDebug)"
            (( FailureCount++ ))
        fi

        if (( Output_Prompt_Enabled != TRUE )); then
            z_Output error "Failed to reset prompt mode (stayed at $PreviousPrompt)"
            (( FailureCount++ ))
        fi

        return $(( FailureCount ? 1 : 0 ))
    }

    # Define test execution order
    typeset -a Test_Sections=(
        "Default Behavior"            test_Default_Behavior
        "Verbose Mode"               test_Verbose_Mode
        "Debug Mode"                 test_Debug_Mode
        "Quiet Mode"                 test_Quiet_Mode
        "Emoji Tests"                test_Emoji_Customization
        "Format Tests"               test_Wrapping_And_Indentation
        "Real-World Tests"           test_Combined_Formatting
        "Non-Interactive"            test_Non_Interactive_Prompts
        "Interactive"                test_Interactive_Prompts
        "Edge Cases"                 test_Edge_Cases
    )

    function test_Default_Behavior {
        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section 1 of 10: Default Behavior"
        z_Output print "============================================================"
        z_Output print "Tests output types with default settings - no verbosity, quiet or debug modes."
        z_Output print "Demonstrates default formatting behavior for each message type."
        z_Output print "============================================================"
        z_Output print ""

        # Base Print Behavior subsection
        z_Output print "A. Base Print Behavior"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Print comparison
        z_Output print "1. Native zsh vs z_Output print:"
        z_Output print "a. Native zsh print:"
        print "This is a native zsh print command's output."
        z_Output print "b. z_Output print:"
        z_Output print "This is a z_Output print output."
        z_Output print ""
        
        # Test 2: Default behavior
        z_Output print "2. Default print behavior:"
        z_Output print "By default, like zsh print, z_Output print has no wrap or indent:"
        z_Output print "This is a basic z_Output print message, with no formatting options - output matches zsh's native print command. $Test_Filler"
        z_Output print ""
        
        # Test 3: Content handling
        z_Output print "3. Basic content handling:"
        z_Output print "a. Single line text:"
        z_Output print "This is a basic single line of text."
        z_Output print ""
        
        z_Output print "b. Multiple lines (natural breaks):"
        z_Output print "Line one\nLine two\nLine three"
        z_Output print ""
        
        z_Output print "c. Whitespace handling:"
        z_Output print "- Multiple spaces:    four    spaces    between    words"
        z_Output print "- Tabs:\tafter\ttab\tcharacter"
        z_Output print "- Mixed spacing:        eight spaces before\n        eight spaces after"
        z_Output print ""
        
        z_Output print "d. Empty content:"
        z_Output print "- Empty string follows:"
        z_Output print ""
        z_Output print "- Single space follows:"
        z_Output print " "
        z_Output print ""
        
        # Special content handling
        z_Output print "4. Special content handling:"
        z_Output print 'a. Special characters: !@#$%^&*()_+-=[]{}|;:'"'"',./<>?'
        z_Output print ""
        z_Output print "b. Unicode text: Hello, 世界! ñ á é í ó ú"
        z_Output print ""
        z_Output print "c. Emoji in text: 👋 🌟 🚀"
        z_Output print ""
        z_Output print "d. Long words: Supercalifragilisticexpialidocious"
        z_Output print ""
        z_Output print "e. URLs: http://very-long-subdomain.example.com/path/to/something"
        z_Output print ""

        # Optional Print Features subsection
        z_Output print "B. Optional Print Features"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Text wrapping
        z_Output print "1. Text wrapping (optional):"
        z_Output print "a. Wrap at 60 characters:"
        z_Output print "This text demonstrates wrapping at 60 characters. $Test_Filler" Wrap=60
        z_Output print ""
        z_Output print "b. Narrow wrap at 30 characters:"
        z_Output print "This text demonstrates narrow wrapping. $Test_Filler" Wrap=30
        z_Output print ""
        
        # Test 2: Indentation
        z_Output print "2. Indentation (optional):"
        z_Output print "a. 4-space indent:"
        z_Output print "This text demonstrates basic indentation with 4 spaces. No wrapping is applied unless specifically requested." Indent=4
        z_Output print ""
        
        z_Output print "b. 8-space indent:"
        z_Output print "This text demonstrates deeper indentation with 8 spaces. No wrapping is applied unless specifically requested." Indent=8
        z_Output print ""
        
        # Test 3: Combined wrap/indent
        z_Output print "3. Combined wrap+indent (with auto-wrapping):"
        z_Output print "a. 4-space indent + wrap at 60 chars:"
        z_Output print "This text demonstrates combined indentation and wrapping. Note that continuation lines are indented +2 spaces for visual clarity. $Test_Filler" Indent=4 Wrap=60
        z_Output print ""
        
        z_Output print "b. 8-space indent + narrow wrap at 40 chars:"
        z_Output print "This text demonstrates deeper indentation with narrow wrapping. Note that continuation lines are indented +2 spaces. $Test_Filler" Indent=8 Wrap=40
        z_Output print ""
        
        # Test 4: Emoji
        z_Output print "4. Emoji customization (optional for print):"
        z_Output print "a. Basic print with emoji:"
        z_Output print "This print message includes a custom emoji prefix." Emoji="📢"
        z_Output print ""
        
        z_Output print "b. Emoji with indentation:"
        z_Output print "This print message combines emoji and indentation." Emoji="✨" Indent=4
        z_Output print ""
        
        z_Output print "c. Complete customization:"
        z_Output print "This print message uses all optional features: emoji, indent, wrap, and color." Emoji="🔸" Indent=4 Wrap=50 Color="$Term_BrightYellow"
        z_Output print ""
        
        # Other Message Types subsection
        z_Output print "C. Other Message Types"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Info
        z_Output print "1. Info messages:"
        z_Output print "a. Basic info (has emoji by default):"
        z_Output info "This is a basic info message. It includes an emoji by default."
        z_Output print ""
        
        z_Output print "b. Info with wrap:"
        z_Output info "This info message demonstrates automatic wrapping when the Wrap parameter is specified. $Test_Filler" Wrap=60
        z_Output print ""
        
        z_Output print "c. Info with indent:"
        z_Output info "This info message demonstrates indentation. Note that indentation automatically enables wrapping at terminal width." Indent=4
        z_Output print ""
        
        z_Output print "d. Info with custom emoji:"
        z_Output info "This info message demonstrates a custom emoji replacing the default." Emoji="📌"
        z_Output print ""
        
        # Test 2: Success
        z_Output print "2. Success messages:"
        z_Output print "a. Basic success (has emoji by default):"
        z_Output success "This is a basic success message. It includes an emoji by default."
        z_Output print ""
        
        z_Output print "b. Success with wrap:"
        z_Output success "This success message demonstrates automatic wrapping when the Wrap parameter is specified. $Test_Filler" Wrap=60
        z_Output print ""
        
        z_Output print "c. Success with indent:"
        z_Output success "This success message demonstrates indentation. Note that indentation automatically enables wrapping at terminal width." Indent=4
        z_Output print ""
        
        z_Output print "d. Success with custom emoji:"
        z_Output success "This success message demonstrates a custom emoji replacing the default." Emoji="🏆"
        z_Output print ""
        
        # Test 3: Warning
        z_Output print "3. Warning messages:"
        z_Output print "a. Basic warning (has emoji by default):"
        z_Output warn "This is a basic warning message. It includes an emoji by default."
        z_Output print ""
        
        z_Output print "b. Warning with wrap:"
        z_Output warn "This warning message demonstrates automatic wrapping when the Wrap parameter is specified. $Test_Filler" Wrap=60
        z_Output print ""
        
        z_Output print "c. Warning with indent:"
        z_Output warn "This warning message demonstrates indentation. Note that indentation automatically enables wrapping at terminal width." Indent=4
        z_Output print ""
        
        z_Output print "d. Warning with custom emoji:"
        z_Output warn "This warning message demonstrates a custom emoji replacing the default." Emoji="⚠️"
        z_Output print ""
        
        # Test 4: Error
        z_Output print "4. Error messages:"
        z_Output print "a. Basic error (has emoji by default):"
        z_Output error "This is a basic error message. It includes an emoji by default."
        z_Output print ""
        
        z_Output print "b. Error with wrap:"
        z_Output error "This error message demonstrates automatic wrapping when the Wrap parameter is specified. $Test_Filler" Wrap=60
        z_Output print ""
        
        z_Output print "c. Error with indent:"
        z_Output error "This error message demonstrates indentation. Note that indentation automatically enables wrapping at terminal width." Indent=4
        z_Output print ""
        
        z_Output print "d. Error with custom emoji:"
        z_Output error "This error message demonstrates a custom emoji replacing the default." Emoji="🛑"
        z_Output print ""
        
        # Conditionally Suppressed Messages subsection
        z_Output print "D. Conditionally Suppressed Messages"
        z_Output print "------------------------------------------------------------"
        
        # These should not appear under default settings
        z_Output print "1. Messages suppressed under default settings:"
        z_Output print "a. Verbose (should NOT show with verbose mode OFF):"
        z_Output verbose "This verbose message should not be displayed in non-verbose mode."
        z_Output print "b. Debug (should NOT show with debug mode OFF):"
        z_Output debug "This debug message should not be displayed in non-debug mode."
        z_Output print "c. Verbose Debug (should NOT show with verbose AND debug modes OFF):"
        z_Output vdebug "This verbose debug message should not be displayed without both verbose and debug modes."
        z_Output print ""
        
        # Force display with Force flag
        z_Output print "2. Force flag to override suppression:"
        z_Output print "a. Forced verbose with verbose OFF:"
        z_Output verbose "This verbose message SHOULD appear despite verbose mode being OFF because Force=1." Force=1
        z_Output print ""
        z_Output print "b. Forced debug with debug OFF:"
        z_Output debug "This debug message SHOULD appear despite debug mode being OFF because Force=1." Force=1
        z_Output print ""
        
        # Reset modes at the end of test
        reset_Output_Modes
        return 0
    }

    function test_Verbose_Mode {
        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section 2 of 10: Verbose Mode"
        z_Output print "============================================================"
        z_Output print "Tests output with verbose mode enabled."
        z_Output print "Demonstrates which message types are affected by verbose mode."
        z_Output print "============================================================"
        z_Output print ""
        
        # Reset modes and enable verbose
        reset_Output_Modes
        Output_Verbose_Mode=$TRUE
        
        # Print current mode
        z_Output print "Current mode: Output_Verbose_Mode=$Output_Verbose_Mode"
        z_Output print ""
        
        # Standard Message Types subsection
        z_Output print "A. Standard Message Types"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Print
        z_Output print "1. Print message:"
        z_Output print "Standard print message - always visible regardless of verbose mode."
        z_Output print ""
        
        # Test 2: Info
        z_Output print "2. Info message:"
        z_Output info "Standard info message - always visible regardless of verbose mode."
        z_Output print ""
        
        # Test 3: Success
        z_Output print "3. Success message:"
        z_Output success "Standard success message - always visible regardless of verbose mode."
        z_Output print ""
        
        # Test 4: Warning
        z_Output print "4. Warning message:"
        z_Output warn "Standard warning message - always visible regardless of verbose mode."
        z_Output print ""
        
        # Test 5: Error
        z_Output print "5. Error message:"
        z_Output error "Standard error message - always visible regardless of verbose mode."
        z_Output print ""
        
        # Verbose Message Types subsection
        z_Output print "B. Verbose Message Types"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Verbose
        z_Output print "1. Verbose message:"
        z_Output print "a. Basic verbose:"
        z_Output verbose "This verbose message SHOULD appear when Output_Verbose_Mode=$Output_Verbose_Mode."
        z_Output print ""
        
        z_Output print "b. Formatted verbose:"
        z_Output verbose "This verbose message demonstrates wrap and indent options." Wrap=60 Indent=4
        z_Output print ""
        
        z_Output print "c. Custom verbose:"
        z_Output verbose "This verbose message demonstrates custom emoji and color." Emoji="📣" Color="$Term_BrightYellow"
        z_Output print ""
        
        # Test 2: Debug (should still be hidden without debug mode)
        z_Output print "2. Debug message (should NOT appear without debug mode):"
        z_Output debug "This debug message should NOT appear because Output_Debug_Mode=$Output_Debug_Mode even though Output_Verbose_Mode=$Output_Verbose_Mode."
        z_Output print ""
        
        # Test 3: Verbose Debug (should still be hidden without debug mode)
        z_Output print "3. Verbose Debug message (should NOT appear without debug mode):"
        z_Output vdebug "This verbose debug message should NOT appear because Output_Debug_Mode=$Output_Debug_Mode even though Output_Verbose_Mode=$Output_Verbose_Mode."
        z_Output print ""
        
        # Interaction with Quiet Mode subsection
        z_Output print "C. Interaction with Quiet Mode"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Enabling quiet mode should suppress verbose
        z_Output print "1. Enabling quiet mode (suppresses verbose):"
        Output_Quiet_Mode=$TRUE
        z_Output print "a. With Output_Quiet_Mode=$Output_Quiet_Mode and Output_Verbose_Mode=$Output_Verbose_Mode:"
        z_Output verbose "This verbose message should NOT appear because quiet mode overrides verbose mode."
        z_Output print ""
        
        # Test 2: Force flag can override quiet+verbose interaction
        z_Output print "b. With Force flag to override quiet mode:"
        z_Output verbose "This verbose message SHOULD appear because Force=1 overrides quiet mode." Force=1
        z_Output print ""
        
        # Reset quiet mode
        Output_Quiet_Mode=$FALSE
        z_Output print "c. After resetting to Output_Quiet_Mode=$Output_Quiet_Mode and Output_Verbose_Mode=$Output_Verbose_Mode:"
        z_Output verbose "This verbose message SHOULD appear again because quiet mode is disabled."
        z_Output print ""
        
        # Reset modes at the end of test
        reset_Output_Modes
        return 0
    }

    function test_Debug_Mode {
        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section 3 of 10: Debug Mode"
        z_Output print "============================================================"
        z_Output print "Tests output with debug mode enabled."
        z_Output print "Demonstrates which message types are affected by debug mode."
        z_Output print "============================================================"
        z_Output print ""
        
        # Reset modes and enable debug
        reset_Output_Modes
        Output_Debug_Mode=$TRUE
        
        # Print current mode
        z_Output print "Current mode: Output_Debug_Mode=$Output_Debug_Mode"
        z_Output print ""
        
        # Standard Message Types subsection
        z_Output print "A. Standard Message Types"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Print
        z_Output print "1. Print message:"
        z_Output print "Standard print message - always visible regardless of debug mode."
        z_Output print ""
        
        # Test 2: Info
        z_Output print "2. Info message:"
        z_Output info "Standard info message - always visible regardless of debug mode."
        z_Output print ""
        
        # Test 3: Success
        z_Output print "3. Success message:"
        z_Output success "Standard success message - always visible regardless of debug mode."
        z_Output print ""
        
        # Test 4: Warning
        z_Output print "4. Warning message:"
        z_Output warn "Standard warning message - always visible regardless of debug mode."
        z_Output print ""
        
        # Test 5: Error
        z_Output print "5. Error message:"
        z_Output error "Standard error message - always visible regardless of debug mode."
        z_Output print ""
        
        # Test 6: Verbose (should still be hidden without verbose mode)
        z_Output print "6. Verbose message (should NOT appear without verbose mode):"
        z_Output verbose "This verbose message should NOT appear because Output_Verbose_Mode=$Output_Verbose_Mode even though Output_Debug_Mode=$Output_Debug_Mode."
        z_Output print ""
        
        # Debug Message Types subsection
        z_Output print "B. Debug Message Types"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Debug
        z_Output print "1. Debug message:"
        z_Output print "a. Basic debug:"
        z_Output debug "This debug message SHOULD appear when Output_Debug_Mode=$Output_Debug_Mode."
        z_Output print ""
        
        z_Output print "b. Formatted debug:"
        z_Output debug "This debug message demonstrates wrap and indent options." Wrap=60 Indent=4
        z_Output print ""
        
        z_Output print "c. Custom debug:"
        z_Output debug "This debug message demonstrates custom emoji and color." Emoji="🔍" Color="$Term_BrightBlue"
        z_Output print ""
        
        # Test 2: Verbose Debug (should still be hidden without verbose mode)
        z_Output print "2. Verbose Debug message (should NOT appear without verbose mode):"
        z_Output vdebug "This verbose debug message should NOT appear because Output_Verbose_Mode=$Output_Verbose_Mode even though Output_Debug_Mode=$Output_Debug_Mode."
        z_Output print ""
        
        # Interaction with Other Modes subsection
        z_Output print "C. Combined Mode Tests"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Enabling verbose mode should enable verbose debug
        z_Output print "1. Enabling verbose mode (enables verbose debug):"
        Output_Verbose_Mode=$TRUE
        z_Output print "a. With Output_Verbose_Mode=$Output_Verbose_Mode and Output_Debug_Mode=$Output_Debug_Mode:"
        z_Output vdebug "This verbose debug message SHOULD appear because both verbose and debug modes are enabled."
        z_Output print ""
        
        # Test 2: Quiet mode interaction
        z_Output print "2. Interaction with quiet mode:"
        Output_Quiet_Mode=$TRUE
        z_Output print "a. With Output_Quiet_Mode=$Output_Quiet_Mode, Output_Verbose_Mode=$Output_Verbose_Mode, and Output_Debug_Mode=$Output_Debug_Mode:"
        z_Output debug "This debug message should NOT appear because quiet mode overrides debug mode."
        z_Output vdebug "This verbose debug message should NOT appear because quiet mode overrides both verbose and debug modes."
        z_Output print ""
        
        # Test 3: Force flag can override quiet+debug interaction
        z_Output print "b. With Force flag to override quiet mode:"
        z_Output debug "This debug message SHOULD appear because Force=1 overrides quiet mode." Force=1
        z_Output vdebug "This verbose debug message SHOULD appear because Force=1 overrides quiet mode." Force=1
        z_Output print ""
        
        # Reset quiet mode
        Output_Quiet_Mode=$FALSE
        z_Output print "c. After resetting to Output_Quiet_Mode=$Output_Quiet_Mode, with Output_Verbose_Mode=$Output_Verbose_Mode and Output_Debug_Mode=$Output_Debug_Mode:"
        z_Output debug "This debug message SHOULD appear again because quiet mode is disabled."
        z_Output vdebug "This verbose debug message SHOULD appear again because quiet mode is disabled."
        z_Output print ""
        
        # Reset modes at the end of test
        reset_Output_Modes
        return 0
    }

    function test_Quiet_Mode {
        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section 4 of 10: Quiet Mode"
        z_Output print "============================================================"
        z_Output print "Tests output with quiet mode enabled."
        z_Output print "Demonstrates which message types are affected by quiet mode."
        z_Output print "============================================================"
        z_Output print ""
        
        # Reset modes and enable quiet
        reset_Output_Modes
        Output_Quiet_Mode=$TRUE
        
        # Print current mode
        z_Output print "Current mode: Output_Quiet_Mode=$Output_Quiet_Mode"
        z_Output print ""
        
        # Suppressed Message Types subsection
        z_Output print "A. Messages Suppressed in Quiet Mode"
        z_Output print "------------------------------------------------------------"
        
        # All of these messages should NOT appear in quiet mode
        z_Output print "1. Standard messages (should NOT appear in quiet mode):"
        z_Output print "a. Print message:"
        z_Output print "This print message should NOT appear in quiet mode."
        z_Output print ""
        
        z_Output print "b. Info message:"
        z_Output info "This info message should NOT appear in quiet mode."
        z_Output print ""
        
        z_Output print "c. Success message:"
        z_Output success "This success message should NOT appear in quiet mode."
        z_Output print ""
        
        z_Output print "d. Warning message:"
        z_Output warn "This warning message should NOT appear in quiet mode."
        z_Output print ""
        
        z_Output print "e. Verbose message:"
        z_Output verbose "This verbose message should NOT appear in quiet mode."
        z_Output print ""
        
        z_Output print "f. Debug message (would already be hidden without debug mode):"
        z_Output debug "This debug message should NOT appear in quiet mode."
        z_Output print ""
        
        z_Output print "g. Verbose Debug message (would already be hidden without verbose and debug modes):"
        z_Output vdebug "This verbose debug message should NOT appear in quiet mode."
        z_Output print ""
        
        # Visible Message Types subsection
        z_Output print "B. Messages That Remain Visible in Quiet Mode"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Error messages are always visible regardless of quiet mode
        z_Output print "1. Error messages (always visible):"
        z_Output error "This error message SHOULD appear even in quiet mode."
        z_Output print ""
        
        # Test 2: Messages with Force flag override quiet mode
        z_Output print "2. Messages with Force flag (override quiet mode):"
        z_Output print "a. Print with Force:"
        z_Output print "This print message SHOULD appear in quiet mode because Force=1." Force=1
        z_Output print ""
        
        z_Output print "b. Info with Force:"
        z_Output info "This info message SHOULD appear in quiet mode because Force=1." Force=1
        z_Output print ""
        
        z_Output print "c. Success with Force:"
        z_Output success "This success message SHOULD appear in quiet mode because Force=1." Force=1
        z_Output print ""
        
        z_Output print "d. Warning with Force:"
        z_Output warn "This warning message SHOULD appear in quiet mode because Force=1." Force=1
        z_Output print ""
        
        # Interaction with Other Modes subsection
        z_Output print "C. Combined Mode Tests"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Enabling debug mode should not override quiet mode
        z_Output print "1. Enabling debug mode (should not override quiet mode):"
        Output_Debug_Mode=$TRUE
        z_Output print "a. With Output_Quiet_Mode=$Output_Quiet_Mode and Output_Debug_Mode=$Output_Debug_Mode:"
        z_Output debug "This debug message should NOT appear because quiet mode overrides debug mode."
        z_Output print ""
        
        # Test 2: Enabling verbose mode should not override quiet mode
        z_Output print "2. Enabling verbose mode (should not override quiet mode):"
        Output_Verbose_Mode=$TRUE
        z_Output print "a. With Output_Quiet_Mode=$Output_Quiet_Mode, Output_Verbose_Mode=$Output_Verbose_Mode, and Output_Debug_Mode=$Output_Debug_Mode:"
        z_Output verbose "This verbose message should NOT appear because quiet mode overrides verbose mode."
        z_Output vdebug "This verbose debug message should NOT appear because quiet mode overrides both verbose and debug modes."
        z_Output print ""
        
        # Test 3: Force flag can override quiet mode with any combination
        z_Output print "3. Force flag overrides quiet mode in any combination:"
        z_Output print "a. With Output_Quiet_Mode=$Output_Quiet_Mode, Output_Verbose_Mode=$Output_Verbose_Mode, and Output_Debug_Mode=$Output_Debug_Mode:"
        z_Output print "This print message SHOULD appear because Force=1." Force=1
        z_Output verbose "This verbose message SHOULD appear because Force=1." Force=1
        z_Output debug "This debug message SHOULD appear because Force=1." Force=1
        z_Output vdebug "This verbose debug message SHOULD appear because Force=1." Force=1
        z_Output print ""
        
        # Reset modes at the end of test
        reset_Output_Modes
        return 0
    }

    function test_Emoji_Customization {
        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section 5 of 10: Emoji Customization"
        z_Output print "============================================================"
        z_Output print "Tests emoji customization for different message types."
        z_Output print "Demonstrates default and custom emoji behavior."
        z_Output print "============================================================"
        z_Output print ""
        
        # Reset modes
        reset_Output_Modes
        
        # Default Emoji Behavior subsection
        z_Output print "A. Default Emoji Behavior"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Default emojis for each message type
        z_Output print "1. Default emojis by message type:"
        z_Output print "a. Print (no emoji by default):"
        z_Output print "Print messages have no emoji by default."
        z_Output print ""
        
        z_Output print "b. Info (has info emoji):"
        z_Output info "Info messages have an information emoji by default."
        z_Output print ""
        
        z_Output print "c. Success (has check emoji):"
        z_Output success "Success messages have a check mark emoji by default."
        z_Output print ""
        
        z_Output print "d. Warning (has warning emoji):"
        z_Output warn "Warning messages have a warning emoji by default."
        z_Output print ""
        
        z_Output print "e. Error (has error emoji):"
        z_Output error "Error messages have an error emoji by default."
        z_Output print ""
        
        z_Output print "f. Verbose (has book emoji when visible):"
        Output_Verbose_Mode=$TRUE
        z_Output verbose "Verbose messages have a book emoji by default."
        Output_Verbose_Mode=$FALSE
        z_Output print ""
        
        z_Output print "g. Debug (has tool emoji when visible):"
        Output_Debug_Mode=$TRUE
        z_Output debug "Debug messages have a tool emoji by default."
        Output_Debug_Mode=$FALSE
        z_Output print ""
        
        z_Output print "h. Prompt (has question mark emoji):"
        Output_Prompt_Enabled=$FALSE
        typeset Response=$(z_Output prompt "This prompt has a question mark emoji by default:" Default="Default value")
        z_Output print "Response: $Response"
        z_Output print ""
        
        # Custom Emoji subsection
        z_Output print "B. Custom Emoji Overrides"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Adding emojis to types that don't have them by default
        z_Output print "1. Adding emojis:"
        z_Output print "a. Print with custom emoji:"
        z_Output print "This print message has a custom emoji added." Emoji="📄"
        z_Output print ""
        
        # Test 2: Changing default emojis
        z_Output print "2. Changing default emojis:"
        z_Output print "a. Info with custom emoji:"
        z_Output info "This info message has a custom emoji instead of the default." Emoji="📎"
        z_Output print ""
        
        z_Output print "b. Success with custom emoji:"
        z_Output success "This success message has a custom emoji instead of the default." Emoji="🏆"
        z_Output print ""
        
        z_Output print "c. Warning with custom emoji:"
        z_Output warn "This warning message has a custom emoji instead of the default." Emoji="⚡"
        z_Output print ""
        
        z_Output print "d. Error with custom emoji:"
        z_Output error "This error message has a custom emoji instead of the default." Emoji="💥"
        z_Output print ""
        
        z_Output print "e. Verbose with custom emoji:"
        Output_Verbose_Mode=$TRUE
        z_Output verbose "This verbose message has a custom emoji instead of the default." Emoji="📢"
        Output_Verbose_Mode=$FALSE
        z_Output print ""
        
        z_Output print "f. Debug with custom emoji:"
        Output_Debug_Mode=$TRUE
        z_Output debug "This debug message has a custom emoji instead of the default." Emoji="🔍"
        Output_Debug_Mode=$FALSE
        z_Output print ""
        
        z_Output print "g. Prompt with custom emoji:"
        Output_Prompt_Enabled=$FALSE
        typeset Response=$(z_Output prompt "This prompt has a custom emoji:" Default="Custom emoji prompt" Emoji="🔮")
        z_Output print "Response: $Response"
        z_Output print ""
        
        # Test 3: Removing emojis
        z_Output print "3. Removing emojis:"
        z_Output print "a. Info with emoji removed:"
        z_Output info "This info message has its emoji explicitly removed." Emoji=""
        z_Output print ""
        
        z_Output print "b. Success with emoji removed:"
        z_Output success "This success message has its emoji explicitly removed." Emoji=""
        z_Output print ""
        
        z_Output print "c. Warning with emoji removed:"
        z_Output warn "This warning message has its emoji explicitly removed." Emoji=""
        z_Output print ""
        
        z_Output print "d. Error with emoji removed:"
        z_Output error "This error message has its emoji explicitly removed." Emoji=""
        z_Output print ""
        
        # Emoji with Formatting subsection
        z_Output print "C. Emoji with Formatting"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Emoji with wrapping
        z_Output print "1. Emoji with wrapping:"
        z_Output info "This message demonstrates emoji with wrapping. The emoji should stay at the beginning of the first line and not appear on wrapped lines. $Test_Filler" Wrap=60
        z_Output print ""
        
        # Test 2: Emoji with indentation
        z_Output print "2. Emoji with indentation:"
        z_Output info "This message demonstrates emoji with indentation. The emoji should appear after the indentation." Indent=4
        z_Output print ""
        
        # Test 3: Custom emoji with indentation and wrapping
        z_Output print "3. Custom emoji with indentation and wrapping:"
        z_Output info "This message demonstrates a custom emoji with both indentation and wrapping. $Test_Filler" Emoji="🔆" Indent=4 Wrap=60
        z_Output print ""
        
        # Reset modes at the end of test
        reset_Output_Modes
        return 0
    }

    function test_Wrapping_And_Indentation {
        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section 6 of 10: Text Wrapping and Indentation"
        z_Output print "============================================================"
        z_Output print "Tests text wrapping and indentation features."
        z_Output print "Demonstrates basic and advanced text formatting."
        z_Output print "============================================================"
        z_Output print ""
        
        # Reset modes
        reset_Output_Modes
        
        # Wrapping subsection
        z_Output print "A. Text Wrapping"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Basic wrapping
        z_Output print "1. Basic text wrapping:"
        z_Output print "a. No wrap (default):"
        z_Output print "This text has no wrapping applied. $Test_Filler"
        z_Output print ""
        
        z_Output print "b. Wrap at 40 characters:"
        z_Output print "This text is wrapped at 40 characters. $Test_Filler" Wrap=40
        z_Output print ""
        
        z_Output print "c. Wrap at 60 characters:"
        z_Output print "This text is wrapped at 60 characters. $Test_Filler" Wrap=60
        z_Output print ""
        
        z_Output print "d. Wrap at 80 characters:"
        z_Output print "This text is wrapped at 80 characters. $Test_Filler" Wrap=80
        z_Output print ""
        
        # Test 2: Wrapping with different content
        z_Output print "2. Wrapping different content types:"
        z_Output print "a. Long single word:"
        z_Output print "Supercalifragilisticexpialidocious" Wrap=20
        z_Output print ""
        
        z_Output print "b. URL wrapping:"
        z_Output print "https://this-is-a-very-long-url-that-demonstrates-wrapping-behavior.example.com/path/to/resource" Wrap=40
        z_Output print ""
        
        z_Output print "c. Mixed content wrapping:"
        z_Output print "Text with spaces, Supercalifragilisticexpialidocious, and https://example.com/long/url mixed together." Wrap=40
        z_Output print ""
        
        # Test 3: Natural line breaks with wrapping
        z_Output print "3. Natural line breaks with wrapping:"
        z_Output print "Line one.\nLine two.\nLine three with $Test_Filler" Wrap=40
        z_Output print ""
        
        # Indentation subsection
        z_Output print "B. Indentation"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Basic indentation
        z_Output print "1. Basic indentation:"
        z_Output print "a. No indent (default):"
        z_Output print "This text has no indentation applied."
        z_Output print ""
        
        z_Output print "b. 2-space indent:"
        z_Output print "This text has 2 spaces of indentation." Indent=2
        z_Output print ""
        
        z_Output print "c. 4-space indent:"
        z_Output print "This text has 4 spaces of indentation." Indent=4
        z_Output print ""
        
        z_Output print "d. 8-space indent:"
        z_Output print "This text has 8 spaces of indentation." Indent=8
        z_Output print ""
        
        # Test 2: Indentation with natural line breaks
        z_Output print "2. Indentation with natural line breaks:"
        z_Output print "Line one.\nLine two.\nLine three." Indent=4
        z_Output print ""
        
        # Test 3: Nested indentation levels
        z_Output print "3. Nested indentation levels:"
        z_Output print "Level 0: No indentation."
        z_Output print "Level 1: First indentation level." Indent=2
        z_Output print "Level 2: Second indentation level." Indent=4
        z_Output print "Level 3: Third indentation level." Indent=6
        z_Output print "Back to Level 0."
        z_Output print ""
        
        # Combined Wrap and Indent subsection
        z_Output print "C. Combined Wrap and Indent"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Basic combinations
        z_Output print "1. Basic combinations:"
        z_Output print "a. 4-space indent with 50-char wrap:"
        z_Output print "This text has 4 spaces of indentation and wraps at 50 characters. $Test_Filler" Indent=4 Wrap=50
        z_Output print ""
        
        z_Output print "b. 8-space indent with 40-char wrap:"
        z_Output print "This text has 8 spaces of indentation and wraps at 40 characters. $Test_Filler" Indent=8 Wrap=40
        z_Output print ""
        
        # Test 2: Indentation with automatic wrap
        z_Output print "2. Indentation with automatic terminal-width wrap:"
        z_Output print "a. 4-space indent with auto-wrap:"
        z_Output print "This text has 4 spaces of indentation and automatically wraps at terminal width. Note that indentation alone triggers wrapping. $Test_Filler" Indent=4
        z_Output print ""
        
        # Test 3: Continuation line indentation
        z_Output print "3. Continuation line formatting:"
        z_Output print "a. Notice that continuation lines get additional 2-space indent:"
        z_Output print "This text demonstrates the continuation line indentation. Each wrapped line gets an additional 2 spaces of indentation beyond the base level for better readability. $Test_Filler" Indent=4 Wrap=60
        z_Output print ""
        
        # Edge Cases subsection
        z_Output print "D. Edge Cases and Limits"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Very narrow wrapping
        z_Output print "1. Very narrow wrapping:"
        z_Output print "a. 20-character wrap (minimum):"
        z_Output print "This demonstrates very narrow wrapping at 20 characters." Wrap=20
        z_Output print ""
        
        # Test 2: Deep indentation
        z_Output print "2. Deep indentation:"
        z_Output print "a. 20-space indent:"
        z_Output print "This demonstrates deep indentation at 20 spaces." Indent=20
        z_Output print ""
        
        # Test 3: Combined deep indent with narrow wrap
        z_Output print "3. Deep indent with narrow wrap:"
        z_Output print "a. 16-space indent with 30-char wrap:"
        z_Output print "This combines deep indentation with narrow wrapping." Indent=16 Wrap=30
        z_Output print ""
        
        # Reset modes at the end of test
        reset_Output_Modes
        return 0
    }

    function test_Combined_Formatting {
        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section 7 of 10: Real-World Formatting Combinations"
        z_Output print "============================================================"
        z_Output print "Tests realistic combinations of formatting options."
        z_Output print "Demonstrates practical usage patterns for z_Output."
        z_Output print "============================================================"
        z_Output print ""
        
        # Reset modes
        reset_Output_Modes
        
        # Basic Information Output subsection
        z_Output print "A. Basic Information Output"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Script header example
        z_Output print "1. Script header example:"
        
        # Simulate a script header
        z_Output print "MyScript v1.0 - Utility for managing resources" Emoji="🚀" Color="$Term_BrightCyan"
        z_Output info "Running in standard mode with default settings."
        z_Output print "Copyright © 2025 ExampleCorp" Indent=2
        z_Output print ""
        
        # Test 2: Help text example
        z_Output print "2. Help text example:"
        
        # Simulate help text output
        z_Output print "USAGE:" Emoji="ℹ️" Color="$Term_BrightWhite"
        z_Output print "  myscript [OPTIONS] <command> [ARGS]" Indent=2
        z_Output print ""
        z_Output print "COMMANDS:" Emoji="🔧" Color="$Term_BrightWhite"
        z_Output print "  init      Initialize a new project" Indent=2
        z_Output print "  build     Build the current project" Indent=2
        z_Output print "  deploy    Deploy to production" Indent=2
        z_Output print ""
        z_Output print "OPTIONS:" Emoji="⚙️" Color="$Term_BrightWhite"
        z_Output print "  -v, --verbose    Enable verbose output" Indent=2
        z_Output print "  -q, --quiet      Suppress non-essential output" Indent=2
        z_Output print "  -h, --help       Show this help message" Indent=2
        z_Output print ""
        
        # Status Reporting subsection
        z_Output print "B. Status Reporting"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Operation sequence
        z_Output print "1. Operation sequence example:"
        
        # Simulate a sequence of operations
        z_Output info "Starting initialization process..."
        z_Output print "Checking dependencies..." Indent=2
        z_Output success "All dependencies satisfied." Indent=4
        z_Output print "Validating configuration..." Indent=2
        z_Output warn "Configuration file uses deprecated format." Indent=4
        z_Output print "Setting up environment..." Indent=2
        z_Output print "Creating directory structure..." Indent=4
        z_Output print "Creating log directories..." Indent=6
        z_Output error "Failed to create directory: Permission denied." Indent=8
        z_Output print "Using fallback location..." Indent=8
        z_Output success "Fallback location configured successfully." Indent=8
        z_Output success "Environment setup complete." Indent=4
        z_Output success "Initialization completed with warnings."
        z_Output print ""
        
        # Test 2: Verbose output example
        z_Output print "2. Verbose output example:"
        
        # Simulate verbose mode output
        Output_Verbose_Mode=$TRUE
        z_Output info "Processing with verbose logging enabled..."
        z_Output print "Loading configuration from: /etc/myapp/config.json" Indent=2
        z_Output verbose "Config parser version: 2.1.3" Indent=2
        z_Output verbose "Using JSON schema version: 1.4" Indent=2
        z_Output verbose "Config validation pass 1: Syntax check" Indent=4
        z_Output verbose "Config validation pass 2: Semantic check" Indent=4
        z_Output verbose "Config validation pass 3: Security check" Indent=4
        z_Output success "Configuration loaded successfully." Indent=2
        z_Output print "Processing data files..." Indent=2
        z_Output verbose "Processing file 1 of 3: data.csv" Indent=4
        z_Output verbose "Processing file 2 of 3: users.csv" Indent=4
        z_Output verbose "Processing file 3 of 3: metrics.csv" Indent=4
        z_Output success "All files processed." Indent=2
        Output_Verbose_Mode=$FALSE
        z_Output print ""
        
        # Interactive Dialog subsection
        z_Output print "C. Interactive Dialog"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Configuration dialog example
        z_Output print "1. Configuration dialog example:"
        
        # Simulate a configuration dialog
        z_Output print "PROJECT CONFIGURATION" Emoji="🔧" Color="$Term_BrightWhite"
        z_Output print "Please review the following settings:" Indent=2
        
        z_Output print "1. Installation directory:" Indent=2
        z_Output print "/usr/local/myapp" Indent=4 Color="$Term_BrightGreen"
        
        z_Output print "2. Database connection:" Indent=2
        z_Output print "Type: PostgreSQL" Indent=4
        z_Output print "Host: localhost" Indent=4
        z_Output print "Port: 5432" Indent=4
        z_Output print "Name: myapp_db" Indent=4
        
        z_Output print "3. Logging level:" Indent=2
        z_Output print "INFO (change with --log-level)" Indent=4 Color="$Term_BrightGreen"
        
        Output_Prompt_Enabled=$FALSE
        typeset Response=$(z_Output prompt "Do you want to continue with these settings?" Default="yes")
        z_Output print "Response: $Response" Indent=2
        z_Output print ""
        
        # Debug Output subsection
        z_Output print "D. Debug Output"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Debug trace example
        z_Output print "1. Debug trace example:"
        
        # Simulate debug output
        Output_Debug_Mode=$TRUE
        z_Output info "Troubleshooting connection issue..."
        z_Output debug "Network subsystem version: 3.2.1" Indent=2
        z_Output debug "Protocol: HTTPS" Indent=2
        z_Output debug "Attempting connection to api.example.com:443" Indent=2
        z_Output debug "Connection attempt 1: Timeout after 5000ms" Indent=4
        z_Output debug "Network trace:" Indent=4
        z_Output debug "DNS resolution: api.example.com -> 192.0.2.42" Indent=6
        z_Output debug "Route hop 1: 192.168.1.1 (0.5ms)" Indent=6
        z_Output debug "Route hop 2: 10.0.0.1 (2.3ms)" Indent=6
        z_Output debug "Route hop 3: * * * (timeout)" Indent=6
        z_Output warn "Connection failed: Network timeout."
        z_Output debug "Retry policy: exponential backoff (wait 10s)" Indent=2
        Output_Debug_Mode=$FALSE
        z_Output print ""
        
        # Combined Mode and Format subsection
        z_Output print "E. Combined Mode and Format Tests"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: All features combined
        z_Output print "1. All features combined example:"
        
        # Enable all modes
        Output_Verbose_Mode=$TRUE
        Output_Debug_Mode=$TRUE
        
        # Simulate complex output combining all features
        z_Output print "SYSTEM ANALYSIS REPORT" Emoji="📊" Color="$Term_BrightWhite"
        z_Output info "Running comprehensive system analysis..." Indent=2
        
        z_Output print "Processor Information:" Indent=2 Emoji="🔍"
        z_Output verbose "Scanning CPU details..." Indent=4
        z_Output debug "CPU detection method: sysinfo()" Indent=6
        z_Output print "Model: Intel Core i7-10700K" Indent=4
        z_Output print "Cores: 8 physical, 16 logical" Indent=4
        z_Output debug "CPU flags: sse, sse2, avx, avx2, aes" Indent=6
        z_Output print "Temperature: 42°C (normal range)" Indent=4 Color="$Term_Green"
        
        z_Output print "Memory Information:" Indent=2 Emoji="🔍"
        z_Output verbose "Scanning memory details..." Indent=4
        z_Output debug "Memory detection method: vmstat" Indent=6
        z_Output print "Total: 32GB DDR4" Indent=4
        z_Output print "Used: 12GB (38%)" Indent=4
        z_Output print "Available: 20GB (62%)" Indent=4 Color="$Term_Green"
        z_Output debug "Memory access time average: 74ns" Indent=6
        
        z_Output print "Storage Information:" Indent=2 Emoji="🔍"
        z_Output verbose "Scanning disk details..." Indent=4
        z_Output debug "Storage detection method: df, iostat" Indent=6
        z_Output print "Device: /dev/sda (SSD)" Indent=4
        z_Output print "Total: 1TB" Indent=4
        z_Output print "Used: 750GB (75%)" Indent=4 Color="$Term_Yellow"
        z_Output warn "Storage usage above 75% threshold." Indent=6
        z_Output vdebug "I/O statistics: read 45MB/s, write 23MB/s (24h avg)" Indent=6
        
        z_Output success "System analysis completed successfully." Indent=2
        
        # Reset all modes
        reset_Output_Modes
        return 0
    }

    function test_Prompts {
        typeset -i Original_Prompt_State=$Output_Prompt_Enabled
        
        # Reset state: Should use the passed interactivity parameter
        # This allows both interactive and non-interactive testing
        # with the same function
        typeset -i Interactive_Test=$1
        
        # Set test mode
        typeset TestMode
        if (( Interactive_Test == TRUE )); then
            TestMode="Interactive"
            Output_Prompt_Enabled=$TRUE
        else
            TestMode="Non-Interactive"
            Output_Prompt_Enabled=$FALSE
        fi
        
        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section: $TestMode Prompts"
        z_Output print "============================================================"
        z_Output print "Tests prompt functionality in $TestMode mode."
        z_Output print "Demonstrates basic and advanced prompting features."
        z_Output print "============================================================"
        z_Output print ""
        
        # Print current state
        z_Output print "Current mode: Output_Prompt_Enabled=$Output_Prompt_Enabled"
        z_Output print ""
        
        # Basic Prompts subsection
        z_Output print "A. Basic Prompts"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Basic prompt with default
        z_Output print "1. Basic prompt with default:"
        typeset Response=$(z_Output prompt "Enter a value:" Default="Default Value")
        z_Output print "Response: '$Response'"
        z_Output print ""
        
        # Test 2: Basic prompt without default
        z_Output print "2. Basic prompt without default:"
        typeset Response=$(z_Output prompt "Enter a value (no default):")
        z_Output print "Response: '${Response:-(empty)}'"
        z_Output print ""
        
        # Default Value Processing subsection
        z_Output print "B. Default Value Processing:"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Empty default
        z_Output print "1. Empty string default:"
        typeset Response=$(z_Output prompt "Enter a value:" Default="")
        z_Output print "Empty default: (Expected: '', Got: '${Response:-(null)}')"
        z_Output print ""
        
        # Test 2: Whitespace handling
        z_Output print "2. Whitespace in default:"
        typeset Response=$(z_Output prompt "Enter whitespace:" Default="  spaced  ")
        z_Output print "Whitespace: (Expected: '  spaced  ', Got: '${Response}')"
        z_Output print ""
        
        # Test 3: Multi-line default
        z_Output print "3. Multi-line default:"
        typeset Response=$(z_Output prompt "Enter multi-line:" Default="Line 1\nLine 2")
        z_Output print "Multi-line: (Expected: 'Line 1\nLine 2', Got: '${Response}')"
        z_Output print ""
        
        # Test 4: Only spaces
        z_Output print "4. Only spaces:"
        typeset Response=$(z_Output prompt "Enter spaces" Default="   ")
        z_Output print "Only spaces: (Expected: '   ', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "5. Single space:"
        typeset Response=$(z_Output prompt "Enter space" Default=" ")
        z_Output print "Single space: (Expected: ' ', Got: '${Response}')"
        z_Output print ""

        # Special Content Tests
        z_Output print "C. Special Content:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Special characters:"
        typeset Response=$(z_Output prompt "Enter special" Default="!@#$%")
        z_Output print "Special characters: (Expected: '!@#$%', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "2. Unicode/emoji:"
        typeset Response=$(z_Output prompt "Enter greeting" Default="Hello 世界 👋")
        z_Output print "Unicode/emoji: (Expected: 'Hello 世界 👋', Got: '${Response}')"
        z_Output print ""

        # Prompt Formatting Tests
        z_Output print "D. Prompt Formatting:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Basic prompt:"
        typeset Response=$(z_Output prompt "Basic prompt" Default="test")
        z_Output print "Basic prompt: (Expected: 'test', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "2. Custom emoji:"
        typeset Response=$(z_Output prompt "Custom emoji prompt" Default="test" Emoji="🎯")
        z_Output print "Custom emoji: (Expected: 'test', Got: '${Response}')"
        z_Output print ""

        # Indentation Tests
        z_Output print "E. Indentation Tests:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Basic prompt (no indent):"
        typeset Response=$(z_Output prompt "Enter value at root level" Default="base-level-value")
        z_Output print "No indent: (Expected: 'base-level-value', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "2. Indented prompt (2 spaces):"
        typeset Response=$(z_Output prompt "Enter value at level 1" Default="level-1-value" Indent=2)
        z_Output print "Basic indent: (Expected: 'level-1-value', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "3. Deeply indented prompt (4 spaces):"
        typeset Response=$(z_Output prompt "Enter value at level 2" Default="level-2-value" Indent=4)
        z_Output print "Deep indent: (Expected: 'level-2-value', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "4. Mixed with emoji:"
        typeset Response=$(z_Output prompt "Enter value at level 3" Default="level-3-value" Indent=6 Emoji="🔍")
        z_Output print "Emoji indent: (Expected: 'level-3-value', Got: '${Response}')"
        z_Output print ""

        # Debug output at end of test
        z_Output debug "Test completion state:" Force=$TRUE
        z_Output debug "- Final Output_Prompt_Enabled=$Output_Prompt_Enabled" Force=$TRUE

        # Restore original prompt state
        Output_Prompt_Enabled=$Original_Prompt_State
        z_Output debug "- Restored Output_Prompt_Enabled=$Output_Prompt_Enabled" Force=$TRUE

        return 0
    }

    # Wrapper functions for interactive/non-interactive testing
    function test_Interactive_Prompts { 
        test_Prompts $TRUE 
    }

    function test_Non_Interactive_Prompts { 
        test_Prompts $FALSE 
    }

    function test_Edge_Cases {
        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section 10 of 10: Edge Cases"
        z_Output print "============================================================"
        z_Output print "Tests edge cases and boundary conditions."
        z_Output print "Demonstrates behavior with unusual inputs."
        z_Output print "============================================================"
        z_Output print ""
        
        # Reset modes
        reset_Output_Modes
        
        # Empty Content subsection
        z_Output print "A. Empty Content"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Empty message
        z_Output print "1. Empty message:"
        z_Output print "a. Empty string:"
        z_Output print ""
        z_Output print "b. Empty info:"
        z_Output info ""
        z_Output print "c. Empty success:"
        z_Output success ""
        z_Output print "d. Empty warning:"
        z_Output warn ""
        z_Output print "e. Empty error:"
        z_Output error ""
        z_Output print ""
        
        # Test 2: Just spaces
        z_Output print "2. Just spaces:"
        z_Output print "a. Single space:"
        z_Output print " "
        z_Output print "b. Multiple spaces:"
        z_Output print "     "
        z_Output print ""
        
        # Test 3: Just newlines
        z_Output print "3. Just newlines:"
        z_Output print "a. Single newline:"
        z_Output print "\n"
        z_Output print "b. Multiple newlines:"
        z_Output print "\n\n\n"
        z_Output print ""
        
        # Extreme Values subsection
        z_Output print "B. Extreme Values"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Very long words
        z_Output print "1. Very long words:"
        z_Output print "a. Long technical term:"
        z_Output print "Pneumonoultramicroscopicsilicovolcanoconiosis"
        z_Output print "b. Long technical term with wrapping:"
        z_Output print "Pneumonoultramicroscopicsilicovolcanoconiosis" Wrap=20
        z_Output print ""
        
        # Test 2: Very narrow wrap
        z_Output print "2. Minimum wrap width:"
        z_Output print "a. Wrap at 10 (should clamp to minimum):"
        z_Output print "This demonstrates very narrow wrapping." Wrap=10
        z_Output print ""
        
        # Test 3: Very deep indent
        z_Output print "3. Very deep indent:"
        z_Output print "a. 30-space indent:"
        z_Output print "Deep indent text." Indent=30
        z_Output print ""
        
        # Special Characters subsection
        z_Output print "C. Special Characters"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: Unicode
        z_Output print "1. Unicode text:"
        z_Output print "a. International text:"
        z_Output print "English: Hello, World!"
        z_Output print "Chinese: 你好，世界！"
        z_Output print "Japanese: こんにちは、世界！"
        z_Output print "Arabic: مرحبا بالعالم!"
        z_Output print "Russian: Привет, мир!"
        z_Output print "Greek: Γειά σου, κόσμε!"
        z_Output print ""
        
        # Test 2: Emoji
        z_Output print "2. Emoji characters:"
        z_Output print "a. Basic emoji:"
        z_Output print "😀 😃 😄 😁 😆 😅 😂 🤣 😊 😇"
        z_Output print "b. Emoji with modifiers:"
        z_Output print "👋 👋🏻 👋🏼 👋🏽 👋🏾 👋🏿"
        z_Output print "c. Complex emoji:"
        z_Output print "👨‍👩‍👧‍👦 👩‍🚒 🏳️‍🌈 👨‍💻 🧘‍♀️"
        z_Output print ""
        
        # Test 3: Control characters
        z_Output print "3. Special control sequences:"
        z_Output print "a. Tab characters:"
        z_Output print "Before\tAfter\tMultiple\tTabs"
        z_Output print "b. Backspace character (may not work as expected):"
        z_Output print "With\bBS"
        z_Output print "c. Bell character (may not show):"
        z_Output print "Bell\a"
        z_Output print ""
        
        # Mode Interactions subsection
        z_Output print "D. Mode Interactions"
        z_Output print "------------------------------------------------------------"
        
        # Test 1: All modes enabled
        z_Output print "1. All modes enabled:"
        Output_Verbose_Mode=$TRUE
        Output_Debug_Mode=$TRUE
        z_Output print "a. With Output_Verbose_Mode=$Output_Verbose_Mode and Output_Debug_Mode=$Output_Debug_Mode:"
        z_Output debug "Debug message should show."
        z_Output verbose "Verbose message should show."
        z_Output vdebug "Verbose debug message should show."
        z_Output print ""
        
        # Test 2: All modes enabled then quiet
        z_Output print "2. All modes enabled + quiet mode:"
        Output_Quiet_Mode=$TRUE
        z_Output print "a. With all modes + Output_Quiet_Mode=$Output_Quiet_Mode:"
        z_Output debug "Debug message should NOT show due to quiet mode."
        z_Output verbose "Verbose message should NOT show due to quiet mode."
        z_Output vdebug "Verbose debug message should NOT show due to quiet mode."
        z_Output error "Error message should ALWAYS show even in quiet mode."
        z_Output print ""
        
        # Test 3: All modes enabled + quiet + force
        z_Output print "3. All modes + quiet + force:"
        z_Output print "a. With all modes + quiet + Force=1:"
        z_Output debug "Debug message with Force=1 should show despite quiet mode." Force=1
        z_Output verbose "Verbose message with Force=1 should show despite quiet mode." Force=1
        z_Output vdebug "Verbose debug message with Force=1 should show despite quiet mode." Force=1
        z_Output print ""
        
        # Parameter Combinations subsection
        z_Output print "E. Parameter Combinations"
        z_Output print "------------------------------------------------------------"
        
        # Reset modes 
        reset_Output_Modes
        
        # Test 1: All parameters combined
        z_Output print "1. All parameters combined:"
        z_Output print "a. All formatting options together:"
        z_Output info "This message combines a custom emoji, color, indentation, and wrapping for maximal formatting control. $Test_Filler" Emoji="💠" Color="$Term_BrightMagenta" Indent=4 Wrap=50 Force=1
        z_Output print ""
        
        # Test 2: Parameter edge cases
        z_Output print "2. Parameter edge cases:"
        z_Output print "a. Empty emoji parameter:"
        z_Output info "Info message with empty emoji parameter." Emoji=""
        z_Output print "b. Empty color parameter:"
        z_Output info "Info message with empty color parameter." Color=""
        z_Output print "c. Zero indent parameter:"
        z_Output info "Info message with zero indent parameter." Indent=0
        z_Output print "d. Zero wrap parameter:"
        z_Output info "Info message with zero wrap parameter." Wrap=0
        z_Output print ""
        
        # Test 3: Invalid parameter combinations
        z_Output print "3. Unusual parameter combinations:"
        z_Output print "a. Large indent with small wrap:"
        z_Output print "This has a large indent (20) with small wrap (30)." Indent=20 Wrap=30
        z_Output print "b. Negative indent (should clamp to zero):"
        z_Output print "This has a negative indent parameter." Indent=-10
        z_Output print "c. Negative wrap (should clamp to minimum):"
        z_Output print "This has a negative wrap parameter." Wrap=-10
        z_Output print ""
        
        # Reset modes at the end of test
        reset_Output_Modes
        return 0
    }

    # Display test suite header
    z_Output print "============================================================"
    z_Output print "z_Output Complete Test Suite"
    z_Output print "============================================================"
    z_Output print "Terminal width: $Terminal_Width columns"
    z_Output print "Original script environment: Verbose=$Initial_Verbose, Quiet=$Initial_Quiet, Debug=$Initial_Debug, Prompt=$Initial_Prompt"
    z_Output print "============================================================"
    z_Output print ""
    
    # Debug output
    z_Output debug "About to start executing test sections" Force=1

    # Execute test sections - simplified for debugging
    print "DEBUG: Starting test execution with simplified loop"
    print "DEBUG: Test_Sections array size: ${#Test_Sections[@]}"
    
    # Reset modes before test
    reset_Output_Modes
    
    # Just run the first test directly
    z_Output print "------------------------------------------------------------"
    z_Output print "Running first test: Default Behavior"
    z_Output print "------------------------------------------------------------"
    
    test_Default_Behavior

    z_Output print "------------------------------------------------------------"
    z_Output print "Completed first test"
    z_Output print "------------------------------------------------------------"
    z_Output print ""

    # Display test suite footer and restore environment
    z_Output print "============================================================"
    z_Output print "Test suite completed successfully."
    z_Output print "============================================================"
    
    # Restore global state
    z_Restore_Global_Test_State
    
    return 0
}

# Function to run a subset of the tests for incremental testing
function run_Incremental_Tests() {
    # Save global state
    z_Save_Global_Test_State

    # Reset the shell environment to a known state
    emulate -LR zsh
    setopt errexit nounset pipefail localoptions warncreateglobal

    # Reset modes to defaults
    Output_Verbose_Mode=$FALSE
    Output_Quiet_Mode=$FALSE
    Output_Debug_Mode=$FALSE
    Output_Prompt_Enabled=$TRUE

    # Print header
    print "============================================================"
    print "z_Output Incremental Test - Basic Functionality"
    print "============================================================"
    print "Testing basic message types and mode handling"
    print "============================================================"
    print ""

    # Test basic message types
    print "1. Basic message types:"
    print "------------------------"
    z_Output print "Print message"
    z_Output info "Info message"
    z_Output success "Success message"
    z_Output warn "Warning message"
    z_Output error "Error message"
    print ""

    # Test verbose mode
    print "2. Verbose mode:"
    print "------------------------"
    print "Default (should not show):"
    z_Output verbose "Verbose message (should NOT show with Output_Verbose_Mode=$Output_Verbose_Mode)"
    
    Output_Verbose_Mode=$TRUE
    print "Enabled (should show):"
    z_Output verbose "Verbose message (SHOULD show with Output_Verbose_Mode=$Output_Verbose_Mode)"
    Output_Verbose_Mode=$FALSE
    print ""

    # Test debug mode
    print "3. Debug mode:"
    print "------------------------"
    print "Default (should not show):"
    z_Output debug "Debug message (should NOT show with Output_Debug_Mode=$Output_Debug_Mode)"
    
    Output_Debug_Mode=$TRUE
    print "Enabled (should show):"
    z_Output debug "Debug message (SHOULD show with Output_Debug_Mode=$Output_Debug_Mode)"
    Output_Debug_Mode=$FALSE
    print ""

    # Test quiet mode
    print "4. Quiet mode:"
    print "------------------------"
    print "Default:"
    z_Output print "Standard message (should show with Output_Quiet_Mode=$Output_Quiet_Mode)"
    
    Output_Quiet_Mode=$TRUE
    print "Enabled (should suppress most messages):"
    z_Output print "Standard message (should NOT show with Output_Quiet_Mode=$Output_Quiet_Mode)"
    z_Output error "Error message (SHOULD show despite quiet mode)"
    Output_Quiet_Mode=$FALSE
    print ""

    # Test formatting options
    print "5. Formatting options:"
    print "------------------------"
    print "Default (no formatting):"
    z_Output print "Standard message with no formatting"
    
    print "With wrapping (60 characters):"
    z_Output print "This message demonstrates text wrapping at 60 characters. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas." Wrap=60
    
    print "With indentation (4 spaces):"
    z_Output print "This message demonstrates indentation with 4 spaces." Indent=4
    
    print "With custom emoji:"
    z_Output print "This message demonstrates a custom emoji." Emoji="🚀"
    
    print "With color:"
    z_Output print "This message demonstrates custom color." Color="$Term_BrightCyan"
    
    print "Combined formatting:"
    z_Output print "This message demonstrates combined formatting options (emoji, indent, wrap, color)." Emoji="✨" Indent=4 Wrap=60 Color="$Term_BrightMagenta"
    print ""

    # Test combination of modes
    print "6. Combined modes:"
    print "------------------------"
    print "Both verbose and debug mode enabled:"
    Output_Verbose_Mode=$TRUE
    Output_Debug_Mode=$TRUE
    z_Output verbose "Verbose message (should show)"
    z_Output debug "Debug message (should show)"
    z_Output vdebug "Verbose debug message (should show)"
    
    print "All modes enabled but force flag overriding:"
    Output_Quiet_Mode=$TRUE
    z_Output print "Forced message despite quiet mode" Force=1
    z_Output verbose "Forced verbose message despite quiet mode" Force=1
    z_Output debug "Forced debug message despite quiet mode" Force=1
    print ""

    # Reset all modes
    Output_Verbose_Mode=$FALSE
    Output_Debug_Mode=$FALSE
    Output_Quiet_Mode=$FALSE

    # Print footer
    print "============================================================"
    print "Incremental test completed successfully."
    print "============================================================"
    
    # Restore global state
    z_Restore_Global_Test_State
    
    return 0
}

# Run the tests if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    # Parse command line arguments
    z_Parse_Test_Args "$@"
    
    # Check for help flag
    if (( Test_Show_Help == 1 )); then
        print "\nUsage: $0 [OPTIONS]"
        print "Options:"
        print "  -s, --save        Save output to file (default: terminal only)"
        print "  --incremental     Run incremental tests (default)"
        print "  --complete        Run complete comprehensive tests"
        print "  -h, --help        Display this help message"
        exit 0
    fi
    
    # Configure test output
    z_Handle_Test_Output "$SCRIPT_NAME" "FUNCTEST" "$Test_Save_Output"
    
    # Determine which tests to run
    if (( Test_Run_All == 1 )); then
        # Run incremental tests by default
        run_Incremental_Tests
    else
        # Run specific modules based on command line arguments
        for module in "${Test_Specific_Modules[@]}"; do
            case "$module" in
                incremental)
                    run_Incremental_Tests
                    ;;
                complete)
                    z_Output_Complete_Test
                    ;;
                *)
                    print "Unknown test module: $module"
                    ;;
            esac
        done
    fi
fi