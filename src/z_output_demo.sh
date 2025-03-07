#!/usr/bin/env zsh

########################################################################
##                          SCRIPT INFO
##
## z_output_demo.sh
## - Demonstrate z_Output Functions in Zsh
##
## VERSION:     1.0.00
##              (Last Updated: 2024-01-30)
##
## DESCRIPTION:
## This script demonstrates the use of `z_Output`, a versatile function
## for managing script output, with support for verbosity, quiet mode,
## text wrapping, indentation, emojis, colors, and interactive prompts.
##
## FEATURES:
## - Modular output handling with types: info, success, warn, error, verbose, prompt.
## - Configurable colors, emojis, indentation, and text wrapping.
## - Verbosity (`Output_Verbose_Mode`) and quiet (`Output_Quiet_Mode`) mode support.
## - Debug mode (`Output_Debug_Mode`) for enhanced troubleshooting.
## - Interactive prompts (`Output_Prompt_Enabled`) with default values, skippable for automation.
##
## USAGE:
## ./z_output_demo.sh [options]
##
## OPTIONS:
##   -v, --verbose     Enable verbose output
##   -q, --quiet       Enable quiet mode (suppress non-critical output)
##   -d, --debug       Enable debug mode
##   -h, --help        Show help message and exit
##   -n, --no-color    Disable colored output
##   -c, --color       Force colored output (overrides auto-detection)
##   -p, --no-prompt   Disable interactive prompts (non-interactive mode)
##   -i, --interactive Force interactive mode (overrides non-interactive detection)
##
## REQUIREMENTS:
## - Zsh 5.8 or later.
## - Terminal with ANSI color support for enhanced visuals (optional).
##
## EXIT CODES:
## - 0: Success
## - 1: General error
## - 2: Invalid arguments
## - 130: Script interrupted (SIGINT)
## - 143: Script terminated (SIGTERM)
##
########################################################################

########################################################################
## CHANGE LOG
########################################################################
## 0.1.00   - Initial release (2024-01-30)
##          - Flexible output function for Zsh scripts
##          - Text indentation and wrapping
##          - Color and emoji support
##          - Modes: 
##              - Verbose - more detailed output
##              - Quiet - suppress non-critical messages
##              - Color - enable/disable color output
##              - Debug - enable debugging output
##              - No-Prompt - disable interactive prompts, accept defaults
########################################################################

#######################################################################
## Section: ZSH Configuration and Environment Initialization
##--------------------------------------------------------------------##
## Description:
## - Configures the Zsh environment to ensure robust error handling and
##   predictable execution behavior.
## - Implements safe Zsh options to prevent silent script failures,
##   unintentional global variables, or accidental file overwrites.
## - Declares script-scoped variables, constants, and execution flags
## - Early functions for setting up the script environment and verifying
##   requirements.
##
## Declarations:
## - Safe ZSH Environment Options: Strict error-handling and behavior flags.
## - Script-Scoped Variables:
##   - Boolean Constants: TRUE and FALSE for boolean logic.
##   - Execution Flags: Control script behavior and modes.
##   - Script Constants: Immutable variables for script metadata and 
##   runtime context.
##   - Command-Line Arguments and Runtime Context: Processes arguments and
##   runtime details for improved usability and debugging.
##
## Functions:
## - setup_Environment: Initializes script settings and variables.
## - check_Requirements: Verifies all prerequisites are met.
#######################################################################

#----------------------------------------------------------------------#
# Safe ZSH Environment Options
#----------------------------------------------------------------------#
# Description:
# - Configures Zsh options to ensure safe and predictable script execution.
# - Prevents common pitfalls such as unintentional global variable creation,
#   silent command failures, and accidental file overwrites.
#----------------------------------------------------------------------#

# Reset the shell environment to a default Zsh state for predictability
emulate -LR zsh

#----------------------------------------------------------------------#
# Function: z_Error_Handler
#----------------------------------------------------------------------#
# Description:
#   Handles script errors with detailed information about where and why
#   the error occurred. Provides stack traces and context for debugging.
#
# Parameters:
#   $1 - Exit code from the failed command
#   $2 - Line number where the error occurred
#   $3 - Script name
#   $4 - Additional error message (optional)
#
# Example Usage:
#   trap '[[ ${#funcstack[@]} -gt 0 ]] && z_Error_Handler $? $LINENO ${0##*/} "Error in ${funcstack[1]}"' ERR
#
# Returns:
#   Outputs error information to stderr and returns the original error code
#----------------------------------------------------------------------#
function z_Error_Handler {
    # Store parameters
    typeset -i ErrorCode=$1
    typeset ErrorLine=$2
    typeset ScriptName=$3
    typeset ErrorMsg=${4:-"No additional error information"}
    
    # Build the basic error message
    typeset BaseMsg="[ERROR] in $ScriptName:$ErrorLine (Code: $ErrorCode)"
    
    # Add function context if available
    typeset FuncContext=""
    if [[ ${#funcstack[@]} -gt 0 ]]; then
        FuncContext="Function stack: ${(j: → :)funcstack}"
    fi
    
    # Generate a stack trace if available
    typeset StackTrace=""
    if [[ ${#funcfiletrace[@]} -gt 0 ]]; then
        StackTrace="Stack trace:\n"
        typeset -i i=1
        while (( i <= ${#funcfiletrace[@]} )); do
            StackTrace+="  $i: ${funcfiletrace[i]}\n"
            (( i++ ))
        done
    fi
    
    # Output the error information
    print -u2 "\n${BaseMsg}"
    print -u2 "Message: ${ErrorMsg}"
    [[ -n "$FuncContext" ]] && print -u2 "${FuncContext}"
    [[ -n "$StackTrace" ]] && print -u2 "${StackTrace}"
    
    # Return the original error code
    return $ErrorCode
}

#----------------------------------------------------------------------#
# Function: z_Debug_Handler
#----------------------------------------------------------------------#
# Description:
#   Handles debug traps for command tracing. Only active when debug mode
#   is enabled.
#
# Parameters:
#   None - Uses ZSH_DEBUG_CMD from the environment
#
# Example Usage:
#   trap 'z_Debug_Handler' DEBUG
#
# Notes:
#   - Only outputs when Output_Debug_Mode is TRUE
#   - Filters out common commands to reduce noise
#----------------------------------------------------------------------#
function z_Debug_Handler {
    # Only process if debug mode is enabled
    (( Output_Debug_Mode )) || return 0
    
    # Skip empty commands
    [[ -z "$ZSH_DEBUG_CMD" ]] && return 0
    
    # Skip common commands that create noise
    typeset -a SkipPatterns=(
        'print *'           # Skip print commands
        '[[ *'             # Skip test constructs
        '(( *'             # Skip arithmetic
        'typeset *'        # Skip variable declarations
        'local *'          # Skip local declarations
        'return *'         # Skip return statements
    )
    
    for pattern in $SkipPatterns; do
        [[ "$ZSH_DEBUG_CMD" = ${~pattern} ]] && return 0
    done
    
    # Get current function name if available
    typeset FuncName="global_scope"
    if [[ ${#funcstack[@]} -gt 0 ]]; then
        FuncName="${funcstack[1]}"
    fi
    
    # Output debug information using z_Output if available
    if (( ${+functions[z_Output]} )); then
        z_Output debug "[$FuncName] $ZSH_DEBUG_CMD" Force=$TRUE
    else
        print -u2 "[DEBUG] [$FuncName] $ZSH_DEBUG_CMD"
    fi
}

# Set up the trap handlers
trap 'z_Debug_Handler' DEBUG
trap '[[ ${#funcstack[@]} -gt 0 ]] && z_Error_Handler $? $LINENO ${0##*/} "Error in ${funcstack[1]:-}"' ERR

# # Setting safe options for robust error handling:
# setopt errexit          # Exit the script when a command fails
setopt nounset          # Treat unset variables as an error
setopt pipefail         # Return the ERR exit status of the last command in the pipe that failed
setopt noclobber        # Prevents accidental overwriting of files
setopt localoptions     # Ensures script options remain local
setopt warncreateglobal # Warns if a global variable is created by mistake
setopt no_nomatch       # Prevents errors when a glob pattern does not match
setopt no_list_ambiguous # Disables ambiguous globbing behavior

#----------------------------------------------------------------------#
# Script-Scoped Variables - Boolean Constants
#----------------------------------------------------------------------#
# - `TRUE` and `FALSE` are integer constants representing boolean values.
# - Declared as readonly to ensure immutability
#----------------------------------------------------------------------#
typeset -r -i TRUE=1  # Represents the "true" state or enabled mode
typeset -r -i FALSE=0 # Represents the "false" state or disabled mode

#----------------------------------------------------------------------#
# Script-Scoped Variables - Execution Flags
#----------------------------------------------------------------------#
# - Script-scoped flags controlling various modes and behaviors
# - Declared as integers using `typeset -i` to ensure type safety
#----------------------------------------------------------------------#
typeset -i ScriptRunning=$FALSE         # Prevents recursive execution
typeset -i Output_Verbose_Mode=$FALSE   # Verbose mode
typeset -i Output_Quiet_Mode=$FALSE     # Quiet mode
typeset -i Output_Debug_Mode=$FALSE     # Debug mode
typeset -i Output_Color_Enabled=$TRUE   # Color output
typeset -i Output_Prompt_Enabled=$TRUE  # Interactive prompting

#----------------------------------------------------------------------#
# Script-Scoped Variables - Environment Detection Variables
#----------------------------------------------------------------------#
# - Environment variables used for detecting terminal capabilities
#   and script execution context
# - These can be overridden by command line flags
#----------------------------------------------------------------------#
typeset Script_No_Color="${NO_COLOR:-}"      # Industry standard for disabling color
typeset Script_Force_Color="${FORCE_COLOR:-}" # Build system standard for forcing color
typeset Script_CI="${CI:-}"                  # Continuous Integration environment flag
typeset Script_PS1="${PS1:-}"                # Shell prompt - indicates interactive shell
typeset Script_Term="${TERM:-}"              # Terminal type and capabilities

#----------------------------------------------------------------------#
# Terminal Color Constants
#----------------------------------------------------------------------#
# Description:
# - Defines terminal colors and attributes for script output styling.
# - Includes basic colors, bright variations, and emphasis attributes.
# - Dynamically initialized based on terminal capabilities.
# - Read-only to ensure consistent and predictable usage.
#----------------------------------------------------------------------#
typeset -i Output_Has_Color=$FALSE
typeset -i TputColors=0

# Safely retrieve the number of terminal colors
typeset -i Output_Has_Color=$FALSE
typeset -i TputColors=0

if command -v tput >/dev/null 2>&1; then
    TputColors=$(tput colors 2>/dev/null || echo 0)
    (( TputColors >= 8 )) && Output_Has_Color=$TRUE
fi

# Initialize terminal color variables if supported and enabled
if (( Output_Has_Color && Output_Color_Enabled )); then
    # Basic Colors
    Term_Black=$(tput setaf 0)
    Term_Red=$(tput setaf 1)
    Term_Green=$(tput setaf 2)
    Term_Yellow=$(tput setaf 3)
    Term_Blue=$(tput setaf 4)
    Term_Magenta=$(tput setaf 5)
    Term_Cyan=$(tput setaf 6)
    Term_White=$(tput setaf 7)

    # Bright Colors
    Term_BrightBlack=$(tput bold; tput setaf 0)
    Term_BrightRed=$(tput bold; tput setaf 1)
    Term_BrightGreen=$(tput bold; tput setaf 2)
    Term_BrightYellow=$(tput bold; tput setaf 3)
    Term_BrightBlue=$(tput bold; tput setaf 4)
    Term_BrightMagenta=$(tput bold; tput setaf 5)
    Term_BrightCyan=$(tput bold; tput setaf 6)
    Term_BrightWhite=$(tput bold; tput setaf 7)

    # Emphasis Attributes
    Term_Bold=$(tput bold)
    Term_Underline=$(tput smul)
    Term_NoUnderline=$(tput rmul)
    Term_Standout=$(tput smso)
    Term_NoStandout=$(tput rmso)
    Term_Blink=$(tput blink)
    Term_Dim=$(tput dim)
    Term_Reverse=$(tput rev)
    Term_Invisible=$(tput invis)

    # Reset Attributes
    Term_Reset=$(tput sgr0)
else
    # Fallback to empty strings if color is unsupported or disabled
    Term_Black="" Term_Red="" Term_Green=""
    Term_Yellow="" Term_Blue="" Term_Magenta=""
    Term_Cyan="" Term_White=""
    Term_BrightBlack="" Term_BrightRed="" Term_BrightGreen=""
    Term_BrightYellow="" Term_BrightBlue="" Term_BrightMagenta=""
    Term_BrightCyan="" Term_BrightWhite=""
    Term_Bold="" Term_Underline="" Term_NoUnderline=""
    Term_Standout="" Term_NoStandout="" Term_Blink=""
    Term_Dim="" Term_Reverse="" Term_Invisible=""
    Term_Reset=""
fi

# Make all terminal color and attribute variables readonly
typeset -r Term_Black Term_Red Term_Green \
          Term_Yellow Term_Blue Term_Magenta \
          Term_Cyan Term_White Term_BrightBlack \
          Term_BrightRed Term_BrightGreen Term_BrightYellow \
          Term_BrightBlue Term_BrightMagenta Term_BrightCyan \
          Term_BrightWhite Term_Bold Term_Underline \
          Term_NoUnderline Term_Standout Term_NoStandout \
          Term_Blink Term_Dim Term_Reverse \
          Term_Invisible Term_Reset

#----------------------------------------------------------------------#
# Function: cleanup
#----------------------------------------------------------------------#
# Description:
#   Performs cleanup operations when the script exits.
#
# Parameters:
#   $1 - Success flag (boolean)
#   $2 - Verbose flag (boolean) 
#
# Returns:
#   None
#----------------------------------------------------------------------#
function cleanup {
    typeset Success=$1
    typeset Verbose=$2

    # Reset the script running flag
    ScriptRunning=$FALSE

    if (( Success == $TRUE )); then
        # On success, report cleanup completion in verbose mode
        z_Output verbose "Cleanup completed successfully."
    else
        # On failure, use warning type which respects quiet mode
        z_Output warn "Script terminated with errors. Cleanup completed."
    fi
}

#----------------------------------------------------------------------#
# Function: check_Requirements
#----------------------------------------------------------------------#
# Description:
#   Verifies that all required external tools and capabilities are
#   available. Called as part of environment initialization.
#
# Parameters:
#   None
#
# Returns:
#   0 if all requirements are met
#   1 if any requirement is missing
#----------------------------------------------------------------------#
function check_Requirements {
    typeset -i ErrorCount=0

    # Local function to check Zsh version
    function check_Zsh_Version {
        typeset ZshOutput MinVer
        typeset -i Major=0 Minor=0

        ZshOutput="$(zsh --version)"
        if [[ -z "${ZshOutput}" ]]; then
            z_Error "Failed to get Zsh version"
            return 1
        fi

        # Extract version numbers using parameter expansion
        MinVer="${ZshOutput#*zsh }"
        MinVer="${MinVer%% *}"
        Major="${MinVer%%.*}"
        Minor="${MinVer#*.}"

        if (( Major < 5 || (Major == 5 && Minor < 8) )); then
            z_Error "Zsh version 5.8 or later required (found ${Major}.${Minor})"
            return 1
        fi
        return 0
    }

    # local function to check required commands
    function check_Required_Commands {
        typeset -a RequiredCommands=(
            "printf"  # For formatted output
            "zsh"     # To check version
        )
        typeset Command
        typeset -i CmdIdx
        typeset ErrorCount=0

        for (( CmdIdx=1; CmdIdx <= ${#RequiredCommands[@]}; CmdIdx++ )); do
            Command="${RequiredCommands[CmdIdx]}"
            if ! command -v "${Command}" >/dev/null 2>&1; then
                z_Error "Required command not found: ${Command}"
                (( ErrorCount++ ))
            fi
        done
        return $ErrorCount
    }

    # Execute each test
    check_Zsh_Version || (( ErrorCount++ ))
    check_Required_Commands || (( ErrorCount++ ))

    return (( ErrorCount ? 1 : 0 ))
}

#----------------------------------------------------------------------#
# Function: setup_Environment
#----------------------------------------------------------------------#
# Description:
#   Initializes the script environment and checks requirements.
#   Part of the core environment initialization process.
#
# Parameters:
#   None
#
# Returns:
#   0 on successful setup
#   1 on setup failure
#----------------------------------------------------------------------#
function setup_Environment {
    # Check requirements
    check_Requirements || return 1

    # Additional setup steps can be added here
    return 0
}

########################################################################
## Section: z_Utils
##--------------------------------------------------------------------##
## Description:
## - This section contains reusable Zsh utility functions (`z_Utils`) 
##   designed to enhance script functionality, maintainability, and 
##   consistency.
## - Functions in `z_Utils` can include support for:
##   - Structured output and formatted messaging
##   - Interactive prompts and user input handling
##   - Debugging, logging, and error management
##   - Automation and script execution utilities
##   - Text and binary manipulation
##   - Git and SSH management tools
## - Each function is modular, well-documented, and designed for easy 
##   integration into other scripts.
## - Most functions are lightweight and optimized for Zsh, but some 
##   may require external dependencies (e.g., Git, SSH, or jq), which 
##   are noted in their documentation.
##
## Part of Z_Utils - ZSH Utility Scripts 
##   - <https://github.com/ChristopherA/Z_Utils>
##   - <did:repo:e649e2061b945848e53ff369485b8dd182747991>
##     (c) 2025 Christopher Allen    
##     Licensed under BSD-2-Clause Plus Patent License
##
## Functions availalbe in this section:
##   - **z_Output** (1.0.00 - 2024-01-30)  
##     - Modular output function for managing script messages and prompts.
##
########################################################################

#----------------------------------------------------------------------#
# Function: z_Output
#----------------------------------------------------------------------#
# Description:
#   A flexible and modular function for displaying formatted output
#   in Zsh scripts. Provides consistent output formatting with support
#   for multiple message types, emoji prefixes, text wrapping,
#   indentation, verbosity levels, and interactive prompts.
#
# Version: 1.0.00 (2024-01-30)
#
# Change Log:   - 1.0.00 Initial stable release (2024-01-17)
#                   - Feature complete with 
#                       - Nine message types
#                       - Five modes
#                   - Text wrapping, indentation, and color support
#                   - Emoji and Unicode handling
#                   - Flexible message type and mode controls
#                   - Robust interactive and non-interactive prompting
#
# Features:
#   - Message Types: print, info, verbose, success, warn, error,
#       debug, vdebug, prompt
#   - Verbosity Modes:
#     - Verbose for detailed information
#     - Quiet to suppress non-critical messages
#     - Debug for troubleshooting output
#   - Other Modes:
#     - No-Prompt to disable interactive prompts
#     - Color to set color output
#   - Text Formatting: wrapping, indentation, ANSI colors
#   - Emoji Support: Customizable emoji prefixes per message type
#   - Interactive Prompts: With default values and automation support
#
# Default Behaviors:
#   print type:
#     - By default, behaves exactly like zsh's native print command
#     - No formatting (wrapping, indentation, emoji) by default
#     - Can optionally use formatting features if explicitly requested
#     - Suppressed in quiet mode like other non-critical messages
#     - Emoji support must be explicitly enabled via Emoji option
#   
#   Other message types:
#     - Without indent:
#       * If Wrap=0 or Wrap not specified: No wrapping
#       * If Wrap>0: Wrap at specified width
#     - With indent:
#       * Always wraps (at terminal width if Wrap not specified)
#       * Wraps at Wrap width if specified and < terminal width
#       * Continuation lines indented +2 spaces from base indent
#     - Line Continuation:
#       * Wrapped lines align with text after emoji/prefix
#       * Preserves spacing and formatting
#     - Mode Controls:
#       * debug/vdebug respect both Force and mode flags
#       * verbose respects both quiet mode and Force
#       * error shows even in quiet mode
#
# Parameters:
#   1. Type (string):
#      Message type controlling appearance and behavior
#      Supported types:
#        print:   Standard output, like zsh print (no formatting by default)
#        info:    Informational messages (cyan, 💡)
#        verbose: Detailed output shown in verbose mode, hidden in quiet (yellow, 📘)
#        success: Success messages (green, ✅)
#        warn:    Warning messages (magenta, ⚠️)
#        error:   Critical errors, shown even in quiet mode (red, ❌)
#        debug:   Debug messages shown only in debug mode (blue, 🛠️)
#        vdebug:  Verbose debug messages, requires both debug AND verbose (magenta, 🔍)
#        prompt:  Interactive prompts (standout color, ❓, supports non-interactive)
#
#   2. Message (string):
#      The text content to display. Supports:
#      - Multi-line text
#      - Spaces and tabs (preserved)
#      - Empty messages
#      - Special characters
#      - Very long words/URLs
#      - Unicode including emoji
#
#   3. Options (Key=Value pairs, optional):
#      Additional formatting options:
#      
#      Color (string):
#        - ANSI color code to override default for message type
#        - Empty string disables coloring
#        Example: Color="$(tput setaf 1)" # Force red text
#                Color="" # Disable color
#
#      Emoji (string):
#        - Custom emoji prefix overriding default for message type
#        - Empty string disables emoji
#        - Required for print type to show emoji
#        Example: Emoji="🌟" # Custom star emoji
#
#      Wrap (integer):
#        - Maximum line width for text wrapping
#        - When not specified or 0:
#          * No wrapping if no indent specified
#          * Terminal width wrapping if indent specified
#        - When >0: Wrap at specified width
#        - When >terminal width: Wrap at terminal width
#        - Minimum 20 characters, maximum current terminal width
#        - Adjusts automatically if terminal is resized
#        - Takes precedence over indent-triggered wrapping
#        Example: Wrap=60 # Wrap at 60 characters
#
#      Indent (integer):
#        - Number of spaces for left indentation
#        - Defaults to 0 (no indent)
#        - When specified: Enables wrapping even if Wrap=0
#        - Applies to all lines including wrapped text
#        - Wrapped lines get +2 spaces additional indent
#        - Wrap width defaults to terminal width if not specified
#        Example: Indent=4 # Four space indent
#
#      Default (string):
#        - Default value for prompts when non-interactive
#        - Used when Output_Prompt_Enabled is FALSE
#        - Preserves exact spacing when used
#        Example: Default="yes" # Default prompt response
#
#      Force (boolean):
#        - Forces output even in quiet mode
#        - Overrides quiet mode for all message types
#        - Does not bypass debug/verbose mode requirements
#        - vdebug still requires both debug AND verbose even with Force
#        Example: Force=$TRUE # Force display in quiet mode
#
# Returns:
#   - For prompts: Prints and returns user input or default value
#   - For messages: Prints formatted text, returns 0
#   - For errors: Prints error message and returns 1
#   - Returns 2 for invalid message types
#
# Dependencies:
#   Required commands:
#   - tput: For color and terminal capabilities
#   - printf: For formatted output
#
#   Required zsh options:
#   - localoptions: For local option scope
#   - warncreateglobal: For variable scope warnings
#
#   Script-scoped variables (must be declared):
#   - Output_Verbose_Mode (integer): Controls verbose message display
#   - Output_Quiet_Mode (integer): Controls message suppression
#   - Output_Debug_Mode (integer): Controls debug message display
#   - Output_Prompt_Enabled (integer): Controls interactive prompting
#   - TRUE/FALSE (integer): Boolean constants as integers (i.e. 1/0)
#   - Term_* variables: Color and formatting codes
#
#   Required terminal color variables (script-local read-only):
#   - Basic colors: Term_Black, Term_Red, Term_Green, Term_Yellow,  
#     Term_Blue, Term_Magenta, Term_Cyan, Term_White: 
#   - Bright colors: Term_BrightBlack, Term_BrightRed, 
#     Term_BrightGreen, Term_BrightYellow, Term_BrightBlue, 
#     Term_BrightMagenta, Term_BrightCyan, Term_BrightWhite
#   - Text attributes: Term_Bold, Term_Underline, 
#     Term_NoUnderline, Term_Standout, Term_NoStandout, 
#     Term_Blink, Term_Dim, Term_Reverse, Term_Invisible 
#   - Reset all: Term_Reset
#
# Examples:
#   ### Basic Message Types ###
#   - Print (standard output):
#       z_Output print "Standard message with no formatting"
#       z_Output print "Print with wrap" Wrap=60
#       z_Output print "Print with emoji" Emoji="📝"
#
#   - Info messages:
#       z_Output info "Basic informational message"
#       z_Output info "Custom info message" Emoji="ℹ️" Color="$Term_Cyan"
#       z_Output info "Info with wrap and indent" Wrap=60 Indent=4
#
#   - Success messages:
#       z_Output success "Operation completed successfully"
#       z_Output success "Detailed success" Wrap=60 Indent=2
#
#   - Warning messages:
#       z_Output warn "Configuration issue detected"
#       z_Output warn "Multi-line warning\nSecond line" Indent=4
#
#   - Error messages:
#       z_Output error "Operation failed"
#       z_Output error "Critical error" Color="$Term_BrightRed"
#
#   ### Debug and Verbose Messages ###
#   - Debug messages (requires debug mode):
#       z_Output debug "Debug information follows..."
#       z_Output debug "Force debug message" Force=$TRUE
#
#   - Verbose messages (requires verbose mode):
#       z_Output verbose "Detailed processing information"
#       z_Output verbose "Force verbose message" Force=$TRUE
#
#   - Verbose debug (requires both modes):
#       z_Output vdebug "Detailed debug trace"
#       z_Output vdebug "Forced vdebug" Force=$TRUE
#
#   ### Interactive Prompts ###
#   - Basic prompts:
#       UserInput=$(z_Output prompt "Enter your name:")
#       Choice=$(z_Output prompt "Continue? (Y/n):" Default="Y")
#
#   - Non-interactive mode:
#       Output_Prompt_Enabled=$FALSE
#       Default=$(z_Output prompt "Skip prompt" Default="yes")
#
#   ### Advanced Formatting ###
#   - Wrapping and indentation:
#       z_Output info "Long wrapped message at 60 chars" Wrap=60
#       z_Output warn "Indented warning message" Indent=4
#       z_Output info "Combined format" Wrap=50 Indent=2
#
#   - Custom formatting:
#       z_Output info "Custom color" Color="$Term_BrightCyan"
#       z_Output warn "Custom emoji" Emoji="⚡"
#       z_Output info "No emoji message" Emoji=""
#
#   - Complex combinations:
#       z_Output info "Complex formatted message with custom\n" \
#          "appearance and wrapped text that spans\n" \
#          "multiple lines" \
#          Wrap=40 Indent=4 Emoji="📢" Color="$Term_BrightBlue"
#
#   ### Mode Control ###
#   - Quiet mode override:
#       z_Output info "Always show this" Force=$TRUE
#       z_Output verbose "Force verbose in quiet" Force=$TRUE
#
#   - Debug control:
#       z_Output debug "Debug if enabled" Force=$TRUE
#       z_Output vdebug "Vdebug needs both modes" Force=$TRUE
#
# Notes:
#   - Terminal Support:
#     - Requires terminal with ANSI color support
#     - Automatically wraps to terminal width
#     - Adapts to terminal resizing during execution
#     - Degrades gracefully in basic terminals
#     - Minimum width of 20 characters enforced
#     - Uses current terminal width at time of each call
#
#   - Text Processing:
#     - Preserves tabs (converts to spaces)
#     - Maintains spacing and line breaks
#     - Handles special characters and Unicode
#     - Word-wraps long text
#     - Preserves empty lines
#     - Handles multi-byte characters and emoji correctly
#
#   - Message Control:
#     - Quiet mode suppresses all except error and forced messages
#     - Verbose mode shows verbose messages (unless quiet)
#     - Debug mode enables debug messages
#     - Debug AND verbose modes required for vdebug
#     - Force flag overrides quiet mode only
#     - Error messages always show regardless of modes
#
#   - Zsh Specific:
#     - Uses Zsh parameter expansion flags
#     - Requires Zsh arrays and associative arrays
#     - Takes advantage of Zsh string manipulation
#     - Uses Zsh read builtin for prompts
#     - Handles zsh-specific terminal behavior
#
# Known Issues:
#   - Space Preservation in Interactive Prompts:
#     When entering text at interactive prompts (not accepting defaults),
#     spaces may be affected:
#     - Leading spaces are stripped
#     - Trailing spaces may be inconsistent
#     - Internal spaces are preserved
#     This is a limitation of zsh's read builtin and affects only
#     manually entered text; default values preserve spaces correctly.
#----------------------------------------------------------------------#
function z_Output {
    # Required first parameter is message type with error on missing
    # ${1:?msg} is shared between zsh/bash but behavior differs on missing parameter
    typeset MessageType="${1:?Missing message type}"
    shift

    # Zsh arrays are 1-based and require explicit declaration of pattern matching arrays
    # match/mbegin/mend are special zsh arrays used for regex capture groups
    typeset -a match mbegin mend
    typeset -a MessageParts
    # -A creates associative array (like bash -A but with different scoping rules)
    typeset -A OptionsMap
    
    # In zsh, typeset creates local variables with explicit typing
    # Unlike bash where local/declare are interchangeable
    typeset MessageText IndentText WrapIndentText PrefixText
    typeset LineText WordText CurrentLine OutputText
    typeset KeyName Value
    
    # Zsh associative arrays persist declaration order unlike bash
    typeset -A ColorMap EmojiMap SuppressionMap
    
    ColorMap=(
        "print"   "$Term_Reset"
        "info"    "$Term_Cyan"
        "verbose" "$Term_Yellow"
        "success" "$Term_Green"
        "warn"    "$Term_Magenta"
        "error"   "$Term_Red"
        "debug"   "$Term_Blue"
        "vdebug"  "$Term_Blue"
        "prompt"  "$Term_Standout"
        "reset"   "$Term_Reset"
    )
    
    EmojiMap=(
        "print"   ""
        "info"    "💡"
        "verbose" "📘"
        "success" "✅"
        "warn"    "⚠️"
        "error"   "❌"
        "debug"   "🛠️"
        "vdebug"  "🔍"
        "prompt"  "❓"
    )
    
    SuppressionMap=(
        "print"   1
        "info"    1
        "verbose" 1
        "success" 1
        "warn"    1
        "error"   0
        "debug"   1
        "vdebug"  1
        "prompt"  0
    )

    # Zsh regex pattern matching using =~ behaves differently than bash
    # Captures stored in $match array rather than bash's ${BASH_REMATCH}
    while (( $# > 0 )); do
        if [[ "$1" =~ ^([^=]+)=(.*)$ ]]; then
            KeyName="${match[1]}"
            Value="${match[2]}"
            OptionsMap[$KeyName]="$Value"
        else
            MessageParts+=("$1")
        fi
        shift
    done
    
    # ${(j: :)array} is zsh array joining with space separator
    # Equivalent to "${array[*]}" in bash but preserves multiple spaces
    MessageText="${(j: :)MessageParts}"

    # Explicit integer declaration required in zsh for arithmetic context
    typeset -i AllowMessage=$FALSE
    case "$MessageType" in
        "vdebug")
            # Zsh arithmetic expressions use (( )) like bash but with stricter typing
            (( AllowMessage = (Output_Debug_Mode == 1 && Output_Verbose_Mode == 1) ? TRUE : FALSE ))
            ;;
        "debug")
            (( AllowMessage = (Output_Debug_Mode == 1) ? TRUE : FALSE ))
            ;;
        "verbose")
            (( AllowMessage = (Output_Verbose_Mode == 1) ? TRUE : FALSE ))
            ;;
        *)
            (( AllowMessage = TRUE ))
            ;;
    esac

    if (( Output_Quiet_Mode == 1 && ${SuppressionMap[$MessageType]:-0} == 1 && ${OptionsMap[Force]:-0} != 1 )); then
        return 0
    fi

    if (( AllowMessage == 0 && ${OptionsMap[Force]:-0} != 1 )); then
        return 0
    fi

    if [[ "$MessageType" == "prompt" ]]; then
        typeset Default="${OptionsMap[Default]:-}"
        typeset EmptyDefault="$([[ -z "$Default" ]] && echo "(empty)" || echo "$Default")"
        typeset Prompt="${MessageText:-Enter value}"
        typeset PromptEmoji="${OptionsMap[Emoji]:-${EmojiMap[$MessageType]:-}}"
        typeset IndentText=""
        typeset PromptText
        
        # Handle indentation for prompts
        typeset -i IndentSize=${OptionsMap[Indent]:-0}
        (( IndentSize > 0 )) && IndentText="$(printf '%*s' $IndentSize '')"
        
        if [[ -n "$Default" ]]; then
            # :+ is parameter expansion shared with bash but more commonly used in zsh
            PromptText="${IndentText}${PromptEmoji:+$PromptEmoji }${Prompt} [${EmptyDefault}]"
        else
            PromptText="${IndentText}${PromptEmoji:+$PromptEmoji }${Prompt}"
        fi

        if (( Output_Prompt_Enabled == 0 )); then
            print -- "${Default}"
            return 0
        fi

        # Zsh read has -r flag like bash but variable=value? syntax for prompt
        # This syntax preserves exact spacing unlike bash's -p flag
        typeset UserInput
        read -r "UserInput?${PromptText}: "
        print -- "${UserInput:-$Default}"
        return 0
    fi

    typeset CurrentColor="${OptionsMap[Color]:-${ColorMap[$MessageType]:-}}"
    typeset ResetColor="${ColorMap[reset]}"
    typeset CurrentEmoji=""

    if [[ -n "$MessageText" && ("$MessageType" != "print" || ( -v "OptionsMap[Emoji]" )) ]]; then
        # Use :+ to check if Emoji is set (even if empty) before falling back to default
        if [[ -v "OptionsMap[Emoji]" ]]; then
            CurrentEmoji="${OptionsMap[Emoji]}"
        else
            CurrentEmoji="${EmojiMap[$MessageType]:-}"
        fi
        [[ -n "$CurrentEmoji" ]] && CurrentEmoji+=" "
    fi

    # Integer math in zsh requires explicit typing for reliable results
    typeset -i IndentSize=${OptionsMap[Indent]:-0}
    typeset -i BaseIndent=$IndentSize
    (( BaseIndent < 0 )) && BaseIndent=0

    IndentText=""
    [[ $BaseIndent -gt 0 ]] && IndentText="$(printf '%*s' $BaseIndent '')"
    
    WrapIndentText="$IndentText"
    [[ $BaseIndent -gt 0 ]] && WrapIndentText+="  "

    typeset -i TerminalWidth=$(tput cols)
    typeset -i RequestedWrap=${OptionsMap[Wrap]:-0}
    typeset -i WrapWidth

    if (( RequestedWrap == 0 && IndentSize == 0 )); then
        # print -- behaves differently than echo in zsh, more predictable for output
        print -- "${CurrentColor}${CurrentEmoji}${MessageText}${ResetColor}"
        return 0
    elif (( RequestedWrap > 0 )); then
        WrapWidth=$(( RequestedWrap <= TerminalWidth ? RequestedWrap : TerminalWidth ))
    elif (( IndentSize > 0 )); then
        WrapWidth=$TerminalWidth
    else
        print -- "${CurrentColor}${CurrentEmoji}${MessageText}${ResetColor}"
        return 0
    fi

    typeset -i WrapMargin=2
    typeset -i MinContentWidth=40
    typeset -i EffectiveWidth=$(( WrapWidth - BaseIndent - WrapMargin ))
    (( EffectiveWidth < MinContentWidth )) && EffectiveWidth=MinContentWidth

    OutputText=""
    CurrentLine="${IndentText}${CurrentEmoji}"
    typeset -i IsFirstLine=1

    # ${(ps:\n:)text} is zsh-specific splitting that preserves empty lines
    # Unlike bash IFS splitting which would collapse empty lines
    typeset -a Lines
    typeset Line
    Lines=(${(ps:\n:)MessageText})
    
    typeset -i LineNum=1
    for Line in $Lines; do
        if (( LineNum > 1 )); then
            OutputText+="${CurrentLine}"$'\n'
            CurrentLine="${IndentText}"
            IsFirstLine=0
        fi
        
        # Split preserving exact whitespace patterns
        typeset -a Words
        Words=(${(ps: :)Line})
        
        for WordText in $Words; do
            # Tab expansion consistent between zsh/bash
            WordText=${WordText//$'\t'/    }
            
            # ${(%)string} is zsh-specific expansion that handles prompt escapes
            # Used for accurate Unicode width calculation, no bash equivalent
            typeset -i WordWidth=${#${(%)WordText}}
            typeset -i CurrentWidth=${#${(%)CurrentLine}}
            
            if (( CurrentWidth + WordWidth + 1 > WrapWidth - WrapMargin )); then
                if (( CurrentWidth > ${#IndentText} + (IsFirstLine ? ${#CurrentEmoji} : 0) )); then
                    OutputText+="${CurrentLine}"$'\n'
                    CurrentLine="${WrapIndentText}"
                    IsFirstLine=0
                fi
                
                if (( WordWidth > EffectiveWidth )); then
                    while (( ${#WordText} > EffectiveWidth )); do
                        # Zsh array slicing uses [start,end] unlike bash's offset/length
                        CurrentLine+="${WordText[1,EffectiveWidth]}"
                        OutputText+="${CurrentLine}"$'\n'
                        WordText="${WordText[EffectiveWidth+1,-1]}"
                        CurrentLine="${WrapIndentText}"
                        IsFirstLine=0
                    done
                fi
                CurrentLine+="$WordText"
            else
                if (( CurrentWidth == ${#IndentText} + (IsFirstLine ? ${#CurrentEmoji} : 0) )); then
                    CurrentLine+="$WordText"
                else
                    CurrentLine+=" $WordText"
                fi
            fi
        done
        (( LineNum++ ))
    done

    [[ -n "$CurrentLine" ]] && OutputText+="${CurrentLine}"

    print -- "${CurrentColor}${OutputText}${ResetColor}"
    return 0
}

#----------------------------------------------------------------------#
# Function: z_Output_Demo
#----------------------------------------------------------------------#
# Description:
#   Demonstrates the functionality and flexibility of the `z_Output` function.
#   Covers all message types (info, success, warn, error, verbose, prompt),
#   while exploring verbosity, quiet mode, wrapping, indentation, custom emojis,
#   and more. Provides clear examples for users to understand and adapt
#   `z_Output` for their own scripts.
#
# Parameters:
#   None
#
# Returns:
#   None. Outputs demonstration results to the console.
#----------------------------------------------------------------------#
function z_Output_Demo {
    # Save initial state
    typeset -i Initial_Verbose=$Output_Verbose_Mode
    typeset -i Initial_Quiet=$Output_Quiet_Mode
    typeset -i Initial_Debug=$Output_Debug_Mode
    typeset -i Initial_Prompt=$Output_Prompt_Enabled

    # Test suite shared variables
    typeset -i TerminalWidth=$(tput cols)
    typeset -r TestFiller="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Curabitur convallis."

    # Resets all output modes to their default states and validates reset.
    #   Called before each test section to ensure clean test environment.

    function reset_modes {
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
    typeset -a TestSections=(
        "Default Behavior"         test_default_behavior
        "Verbose Mode"            test_verbose_mode
        "Debug Mode"              test_debug_mode
        "Quiet Mode"              test_quiet_mode
        "Emoji Tests"             test_emoji_customization
        "Format Tests"            test_wrapping_and_indentation
        "Real-World Tests"        test_combined_wrapping_and_indentation
        "Non-Interactive"         test_non_interactive_prompts
        "Interactive"             test_interactive_prompts
    )

    function test_default_behavior {
        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section 1 of 9: Default Behavior"
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
        z_Output print "This is a basic z_Output print message, with no formatting options - output matches zsh's native print command. $TestFiller"
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
        z_Output print "This text demonstrates wrapping at 60 characters. $TestFiller" Wrap=60
        z_Output print ""
        z_Output print "b. Narrow wrap at 30 characters:"
        z_Output print "This text demonstrates narrow wrapping. $TestFiller" Wrap=30
        z_Output print ""
        
        # Test 2: Indentation
        z_Output print "2. Indentation (optional):"
        z_Output print "a. 4-space indent:"
        z_Output print "This shows 4-space indentation." Indent=4
        z_Output print ""
        z_Output print "b. 8-space indent with natural wrap:"
        z_Output print "This shows 8-space indent with terminal width wrapping. $TestFiller" Indent=8
        z_Output print ""
        
        # Test 3: Combined formatting
        z_Output print "3. Combined formatting:"
        z_Output print "a. Indent and wrap together:"
        z_Output print "This shows combined indent and wrap formatting. $TestFiller" Indent=4 Wrap=40
        z_Output print ""
        z_Output print "b. With line breaks:"
        z_Output print "First line with formatting. $TestFiller\nSecond line continues. $TestFiller" Wrap=72 Indent=8
        z_Output print ""
        
        # Test 4: Custom formatting
        z_Output print "4. Custom formatting:"
        z_Output print "Custom emoji and color example:" Emoji="🌟" Color="$Term_Yellow"
        z_Output print ""
        
        # Message Type Defaults subsection
        z_Output print "C. Message Type Defaults"
        z_Output print "------------------------------------------------------------"
        z_Output print "Default formatting for each message type:"
        z_Output info "Info message (💡 cyan)"
        z_Output success "Success message (✅ green)"
        z_Output warn "Warning message (⚠️ yellow)"
        z_Output error "Error message (❌ red)"
        z_Output verbose "Verbose message (📘 blue, hidden without --verbose)"
        z_Output debug "Debug message (🛠️ magenta, hidden without --debug)"
        z_Output vdebug "Verbose debug message (🔍 magenta, hidden without --debug and --verbose)"
        z_Output print ""
    }

    function test_verbose_mode {
        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section 2 of 9: Verbose Mode Tests"
        z_Output print "============================================================"
        z_Output print "Tests output behavior across verbose mode states."
        z_Output print "Shows message visibility in each state."
        z_Output print "============================================================"
        z_Output print ""

        # Initial State subsection
        z_Output print "A. Initial State (verbose=0):" Force=$TRUE
        z_Output print "------------------------------------------------------------"
        Output_Verbose_Mode=$FALSE
        
        z_Output print "1. Standard Messages (should appear):" Force=$TRUE
        z_Output print "Print message (standard output)"
        z_Output info "Info message (standard output)"
        z_Output success "Success message (standard output)"
        z_Output warn "Warning message (standard output)"
        z_Output error "Error message (standard output)"
        z_Output print ""
        
        z_Output print "2. Verbose Messages (should be hidden):" Force=$TRUE
        z_Output verbose "This verbose message should be hidden [Expected: Hidden]"
        z_Output verbose "Another verbose message that should be hidden [Expected: Hidden]"
        z_Output print ""

        # Verbose Mode Enabled subsection
        z_Output print "B. With Verbose Mode (verbose=1):" Force=$TRUE
        z_Output print "------------------------------------------------------------"
        Output_Verbose_Mode=$TRUE
        z_Output print "Enabling verbose mode..." Force=$TRUE
        
        z_Output print "1. Standard Messages (should appear):" Force=$TRUE
        z_Output print "Print message (with verbose)"
        z_Output info "Info message (with verbose)"
        z_Output success "Success message (with verbose)"
        z_Output warn "Warning message (with verbose)"
        z_Output error "Error message (with verbose)"
        z_Output print ""
        
        z_Output print "2. Verbose Messages (should now appear):" Force=$TRUE
        z_Output verbose "This verbose message should now be visible [Expected: Visible]"
        z_Output verbose "Another verbose message that should now be visible [Expected: Visible]"
        z_Output print ""

        # Force Flag subsection
        z_Output print "C. Force Flag Tests:" Force=$TRUE
        z_Output print "------------------------------------------------------------"
        Output_Verbose_Mode=$FALSE
        z_Output print "Disabling verbose mode..." Force=$TRUE
        
        z_Output print "1. Without Force (verbose=0):" Force=$TRUE
        z_Output verbose "Verbose without force [Expected: Hidden]"
        z_Output print ""

        z_Output print "2. With Force (verbose=0):" Force=$TRUE
        z_Output verbose "Forced verbose message [Expected: Visible]" Force=$TRUE
        z_Output print ""

        # Reset verbose mode
        Output_Verbose_Mode=$FALSE
        z_Output print "Resetting verbose mode to default state (verbose=0)..." Force=$TRUE
        z_Output print ""
    }

    function test_debug_mode {
        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section 3 of 9: Debug Mode Tests"
        z_Output print "============================================================"
        z_Output print "Tests output behavior across all debug and verbose combinations."
        z_Output print "Shows message visibility in each state."
        z_Output print "============================================================"
        z_Output print ""

        # Initial State subsection
        z_Output print "A. Initial State (debug=0, verbose=0):" Force=$TRUE
        z_Output print "------------------------------------------------------------"
        Output_Debug_Mode=$FALSE
        Output_Verbose_Mode=$FALSE
        z_Output print "Starting with all modes disabled..." Force=$TRUE
        
        z_Output print "1. Standard Messages (should appear):" Force=$TRUE
        z_Output info "Standard message [State: no debug, no verbose]"
        z_Output print ""
        
        z_Output print "2. Debug Messages (should be hidden):" Force=$TRUE
        z_Output debug "Debug message [Expected: Hidden]"
        z_Output print ""
        
        z_Output print "3. Verbose Debug Messages (should be hidden):" Force=$TRUE
        z_Output vdebug "Verbose debug message [Expected: Hidden]"
        z_Output print ""

        # Verbose Only subsection
        z_Output print "B. Verbose Only (debug=0, verbose=1):" Force=$TRUE
        z_Output print "------------------------------------------------------------"
        Output_Debug_Mode=$FALSE
        Output_Verbose_Mode=$TRUE
        z_Output print "Enabling verbose mode only..." Force=$TRUE
        
        z_Output print "1. Standard Messages (should appear):" Force=$TRUE
        z_Output info "Standard message [State: no debug, with verbose]"
        z_Output print ""
        
        z_Output print "2. Debug Messages (should be hidden):" Force=$TRUE
        z_Output debug "Debug message [Expected: Hidden]"
        z_Output print ""
        
        z_Output print "3. Verbose Debug Messages (should be hidden):" Force=$TRUE
        z_Output vdebug "Verbose debug message [Expected: Hidden - needs both modes]"
        z_Output print ""

        # Debug Only subsection
        z_Output print "C. Debug Only (debug=1, verbose=0):" Force=$TRUE
        z_Output print "------------------------------------------------------------"
        Output_Debug_Mode=$TRUE
        Output_Verbose_Mode=$FALSE
        z_Output print "Enabling debug mode only..." Force=$TRUE
        
        z_Output print "1. Standard Messages (should appear):" Force=$TRUE
        z_Output info "Standard message [State: with debug, no verbose]"
        z_Output print ""
        
        z_Output print "2. Debug Messages (should appear):" Force=$TRUE
        z_Output debug "Debug message [Expected: Visible]"
        z_Output print ""
        
        z_Output print "3. Verbose Debug Messages (should be hidden):" Force=$TRUE
        z_Output vdebug "Verbose debug message [Expected: Hidden - needs verbose too]"
        z_Output print ""

        # Debug and Verbose subsection
        z_Output print "D. Both Debug and Verbose (debug=1, verbose=1):" Force=$TRUE
        z_Output print "------------------------------------------------------------"
        Output_Debug_Mode=$TRUE
        Output_Verbose_Mode=$TRUE
        z_Output print "Enabling both debug and verbose modes..." Force=$TRUE
        
        z_Output print "1. Standard Messages (should appear):" Force=$TRUE
        z_Output info "Standard message [State: with debug and verbose]"
        z_Output print ""
        
        z_Output print "2. Debug Messages (should appear):" Force=$TRUE
        z_Output debug "Debug message [Expected: Visible]"
        z_Output print ""
        
        z_Output print "3. Verbose Debug Messages (should appear):" Force=$TRUE
        z_Output vdebug "Verbose debug message [Expected: Visible]"
        z_Output print ""

        # Force Flag subsection
        z_Output print "E. Force Flag Tests:" Force=$TRUE
        z_Output print "------------------------------------------------------------"
        Output_Debug_Mode=$FALSE
        Output_Verbose_Mode=$FALSE
        z_Output print "Disabling all modes for force testing..." Force=$TRUE
        
        z_Output print "1. Force Debug (debug=0):" Force=$TRUE
        z_Output debug "Forced debug message [Expected: Visible]" Force=$TRUE
        z_Output print ""
        
        z_Output print "2. Force Verbose Debug (debug=0, verbose=0):" Force=$TRUE
        z_Output vdebug "Forced verbose debug message [Expected: Visible]" Force=$TRUE
        z_Output print ""

        # Reset all modes
        Output_Debug_Mode=$FALSE
        Output_Verbose_Mode=$FALSE
        z_Output print "Resetting all modes to default state..." Force=$TRUE
        z_Output print ""
    }

    function test_quiet_mode {
        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section 4 of 9: Quiet Mode Tests"
        z_Output print "============================================================"
        z_Output print "Tests message suppression in quiet mode."
        z_Output print "Validates proper handling of verbose and debug messages."
        z_Output print "============================================================"
        z_Output print ""

        # Baseline - No Quiet Mode
        z_Output print "A. Baseline - No Quiet Mode (quiet=0):" Force=$TRUE
        z_Output print "------------------------------------------------------------"
        Output_Quiet_Mode=$FALSE
        Output_Debug_Mode=$FALSE
        Output_Verbose_Mode=$FALSE
        
        z_Output print "1. Regular Messages (should appear):" Force=$TRUE
        z_Output info "Info message [State: no quiet]"
        z_Output debug "Debug message [State: no quiet, no debug]"
        z_Output verbose "Verbose message [State: no quiet, no verbose]"
        z_Output vdebug "VDebug message [State: no quiet, no debug, no verbose]"
        z_Output print ""

        # Basic Quiet Mode
        z_Output print "B. Basic Quiet Mode (quiet=1):" Force=$TRUE
        z_Output print "------------------------------------------------------------"
        Output_Quiet_Mode=$TRUE
        
        z_Output print "1. Regular Messages (should be hidden):" Force=$TRUE
        z_Output info "Info message [State: quiet]"
        z_Output print "Print message [State: quiet]"
        z_Output print ""
        
        z_Output print "2. Error Messages (should show):" Force=$TRUE
        z_Output error "Error message [State: quiet]"
        z_Output print ""
        
        z_Output print "3. Forced Messages (should show):" Force=$TRUE
        z_Output info "Forced info message [State: quiet]" Force=$TRUE
        z_Output print ""

        # Quiet + Verbose Mode
        z_Output print "C. Quiet + Verbose Mode (quiet=1, verbose=1):" Force=$TRUE
        z_Output print "------------------------------------------------------------"
        Output_Verbose_Mode=$TRUE
        
        z_Output print "1. Regular Messages (should be hidden):" Force=$TRUE
        z_Output info "Info message [State: quiet, verbose]"
        z_Output print ""
        
        z_Output print "2. Verbose Messages (should be hidden):" Force=$TRUE
        z_Output verbose "Verbose message [State: quiet, verbose]"
        z_Output verbose "Forced verbose message [State: quiet, verbose]" Force=$TRUE
        z_Output print ""
        
        z_Output print "3. VDebug Messages (should be hidden):" Force=$TRUE
        z_Output vdebug "VDebug message [State: quiet, verbose, no debug]"
        z_Output print ""

        # Quiet + Debug Mode
        z_Output print "D. Quiet + Debug Mode (quiet=1, debug=1):" Force=$TRUE
        z_Output print "------------------------------------------------------------"
        Output_Verbose_Mode=$FALSE
        Output_Debug_Mode=$TRUE
        
        z_Output print "1. Regular Messages (should be hidden):" Force=$TRUE
        z_Output info "Info message [State: quiet, debug]"
        z_Output print ""
        
        z_Output print "2. Debug Messages (should be hidden):" Force=$TRUE
        z_Output debug "Debug message [State: quiet, debug]"
        z_Output debug "Forced debug message [State: quiet, debug]" Force=$TRUE
        z_Output print ""
        
        z_Output print "3. VDebug Messages (should be hidden):" Force=$TRUE
        z_Output vdebug "VDebug message [State: quiet, debug, no verbose]"
        z_Output print ""

        # Quiet + Debug + Verbose Mode
        z_Output print "E. All Modes (quiet=1, debug=1, verbose=1):" Force=$TRUE
        z_Output print "------------------------------------------------------------"
        Output_Verbose_Mode=$TRUE
        
        z_Output print "1. Regular Messages (should be hidden):" Force=$TRUE
        z_Output info "Info message [State: quiet, debug, verbose]"
        z_Output print ""
        
        z_Output print "2. Debug Messages (should be hidden):" Force=$TRUE
        z_Output debug "Debug message [State: quiet, debug, verbose]"
        z_Output print ""
        
        z_Output print "3. Verbose Messages (should be hidden):" Force=$TRUE
        z_Output verbose "Verbose message [State: quiet, debug, verbose]"
        z_Output print ""
        
        z_Output print "4. VDebug Messages (should be hidden):" Force=$TRUE
        z_Output vdebug "VDebug message [State: quiet, debug, verbose]"
        z_Output print ""
        
        z_Output print "5. Force Flag Tests:" Force=$TRUE
        z_Output info "Forced info [State: quiet, debug, verbose]" Force=$TRUE
        z_Output debug "Forced debug [State: quiet, debug, verbose]" Force=$TRUE
        z_Output verbose "Forced verbose [State: quiet, debug, verbose]" Force=$TRUE
        z_Output vdebug "Forced vdebug [State: quiet, debug, verbose]" Force=$TRUE
        z_Output print ""

        # Reset all modes
        Output_Quiet_Mode=$FALSE
        Output_Debug_Mode=$FALSE
        Output_Verbose_Mode=$FALSE
        z_Output print "Resetting all modes to default state..." Force=$TRUE
        z_Output print ""
    }

    function test_emoji_customization {
        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section 5 of 9: Emoji Customization"
        z_Output print "============================================================"
        z_Output print "Tests emoji display and alignment with different Unicode types."
        z_Output print "Shows how varying emoji widths affect message formatting."
        z_Output print "============================================================"
        z_Output print ""

        # Simple Emoji Tests
        z_Output print "A. Simple Emoji (Single Unicode Code Point):"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Basic single-character emoji:"
        z_Output info "Globe (standard width, renders as single character)" Emoji="🌍"
        z_Output print ""
        
        z_Output print "2. Another single-character emoji:"
        z_Output warn "Dragon (standard width, no modifiers needed)" Emoji="🐉"
        z_Output print ""
        
        z_Output print "3. Basic symbol emoji:"
        z_Output success "Star without variant selector (may appear as text in some terminals)" Emoji="⭐"
        z_Output print ""

        # Complex Emoji Tests
        z_Output print "B. Complex Emoji (Multiple Code Points):"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Zero-width joiner sequence:"
        z_Output info "Person coding (multiple emoji joined with ZWJ)" Emoji="🧑‍💻"
        z_Output print ""
        
        z_Output print "2. Multi-person grouping:"
        z_Output warn "Family (multiple emoji linked with multiple ZWJs)" Emoji="👨‍👩‍👧‍👦"
        z_Output print ""
        
        z_Output print "3. Modified flag sequence:"
        z_Output success "Pride flag (base flag modified with variation selector and rainbow)" Emoji="🏳️‍🌈"
        z_Output print ""

        # Variation Selector Tests
        z_Output print "C. Emoji With Variation Selectors:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Text vs emoji variation:"
        z_Output info "Hammer and wrench (VS-16 makes colorful emoji instead of monochrome text)" Emoji="🛠️"
        z_Output print ""
        
        z_Output print "2. Color variation:"
        z_Output warn "Heart (VS-16 changes black text ❤ to red emoji heart)" Emoji="❤️"
        z_Output print ""
        
        z_Output print "3. Keycap sequence:"
        z_Output success "Hash (VS-16 plus keycap creates button appearance from #)" Emoji="#️⃣"
        z_Output print ""

        # Skin Tone Tests
        z_Output print "D. Skin Tone and Other Modifiers:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Basic skin tone:"
        z_Output info "Construction worker with medium skin tone" Emoji="👷🏽"
        z_Output print ""
        
        z_Output print "2. Hand gesture with tone:"
        z_Output warn "Thumbs up with medium-dark skin tone" Emoji="👍🏾"
        z_Output print ""

        # Alignment Tests
        z_Output print "E. Emoji Alignment with Text Formatting:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Single emoji wrap test:"
        z_Output info "This text demonstrates wrapping alignment with simple emoji" Emoji="🌍" Wrap=40
        z_Output print ""
        
        z_Output print "2. Complex emoji wrap test:"
        z_Output warn "This text shows wrapping alignment with ZWJ sequence emoji" Emoji="🧑‍💻" Wrap=40
        z_Output print ""
        
        z_Output print "3. Modified emoji wrap test:"
        z_Output success "This text verifies wrapping with variation-selector emoji" Emoji="🛠️" Wrap=40
        z_Output print ""

        # Indentation Tests
        z_Output print "F. Emoji with Indentation:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Simple emoji indent:"
        z_Output info "Testing indentation with single-character emoji" Emoji="🐉" Indent=4
        z_Output print ""
        
        z_Output print "2. Complex emoji indent:"
        z_Output warn "Testing indentation with multi-character family emoji" Emoji="👨‍👩‍👧‍👦" Indent=4
        z_Output print ""

        # Combined Format Tests
        z_Output print "G. Combined Formatting Tests:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Simple emoji full format:"
        z_Output info "This shows wrapping and indentation with basic star emoji" Emoji="⭐" Wrap=50 Indent=4
        z_Output print ""
        
        z_Output print "2. ZWJ emoji full format:"
        z_Output warn "This shows wrapping and indentation with person coding emoji" Emoji="🧑‍💻" Wrap=50 Indent=4
        z_Output print ""
        
        z_Output print "3. VS emoji full format:"
        z_Output success "This shows wrapping and indentation with hammer and wrench emoji" Emoji="🛠️" Wrap=50 Indent=4
        z_Output print ""

        # Edge Cases
        z_Output print "H. Edge Cases:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Empty message with emoji:"
        z_Output info "" Emoji="🌟"
        z_Output print ""
        
        z_Output print "2. Multiple emoji prefix:"
        z_Output warn "Testing multiple emoji in prefix" Emoji="🎯🎯"
        z_Output print ""
        
        z_Output print "3. Mixed emoji in text:"
        z_Output success "Testing emoji both in prefix and content 👍 🎉 🚀" Emoji="📝"
        z_Output print ""

        # Emoji Override Tests
        z_Output print "I. Emoji Override Tests:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Default emoji behavior:"
        z_Output info "Message with default info emoji"
        z_Output warn "Message with default warning emoji"
        z_Output error "Message with default error emoji"
        z_Output print ""
        
        z_Output print "2. Custom emoji override:"
        z_Output info "Custom star emoji" Emoji="⭐"
        z_Output warn "Custom alert emoji" Emoji="🚨"
        z_Output error "Custom x emoji" Emoji="❌"
        z_Output print ""
        
        z_Output print "3. Explicitly disabled emoji:"
        z_Output info "Info without emoji" Emoji=""
        z_Output warn "Warning without emoji" Emoji=""
        z_Output error "Error without emoji" Emoji=""
        z_Output print ""
        
        z_Output print "4. Print type emoji behavior:"
        z_Output print "Print with no emoji by default"
        z_Output print "Print with explicit emoji" Emoji="📝"
        z_Output print "Print with empty emoji" Emoji=""
        z_Output print ""
    }

    function test_wrapping_and_indentation {
        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section 6 of 9: Wrapping and Indentation Tests"
        z_Output print "============================================================"
        z_Output print "Tests text wrapping and indentation behavior."
        z_Output print "Shows how options affect output formatting."
        z_Output print "============================================================"
        z_Output print ""

        # Print Type Tests
        z_Output print "A. Print Type Tests (should mimic native print):"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Basic print (no options):"
        z_Output print "$TestFiller"
        z_Output print ""
        
        z_Output print "2. Print Type with newlines (should preserve):"
        z_Output print "Line one $TestFiller\nLine two $TestFiller\nLine three $TestFiller"
        z_Output print ""
        
        z_Output print "3. Print Type with Wrap option (should ignore):"
        z_Output print "This text should wrap at 20 characters. $TestFiller" Wrap=20
        z_Output print ""
        
        z_Output print "4. Print with Indent option (should ignore):"
        z_Output print "This text should be unindented despite Indent=4 being set. $TestFiller" Indent=4
        z_Output print ""

        # Message Type Tests
        z_Output print "B. Message Type Default Behavior:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Info default (terminal width wrap):"
        z_Output info "This is a long info message that should wrap at terminal width since no explicit wrap is specified"
        z_Output print ""
        
        z_Output print "2. Warning default (terminal width wrap):"
        z_Output warn "This is a long warning message that should wrap at terminal width since no explicit wrap is specified"
        z_Output print ""
        
        z_Output print "3. Error default (terminal width wrap):"
        z_Output error "This is a long error message that should wrap at terminal width since no explicit wrap is specified"
        z_Output print ""

        # Wrap Tests
        z_Output print "C. Wrap Tests:"
        z_Output print "------------------------------------------------------------"
        z_Output print "1. No wrap (Wrap=0):"
        z_Output info "This message should not wrap at all because Wrap=0 was explicitly set" Wrap=0
        z_Output print ""
        
        z_Output print "2. Narrow wrap (Wrap=40):"
        z_Output info "This message should wrap at 40 characters which is a fairly narrow width that will cause frequent wrapping" Wrap=40
        z_Output print ""
        
        z_Output print "3. Wide wrap (Wrap=80):"
        z_Output info "This message should wrap at 80 characters which is a more typical terminal width that will cause less frequent wrapping" Wrap=80
        z_Output print ""

        # Indent Tests
        z_Output print "D. Indent Tests:"
        z_Output print "------------------------------------------------------------"
        z_Output print "1. Zero indent (Indent=0):"
        z_Output info "This message should have no indentation because Indent=0 was explicitly set" Indent=0
        z_Output print ""
        
        z_Output print "2. Small indent (Indent=2):"
        z_Output info "This message should have a two-space indent, commonly used for nested content" Indent=2
        z_Output print ""
        
        z_Output print "3. Large indent (Indent=8):"
        z_Output info "This message should have a large eight-space indent to test extreme indentation" Indent=8
        z_Output print ""

        # Combined Tests
        z_Output print "E. Combined Wrap and Indent Tests:"
        z_Output print "------------------------------------------------------------"
        z_Output print "1. Narrow wrap with small indent (Wrap=40, Indent=2):"
        z_Output info "This message combines a narrow wrap width with a small indent to test the interaction between wrapping and indentation" Wrap=40 Indent=2
        z_Output print ""
        
        z_Output print "2. Wide wrap with large indent (Wrap=80, Indent=8):"
        z_Output info "This message combines a wide wrap width with a large indent to test how extreme indentation affects wrapping" Wrap=80 Indent=8
        z_Output print ""

        # Special Content Tests
        z_Output print "F. Special Content Tests:"
        z_Output print "------------------------------------------------------------"
        z_Output print "1. Long word handling (Wrap=20):"
        z_Output info "Supercalifragilisticexpialidocious should break across lines" Wrap=20
        z_Output print ""
        
        z_Output print "2. URL handling (Wrap=40):"
        z_Output info "URL https://very-long-subdomain.example.com/path should break properly" Wrap=40
        z_Output print ""
        
        z_Output print "3. Spaces and tabs (should preserve):"
        z_Output info "Text with    multiple    spaces and\ttabs\tshould preserve spacing"
        z_Output print ""
        
        z_Output print "4. Mixed whitespace:"
        z_Output info "Line with trailing spaces    \nLine with leading spaces\n    Indented line\n\nBlank line above"
        z_Output print ""

        # Empty and Special Tests
        z_Output print "G. Empty and Special Character Tests:"
        z_Output print "------------------------------------------------------------"
        z_Output print "1. Empty message (should show no emoji):"
        z_Output info ""
        z_Output print ""
        
        z_Output print "2. Single space message:"
        z_Output info " "
        z_Output print ""
        
        z_Output print "3. Special characters:"
        z_Output info "!@#$%^&*()_+-=[]{}|;:'\",.<>/?"
        z_Output print ""

        # Nesting Tests
        z_Output print "H. Nesting Level Tests:"
        z_Output print "------------------------------------------------------------"
        z_Output info "Base level text (no indent)"
        z_Output info "First level indent (2 spaces)" Indent=2
        z_Output info "Second level (4 space indent, 60 char wrap) with longer text to demonstrate wrapping behavior" Indent=4 Wrap=60
        z_Output info "Third level (6 space indent, 40 char wrap) with longer text to demonstrate nested wrapping" Indent=6 Wrap=40
        z_Output print ""

        # Parameter Order Tests
        z_Output print "I. Parameter Order Tests:"
        z_Output print "------------------------------------------------------------"
        z_Output print "1. Message first, then options:"
        z_Output info "This message has options after" Wrap=40 Indent=2
        z_Output print ""
        
        z_Output print "2. Options first, then message:"
        z_Output info Wrap=40 Indent=2 "This message has options before"
        z_Output print ""
        
        z_Output print "3. Options split around message:"
        z_Output info Wrap=40 "This message has split options" Indent=2
        z_Output print ""
        
        z_Output print "4. Multiple option groups:"
        z_Output info Indent=2 "This message" Wrap=40 "has interspersed options" Emoji="📝"
        z_Output print ""
        
        z_Output print "5. All parameter types:"
        z_Output info Wrap=40 "First part" Indent=2 "Second part" Emoji="📝" Force=$TRUE
        z_Output print ""
        
        z_Output print "6. Option variation tests:"
        z_Output info Indent=2 Wrap=40 "Options adjacent, before message"
        z_Output info "Message first" Indent=2 Wrap=40 "with continuation"
        z_Output info Wrap=40 "Split message" Indent=2 "with options between"
        z_Output print ""
    }

    function test_combined_wrapping_and_indentation {
        # Get terminal width for dynamic adjustments
        typeset -i LocalTerminalWidth=$TerminalWidth
        
        # Test content variables
        typeset -r Lorem="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Curabitur convallis."
        typeset -r LongWord="SupercalifragilisticexpialidociousEvenThoughTheSoundOfItIsSomethingQuiteAtrocious"
        typeset -r CodeBlock='function example() {
        typeset var=value
        print "test output"
}'
    
    # SSH test content
    typeset -r exampleArmoredSshSignatureScript="-----BEGIN SSH SIGNATURE-----
U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgLY72f0jtErUNe+d3v54phP7QKv
VsIm903+l2RvvrblIAAAAEZmlsZQAAAAAAAAAGc2hhNTEyAAAAUwAAAAtzc2gtZWQyNTUx
OQAAAEAx+8hsFDjJgnvdPXVHVvBQ19wYA+YwMB4qH/h39wuPk30yvONb0di7D5WVHzKhwF
Rv5pOhGy5Hz/zcEg/YZFwJ
-----END SSH SIGNATURE-----"
        
    typeset -r exampleArmoredSshSignatureUnix="-----BEGIN SSH SIGNATURE-----
U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgLY72f0jtErUNe+d3v54phP7QKv
VsIm903+l2RvvrblIAAAAEZmlsZQAAAAAAAAAGc2hhNTEyAAAAUwAAAAtzc2gtZWQyNTUx
OQAAAEB8USEis6d49g/F6SRPlyLz6q5nmsbDDg+OncxMGH2zLHmGbPDaVF6SGdMYR5M9Gr
+SyHn4sP1trq/ohFENnckD
-----END SSH SIGNATURE-----"
        
    typeset -r exampleArmoredSshSignatureWindows="-----BEGIN SSH SIGNATURE-----\r\n
U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgLY72f0jtErUNe+d3v54phP7QKv\r\n
VsIm903+l2RvvrblIAAAAEZmlsZQAAAAAAAAAGc2hhNTEyAAAAUwAAAAtzc2gtZWQyNTUx\r\n
OQAAAEB8USEis6d49g/F6SRPlyLz6q5nmsbDDg+OncxMGH2zLHmGbPDaVF6SGdMYR5M9Gr\r\n
+SyHn4sP1trq/ohFENnckD\r\n
-----END SSH SIGNATURE-----"
        
    typeset -r exampleArmoredSshSignatureMac="-----BEGIN SSH SIGNATURE-----\r
U1NIU0lHAAAAAQAAADMAAAALc3NoLWVkMjU1MTkAAAAgLY72f0jtErUNe+d3v54phP7QKv\r
VsIm903+l2RvvrblIAAAAEZmlsZQAAAAAAAAAGc2hhNTEyAAAAUwAAAAtzc2gtZWQyNTUx\r
OQAAAEB8USEis6d49g/F6SRPlyLz6q5nmsbDDg+OncxMGH2zLHmGbPDaVF6SGdMYR5M9Gr\r
+SyHn4sP1trq/ohFENnckD\r
-----END SSH SIGNATURE-----"

        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section 7 of 9: Complex Real-World Formatting Scenarios"
        z_Output print "============================================================"
        z_Output print "Tests formatting behavior in practical usage scenarios."
        z_Output print "Shows how wrap and indent work in common script outputs."
        z_Output print "Current terminal width: $LocalTerminalWidth columns"
        z_Output print "(Tests automatically adjust to your terminal size)"
        z_Output print "============================================================"
        z_Output print ""

        # Documentation-Style
        z_Output print "A. Documentation-Style Output:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Section header with wrapped description:"
        z_Output info "DESCRIPTION: $Lorem" Wrap=60
        z_Output print ""
        
        z_Output print "2. Bulleted list with indentation:"
        z_Output info "• First item in list\n• Second item with some additional text\n• Third item that includes a much longer description to demonstrate wrapping" Indent=2
        z_Output print ""
        
        z_Output print "3. Code block with indent:"
        z_Output info "$CodeBlock" Indent=4 
        z_Output print ""

        # Error and Warning Format
        z_Output print "B. Error and Warning Formats:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Multi-line error message:"
        z_Output error "ERROR: Process failed\nDETAILS: $Lorem" Wrap=60
        z_Output print ""
        
        z_Output print "2. Warning with context:"
        z_Output warn "WARNING: $Lorem" Indent=4 Wrap=50
        z_Output print ""
        
        z_Output print "3. Debug details:"
        z_Output info "Location: example.sh:123\nFunction: test_function\nValue: $LongWord" Indent=6
        z_Output print ""

        # Help Text
        z_Output print "C. Help Text Formatting:"
        z_Output print "------------------------------------------------------------"
        z_Output info "USAGE: script.sh [options]" Indent=2
        z_Output info "OPTIONS:" Indent=2
        z_Output info "--help     Show this help text" Indent=4
        z_Output info "--verbose  Enable verbose output" Indent=4
        z_Output info "--file     Specify input file" Indent=4
        z_Output info "EXAMPLE:" Indent=2
        z_Output info "script.sh --verbose --file input.txt" Indent=4
        z_Output print ""

        # Log Style
        z_Output print "D. Log-Style Output:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Timestamp with message:"
        z_Output info "[2024-01-11 14:30:15] Starting process" Wrap=60
        z_Output print ""
        
        z_Output print "2. Indented subprocess:"
        z_Output info "[2024-01-11 14:30:16] Initializing components\n  - Component A: Ready\n  - Component B: Ready" Indent=2 Wrap=50
        z_Output print ""
        
        z_Output print "3. Warning event:"
        z_Output warn "[2024-01-11 14:30:17] Resource usage high: $Lorem" Indent=4
        z_Output print ""

        # Configuration Display
        z_Output print "E. Configuration Display:"
        z_Output print "------------------------------------------------------------"
        z_Output info "Current Settings:" Indent=2
        z_Output info "Database:" Indent=4
        z_Output info "host: localhost" Indent=6
        z_Output info "port: 5432" Indent=6
        z_Output info "name: mydb" Indent=6
        z_Output info "Security:" Indent=4
        z_Output info "ssl: enabled" Indent=6
        z_Output info "cert: /path/to/cert.pem" Indent=6
        z_Output print ""

        # Progress Updates
        z_Output print "F. Progress Updates:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Task start:"
        z_Output info "Beginning backup process..." Wrap=60
        z_Output print ""
        
        z_Output print "2. Subtask details:"
        z_Output info "• Scanning files...\n• Compressing data...\n• Transferring to remote..." Indent=2
        z_Output print ""
        
        z_Output print "3. Completion summary:"
        z_Output success "Backup completed successfully:\n• Total files: 1,234\n• Size: 1.5GB\n• Duration: 5m 30s" Indent=2 Wrap=50
        z_Output print ""

        # Mixed Content
        z_Output print "G. Mixed Content Display:"
        z_Output print "------------------------------------------------------------"
        z_Output info "System Status Report" Wrap=60
        z_Output info "1. Hardware:" Indent=2
        z_Output info "CPU: Intel i7 (8 cores)" Indent=4
        z_Output info "Memory: 16GB (Usage: $Lorem)" Indent=4 Wrap=50
        z_Output info "2. Software:" Indent=2
        z_Output info "OS: Linux 5.15.0" Indent=4
        z_Output warn "Updates available: Security patches pending" Indent=4 Wrap=50
        z_Output print ""

        # SSH Signature Tests
        z_Output print "H. Structured Text Blocks:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. SSH Signatures (preserving format):"
        z_Output info "Original script format:\n$exampleArmoredSshSignatureScript"
        z_Output print ""
        z_Output info "Unix line endings:\n$exampleArmoredSshSignatureUnix"
        z_Output print ""
        z_Output info "Windows line endings:\n$exampleArmoredSshSignatureWindows"
        z_Output print ""
        z_Output info "Mac line endings:\n$exampleArmoredSshSignatureMac"
        z_Output print ""
        
        z_Output print "2. SSH Signatures with indentation:"
        z_Output info "Indented signature block:\n$exampleArmoredSshSignatureScript" Indent=4
        z_Output print ""
        z_Output info "Deep indented signature:\n$exampleArmoredSshSignatureUnix" Indent=8
        z_Output print ""
        
        z_Output print "3. Wrapped signature displays:"
        z_Output info "Signature verification result:\n$exampleArmoredSshSignatureScript" Wrap=50
        z_Output print ""
        z_Output info "VERIFICATION OUTPUT:\n$exampleArmoredSshSignatureUnix\nSignature is valid." Indent=4 Wrap=60
        z_Output print ""
        
        z_Output print "4. Mixed signature scenarios:"
        z_Output warn "Command output with signature:"
        z_Output info "stdout: Verification successful" Indent=4
        z_Output info "stderr:\n$exampleArmoredSshSignatureScript" Indent=4
        z_Output error "Exit code: 1" Indent=4
        z_Output print ""
    }

    #----------------------------------------------------------------------#
    # Function: test_prompts
    #----------------------------------------------------------------------#
    # Description:
    #   Tests the interactive and non-interactive prompt behavior of z_Output.
    #   Validates input handling, default values, and prompt formatting across
    #   different modes.
    #
    # Parameters:
    #   $1 (integer) - WantInteractive flag:
    #                  TRUE (1) for interactive testing
    #                  FALSE (0) for non-interactive testing
    #
    # Returns:
    #   0 on successful completion of tests
    #   1 on test failure or setup error
    #
    # Side Effects:
    #   - Temporarily modifies Output_Prompt_Enabled
    #   - Outputs test results to console
    #   - May prompt for user input in interactive mode
    #----------------------------------------------------------------------#
    function test_prompts {
        # Parameter validation
        typeset -i WantInteractive=${1:-$FALSE}
        typeset TestMode
        typeset Response
        
        # Store original prompt state to restore later
        typeset -i Original_Prompt_State=$Output_Prompt_Enabled

        # Set mode based on parameter
        if (( WantInteractive )); then
            TestMode="Interactive"
            Output_Prompt_Enabled=$TRUE
            z_Output debug "Interactive Mode Enabled (Output_Prompt_Enabled=$Output_Prompt_Enabled)" Force=$TRUE
        else
            TestMode="Non-Interactive" 
            Output_Prompt_Enabled=$FALSE
            z_Output debug "Non-Interactive Mode (Output_Prompt_Enabled=$Output_Prompt_Enabled)" Force=$TRUE
        fi

        # Section Header
        z_Output print "============================================================"
        z_Output print "Test Section ${TestMode} Prompt Tests (Output_Prompt_Enabled=$Output_Prompt_Enabled)"
        z_Output print "============================================================"
        z_Output print "Tests prompt behavior and default value handling."
        z_Output print "Shows how prompts work in ${TestMode} mode."
        z_Output print "============================================================"
        z_Output print ""

        # Basic Default Tests
        z_Output print "A. Basic Default Handling:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. No default value:"
        Response=$(z_Output prompt "Enter value")
        z_Output print "No default: (Expected: '', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "2. Simple default:"
        Response=$(z_Output prompt "Enter name" Default="John")
        z_Output print "Simple default: (Expected: 'John', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "3. Empty default:"
        Response=$(z_Output prompt "Enter value" Default="")
        z_Output print "Empty string default: (Expected: '', Got: '${Response}')"
        z_Output print ""

        # Space Handling Tests
        z_Output print "B. Space Handling:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Leading spaces:"
        Response=$(z_Output prompt "Enter spaced" Default="   text")
        z_Output print "Leading spaces: (Expected: '   text', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "2. Trailing spaces:"
        Response=$(z_Output prompt "Enter spaced" Default="text   ")
        z_Output print "Trailing spaces: (Expected: 'text   ', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "3. Internal spaces:"
        Response=$(z_Output prompt "Enter spaced" Default="text with   spaces")
        z_Output print "Internal spaces: (Expected: 'text with   spaces', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "4. Only spaces:"
        Response=$(z_Output prompt "Enter spaces" Default="   ")
        z_Output print "Only spaces: (Expected: '   ', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "5. Single space:"
        Response=$(z_Output prompt "Enter space" Default=" ")
        z_Output print "Single space: (Expected: ' ', Got: '${Response}')"
        z_Output print ""

        # Special Content Tests
        z_Output print "C. Special Content:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Special characters:"
        Response=$(z_Output prompt "Enter special" Default="!@#$%")
        z_Output print "Special characters: (Expected: '!@#$%', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "2. Unicode/emoji:"
        Response=$(z_Output prompt "Enter greeting" Default="Hello 世界 👋")
        z_Output print "Unicode/emoji: (Expected: 'Hello 世界 👋', Got: '${Response}')"
        z_Output print ""

        # Prompt Formatting Tests
        z_Output print "D. Prompt Formatting:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Basic prompt:"
        Response=$(z_Output prompt "Basic prompt" Default="test")
        z_Output print "Basic prompt: (Expected: 'test', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "2. Custom emoji:"
        Response=$(z_Output prompt "Custom emoji prompt" Default="test" Emoji="🎯")
        z_Output print "Custom emoji: (Expected: 'test', Got: '${Response}')"
        z_Output print ""

        # Indentation Tests
        z_Output print "E. Indentation Tests:"
        z_Output print "------------------------------------------------------------"
        
        z_Output print "1. Basic prompt (no indent):"
        Response=$(z_Output prompt "Enter value at root level" Default="base-level-value")
        z_Output print "No indent: (Expected: 'base-level-value', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "2. Indented prompt (2 spaces):"
        Response=$(z_Output prompt "Enter value at level 1" Default="level-1-value" Indent=2)
        z_Output print "Basic indent: (Expected: 'level-1-value', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "3. Deeply indented prompt (4 spaces):"
        Response=$(z_Output prompt "Enter value at level 2" Default="level-2-value" Indent=4)
        z_Output print "Deep indent: (Expected: 'level-2-value', Got: '${Response}')"
        z_Output print ""
        
        z_Output print "4. Mixed with emoji:"
        Response=$(z_Output prompt "Enter value at level 3" Default="level-3-value" Indent=6 Emoji="🔍")
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
    function test_interactive_prompts { 
        test_prompts $TRUE 
    }

    function test_non_interactive_prompts { 
        test_prompts $FALSE 
    }

    # Display test suite header
    z_Output print "============================================================"
    z_Output print "z_Output Function Test Suite"
    z_Output print "============================================================"
    z_Output print "Terminal width: $TerminalWidth columns"
    z_Output print "------------------------------------------------------------"
    z_Output print ""

    # Execute test sections
    typeset -i TestCount=${#TestSections[@]}/2
    typeset -i CurrentTest=0
    typeset -i LoopIndex
    
     for ((LoopIndex = 1; LoopIndex <= ${#TestSections[@]}; LoopIndex += 2)); do
        (( CurrentTest++ ))
        typeset TestName=${TestSections[$LoopIndex]}
        typeset TestFunction=${TestSections[$((LoopIndex + 1))]}

        # Reset modes before each test
        if ! reset_modes; then
            z_Output error "Failed to reset modes before test $CurrentTest: $TestName"
            return 1
        fi

        # Run test section
        $TestFunction || {
            z_Output error "Test section failed: $TestName"
            return 1
        }
    done

    # Restore initial state
    Output_Verbose_Mode=$Initial_Verbose
    Output_Quiet_Mode=$Initial_Quiet
    Output_Debug_Mode=$Initial_Debug
    Output_Prompt_Enabled=$Initial_Prompt

    # Display test suite summary
    z_Output print "\n============================================================"
    z_Output print "Test Suite Complete"
    z_Output print "============================================================"
    z_Output print "Ran $TestCount test sections"
    z_Output print "Initial modes restored:"
    z_Output print "- Verbose: $Initial_Verbose"
    z_Output print "- Quiet: $Initial_Quiet"
    z_Output print "- Debug: $Initial_Debug"
    z_Output print "- Interactive: $Initial_Prompt"
    z_Output print "============================================================"

    return 0
}

#----------------------------------------------------------------------#
# Simple Command Line Processing (--debug only)
#----------------------------------------------------------------------#
function parse_Arguments {
    if [[ "${1:-}" == "--debug" ]]; then
        Output_Debug_Mode=$TRUE
    fi

    return 0
}

#----------------------------------------------------------------------#
# Main Function
#----------------------------------------------------------------------#
function main {
    parse_Arguments "$@"

    z_Output_Demo

    return $?
}

# Execute main
main "$@"
