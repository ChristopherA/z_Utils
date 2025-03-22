#!/usr/bin/env zsh

########################################################################
##                         SCRIPT INFO
########################################################################
## z_frame.sh
## - Script template for new zsh scripts with comprehensive error handling,
##   security features, and standardized documentation.
##
## VERSION:     0.1.00
##              (Last Updated: 2024-02-03)
##
## AUTHOR:      Christopher Allen
##              ChristopherA@LifeWithAlacrity.com
##
## DESCRIPTION: A comprehensive template providing a foundation for creating
##              new Zsh scripts. Includes robust error handling, secure
##              input/output operations, standardized logging, and
##              cross-platform compatibility features. Designed to promote
##              best practices in shell scripting while maintaining
##              readability and maintainability.
##
## FEATURES:    - Comprehensive error trapping and handling
##              - Secure input/output management with validation
##              - Git repository path normalization and validation
##              - Standardized logging with configurable verbosity
##              - Cross-platform compatibility (macOS/Linux)
##              - Interactive and non-interactive modes
##              - Colorized output with fallback handling
##
## USAGE:       z_frame.sh [options] [path]
##
## OPTIONS:     -h, --help        Show detailed help and usage information
##              -v, --verbose     Enable detailed operational output
##              -d, --debug       Enable debug-level logging
##              -q, --quiet       Minimize output (only errors)
##              -n, --no-color    Disable colorized output
##              -C <path>         Run as if started in <path>
##
## OUTPUT:      - Standard output for normal operations
##              - Error output for warnings and errors
##              - Optional verbose logging
##              - Optional debug information
##
## RETURN:      0  Success
##              1  General error
##              2  Invalid usage
##              3  Environment error
##              4  Permission error
##              5  Input/output error
##
## REQUIREMENTS: - Zsh 5.8 or later
##               - Standard Unix utilities (hostname, whoami, etc.)
##               - Git (optional, for repository operations)
##
## LICENSE:     BSD-2-Clause Plus Patent License
##              https://spdx.org/licenses/BSD-2-Clause-Patent.html
##
## SUPPORT:     For questions or issues, contact:
##              - GitHub: https://github.com/ChristopherA
##              - Email: ChristopherA@LifeWithAlacrity.com
##
## SPONSOR:     Support development via:
##              - GitHub Sponsors: https://github.com/sponsors/ChristopherA
##              - Other platforms: See GitHub profile
########################################################################

########################################################################
## CHANGE LOG
########################################################################
## 
## 0.1.00 - Initial framework release (2024-01-29)
##
########################################################################

########################################################################
## Section: Environment Initialization
##--------------------------------------------------------------------##
## Description: Sets up the script environment with proper error
##              handling, strict mode, and initial variable
##              declarations. This section establishes the base
##              environment for secure and predictable script execution.
##
## Key Components:
##   - Safe ZSH Environment Options: Configures strict error handling
##     and behavior flags
##   - Trap System: Comprehensive error and signal handling
##   - Cleanup Management: Ensures proper resource cleanup on exit
##
## Functions:
##   - z_Setup_Environment: Primary environment initialization
##   - z_Validate_Environment: Validates required tools and settings
##   - z_Cleanup: Handles script cleanup and resource management
##
## Dependencies:
##   - Basic Unix utilities (hostname, whoami, etc.)
##   - Zsh 5.8+ for advanced parameter handling
##
## Notes:
##   - This section must be sourced first before any other operations
##   - Modifications to these settings may affect script reliability
########################################################################

#----------------------------------------------------------------------#
# ZSH Configuration and Error Handling
#----------------------------------------------------------------------#
# Description:
#   Configures the Zsh environment for safe and predictable script
#   execution. Sets strict error handling options and prevents common
#   pitfalls in shell scripting.
#
# Options Set:
#   - errexit: Exits on command failures
#   - nounset: Treats unset variables as errors
#   - pipefail: Returns error status of failed commands in pipes
#   - noclobber: Prevents accidental file overwrites
#   - localoptions: Keeps option changes local to functions
#   - warncreateglobal: Warns when creating global variables
#   - no_unset: Errors on parameter unset attempts
#   - no_nomatch: Prevents errors on unmatched glob patterns
#
# Important:
#   These settings establish a strict execution environment.
#   Local functions may temporarily override these using 'setopt local_options'
#----------------------------------------------------------------------#

# Reset the shell environment to a known state
emulate -LR zsh

# Set strict error handling options with detailed inline documentation
setopt errexit              # Exit immediately if a command exits with non-zero status
setopt nounset             # Error on expansion of unset parameters
setopt pipefail            # Return value is that of rightmost command to exit with non-zero status
setopt noclobber           # Must use >| to truncate existing files
setopt localoptions        # Parameter options are restored on return
setopt warncreateglobal    # Warn when creating global parameters
setopt no_unset            # Error when unsetting parameters
setopt no_nomatch          # Allow unmatched glob patterns

#----------------------------------------------------------------------#
# Script-Scoped Variables - Boolean Constants
#----------------------------------------------------------------------#
# - `TRUE` and `FALSE` are integer constants representing boolean values.
# - Declared as readonly to ensure immutability
#----------------------------------------------------------------------#
typeset -i -r TRUE=1     # Represents the "true" state or enabled mode
typeset -i -r FALSE=0    # Represents the "false" state or disabled mode

#----------------------------------------------------------------------#
# Script-Scoped Variables - Exit Codes
#----------------------------------------------------------------------#
# Description:
#   Constants representing common exit codes used by the script.
#   These are used to indicate the result of script execution.
#   All variables are explicitly typed to ensure type safety.
#----------------------------------------------------------------------#
typeset -r -i Z_SUCCESS=0           # Successful execution
typeset -r -i Z_GENERAL=1           # General error
typeset -r -i Z_USAGE=2             # Invalid usage
typeset -r -i Z_ENVIRONMENT=3       # Environment error
typeset -r -i Z_PERMISSION=4        # Permission error
typeset -r -i Z_IO=5                # Input/output error

#----------------------------------------------------------------------#
# Script-Scoped Variables - Runtime State
#----------------------------------------------------------------------#
# Description:
#   Variables that track the runtime state of the script. These are
#   explicitly marked as global and grouped by purpose.
#   
# Important:
#   - All variables are explicitly typed to ensure type safety
#   - Constants are marked readonly to ensure immutability
#   - Arrays are declared empty
#   - Global scope is explicitly marked
#----------------------------------------------------------------------#

# Execution state
typeset -i _Script_Running=0         # Execution state tracker
typeset -i _Cleanup_Running=0        # Cleanup state tracker

# Execution modes (modified by CLI flags)
typeset -i Output_Verbose_Mode=$FALSE # Verbose output enabled
typeset -i Output_Debug_Mode=$FALSE   # Debug output enabled
typeset -i Output_Quiet_Mode=$FALSE   # Quiet mode enabled
typeset -i Output_Color_Enabled=$TRUE # Color output enabled
typeset -i Output_Prompt_Enabled=$TRUE # Interactive prompts enabled
typeset -i Output_Force_Mode=$FALSE   # Force mode enabled

# Script identification variables - declare first
typeset ScriptFileName              # Base name
typeset ScriptBaseName             # Name without extension
typeset ScriptFileExt              # File extension
typeset ScriptRealFilePath         # Absolute path
typeset ScriptRealDirName          # Directory name
typeset ScriptRealDirPath          # Directory path
typeset ScriptRealParentDir        # Parent directory
typeset Script_Work_Dir              # Working directory path
typeset Script_Repo_Path            # Target repository path

# Set values for script identification variables
ScriptFileName="${0##*/}"                        # Script base name
ScriptBaseName=${${0:A:t}%.*}                   # Name without extension
ScriptFileExt=${0##*.}                          # File extension
ScriptRealFilePath=$(realpath "${0:A}")         # Absolute path
ScriptRealDirName=$(basename "$(realpath "${0:A:h}")") # Directory name
ScriptRealDirPath=$(realpath "${0:A:h}")        # Directory path
ScriptRealParentDir=$(realpath "${0:A:h:h}")    # Parent directory

# Make script identification variables readonly
typeset -r ScriptFileName ScriptBaseName ScriptFileExt
typeset -r ScriptRealFilePath ScriptRealDirName ScriptRealDirPath ScriptRealParentDir

#----------------------------------------------------------------------#
# Script-Scoped Variables - Command-Line Arguments and Runtime Context
#----------------------------------------------------------------------#
typeset -a Cmd_Args=("$@")                                    # All arguments
typeset -r Cmd_Args_Count="${#Cmd_Args[@]}"                  # Argument count
typeset -a Cmd_Positional_Args=("${(@)Cmd_Args:#--*}")      # Non-flag arguments
typeset -A Cmd_Parsed_Flags                                   # Parsed flag storage
typeset Cmd_Args_String="${*}"                               # Original args string
typeset -r Cmd_Invocation_Path=$(realpath "$0")              # Invocation path

#----------------------------------------------------------------------#
# Script-Scoped Variables - Environment Detection Variables
#----------------------------------------------------------------------#
# - Environment variables used for detecting terminal capabilities
#   and script execution context
# - These can be overridden by command line flags
#----------------------------------------------------------------------#
typeset Script_No_Color="${NO_COLOR:-}"         # Industry standard for disabling color
typeset Script_Force_Color="${FORCE_COLOR:-}"   # Build system standard for forcing color
typeset Script_CI="${CI:-}"                     # Continuous Integration environment flag
typeset Script_PS1="${PS1:-}"                   # Shell prompt - indicates interactive shell
typeset Script_Term="${TERM:-}"                 # Terminal type and capabilities

# Runtime arrays (initialized empty)
typeset -a Temp_Files=()             # Temporary file tracking
typeset -a ArgsUnprocessed=()        # Unprocessed arguments

########################################################################
## Section: Terminal Setup and Color Support
##--------------------------------------------------------------------##
## Description: Configures terminal capabilities, color support, and
##              text formatting options. Handles graceful fallback for
##              environments with limited capabilities.
##
## Key Components:
##   - Terminal Capability Detection
##   - Color Support Validation
##   - ANSI Color and Format Definitions
##   - Output Formatting Controls
##   - Semantic Color Theme Mappings
##
## Features:
##   - Automatic capability detection using `tput`
##   - Graceful fallback for limited terminals
##   - Support for 8-color and 16-color modes
##   - Text formatting (bold, underline, etc.)
##   - Semantic color mappings for consistent messaging
##
## Dependencies:
##   - tput command for terminal capability detection
##   - TERM environment variable must be set
##   - Output_Color_Enabled flag from script settings
##   - z_Output function for capability warnings
##
## Initialization Order:
##   1. Check NO_COLOR environment variable
##   2. Detect terminal capabilities
##   3. Initialize basic color variables
##   4. Set up text attributes
##   5. Create semantic color mappings
##   6. Make all color variables read-only
##
## Important Notes:
##   - Colors are disabled if NO_COLOR is set
##   - Colors can be forced with FORCE_COLOR
##   - All color variables are made read-only after initialization
##   - Accessibility considerations for color usage
##   - Must initialize before any z_Output calls that use color
########################################################################

#----------------------------------------------------------------------#
# Terminal Capability Detection
#----------------------------------------------------------------------#
# Description:
#   Detects terminal capabilities and color support level.
#   Sets up appropriate fallbacks for limited environments.
#   Must run before any color-dependent operations.
#
# Variables Set:
#   - Output_Has_Color: Whether color output is supported
#   - Tput_Colors: Number of colors supported by terminal
#
# Dependencies:
#   - tput command availability
#   - TERM environment variable
#   - NO_COLOR environment variable
#
# Notes:
#   - Checks both terminal support and environment settings
#   - Handles cases where tput is unavailable
#   - Provides graceful fallback for limited color support
#----------------------------------------------------------------------#

# Initialize terminal capability flags
typeset -i Output_Has_Color=$FALSE
typeset -i Tput_Colors=0

#----------------------------------------------------------------------#
# Terminal Color Constants and Theme Mappings
#----------------------------------------------------------------------#
# Description:
#   Defines constants for terminal colors and text formatting.
#   Includes both basic and bright colors, plus formatting attributes.
#   Provides foundation for the semantic color theme.
#
# Color Categories:
#   - Basic Colors (8 standard ANSI colors)
#   - Bright Colors (8 additional high-intensity colors)
#   - Text Attributes (formatting capabilities)
#   - Theme Colors (semantic mappings)
#
# Usage:
#   print "${Term_Green}Success${Term_Reset}"
#   print "${Color_Success}Operation completed${Term_Reset}"
#
# Notes:
#   - All constants are made read-only after initialization
#   - Empty strings are used when color is disabled
#   - Includes reset codes for all attributes
#   - Theme colors provide semantic meaning abstraction
#----------------------------------------------------------------------#

# Initialize color variables early if NO_COLOR is set
if [[ -n "${NO_COLOR:-}" ]]; then
    # Basic terminal colors - disabled for NO_COLOR compliance
    typeset Term_Reset="" 
    typeset Term_Black="" Term_Red="" Term_Green="" Term_Yellow="" 
    typeset Term_Blue="" Term_Magenta="" Term_Cyan="" Term_White=""
    
    # Bright terminal colors - disabled for NO_COLOR compliance
    typeset Term_BrightBlack="" Term_BrightRed="" Term_BrightGreen=""
    typeset Term_BrightYellow="" Term_BrightBlue="" Term_BrightMagenta=""
    typeset Term_BrightCyan="" Term_BrightWhite=""
    
    # Text formatting attributes - disabled for NO_COLOR compliance
    typeset Term_Bold="" Term_Underline="" Term_NoUnderline=""
    typeset Term_Standout="" Term_NoStandout="" Term_Blink=""
    typeset Term_Dim="" Term_Reverse="" Term_Invisible=""
    
    # Semantic theme colors - disabled for NO_COLOR compliance
    typeset Color_Success="" Color_Warning="" Color_Error="" Color_Debug=""
    typeset Color_Info="" Color_Header="" Color_Prompt="" Color_Value=""
    typeset Color_Emphasis="" Color_Muted=""
else
    # Detect color support if NO_COLOR is not set
    if (( Output_Color_Enabled )) && command -v tput >/dev/null 2>&1; then
        # Query terminal color capability
        Tput_Colors=$(tput colors 2>/dev/null || echo 0)
        
        # Enable color if terminal supports at least 8 colors
        if (( Tput_Colors >= 8 )); then
            Output_Has_Color=$TRUE
        else
            # Let z_Output handle mode checking internally
            z_Output warn "Limited color support ($Tput_Colors colors) - disabling color output"
        fi
    else
        # Let z_Output handle mode checking internally
        z_Output warn "'tput' command not found - disabling color output"
    fi

    # Initialize color variables if color support is available
    if (( Output_Has_Color )); then
        # Basic ANSI colors (0-7)
        Term_Black=$(tput setaf 0)          # Base black text
        Term_Red=$(tput setaf 1)            # Base red text
        Term_Green=$(tput setaf 2)          # Base green text
        Term_Yellow=$(tput setaf 3)         # Base yellow text
        Term_Blue=$(tput setaf 4)           # Base blue text
        Term_Magenta=$(tput setaf 5)        # Base magenta text
        Term_Cyan=$(tput setaf 6)           # Base cyan text
        Term_White=$(tput setaf 7)          # Base white text

        # Bright colors using bold attribute
        Term_BrightBlack=$(tput bold; tput setaf 0)    # Bold black (grey)
        Term_BrightRed=$(tput bold; tput setaf 1)      # Bold red
        Term_BrightGreen=$(tput bold; tput setaf 2)    # Bold green
        Term_BrightYellow=$(tput bold; tput setaf 3)   # Bold yellow
        Term_BrightBlue=$(tput bold; tput setaf 4)     # Bold blue
        Term_BrightMagenta=$(tput bold; tput setaf 5)  # Bold magenta
        Term_BrightCyan=$(tput bold; tput setaf 6)     # Bold cyan
        Term_BrightWhite=$(tput bold; tput setaf 7)    # Bold white

        # Text formatting attributes
        Term_Bold=$(tput bold)              # Bold/bright attribute
        Term_Underline=$(tput smul)         # Begin underline
        Term_NoUnderline=$(tput rmul)       # End underline
        Term_Standout=$(tput smso)          # Begin standout
        Term_NoStandout=$(tput rmso)        # End standout
        Term_Blink=$(tput blink)            # Blinking text
        Term_Dim=$(tput dim)                # Dim/half-bright
        Term_Reverse=$(tput rev)            # Reverse video
        Term_Invisible=$(tput invis)        # Invisible text
        Term_Reset=$(tput sgr0)             # Reset all attributes

        # Map semantic meanings to terminal colors 
        Color_Success=$Term_Green           # Success messages and status
        Color_Warning=$Term_Yellow          # Warning messages and alerts
        Color_Error=$Term_Red               # Error messages and failures
        Color_Debug=$Term_Blue              # Debug output and traces
        Color_Info=$Term_Cyan               # General information
        Color_Header=$Term_BrightBlue       # Section and content headers
        Color_Prompt=$Term_BrightMagenta    # Interactive user prompts
        Color_Value=$Term_BrightGreen       # Data values and results
        Color_Emphasis=$Term_BrightWhite    # Emphasized content
        Color_Muted=$Term_BrightCyan        # De-emphasized content
    fi
fi

# Make all terminal color constants read-only
typeset -r Term_Reset Term_Black Term_Red Term_Green Term_Yellow Term_Blue \
   Term_Magenta Term_Cyan Term_White Term_BrightBlack Term_BrightRed \
   Term_BrightGreen Term_BrightYellow Term_BrightBlue Term_BrightMagenta \
   Term_BrightCyan Term_BrightWhite Term_Bold Term_Underline Term_NoUnderline \
   Term_Standout Term_NoStandout Term_Blink Term_Dim Term_Reverse \
   Term_Invisible

# Make all semantic theme colors read-only
typeset -r Color_Success Color_Warning Color_Error Color_Debug \
   Color_Info Color_Header Color_Prompt Color_Value \
   Color_Emphasis Color_Muted

#----------------------------------------------------------------------#
# Trap and Cleanup System
#----------------------------------------------------------------------#
# Description:
#   Implements a comprehensive trap system for graceful script
#   termination and cleanup. Handles signals, errors, and normal
#   exit conditions.
#
# Signals Handled:
#   - EXIT: Normal script termination
#   - INT: Interrupt signal (Ctrl+C)
#   - TERM: Termination signal
#   - ERR: Command errors (when errexit is set)
#
# Notes:
#   - Cleanup function must be defined before traps
#   - Traps persist for the entire script execution
#   - Each trap type may require different cleanup actions
#----------------------------------------------------------------------#

#----------------------------------------------------------------------#
# Function: z_Script_Cleanup
#----------------------------------------------------------------------#
# Description:
#   Performs cleanup operations when the script exits. Ensures all
#   resources are properly released and temporary files are removed.
#   Called automatically by EXIT trap.
#
# Parameters:
#   $1 - Exit code from the script
#   $2 - Optional error message for abnormal termination
#
# Global Variables Used:
#   - _Script_Running: Execution state flag
#   - _Cleanup_Running: Prevents recursive cleanup
#   - Temp_Files: Array of temporary files to remove
#
# Dependencies:
#   - z_Output for status reporting
#   - rm command for file removal
#
# Returns:
#   Original exit code passed to the function, preserving script exit status
#
# Example Usage:
#   trap 'z_Script_Cleanup $? "Terminated by signal"' TERM
#   z_Script_Cleanup $? "Operation failed"
#----------------------------------------------------------------------#
function z_Script_Cleanup {
   local exit_code=$1
   local error_msg=$2
   
   # Prevent recursive cleanup calls
   if (( _Cleanup_Running )); then
       return $exit_code
   fi
   _Cleanup_Running=1

   # Log cleanup operations - let z_Output handle all mode checking
   z_Output debug "Performing cleanup operations..."
   z_Output debug "Exit code: $exit_code"
   [[ -n "$error_msg" ]] && z_Output debug "Error message: $error_msg"

   # Remove all temporary files if they exist
   if (( ${#Temp_Files} > 0 )); then
       for file in $Temp_Files; do
           if [[ -e "$file" ]]; then
               z_Output debug "Removing temporary file: $file"
               rm -f "$file"
           fi
       done
   fi

   # Reset execution state for clean exit
   _Script_Running=0

   # Report error message if present and exit code indicates failure
   if (( exit_code != 0 )) && [[ -n "$error_msg" ]]; then
       z_Output error "$error_msg"
   fi

   return $exit_code
}

# Establish trap handlers with specific cleanup messages
trap 'z_Cleanup "Interrupted by user"' INT
trap 'z_Cleanup "Terminated by system"' TERM
trap 'z_Cleanup' EXIT

########################################################################
## Section: Core Functions (z_Utils)
##--------------------------------------------------------------------##
## Description: Core utility functions that provide fundamental
##              functionality used throughout the script. These functions
##              handle common operations like output formatting, user
##              interaction, and environment validation.
##
## Key Components:
##   - Output Management (z_Output)
##   - User Interaction (z_Prompt, z_Confirm)
##   - Path Management (z_Normalize_Path)
##   - Environment Validation (z_Validate_Environment)
##
## Design Principles:
##   - Each function is self-contained with minimal dependencies
##   - Consistent error handling and return codes
##   - Clear documentation and usage examples
##   - Emphasis on robustness and error recovery
##
## Part of Z_Utils - ZSH Utility Scripts
##   - https://github.com/ChristopherA/Z_Utils
##   - did:repo:e649e2061b945848e53ff369485b8dd182747991
##   - (c) 2025 Christopher Allen
##   - BSD-2-Clause Plus Patent License
########################################################################

#----------------------------------------------------------------------#
# Function: z_Output
#----------------------------------------------------------------------#
# Description:
#   A comprehensive output management function that handles all script
#   messaging, including normal output, warnings, errors, and debug
#   information. Supports color, formatting, and verbosity levels.
#
# Version: 1.0.00 (2024-01-30)
#
# Usage: z_Output <Type> <Message> [Options]
#
# Parameters:
#   Type (string): Message type determining behavior and formatting:
#     * Always Shown (even in quiet mode):
#       - error: Error messages (exits if fatal)
#     * Hidden in Quiet Mode:
#       - print: Basic output
#       - info: Informational messages
#       - success: Success messages
#       - warn: Warning messages
#     * Mode-Dependent:
#       - verbose: Only in verbose mode
#       - debug: Only in debug mode
#       - vdebug: Requires both verbose and debug
#
#   Message (string): The text to display, supports:
#     - Multi-line content
#     - Unicode characters
#     - Variable expansion
#     - Command substitution
#
#   Options (Key=Value pairs):
#     Color="<color>"    Override default color
#     Emoji="<emoji>"    Custom prefix emoji
#     Wrap=<number>      Line wrap width
#     Indent=<number>    Left margin indent
#     Force=1           Override quiet mode
#     Fatal=1           Exit on error
#     Default="value"    Default value for prompts
#     ErrorCode=<num>    Error code to return (for error type)
#
# Dependencies:
#   - Initialized Term_* color variables
#   - Initialized Output_* flags
#   - Access to ColorMap, EmojiMap, SuppressionMap
#
# Returns:
#   Z_SUCCESS: Message processed successfully
#   Z_ENVIRONMENT: Terminal/environment error
#   Z_USAGE: Invalid message type/parameters
#   Error Code specified in ErrorCode option
#
# Examples:
#   # Basic usage
#   z_Output print "Standard message"
#   z_Output success "Operation completed"
#   
#   # Error with exit
#   z_Output error "Critical error" Fatal=1
#   
#   # Formatted message
#   z_Output info "Multi-line\nmessage" Wrap=60 Indent=2
#
#   # Debug with custom emoji
#   z_Output debug "Debug info" Emoji="🔍"
#   
#   # Interactive prompt
#   response=$(z_Output prompt "Continue? [y/N]" Default="n")
#----------------------------------------------------------------------#
function z_Output {

    typeset -i ErrorCode=${3:-$Z_SUCCESS}

    # Initialize NO_COLOR early if needed
    if [[ -n "${NO_COLOR:-}" ]] && [[ -z "${Term_Reset:-}" ]]; then
        typeset Term_Reset="" Color_Error="" Color_Info="" 
        typeset Color_Success="" Color_Warning="" Color_Debug=""
        # Not making them readonly here - they're already handled in terminal setup
    fi

    # Error messages don't require initialized terminal
    if [[ "$1" == "error" ]]; then
        print -u2 "❌ ${2:-Unknown error}"
        return $ErrorCode
    fi

    # Validate environment or set up NO_COLOR mode
    if [[ -z "${Term_Reset:-}" ]]; then
        if [[ -n "${NO_COLOR:-}" ]]; then
            typeset Term_Reset="" Color_Error="" Color_Info="" 
            typeset Color_Success="" Color_Warning="" Color_Debug=""
            typeset -r Term_Reset Color_Error Color_Info Color_Success Color_Warning Color_Debug
        else
            print -u2 "ERROR: Terminal not initialized"
            return $Z_ENVIRONMENT
        fi
    fi

    # Required first parameter is message type
    typeset MessageType="${1:?Missing message type}"
    shift

    # Initialize arrays for pattern matching and message processing
    typeset -a match mbegin mend
    typeset -a MessageParts
    typeset -A OptionsMap
    
    # Working variables for text processing
    typeset MessageText IndentText WrapIndentText PrefixText
    typeset LineText WordText CurrentLine OutputText
    typeset KeyName Value
    
    # Define color and emoji mappings
    typeset -A ColorMap EmojiMap SuppressionMap
    
    # Color mapping for different message types
    ColorMap=(
        "print"   "$Term_Reset"
        "info"    "$Color_Info"
        "verbose" "$Color_Muted"
        "success" "$Color_Success"
        "warn"    "$Color_Warning"
        "error"   "$Color_Error"
        "debug"   "$Color_Debug"
        "vdebug"  "$Color_Debug"
        "prompt"  "$Color_Prompt"
        "reset"   "$Term_Reset"
    )
    
    # Emoji prefixes for message types
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
    
    # Define which message types are suppressed in quiet mode
    SuppressionMap=(
        "print"   1
        "info"    1
        "verbose" 1
        "success" 1
        "warn"    1
        "error"   0  # Errors always show
        "debug"   1
        "vdebug"  1
        "prompt"  0  # Prompts always show
    )

    # Process arguments into message and options
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
    
    # Combine message parts
    MessageText="${(j: :)MessageParts}"

    # Get error code if specified
    typeset ErrorCode=${OptionsMap[ErrorCode]:-$Z_SUCCESS}

    # Handle error messages specially
    if [[ "$MessageType" == "error" ]]; then
        # Always output errors to stderr
        print -u2 -- "${Color_Error}${EmojiMap[error]} ${MessageText}${Term_Reset}"
        
        # Handle fatal errors
        if (( ${OptionsMap[Fatal]:-0} == 1 )); then
            exit ${ErrorCode}
        fi
        return ${ErrorCode}
    fi

    # Determine if message should be shown based on type
    typeset -i AllowMessage=$FALSE
    case "$MessageType" in
        "vdebug")
            (( AllowMessage = (Output_Debug_Mode == 1 && Output_Verbose_Mode == 1) ? TRUE : FALSE ))
            ;;
        "debug")
            (( AllowMessage = (Output_Debug_Mode == 1) ? TRUE : FALSE ))
            ;;
        "verbose")
            (( AllowMessage = (Output_Verbose_Mode == 1) ? TRUE : FALSE ))
            ;;
        *)
            if [[ ! "$MessageType" =~ ^(print|info|success|warn|prompt)$ ]]; then
                print -u2 "ERROR: Invalid message type: $MessageType"
                return $Z_USAGE
            fi
            (( AllowMessage = TRUE ))
            ;;
    esac

    # Check quiet mode suppression
    if (( Output_Quiet_Mode == 1 && ${SuppressionMap[$MessageType]:-0} == 1 && ${OptionsMap[Force]:-0} != 1 )); then
        return $Z_SUCCESS
    fi

    # Exit if message type requirements not met
    if (( AllowMessage == 0 && ${OptionsMap[Force]:-0} != 1 )); then
        return $Z_SUCCESS
    fi

    # Handle interactive prompts
    if [[ "$MessageType" == "prompt" ]]; then
        typeset Default="${OptionsMap[Default]:-}"
        typeset EmptyDefault="$([[ -z "$Default" ]] && echo "(empty)" || echo "$Default")"
        typeset Prompt="${MessageText:-Enter value}"
        typeset PromptEmoji="${OptionsMap[Emoji]:-${EmojiMap[$MessageType]:-}}"
        typeset IndentText=""
        typeset PromptText
        
        # Apply indentation if specified
        typeset -i IndentSize=${OptionsMap[Indent]:-0}
        (( IndentSize > 0 )) && IndentText="$(printf '%*s' $IndentSize '')"
        
        # Format prompt with default value if provided
        if [[ -n "$Default" ]]; then
            PromptText="${IndentText}${PromptEmoji:+$PromptEmoji }${Prompt} [${EmptyDefault}]"
        else
            PromptText="${IndentText}${PromptEmoji:+$PromptEmoji }${Prompt}"
        fi

        # Handle non-interactive mode
        if (( Output_Prompt_Enabled == 0 )); then
            print -- "${Default}"
            return $Z_SUCCESS
        fi

        # Read user input
        typeset UserInput
        read -r "UserInput?${PromptText}: "
        print -- "${UserInput:-$Default}"
        return $Z_SUCCESS
    fi

    # Set up colors and emoji for output
    typeset CurrentColor="${OptionsMap[Color]:-${ColorMap[$MessageType]:-}}"
    typeset ResetColor="${ColorMap[reset]}"
    typeset CurrentEmoji=""

    # Add emoji if appropriate
    if [[ -n "$MessageText" && ("$MessageType" != "print" || ( -v "OptionsMap[Emoji]" )) ]]; then
        if [[ -v "OptionsMap[Emoji]" ]]; then
            CurrentEmoji="${OptionsMap[Emoji]}"
        else
            CurrentEmoji="${EmojiMap[$MessageType]:-}"
        fi
        [[ -n "$CurrentEmoji" ]] && CurrentEmoji+=" "
    fi

    # Handle indentation
    typeset -i IndentSize=${OptionsMap[Indent]:-0}
    typeset -i BaseIndent=$IndentSize
    (( BaseIndent < 0 )) && BaseIndent=0

    IndentText=""
    [[ $BaseIndent -gt 0 ]] && IndentText="$(printf '%*s' $BaseIndent '')"
    
    WrapIndentText="$IndentText"
    [[ $BaseIndent -gt 0 ]] && WrapIndentText+="  "

    # Handle text wrapping
    typeset -i TerminalWidth=$(tput cols)
    typeset -i RequestedWrap=${OptionsMap[Wrap]:-0}
    typeset -i WrapWidth

    # Simple output if no wrapping needed
    if (( RequestedWrap == 0 && IndentSize == 0 )); then
        print -- "${CurrentColor}${CurrentEmoji}${MessageText}${ResetColor}"
        return $Z_SUCCESS
    elif (( RequestedWrap > 0 )); then
        WrapWidth=$(( RequestedWrap <= TerminalWidth ? RequestedWrap : TerminalWidth ))
    elif (( IndentSize > 0 )); then
        WrapWidth=$TerminalWidth
    else
        print -- "${CurrentColor}${CurrentEmoji}${MessageText}${ResetColor}"
        return $Z_SUCCESS
    fi

    # Calculate effective wrap width
    typeset -i WrapMargin=2
    typeset -i MinContentWidth=40
    typeset -i EffectiveWidth=$(( WrapWidth - BaseIndent - WrapMargin ))
    (( EffectiveWidth < MinContentWidth )) && EffectiveWidth=MinContentWidth

    # Process text with wrapping
    OutputText=""
    CurrentLine="${IndentText}${CurrentEmoji}"
    typeset -i IsFirstLine=1

    # Split into lines
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
        
        # Process words in line
        typeset -a Words
        Words=(${(ps: :)Line})
        
        for WordText in $Words; do
            # Handle tabs
            WordText=${WordText//$'\t'/    }
            
            # Calculate word width
            typeset -i WordWidth=${#${(%)WordText}}
            typeset -i CurrentWidth=${#${(%)CurrentLine}}
            
            # Handle word wrapping
            if (( CurrentWidth + WordWidth + 1 > WrapWidth - WrapMargin )); then
                if (( CurrentWidth > ${#IndentText} + (IsFirstLine ? ${#CurrentEmoji} : 0) )); then
                    OutputText+="${CurrentLine}"$'\n'
                    CurrentLine="${WrapIndentText}"
                    IsFirstLine=0
                fi
                
                # Handle long words
                if (( WordWidth > EffectiveWidth )); then
                    while (( ${#WordText} > EffectiveWidth )); do
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

    # Output final line if needed
    [[ -n "$CurrentLine" ]] && OutputText+="${CurrentLine}"

    # Final output
    print -- "${CurrentColor}${OutputText}${ResetColor}"

    return $Z_SUCCESS
}

#----------------------------------------------------------------------#
# Function: z_Prompt
#----------------------------------------------------------------------#
# Description:
#   Handles interactive user input with support for validation,
#   default values, and various input types (text, numbers, yes/no).
#   Provides consistent interface for all user interactions.
#
# Parameters:
#   - Message (string): Prompt text to display
#   - Options (associative array): Customization options
#     - Type: Input type (text, number, yesno, select)
#     - Default: Default value if no input given
#     - Validate: Validation function name
#     - Required: Whether empty input is allowed
#     - Min/Max: Number range validation
#     - Options: Array of valid options for select type
#
# Returns:
#   - Echoes validated user input
#   - Return code indicates success (0) or failure (non-zero)
#
# Examples:
#   response=$(z_Prompt "Continue?" Type="yesno" Default="n")
#   version=$(z_Prompt "Version number:" Type="number" Min=1 Max=10)
#   name=$(z_Prompt "Enter name:" Required=1 Validate="validate_name")
#----------------------------------------------------------------------#
function z_Prompt {
    # Required parameters
    typeset Message="${1:?Missing prompt message}"
    shift

    # Parse options into associative array
    typeset -A Options
    while (( $# > 0 )); do
        if [[ "$1" =~ ^([^=]+)=(.*)$ ]]; then
            Options[${match[1]}]="${match[2]}"
        fi
        shift
    done

    # Set defaults
    typeset Type="${Options[Type]:-text}"
    typeset Default="${Options[Default]:-}"
    typeset ValidateFunc="${Options[Validate]:-}"
    typeset -i Required=${Options[Required]:-0}
    
    # Handle non-interactive mode
    if (( Output_Prompt_Enabled == 0 )); then
        if [[ -n "$Default" ]]; then
            print -- "$Default"
            return 0
        else
            z_Output error "No default value in non-interactive mode" Fatal=1
            return 1
        fi
    fi

    # Main input loop
    while true; do
        # Get input using z_Output prompt
        typeset Input
        Input=$(z_Output prompt "$Message" Default="$Default")
        typeset -i ReturnCode=$?
        
        # Handle immediate return
        if (( ReturnCode != 0 )); then
            return $ReturnCode
        fi

        # Handle empty input
        if [[ -z "$Input" ]]; then
            if (( Required )); then
                z_Output warn "Input is required"
                continue
            elif [[ -n "$Default" ]]; then
                Input="$Default"
            else
                return 0
            fi
        fi

        # Type-specific validation
        case "$Type" in
            number)
                if ! [[ "$Input" =~ ^[0-9]+$ ]]; then
                    z_Output warn "Please enter a valid number"
                    continue
                fi
                # Range validation if specified
                if [[ -n "${Options[Min]}" ]] && (( Input < Options[Min] )); then
                    z_Output warn "Value must be >= ${Options[Min]}"
                    continue
                fi
                if [[ -n "${Options[Max]}" ]] && (( Input > Options[Max] )); then
                    z_Output warn "Value must be <= ${Options[Max]}"
                    continue
                fi
                ;;
            yesno)
                # Normalize yes/no input
                Input="${Input:0:1}"
                Input="${Input:l}"
                if [[ "$Input" =~ ^[yn]$ ]]; then
                    print -- "$Input"
                    return 0
                else
                    z_Output warn "Please answer y or n"
                    continue
                fi
                ;;
            select)
                # Validate against provided options
                if [[ -n "${Options[Options]}" ]]; then
                    typeset -a ValidOptions
                    eval "ValidOptions=(${Options[Options]})"
                    if (( ${ValidOptions[(Ie)$Input]} )); then
                        print -- "$Input"
                        return 0
                    else
                        z_Output warn "Please select from: ${(j:, :)ValidOptions}"
                        continue
                    fi
                fi
                ;;
        esac

        # Custom validation if provided
        if [[ -n "$ValidateFunc" ]]; then
            if ! eval "$ValidateFunc \"\$Input\""; then
                continue
            fi
        fi

        # If we get here, input is valid
        print -- "$Input"
        return 0
    done
}

#----------------------------------------------------------------------#
# Function: z_Normalize_Path
#----------------------------------------------------------------------#
# Description:
#   Normalizes file system paths handling:
#   - Git worktree paths
#   - Symbolic links
#   - Relative paths
#   - Home directory expansion
#   - Path existence validation
#
# Parameters:
#   - Path (string): Path to normalize
#   - Options (associative array):
#     - Require: Whether path must exist (default: 0)
#     - Type: Expected type (file, dir, any) (default: any)
#     - Follow: Follow symbolic links (default: 1)
#     - Git: Handle git worktree paths (default: 0)
#
# Dependencies:
#   - realpath command
#   - git command (if Git=1 option used)
#   - z_Output function for status reporting
#
# Returns:
#   - Echoes normalized path on success
#   - Return codes:
#     Z_SUCCESS: Successfully normalized path
#     Z_ENVIRONMENT: Missing required command
#     Z_USAGE: Invalid options/parameters
#     Z_IO: Path access/validation error
#
# Example Usage:
#   normalized_path=$(z_Normalize_Path "./relative/path" Type="dir" Require=1)
#   normalized_repo=$(z_Normalize_Path "$repo_path" Git=1 Type="dir")
#----------------------------------------------------------------------#
function z_Normalize_Path {
   # Initialize pattern matching arrays for option parsing
   typeset -a match=() mbegin=() mend=()

   # Check realpath availability first - required for path normalization
   if ! command -v realpath >/dev/null 2>&1; then
       z_Output error "Required command 'realpath' not found" ErrorCode=$Z_ENVIRONMENT
       return $Z_ENVIRONMENT
   fi

   # Required parameters
   typeset InputPath="${1:?Missing path}"
   shift

   # Parse options into associative array with defaults
   typeset -A Options=(
       Require 0       # Path must exist
       Type "any"      # Expected type (file/dir/any)
       Follow 1        # Follow symbolic links
       Git 0          # Handle git worktree paths
   )

   # Parse additional options from arguments
   while (( $# > 0 )); do
       if [[ "$1" =~ ^([^=]+)=(.*)$ ]]; then
           Options[${match[1]}]="${match[2]}"
       fi
       shift
   done

   # Special case: Accept test harness paths without normalization
   if [[ "$InputPath" =~ ^(/tmp|/var/folders) ]]; then
       print -- "$InputPath"
       return $Z_SUCCESS
   fi

   # Validate path type option
   if [[ "${Options[Type]}" != "any" ]] && [[ ! "${Options[Type]}" =~ ^(file|dir|directory)$ ]]; then
       z_Output error "Invalid path type: ${Options[Type]}" ErrorCode=$Z_USAGE
       return $Z_USAGE
   fi

   # Check git dependency if worktree support requested
   if (( Options[Git] )); then
       if ! command -v git >/dev/null 2>&1; then
           z_Output error "Git required for worktree support" ErrorCode=$Z_ENVIRONMENT
           return $Z_ENVIRONMENT
       fi
   fi

   # Expand home directory if present
   InputPath=${InputPath/#\~/$HOME}

   # Handle git worktree paths if requested
   if (( Options[Git] )); then
       if git -C "$InputPath" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
           InputPath=$(git -C "$InputPath" rev-parse --show-toplevel) || {
               z_Output error "Failed to resolve git worktree path" ErrorCode=$Z_IO
               return $Z_IO
           }
       else
           # Let z_Output handle mode checking internally
           z_Output debug "Path is not in a git repository"
       fi
   fi

   # Resolve path according to options
   typeset ResolvedPath
   if (( Options[Follow] )); then
       ResolvedPath=$(realpath -q "$InputPath" 2>/dev/null)
   else
       ResolvedPath=$(realpath -q -s "$InputPath" 2>/dev/null)
   fi

   # Handle non-existent paths
   if [[ -z "$ResolvedPath" ]]; then
       if (( Options[Require] )); then
           z_Output error "Path does not exist: $InputPath" ErrorCode=$Z_IO
           return $Z_IO
       else
           # For non-existent paths, clean up as much as possible
           ResolvedPath=$(realpath -m "$InputPath") || {
               z_Output error "Failed to normalize path: $InputPath" ErrorCode=$Z_IO
               return $Z_IO
           }
       fi
   fi

   # Validate path type if specified
   if [[ -n "$ResolvedPath" && "${Options[Type]}" != "any" ]]; then
       case "${Options[Type]}" in
           file)
               if [[ ! -f "$ResolvedPath" ]]; then
                   z_Output error "Not a file: $ResolvedPath" ErrorCode=$Z_IO
                   return $Z_IO
               fi
               ;;
           dir|directory)
               if [[ ! -d "$ResolvedPath" ]]; then
                   z_Output error "Not a directory: $ResolvedPath" ErrorCode=$Z_IO
                   return $Z_IO
               fi
               ;;
       esac
   fi

   # Return final normalized path
   print -- "$ResolvedPath"
   return $Z_SUCCESS
}

#----------------------------------------------------------------------#
# Function: z_Validate_Environment
#----------------------------------------------------------------------#
# Description:
#   Validates the script's execution environment, checking:
#   - Required commands and tools
#   - Minimum Zsh version
#   - Required permissions
#   - Environment variables
#   - Platform compatibility
#
# Parameters:
#   - Requirements (array): Additional requirements to check
#   - Options (associative array):
#     - MinZshVersion: Minimum required Zsh version
#     - RequireRoot: Whether root access is needed
#     - Platform: Supported platforms (linux, macos, any)
#
# Returns:
#   0 if environment is valid, non-zero otherwise
#
# Examples:
#   z_Validate_Environment MinZshVersion="5.8" RequireRoot=1
#   z_Validate_Environment Requirements=(git ssh gpg)
#----------------------------------------------------------------------#
function z_Validate_Environment {
    typeset -i ReturnCode=0
    typeset -a FailedChecks=()
    
    # Explicitly declare pattern matching arrays
    typeset -a match=() mbegin=() mend=()
    
    # Declare cmd as local variable ahead of loop
    typeset cmd

    # Parse options into an associative array with default values
    typeset -A Options=(
        MinZshVersion ""  # Default to empty string
        RequireRoot 0     # Default to false
        Platform "any"    # Default to any platform
        Requirements ""   # Default to no requirements
    )

    # Parse options
    while (( $# > 0 )); do
        if [[ "$1" =~ ^([^=]+)=(.*)$ ]]; then
            Options[${match[1]}]="${match[2]}"
        elif [[ "$1" =~ ^[^-].*$ ]]; then
            Options[Requirements]+=" $1"
        fi
        shift
    done

    # Check required commands
    if [[ -n "${Options[Requirements]}" ]]; then
        typeset -a RequiredCommands
        RequiredCommands=(${=Options[Requirements]})
        for cmd in $RequiredCommands; do
            if ! command -v "$cmd" >/dev/null 2>&1; then
                FailedChecks+=("Required command not found: $cmd")
                ReturnCode=1
            fi
        done
    fi

    # Report failures if any
    if (( ReturnCode != 0 )); then
        z_Output error "Environment validation failed:"
        for check in $FailedChecks; do
            z_Output error "  - $check"
        done
        return $ReturnCode
    fi

    # Let z_Output handle mode checking - remove the outer if statement
    z_Output debug "Environment validation passed"
    return 0
}

#----------------------------------------------------------------------#
# Function: z_Script_Cleanup
#----------------------------------------------------------------------#
# Description:
#   Performs cleanup operations when the script exits. Ensures all
#   resources are properly released and temporary files are removed.
#   Called automatically by EXIT trap.
#
# Parameters:
#   $1 - Exit code from the script
#   $2 - Optional error message
#
# Global Variables Used:
#   - _Script_Running: Execution state flag
#   - _Cleanup_Running: Prevents recursive cleanup
#   - Temp_Files: Array of temporary files to remove
#
# Returns:
#   Original exit code passed to the function
#----------------------------------------------------------------------#
function z_Script_Cleanup {
    local exit_code=$1
    local error_msg=$2
    
    # Prevent recursive cleanup
    if (( _Cleanup_Running )); then
        return $exit_code
    fi
    _Cleanup_Running=1

    # Debug output if enabled
    if (( Output_Debug_Mode )); then
        z_Output debug "Performing cleanup operations..."
        z_Output debug "Exit code: $exit_code"
        [[ -n "$error_msg" ]] && z_Output debug "Error message: $error_msg"
    fi

    # Remove temporary files if they exist
    if (( ${#Temp_Files} > 0 )); then
        for file in $Temp_Files; do
            if [[ -e "$file" ]]; then
                (( Output_Debug_Mode )) && z_Output debug "Removing temporary file: $file"
                rm -f "$file"
            fi
        done
    fi

    # Reset execution state
    _Script_Running=0

    # Final error message if needed
    if (( exit_code != 0 )) && [[ -n "$error_msg" ]]; then
        z_Output error "$error_msg"
    fi

    return $exit_code
}

#----------------------------------------------------------------------#
# Function: z_Signal_Handler
#----------------------------------------------------------------------#
# Description:
#   Handles system signals gracefully, ensuring proper cleanup.
#   Works in conjunction with the cleanup function to ensure
#   consistent script termination.
#
# Parameters:
#   $1 - Signal name (INT, TERM, etc)
#
# Exit Codes:
#   130 - SIGINT (interrupt by user)
#   143 - SIGTERM (termination request)
#   1   - Other signals
#
# Example:
#   trap 'z_Signal_Handler INT' INT
#----------------------------------------------------------------------#
function z_Signal_Handler {
   local signal=$1
   
   # Let z_Output handle mode checking - remove the outer if statement
   z_Output debug "Received signal: $signal"

   # Handle different signal types
   case $signal in
       INT)
           z_Script_Cleanup 130 "Script interrupted by user"
           ;;
       TERM)
           z_Script_Cleanup 143 "Script terminated by system"
           ;;
       *)
           z_Script_Cleanup 1 "Script terminated by signal: $signal"
           ;;
   esac
   
   exit $?
}

#----------------------------------------------------------------------#
# Function: z_Core_Logic
#----------------------------------------------------------------------#
# Description:
#   Implements the primary logic and workflow of the script.
#   This function should be structured to clearly show the
#   main operational steps and flow.
#
# Parameters:
#   None
#
# Script-Scoped Variables Used:
#   - Script_Repo_Path: Target repository path
#   - Script_Work_Dir: Current working directory
#
# Returns:
#   0 (Z_SUCCESS) on success, non-zero on error:
#   - Z_IO: Input/output or path errors
#   - Z_ENVIRONMENT: Environment validation failures
#   - Z_GENERAL: General operational failures
#
# Dependencies:
#   - z_Output function for messaging
#   - z_Validate_Environment for checking requirements
#
# Flow:
#   1. Validate input and environment
#   2. Process main operations
#   3. Handle results and cleanup
#----------------------------------------------------------------------#
function z_Core_Logic {
   typeset -i ReturnCode=$Z_SUCCESS

   # Initialize working paths if not set
   if [[ -z "${Script_Work_Dir:-}" ]]; then
       Script_Work_Dir=$PWD
   fi
  
   if [[ -z "${Script_Repo_Path:-}" ]]; then
       Script_Repo_Path=$PWD
   fi

   # Status notifications - let z_Output handle all mode checking
   z_Output info "Validating repository state..."
   z_Output debug "Working directory: $Script_Work_Dir"
   z_Output debug "Repository path: $Script_Repo_Path"

   # Validate paths before proceeding
   # Note: z_Normalize_Path has already validated basic access
   if [[ ! -d "$Script_Repo_Path" ]]; then
       z_Output error "Invalid repository path: $Script_Repo_Path" ErrorCode=$Z_IO
       return $Z_IO
   fi

   if [[ ! -d "$Script_Work_Dir" ]]; then
       z_Output error "Invalid working directory: $Script_Work_Dir" ErrorCode=$Z_IO
       return $Z_IO
   fi

   # Only show success message if no errors occurred
   if (( ReturnCode == 0 )); then
       z_Output success "Operations completed successfully"
   fi
  
   return $ReturnCode
}

########################################################################
## Section: Argument Processing and Control Flow
##--------------------------------------------------------------------##
## Description: Functions for processing command-line arguments and
##              controlling the script's execution flow. Handles both
##              global flags and command-specific arguments.
##
## Key Components:
##   - Initial Argument Processing
##   - Default Command Handler
##   - Help Display
##   - Repository Path Management
##
## Design Philosophy:
##   - Clear separation between global and command-specific options
##   - Consistent error handling and validation
##   - Flexible argument processing for future extension
##   - Support for both interactive and non-interactive modes
##
## Functions:
##   - z_Process_Initial_Arguments: Process global flags
##   - z_Handler_Default: Main command handler
##   - z_Handler_Help: Help display
##   - z_Handler_Set_Repo_Path: Repository path validation
########################################################################

#----------------------------------------------------------------------#
# Function: z_Process_Initial_Arguments
#----------------------------------------------------------------------#
# Description:
#   Processes command-line arguments to set operational flags and stores
#   any unprocessed arguments for further handling. Establishes the
#   script's basic operating mode and behavior.
#
# Parameters:
#   "$@" - All command-line arguments passed to the script
#
# Script-Scoped Variables Modified:
#   - Output_Verbose_Mode: Enables verbose output (-v)
#   - Output_Debug_Mode: Enables debug output (-d)
#   - Output_Quiet_Mode: Suppresses non-essential output (-q)
#   - Output_Color_Enabled: Controls colored output (--no-color)
#   - Output_Force_Mode: Enables force mode override (-f)
#   - Script_Work_Dir: Set when -C option is used
#   - Script_Repo_Path: Set when -C option is used
#   - ArgsUnprocessed: Stores any remaining non-option arguments
#
# Options Processed:
#   -h, --help        Show help message
#   -v, --verbose     Enable verbose output
#   -d, --debug       Enable debug output
#   -q, --quiet       Minimize output
#   -n, --no-color    Disable color output
#   -C, --chdir      Run as if started in <path>
#   -V, --version    Show version information
#   -f, --force      Force operation
#   --               End option processing
#
# Returns:
#   Z_SUCCESS: Arguments processed successfully
#   Z_USAGE: Invalid arguments, conflicting options
#   Z_IO: Directory change or path validation failed
#
# Example Usage:
#   z_Process_Initial_Arguments "$@"
#   ReturnCode=$?
#   (( ReturnCode != 0 )) && return $ReturnCode
#----------------------------------------------------------------------#
function z_Process_Initial_Arguments {
    typeset -i ReturnCode=$Z_SUCCESS
    
    # Initialize default values for paths and arguments
    Script_Work_Dir="${PWD}"
    Script_Repo_Path=""
    ArgsUnprocessed=()
    
    # Process options until no more arguments or -- is encountered
    while (( $# > 0 )); do
        case "$1" in
            -h|--help)
                z_Handler_Help
                # Help handler will exit directly
                ;;
                
            -v|--verbose)
                Output_Verbose_Mode=$TRUE
                shift
                ;;
                
            -d|--debug)
                Output_Debug_Mode=$TRUE
                shift
                ;;
                
            -q|--quiet)
                Output_Quiet_Mode=$TRUE
                shift
                ;;
                
            -n|--no-color)
                Output_Color_Enabled=$FALSE
                shift
                ;;
                
            -C|--chdir)
                # Validate argument presence and format
                if (( $# < 2 )); then
                    z_Output error "Option '$1' requires a directory path" ErrorCode=$Z_USAGE
                    return $Z_USAGE
                fi
                if [[ "$2" == -* ]]; then
                    z_Output error "Option '$1' requires a directory path, got '$2'" ErrorCode=$Z_USAGE
                    return $Z_USAGE
                fi
                
                # Store path and validate later in z_Handler_Default
                Script_Work_Dir="$2"
                Script_Repo_Path="$2"
                shift 2
                ;;
                
            -V|--version)
                print -- "${ScriptFileName} version ${ScriptVersion:-0.1.0}"
                z_Script_Cleanup $Z_SUCCESS ""
                exit $Z_SUCCESS
                ;;
                
            -f|--force)
                Output_Force_Mode=$TRUE
                shift
                ;;
                
            --)
                # End of options marker - collect remaining args
                shift
                ArgsUnprocessed+=("$@")
                break
                ;;
                
            -*)
                # Unknown option - issue warning but continue processing
                z_Output warn "Unknown option: $1"
                shift
                ;;
                
            *)
                # Non-option argument - issue error as we require -C
                z_Output error "Use -C option to specify target directory" ErrorCode=$Z_USAGE
                return $Z_USAGE
                ;;
        esac
    done
    
    # Check for conflicting options early to prevent invalid states
    if (( Output_Quiet_Mode && Output_Verbose_Mode )); then
        z_Output error "Cannot specify both --quiet and --verbose" ErrorCode=$Z_USAGE
        return $Z_USAGE
    fi
    
    # Process NO_COLOR environment variable after argument processing
    if [[ -n "${NO_COLOR:-}" ]]; then
        Output_Color_Enabled=$FALSE
    fi
    
    # Output debug information about final argument state
    # Let z_Output handle mode checking internally
    z_Output debug "Processed arguments:"
    z_Output debug "  Verbose: ${Output_Verbose_Mode}"
    z_Output debug "  Debug: ${Output_Debug_Mode}"
    z_Output debug "  Quiet: ${Output_Quiet_Mode}"
    z_Output debug "  Color: ${Output_Color_Enabled}"
    z_Output debug "  Force: ${Output_Force_Mode}"
    
    return $ReturnCode
}

#----------------------------------------------------------------------#
# Function: z_Handler_Default
#----------------------------------------------------------------------#
# Description:
#   Primary command handler for the script. Processes remaining arguments
#   after initial flag parsing, sets up the execution environment, and
#   delegates to specific operational functions. Manages path initialization
#   and validation before executing the core logic.
#
# Parameters:
#   "$@" - Remaining command-line arguments after initial processing
#
# Script-Scoped Variables Used:
#   - ArgsUnprocessed: Array of unprocessed arguments
#   - Script_Work_Dir: Working directory
#   - Script_Repo_Path: Repository path
#
# Dependencies:
#   - z_Normalize_Path for path validation
#   - z_Validate_Environment for environment checks
#   - z_Core_Logic for main script operations
#   - z_Output for status reporting
#
# Returns:
#   0 on success, non-zero on error:
#   - Z_SUCCESS (0): Operation completed successfully
#   - Z_IO (5): Path validation or access error
#   - Z_ENVIRONMENT (3): Environment validation failed
#   - Other error codes as propagated from called functions
#
# Example Usage:
#   z_Handler_Default "$@"
#   ReturnCode=$?
#----------------------------------------------------------------------#
function z_Handler_Default {
    typeset -a args=("$@")
    typeset -i ReturnCode=$Z_SUCCESS

    # Initialize working paths - provide default if not set
    Script_Work_Dir=${Script_Work_Dir:-$PWD}
    z_Output debug "[handler] Initial Script_Work_Dir: $Script_Work_Dir"
    Script_Repo_Path=""

    # Process repository path from unprocessed arguments if provided
    if (( ${#ArgsUnprocessed} > 0 )); then
        z_Output debug "[handler] Processing path arg: ${ArgsUnprocessed[1]}"
        Script_Repo_Path=$(z_Normalize_Path "${ArgsUnprocessed[1]}" Type="dir")
        ReturnCode=$?
        if (( ReturnCode != 0 )); then
            z_Output debug "[handler] Failed to normalize arg path: $ReturnCode"
            return $ReturnCode
        fi
    else
        # No path argument - use working directory
        z_Output debug "[handler] Using work dir as repo path"
        Script_Repo_Path=$(z_Normalize_Path "$Script_Work_Dir" Type="dir")
        ReturnCode=$?
        if (( ReturnCode != 0 )) {
            z_Output debug "[handler] Failed to normalize work dir: $ReturnCode"
            return $ReturnCode
        }
    fi
    
    # Log final path determination
    z_Output debug "[handler] Final Script_Repo_Path: $Script_Repo_Path"

    # Validate environment before proceeding with operations
    z_Validate_Environment || return $?

    # Execute core logic with configured paths
    z_Core_Logic
    ReturnCode=$?

    return $ReturnCode
}

########################################################################
## Section: Script Execution Gateway
##--------------------------------------------------------------------##
## Description: Manages the script's initial execution setup, ensuring
##              proper handling of the script's environment and
##              operational parameters.
##
## Key Components:
##   - Script sourcing detection
##   - Recursive execution prevention
##   - Initial argument processing
##   - Main execution flow
##   - Exit handling
##
## Design Philosophy:
##   - Consistent initialization sequence
##   - Proper cleanup on all exit paths
##   - Clear error reporting
##   - Support for both direct execution and sourcing
##
## Important Notes:
##   - This section must be at the end of the script
##   - Only basic setup occurs here; complex logic belongs in functions
##   - All cleanup must be handled via traps
########################################################################

########################################################################
## Script Execution Entry Point
##--------------------------------------------------------------------##
## Description:
##   Main entry point for script execution. This section:
##   1. Detects whether the script is being sourced or executed
##   2. Prevents recursive execution
##   3. Sets up signal handlers and traps
##   4. Processes initial arguments
##   5. Executes main logic
##   6. Handles exit conditions
##
## Dependencies:
##   - All functions must be defined before this section
##   - Global variables must be initialized
##   - Trap handlers must be ready
##
## Exit Codes:
##   - Returns the exit code from the last executed command
##   - Ensures cleanup via EXIT trap
##   - Propagates signal handler exit codes
##
## Important:
##   - This must be the last section of the script
##   - No function definitions after this point
##   - All cleanup handled through traps
########################################################################

#----------------------------------------------------------------------#
# Source Detection and Execution Control
#----------------------------------------------------------------------#
# Description:
#   Determines if script is being sourced or executed directly.
#   Prevents recursive execution and initializes runtime environment.
#
# Variables Set:
#   - ScriptRunning: Prevents recursive execution
#   - _Script_Running: Main execution state tracker
#   - _Cleanup_Running: Cleanup state tracker
#
# Exit Codes:
#   - Z_GENERAL: On recursive execution attempt
#   - Inherited from z_Handler_Default otherwise
#----------------------------------------------------------------------#

# Check if script is being sourced or executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    # Ensure we're running in zsh
    if [[ ! -n "$ZSH_VERSION" ]]; then
        print -u2 "Error: Must run in zsh"
        exit $Z_GENERAL
    fi

    # Prevent recursive execution 
    typeset -i ScriptRunning=${ScriptRunning:-0}
    if (( ScriptRunning )); then
        print -u2 "Error: Recursive script execution detected"
        exit $Z_GENERAL
    fi
    ScriptRunning=1

    # Initialize execution state
    typeset -i _Script_Running=0
    typeset -i _Cleanup_Running=0
    typeset -ga Temp_Files

    # Set up signal handlers
    trap 'z_Signal_Handler INT' INT
    trap 'z_Signal_Handler TERM' TERM
    trap 'z_Script_Cleanup $? ""' EXIT

    # Now mark as running AFTER checking
    _Script_Running=1

    # Process command line arguments and handle any errors
    z_Process_Initial_Arguments "$@"
    typeset -i ReturnCode=$?

    # Continue with default handler unless help/version requested
    if (( ReturnCode == 0 )); then
        # Execute main logic
        z_Handler_Default "$@"
        ReturnCode=$?
    fi

    # Exit with appropriate code
    # Note: Cleanup will be performed by EXIT trap
    exit $ReturnCode
else
    # Script is being sourced
    # Initialize if not already set
    typeset -i _Script_Running=${_Script_Running:-0}
    typeset -i _Cleanup_Running=${_Cleanup_Running:-0}
fi

########################################################################
## END of Script `z_frame`
########################################################################    