#!/usr/bin/env zsh

########################################################################
##                         SCRIPT INFO
########################################################################
## z_min_frame.sh
## --------------------------------------------------------------------
## A minimal Zsh script template with robust error handling, output
## management, and example argument processing. Designed according to
## the "80/20" principle: includes the features most commonly needed
## (80%) while avoiding undue complexity (20%).
##
## KEY FEATURES:
##  - Strict Zsh environment setup (errexit, nounset, pipefail, etc.)
##  - Minimal but flexible output function (z_Output) supporting:
##    * print, warn, verbose, debug, vdebug, error modes
##    * optional Indent= and Force= parameters
##    * quiet mode to suppress non-error output
##    * optional ignored parameters from a "full" version of z_Output
##  - Standard signal handling and cleanup logic
##  - Example argument parsing for common CLI flags
##  - Clear, verbose code comments explaining each section/function
##
## This script can be used as a starting point for more specialized
## scripts. Simply copy/rename and adjust for your use case.
##
## NOTE: This file is considered the canonical “base” for future Zsh
##       scripts in the Open Integrity project. You should not remove
##       or rename any sections or functions; rather, insert new logic
##       or specialized functions under the existing structure.
########################################################################

########################################################################
## CHANGE LOG
########################################################################
## 0.1.00 - 2025-02-16
##   - Initial version
##   - Created as a minimal ZSH "frame" script for developer use
##
##   When adding new features or corrections, append entries here in
##   chronological order, preserving the original design and structure.
########################################################################

########################################################################
## SECTION: Environment Initialization
##--------------------------------------------------------------------##
## DESCRIPTION:
##   Sets up the script environment with robust Zsh error handling
##   and safe defaults. Declares script-scoped constants for booleans
##   and exit codes, plus a handful of runtime variables.
##
## DESIGN PHILOSOPHY:
##   - Early, strict configuration assures all subsequent code is safe.
##   - Minimizes risk of global variable misuse or silent failures.
##   - Defines the fundamental script "constants" and "flags" used later.
##
## DEPENDENCIES:
##   - Requires Zsh 5.8 or later for advanced parameter handling.
##   - Inherits environment variables like PWD.
##
## IMPORTANCE:
##   - Must be done first, before any real logic or function calls.
##
## NOTE: We use `emulate -LR zsh` to assure we reset to a clean Zsh
##       environment, and `setopt errexit nounset pipefail` to halt on
##       errors or undefined variables, preventing subtle bugs.
########################################################################

# Reset the shell environment to a known state
emulate -LR zsh

# Set strict error-handling and shell options
setopt errexit              # Exit immediately if a command has non-zero status
setopt nounset             # Unset variable expansion => error
setopt pipefail            # Pipeline exit code => last non-zero
setopt noclobber           # Prevent overwriting files (use >| to force)
setopt localoptions        # Restore options upon function return
setopt warncreateglobal    # Warn if a global variable is implicitly created
setopt no_unset            # Disallow unsetting a variable that doesn't exist
setopt no_nomatch          # Globs that don't match expand to empty
setopt no_list_ambiguous

# Boolean constants
typeset -i -r TRUE=1
typeset -i -r FALSE=0

# Exit status constants
typeset -i -r Exit_Status_Success=0
typeset -i -r Exit_Status_General=1
typeset -i -r Exit_Status_Usage=2
typeset -i -r Exit_Status_IO=5

# Script-scoped execution flags
typeset -i Output_Verbose_Mode=$FALSE
typeset -i Output_Debug_Mode=$FALSE
typeset -i Output_Quiet_Mode=$FALSE
typeset -i Output_Prompt_Enabled=$TRUE
typeset -i Output_Force_Mode=$FALSE
typeset -i Output_Color_Enabled=$TRUE

# Example path variables
typeset -ga Temp_Files      # Array of temporary files for cleanup
typeset Repo_Path="$(pwd)"  # Default repository path is current directory

# Additional flag and default folder for argument parsing
typeset -i Destination_Provided=$FALSE
typeset -r DEFAULT_REPO_FOLDER="myRepoFolder"

# Script-scoped variables for path and directory handling
typeset Script_Work_Dir="$(pwd)"


########################################################################
## SECTION: z_Utility Functions
##--------------------------------------------------------------------##
## DESCRIPTION:
##   Contains generic or broadly useful functions, such as cleanup,
##   signal handling, path manipulation, and a minimal output function.
##   These functions are self-contained and do not depend on each other
##   unless explicitly stated.
##
## DESIGN PHILOSOPHY:
##   - "Utility" means minimal side effects and reusability.
##   - Clear input/output contracts let other sections rely on them.
##
## IMPORTANCE:
##   - Must be defined before being used in other parts of this script.
##
## FUNCTIONS:
##  z_Script_Cleanup    - Gracefully cleans up resources at script exit
##  z_Signal_Handler    - Handles signals (INT, TERM, etc.) with cleanup
##  z_Assure_Valid_Path - Verifies a path exists and matches a type (dir/file)
##  z_Convert_Path_To_Relative - Converts an absolute path to a relative one
##  z_Output            - Minimal output function for various message types
##
## CONTRIBUTING
##   If you expand or revise these utilities (e.g., to add additional
##   path checks, signal handling, or track additional global
##   resources), please update function doc blocks and comments and
##   consider contributing back to the z_Utils project.
########################################################################

#----------------------------------------------------------------------#
# Function: z_Script_Cleanup
#----------------------------------------------------------------------#
# Description:
#   Manages resource cleanup and final processing when a script exits,
#   ensuring proper release of temporary resources and providing 
#   consistent exit handling across the z_utils library.
#
# Design Philosophy:
#   - Provide a centralized, robust mechanism for script finalization
#   - Ensure predictable and safe resource management
#   - Support flexible cleanup across different script scenarios
#   - Minimize the risk of resource leaks
#   - Create a uniform exit strategy for scripts
#
# Parameters:
#   $1 : Exit code to be returned by the script
#   $2 : Optional error message for logging or reporting
#
# Global Variables Used:
#   - Temp_Files: Array of temporary files to be removed
#   - Output_Debug_Mode: Controls detailed cleanup logging
#
# Cleanup Responsibilities:
#   - Remove temporary files and directories
#   - Log final script status and any error messages
#   - Prevent recursive cleanup attempts
#   - Preserve the original exit code
#
# Returns:
#   Returns the original exit code, maintaining script's final status
#
# Side Effects:
#   - Removes temporary files
#   - Logs debug information if debug mode is enabled
#   - May modify _Cleanup_Running state
#
# Error Handling:
#   - Gracefully handles cleanup even if resources are already removed
#   - Prevents multiple simultaneous cleanup attempts
#
# Example Usage:
#   z_Script_Cleanup $? "Optional error context"
#----------------------------------------------------------------------#
function z_Script_Cleanup {
   typeset exit_code=$1
   typeset error_msg="${2:-}"
   
   # Prevent recursive cleanup
   if (( _Cleanup_Running )); then
       return $exit_code
   fi
   _Cleanup_Running=1

   # Remove temporary files if they exist
   if (( ${#Temp_Files} > 0 )); then
       for file in "${Temp_Files[@]}"; do
           if [[ -e "$file" ]]; then
               (( Output_Debug_Mode )) && z_Output debug "Removing temporary file: $file"
               rm -f "$file"
           fi
       done
       # Clear the temporary files array
       Temp_Files=()
   fi

   # Log error message if provided
   if [[ -n "$error_msg" ]]; then
       if (( exit_code != 0 )); then
           z_Output error "$error_msg"
       elif (( Output_Debug_Mode )); then
           z_Output debug "$error_msg"
       fi
   fi

   # Optional final debug output
   if (( Output_Debug_Mode )); then
       z_Output debug "Cleanup completed. Exit code: $exit_code"
   fi

   return $exit_code
}

#----------------------------------------------------------------------#
# Function: z_Signal_Handler
#----------------------------------------------------------------------#
# Description:
#   Manages signal interruptions during script execution, ensuring 
#   clean and predictable script termination while preserving 
#   system resource integrity.
#
# Design Philosophy:
#   - Provide centralized, consistent signal management
#   - Ensure graceful script termination under various interrupt conditions
#   - Minimize potential resource leaks during abrupt terminations
#   - Create a uniform approach to handling unexpected script interruptions
#
# Parameters:
#   $1 : Signal name/type received (e.g., INT, TERM)
#
# Signal Types Handled:
#   - INT  (Ctrl-C): User keyboard interrupt
#   - TERM (Process termination): External process termination request
#   - Other signals: Generic unexpected interruption
#
# Global Variables Modified:
#   - _Script_Running: Tracks script execution state
#   - _Cleanup_Running: Manages cleanup process to prevent recursion
#
# Returns:
#   Exits script with signal-specific status code:
#   - 130 for SIGINT (Ctrl-C interrupt)
#   - 143 for SIGTERM (Termination signal)
#   - 1 for other unexpected signals
#
# Side Effects:
#   - Calls z_Script_Cleanup to release resources
#   - Terminates script execution
#
# Error Handling:
#   - Prevents recursive cleanup attempts
#   - Provides meaningful exit codes for different interrupt types
#
# Example Usage:
#   trap 'z_Signal_Handler INT' INT
#   trap 'z_Signal_Handler TERM' TERM
#----------------------------------------------------------------------#
function z_Signal_Handler {
   typeset signal="$1"
   
   # Prevent recursive cleanup
   if (( _Cleanup_Running )); then
       return 0
   fi
   
   # Select appropriate exit code and message based on signal
   case "$signal" in
       INT)
           z_Output debug "Received interrupt signal (Ctrl-C)"
           z_Script_Cleanup 130 "Script interrupted by user"
           ;;
       TERM)
           z_Output debug "Received termination signal"
           z_Script_Cleanup 143 "Script terminated by system"
           ;;
       *)
           z_Output debug "Received unexpected signal: $signal"
           z_Script_Cleanup 1 "Script terminated by unexpected signal"
           ;;
   esac
   
   exit $?
}

#----------------------------------------------------------------------#
# Function: z_Assure_Valid_Path
#----------------------------------------------------------------------#
# Description:
#   Validates and canonicalizes file system paths, ensuring they meet
#   specific type and existence requirements. Provides a robust mechanism
#   for path verification across z_utils library scripts.
#
# Design Philosophy:
#   - Create a comprehensive path validation utility
#   - Support flexible path type checking
#   - Provide clear, actionable error messages
#   - Minimize side effects and external command usage
#   - Enable consistent path handling across scripts
#
# Parameters:
#   $1 : Path to be validated
#   Additional optional parameters:
#     type=dir   - Validates path as an existing directory (default)
#     type=file  - Validates path as an existing file
#
# Returns:
#   0 (Z_SUCCESS)   - Path successfully validated
#   2 (Z_USAGE)     - Path validation failed
#
# Output:
#   - Prints the fully resolved, canonical path to stdout on success
#   - Outputs error messages to stderr on validation failure
#
# Supported Validations:
#   - Path existence
#   - Path type (directory or file)
#   - Path canonicalization
#
# Zsh Features:
#   - Uses parameter expansion for path resolution (:A modifier)
#   - Leverages regex for flexible parameter parsing
#   - Supports named parameter parsing
#
# Error Handling:
#   - Provides detailed error messages for different validation failures
#   - Supports multiple error scenarios
#   - Uses consistent error codes
#
# Usage Examples:
#   z_Assure_Valid_Path "/path/to/directory" type=dir
#   z_Assure_Valid_Path "/path/to/file.txt" type=file
#
# Notes:
#   - Resolves symlinks and normalizes path
#   - Removes double slashes and resolves '..' components
#   - Does not modify the original path
#----------------------------------------------------------------------#
function z_Assure_Valid_Path() {
    # Existing implementation remains unchanged
    typeset -a match mbegin mend
    
    typeset requiredPath="$1"
    shift  # Move past the first parameter

    # If no path provided, error out
    if [[ -z "$requiredPath" ]]; then
        z_Output error "No path supplied to z_Assure_Valid_Path."
        return $Exit_Status_Usage
    fi

    # Default values
    typeset expectType="dir"

    # Parse Key=Value optional parameters (type=dir|file, etc.)
    while (( $# > 0 )); do
        if [[ "$1" =~ '^([[:alnum:]_]+)=(.*)$' ]]; then
            typeset key="${match[1]}"
            typeset val="${match[2]}"
            case "$key" in
                type)
                    if [[ "$val" != "dir" && "$val" != "file" ]]; then
                        z_Output error "Invalid type '$val'. Must be 'dir' or 'file'."
                        return $Exit_Status_Usage
                    fi
                    expectType="$val"
                    ;;
                *)
                    z_Output error "Unrecognized parameter '$1' in z_Assure_Valid_Path."
                    return $Exit_Status_Usage
                    ;;
            esac
        else
            z_Output error "Invalid usage in z_Assure_Valid_Path: $1"
            return $Exit_Status_Usage
        fi
        shift
    done

    # Canonicalize path (remove double slashes, resolve '..', symlinks, etc.)
    typeset canonPath="${requiredPath:A}"

    # Check if path actually exists
    if [[ ! -e "$canonPath" ]]; then
        z_Output error "Path does not exist: $canonPath"
        return $Exit_Status_Usage
    fi

    # Verify directory or file type
    if [[ "$expectType" == "dir" ]]; then
        if [[ ! -d "$canonPath" ]]; then
            z_Output error "Expected directory, but not found: $canonPath"
            return $Exit_Status_Usage
        fi
    else  # type=file
        if [[ ! -f "$canonPath" ]]; then
            z_Output error "Expected file, but not found: $canonPath"
            return $Exit_Status_Usage
        fi
    fi

    # Print the canonical path and return success
    z_Output debug "Validated existing $expectType: $canonPath"
    print -- "$canonPath"
    return 0
}

#----------------------------------------------------------------------#
# Function: z_Normalize_Path
#----------------------------------------------------------------------#
# Description:
#   Validates, standardizes, and normalizes file system paths, providing
#   a consistent mechanism for path handling across z_utils library scripts.
#
# Design Philosophy:
#   - Create a robust, predictable path processing utility
#   - Provide comprehensive path validation
#   - Support flexible path type checking
#   - Minimize side effects and external command usage
#   - Enable consistent error reporting for path-related issues
#
# Parameters:
#   $1 : Path to be normalized
#   Type : Optional parameter specifying expected path type
#           Supported types: "file", "dir", "any" (default)
#
# Options:
#   Type=file     - Validates path as an existing file
#   Type=dir      - Validates path as an existing directory
#   Type=any      - Allows any existing path type
#
# Returns:
#   0 (Z_SUCCESS)   - Path successfully validated and normalized
#   2 (Z_USAGE)     - Invalid path or type mismatch
#   5 (Z_IO)        - Path does not exist or is inaccessible
#
# Output:
#   Prints the fully resolved, canonical path to stdout
#
# Error Handling:
#   - Provides detailed error messages for path validation failures
#   - Supports various path type validations
#   - Handles relative and absolute paths
#
# Zsh Features:
#   - Uses parameter expansion for path resolution
#   - Leverages Zsh's advanced path manipulation capabilities
#
# Example Usage:
#   normalized_path=$(z_Normalize_Path "/path/to/something" Type="dir")
#----------------------------------------------------------------------#
function z_Normalize_Path() {
   typeset path="${1:?Path argument required}"
   typeset type="${Type:-any}"
   typeset -i ReturnCode=$Z_SUCCESS

   # Resolve path to absolute, canonical form
   typeset resolvedPath="${path:A}"

   # Validate path existence
   if [[ ! -e "$resolvedPath" ]]; then
       z_Output error "Path does not exist: $path"
       return $Exit_Status_IO
   fi

   # Type-specific validations
   case "$type" in
       file)
           if [[ ! -f "$resolvedPath" ]]; then
               z_Output error "Path is not a file: $path"
               return $Z_USAGE
           fi
           ;;
       dir)
           if [[ ! -d "$resolvedPath" ]]; then
               z_Output error "Path is not a directory: $path"
               return $Z_USAGE
           fi
           ;;
       any)
           # No additional checks needed
           ;;
       *)
           z_Output error "Invalid path type specified: $type"
           return $Z_USAGE
           ;;
   esac

   # Ensure path is readable
   if [[ ! -r "$resolvedPath" ]]; then
       z_Output error "Path is not readable: $path"
       return $Exit_Status_IO
   fi

   # Output normalized path
   print -- "$resolvedPath"
   return $ReturnCode
}

#----------------------------------------------------------------------#
# Function: z_Convert_Path_To_Relative
#----------------------------------------------------------------------#
# Description:
#   Converts an absolute path into a relative one, based on the current
#   working directory (PWD). If the path is within PWD, it becomes
#   something like "./some/sub/dir"; if it's outside, it may become
#   "../some/other/dir" or remain absolute if no shared ancestor found.
#   This function is useful for displaying paths in a more user-friendly
#   way, especially in scripts that move around or work with multiple
#   directories.
#
# Design Philosophy:
#   - Create a predictable path conversion mechanism
#   - Minimize complexity of path representation
#   - Provide intuitive path relativity
#   - Support consistent path display across different contexts
#   - Reduce full path verbosity in user-facing output
#
# Parameters:
#   $1 - The absolute or partial path to convert
#
# Usage Examples:
#   z_Convert_Path_To_Relative "/etc/myconfig.conf"
#     - Returns "etc/myconfig.conf" if PWD is "/"
#     - Returns "../../etc/myconfig.conf" if PWD is "/home/user"
#   fileRelativePath="$(z_Convert_Path_To_Relative "/home/otheruser/some/file.txt")"
#     - Sets repoRelativePath to "../otheruser/some/file.txt" if PWD is "/home/user/"
#
# Globals Used:
#   PWD
#
# Returns:
#   0 (Z_SUCCESS)   - Path successfully converted
#   2 (Z_USAGE)     - Invalid path provided
#
# Output:
#   Prints the relative path to stdout
#
# Notes:
#   - Use this function to display paths in a more user-friendly way, but not
#     for path validation or manipulation.
#   - This function does not check if the path exists; it only converts.
#   - If the path is exactly the current directory, it returns ".".
#   - If the path is a sub-path of the current directory, it returns "./..."
#   - If the path is outside the current directory, it returns a relative
#     path with "../" segments.
#   - If no shared ancestor is found, the function keeps the path absolute.
#   - Uses Zsh :A to canonicalize paths (resolve symlinks, etc.).
#   - This function does not produce any side effects besides output to stdout.
#
# Zsh Features:
#   - Uses parameter expansion for path resolution
#   - Leverages :A modifier to canonicalize paths
#   - Minimal external command dependencies
#
# Error Handling:
#   - Validates input path
#   - Handles various path relationship scenarios
#
# Example Usage:
#   relative_path=$(z_Convert_Path_To_Relative "/full/path/to/somewhere")
#----------------------------------------------------------------------#
function z_Convert_Path_To_Relative() {
    typeset pathAbsolute="${1:A}"   # Canonical absolute path
    typeset pwdAbsolute="${PWD:A}"  # Canonical current directory
    
    # If it's exactly the current dir, just return "."
    if [[ "$pathAbsolute" == "$pwdAbsolute" ]]; then
        print "."
        return
    fi

    # If it's a sub-path of the current dir, prefix with "./"
    if [[ "$pathAbsolute" == "$pwdAbsolute/"* ]]; then
        print "./${pathAbsolute#$pwdAbsolute/}"
        return
    fi
    
    # Otherwise, attempt to find a common ancestor
    typeset pathCommon="$pwdAbsolute"
    typeset pathResult=""
    
    # Step upwards until we find shared directory
    while [[ "$pathAbsolute" != "$pathCommon"* ]]; do
        pathResult="../$pathResult"
        pathCommon="${pathCommon:h}"
    done
    
    # If pathCommon is non-empty, remove that portion
    if [[ -n "$pathCommon" ]]; then
        typeset pathRelative="${pathAbsolute#$pathCommon/}"
        if [[ -n "$pathRelative" ]]; then
            print "${pathResult}${pathRelative}"
        else
            # If removing pathCommon leaves nothing, remove trailing slash
            print "${pathResult%/}"
        fi
    else
        # Fallback: no common ancestor => remain absolute
        print "$pathAbsolute"
    fi
}

#------------------------------------------------------------------------------
# FUNCTION: z_Output (minimal version)
#------------------------------------------------------------------------------
# Description:
#   A utility function for formatted output in Zsh scripts. Supports
#   multiple message types, emoji, indentation, and various debug and verbosity
#   levels. Designed to be minimal and flexible, with a focus on clarity.
#
# Version: 1.0.00 (2024-02-16)
#
# Usage:
#   z_Output <Type> <Message> [Options]
#    - Type: The message type, supporting several modes:
#       - print   : Standard output (default)
#       - warn    : Warning message
#       - verbose : Additional information
#       - debug   : Debugging information
#       - vdebug  : Very detailed debug info       
#   - Message: The text to display
#   - Options: Optional parameters in Key=Value format:
#       - Indent=<number>  : Control left indentation
#       - Force=<0|1>      : Override quiet mode
#
#   The function is designed to allow either:
#       z_Output print Indent=2 "Your message"
#       z_Output print "Your message" Indent=2
#
#   The `quiet` mode (Output_Quiet_Mode) suppresses all output except 'error' or
#   if Force=1. 'verbose', 'debug', and 'vdebug' modes only appear if their
#   respective script-scoped flags (Output_Verbose_Mode, Output_Debug_Mode) are
#   set or forced.
#
#   This function also seamlessly ignores certain "original" z_Output
#   parameters (Color, Emoji, Wrap, Fatal, Default, ErrorCode),
#   printing a debug note if the script is in debug mode.
#
#   The final output uses different emoji/color for each mode. Indentation
#   is handled via repeated spaces.
#
#   For more examples or extended usage, see:
#   https://github.com/ChristopherA/Z_Utils/blob/main/z_min_frame.sh
#------------------------------------------------------------------------------
function z_Output() {
    # Declare arrays for regex pattern matching
    typeset -a match mbegin mend

    # Local constants (ANSI colors & emojis)
    typeset resetColor="\033[0m"

    typeset colorPrint=""
    typeset colorWarn="\033[1;33m"
    typeset colorVerbose="\033[1;35m"
    typeset colorDebug="\033[1;36m"
    typeset colorVdebug="\033[1;34m"
    typeset colorError="\033[1;31m"

    typeset emojiPrint=""
    typeset emojiWarn="⚠️"
    typeset emojiVerbose="💬"
    typeset emojiDebug="🐛"
    typeset emojiVdebug="🔍"
    typeset emojiError="❌"

    # Mode & parameters
    typeset messageMode="print"
    typeset -i indentSize=0
    typeset -i forceOutput=0
    typeset -a messageTokens=()

    # If the first argument exists, treat it as the mode
    if (( $# > 0 )); then
        messageMode="$1"
        shift
    fi

    # Parse remaining args for Key=Value params or message text
    while (( $# > 0 )); do
        if [[ "$1" =~ '^([[:alnum:]_]+)=(.*)$' ]]; then
            typeset key="${match[1]}"
            typeset val="${match[2]}"

            case "$key" in
                Indent) indentSize="$val" ;;
                Force)  forceOutput="$val" ;;
                Color|Emoji|Wrap|Fatal|Default|ErrorCode)
                    (( Output_Debug_Mode )) && print "🐛 Ignoring unused parameter '$1'"
                    ;;
                *)
                    print -- "\033[1;31m❌ Unrecognized parameter: $1\033[0m"
                    exit $Exit_Status_Usage
                    ;;
            esac
        else
            # Anything not matching "Key=Value" is part of the message text
            messageTokens+=( "$1" )
        fi
        shift
    done

    # Combine all message tokens into a single string
    typeset messageText="${(j: :)messageTokens}"

    # Quiet mode check (suppress unless 'error' or forced)
    if [[ $Output_Quiet_Mode -eq 1 && $forceOutput -ne 1 && "$messageMode" != "error" ]]; then
        return 0
    fi

    # Gating for verbose/debug/vdebug
    case "$messageMode" in
        vdebug)
            if (( (Output_Verbose_Mode != 1 || Output_Debug_Mode != 1) && forceOutput != 1 )); then
                return 0
            fi
            ;;
        verbose)
            if (( Output_Verbose_Mode != 1 && forceOutput != 1 )); then
                return 0
            fi
            ;;
        debug)
            if (( Output_Debug_Mode != 1 && forceOutput != 1 )); then
                return 0
            fi
            ;;
    esac

    # Map mode => color & emoji
    typeset colorCode="$colorPrint"
    typeset emojiIcon="$emojiPrint"
    case "$messageMode" in
        print)   colorCode="$colorPrint";   emojiIcon="$emojiPrint"   ;;
        warn)    colorCode="$colorWarn";    emojiIcon="$emojiWarn"    ;;
        verbose) colorCode="$colorVerbose"; emojiIcon="$emojiVerbose" ;;
        debug)   colorCode="$colorDebug";   emojiIcon="$emojiDebug"   ;;
        vdebug)  colorCode="$colorVdebug";  emojiIcon="$emojiVdebug"  ;;
        error)   colorCode="$colorError";   emojiIcon="$emojiError"   ;;
    esac

    # Indentation
    typeset indentSpace=""
    (( indentSize > 0 )) && indentSpace="$(printf '%*s' "$indentSize" '')"

    # Final output
    print -- "${indentSpace}${colorCode}${emojiIcon:+$emojiIcon }${messageText}${resetColor}"
}

########################################################################
## SECTION: Core Script Functionality
##--------------------------------------------------------------------##
## DESCRIPTION:
##   Implements the main logic or "pipeline" for the script, typically
##   orchestrating any checks, transformations, or processing. This can
##   be expanded in real-world usage to do real work.
##
## DESIGN PHILOSOPHY:
##   - Keep functions small and purposeful.
##   - "core_Logic" is the primary "action" stage, making calls to
##     utility functions (like z_Output or z_Convert_Path_To_Relative).
##
## IMPORTANCE:
##   - Typically the "guts" of the script, invoked by main().
##
## NOTE: In an actual specialized script, you might subdivide your tasks
##       into multiple smaller functions in this section. This is just
##       an example placeholder.
########################################################################

#----------------------------------------------------------------------#
# Function: core_Logic
#----------------------------------------------------------------------#
# Description:
#   Demonstrates the script's primary functionality and serves as a
#   template for how script-specific logic should be implemented in
#   z_min_frame.sh and other scripts using this template.
#
# Design Philosophy:
#   - Provide a clear, commented example of script execution flow
#   - Showcase utility functions like path conversion and output
#   - Illustrate best practices for script structure and error handling
#   - Serve as a living documentation of script capabilities
#
# Dependencies:
#   - z_Convert_Path_To_Relative for path manipulation
#   - z_Output for structured messaging
#
# Global Variables Used:
#   - Repo_Path: Target repository or working directory
#
# Returns:
#   0 on successful execution
#   Non-zero on errors or demonstration of error handling
#
# Example Usage:
#   core_Logic
#   exit $?
#----------------------------------------------------------------------#
function core_Logic() {
   # Convert repository path to relative path
   typeset repoRelativePath
   repoRelativePath="$(z_Convert_Path_To_Relative "$Repo_Path")"
   
   # Demonstrate various output modes using z_Output
   z_Output print   "Hello from 'print' mode (suppressed if quiet)."
   z_Output warn    "This is a 'warn' message (suppressed if quiet)."
   z_Output verbose "Verbose mode is ON."  Indent=4
   z_Output debug   "Debug mode is ON."    Indent=2
   z_Output vdebug  "vdebug => requires BOTH verbose & debug." Indent=2
   z_Output error   "This is an 'error' message, always shown."
   z_Output print   "Forcing this 'print' output ignoring quiet mode." Force=1

   # Demonstrate various output modes using z_Output
   z_Output print "Initializing repository at: $repoRelativePath"

   # Demonstrate various output modes using z_Output
   z_Output verbose "Checking repository path: $repoRelativePath"

   # Validate repository path type
   if [[ ! -e "$Repo_Path" ]]; then
       z_Output error "Repository path does not exist: $Repo_Path"
       return $Exit_Status_General
   fi

   if [[ ! -d "$Repo_Path" ]]; then
       z_Output error "Repository path is not a directory: $Repo_Path"
       return $Exit_Status_Usage
   fi

   z_Output debug "Performing repository initialization (simulated)..."

   # Placeholder for actual script-specific logic
   z_Output success "Repository initialization complete."

   return $Exit_Status_Success
}

########################################################################
## SECTION: Argument Processing
##--------------------------------------------------------------------##
## DESCRIPTION:
##   Handles command-line arguments, including standard flags for
##   changing directories, enabling verbose/debug/quiet modes, and
##   printing help. Demonstrates typical approach with a "process"
##   function plus a "help" function.
##
## DESIGN PHILOSOPHY:
##   - Centralize argument parsing logic for consistency.
##   - Provide user-friendly help output in handler_Help().
##   - Store user-provided values in script-scoped variables to be used
##     in the main or core_Logic flow.
##
## FUNCTIONS:
##   handler_Help()            - Prints usage text to stdout
##   process_Initial_Arguments - Sets Output_Debug_Mode, etc. and adjusts Repo_Path
##
## NOTE: If you add or remove flags, keep these function doc blocks and
##       usage text up to date so users know exactly how to invoke them.
########################################################################

#----------------------------------------------------------------------#
# Function: handler_Help
#----------------------------------------------------------------------#
# Description:
#   Displays comprehensive help information for the script, explaining
#   available command-line options, usage patterns, and basic functionality.
#
# Design Philosophy:
#   - Provide clear, concise user guidance
#   - Cover all supported command-line options
#   - Facilitate user understanding of script capabilities
#   - Enable self-documentation of script behavior
#   - Support consistent help formatting across z_utils library scripts
#
# Parameters:
#   None
#
# Output:
#   Writes help text to standard output, detailing script usage and options
#
# Behavior:
#   - Displays script usage syntax
#   - Lists and explains all supported command-line options
#   - Provides brief examples of script invocation
#
# Returns:
#   0 (Z_SUCCESS) - Always exits successfully after displaying help
#
# Example Usage:
#   handler_Help
#   exit $Z_SUCCESS
#----------------------------------------------------------------------#
function handler_Help() {
   cat <<EOF
Usage: ${ScriptFileName} [options]

Options:
 -h, --help        Display this help message and exit
 -v, --verbose     Enable verbose output mode
 -d, --debug       Enable debug output and detailed logging
 -q, --quiet       Suppress non-essential output messages
 -n, --no-color    Disable colored terminal output
 -V, --version     Show script version information
 -f, --force       Force operation, overriding default safety checks
 -C, --chdir <dir> Change to the specified directory before execution

Examples:
 ${ScriptFileName}                 Run with default settings
 ${ScriptFileName} -v              Run in verbose mode
 ${ScriptFileName} -C /path/to/dir Change working directory
 ${ScriptFileName} -n              Disable color output

For more information, consult the script's documentation.
EOF
}

#----------------------------------------------------------------------#
# Function: parse_Remaining_Arguments
#----------------------------------------------------------------------#
# Description:
#   Processes script-specific command-line arguments after initial global
#   flag processing. Handles directory change and repository path 
#   specification for this specific script.
#
# Design Philosophy:
#   - Provide script-specific argument handling flexibility
#   - Validate and normalize path arguments
#   - Extend the generic argument processing with local requirements
#   - Ensure robust path handling and error reporting
#
# Parameters:
#   "$@" - Remaining command-line arguments after initial processing
#
# Global Variables Modified:
#   - Repo_Path: Set to the specified or default repository directory
#   - Script_Work_Dir: Updated with the target working directory
#
# Argument Handling:
#   - Processes -C/--chdir option for changing working directory
#   - Validates and normalizes provided directory paths
#   - Provides fallback to current working directory if no path specified
#
# Returns:
#   0 (Z_SUCCESS)   - Arguments processed successfully
#   2 (Z_USAGE)     - Invalid directory or path specification
#   5 (Z_IO)        - Input/output related error with path
#
# Error Handling:
#   - Validates directory existence and accessibility
#   - Provides meaningful error messages for path-related issues
#   - Prevents execution with invalid directory specifications
#
# Environment Interactions:
#   - Respects current working directory
#   - Uses z_Normalize_Path for consistent path handling
#
# Example Usage:
#   parse_Remaining_Arguments "$@"
#   (( $? == 0 )) || exit $?
#----------------------------------------------------------------------#
function parse_Remaining_Arguments() {
    typeset -i ReturnCode=$Z_SUCCESS
    typeset target_dir=""

    # Use first unprocessed argument as potential directory if available
    if (( ${#ArgsUnprocessed} > 0 )); then
        # Check for -C/--chdir option
        if [[ "${ArgsUnprocessed[1]}" == "-C" || "${ArgsUnprocessed[1]}" == "--chdir" ]]; then
            # Validate that we have a path argument
            if (( ${#ArgsUnprocessed} < 2 )); then
                z_Output error "Option '${ArgsUnprocessed[1]}' requires a directory path"
                return $Z_USAGE
            fi
            target_dir="${ArgsUnprocessed[2]}"
            # Remove the -C and path from ArgsUnprocessed
            shift 2 ArgsUnprocessed
        else
            # First argument is potential path
            target_dir="${ArgsUnprocessed[1]}"
            shift 1 ArgsUnprocessed
        fi
    fi

    # Check for any remaining unprocessed arguments
    if (( ${#ArgsUnprocessed} > 0 )); then
        z_Output error "Unrecognized argument: ${ArgsUnprocessed[1]}"
        return $Z_USAGE
    fi

    # If no directory specified, use current working directory
    if [[ -z "$target_dir" ]]; then
        target_dir="$PWD"
    fi

    # Normalize and validate the path
    Repo_Path=$(z_Normalize_Path "$target_dir" Type="dir")
    ReturnCode=$?

    if (( ReturnCode != 0 )); then
        z_Output error "Invalid repository path: $target_dir"
        return $ReturnCode
    fi

    # Update working directory
    Script_Work_Dir="$Repo_Path"

    # Optional: Debug output of path processing
    z_Output debug "Repository path set to: $Repo_Path"

    return $ReturnCode
}

#----------------------------------------------------------------------#
# Function: z_parse_Initial_Arguments
#----------------------------------------------------------------------#
# Description:
#   Processes global command-line arguments to configure script execution
#   mode and behavior. Handles common flags that affect script operation
#   across different utilities in the z_utils library.
#
# Design Philosophy:
#   - Provide a universal, low-overhead argument parsing mechanism
#   - Create a consistent interface for script configuration
#   - Minimize dependencies and side effects
#   - Balance flexibility with predictable behavior
#   - Enable standardized scripting patterns across different utilities
#   - Support graceful degradation and clear error communication
#
# Parameters:
#   "$@" - Complete set of command-line arguments passed to the script
#
# Script-Scoped Variables Modified:
#   - Output_Verbose_Mode: Enables verbose output logging
#   - Output_Debug_Mode: Enables detailed debugging information
#   - Output_Quiet_Mode: Suppresses non-essential output
#   - Output_Color_Enabled: Controls terminal color output
#   - Output_Force_Mode: Enables force/override operations
#   - ArgsUnprocessed: Stores arguments not processed in this function
#
# Supported Options:
#   -h, --help      Display help information and exit
#   -v, --verbose   Enable verbose output mode
#   -d, --debug     Enable debug output mode
#   -q, --quiet     Suppress non-essential output
#   -n, --no-color  Disable color terminal output
#   -V, --version   Display script version information
#   -f, --force     Enable force/override mode
#   --              Terminate option processing
#
# Returns:
#   0 (Z_SUCCESS)   - Arguments processed successfully
#   2 (Z_USAGE)     - Invalid argument configuration
#
# Error Handling:
#   - Detects and reports conflicting option combinations
#   - Provides meaningful error messages for invalid arguments
#   - Supports early termination for help or version display
#
# Environment Variables:
#   - Respects NO_COLOR environment variable for color output
#
# Example Usage:
#   z_parse_Initial_Arguments "$@"
#   (( $? == 0 )) || exit $?
#----------------------------------------------------------------------#
function z_parse_Initial_Arguments() {
    typeset -i ReturnCode=$Z_SUCCESS
    
    # Reset flags to default state
    Output_Verbose_Mode=$FALSE
    Output_Debug_Mode=$FALSE
    Output_Quiet_Mode=$FALSE
    Output_Color_Enabled=$TRUE
    Output_Force_Mode=$FALSE
    
    # Clear previously processed arguments
    ArgsUnprocessed=()
    
    # Process options until no more arguments or -- is encountered
    while (( $# > 0 )); do
        case "$1" in
            -h|--help)
                z_Handler_Help
                exit $Z_SUCCESS
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
                
            -V|--version)
                print -- "${ScriptFileName} version ${ScriptVersion:-0.1.0}"
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
                # Unrecognized option - store for later processing
                ArgsUnprocessed+=("$1")
                shift
                ;;
                
            *)
                # Non-option argument - store for later processing
                ArgsUnprocessed+=("$1")
                shift
                ;;
        esac
    done
    
    # Check for conflicting options
    if (( Output_Quiet_Mode && Output_Verbose_Mode )); then
        z_Output error "Cannot specify both --quiet and --verbose"
        return $Z_USAGE
    fi
    
    # Process NO_COLOR environment variable
    if [[ -n "${NO_COLOR:-}" ]]; then
        Output_Color_Enabled=$FALSE
    fi
    
    # Optional: Output debug information about processed arguments
    z_Output debug "Processed global arguments:" \
        "Verbose: $Output_Verbose_Mode" \
        "Debug: $Output_Debug_Mode" \
        "Quiet: $Output_Quiet_Mode" \
        "Color: $Output_Color_Enabled" \
        "Force: $Output_Force_Mode"
    
    return $ReturnCode
}

#----------------------------------------------------------------------#
# Function: main
#----------------------------------------------------------------------#
# Description:
#   Acts as the top-level controller of this script. Orchestrates the
#   script's execution flow, processing arguments, handling execution
#   environment, and delegating to core logic functions.
#
# Design Philosophy:
#   - Maintain a clear, linear execution flow
#   - Separate concerns between argument processing, environment setup,
#     and core logic
#   - Provide granular error handling and reporting
#   - Minimize side effects and global state modifications
#   - Enable easy extension and customization of script behavior
#   - Follow the principle of "fail fast" - detect and report errors early
#   - Preserve the script's core purpose while allowing flexible 
#     configuration through command-line arguments
#
# Parameters:
#   "$@" - All command-line arguments passed to the script
#
# Workflow:
#   1. Process initial arguments (global flags, modes)
#   2. Handle script-specific argument processing
#   3. Validate execution environment
#   4. Execute core script logic
#
# Global Variables Modified:
#   - Output_Verbose_Mode
#   - Output_Debug_Mode
#   - Output_Quiet_Mode
#   - ArgsUnprocessed
#   - Repo_Path
#
# Dependencies:
#   - z_parse_Initial_Arguments: Processes global script flags
#   - parse_Remaining_Arguments: Handles script-specific arguments
#   - core_Logic: Executes primary script functionality
#
# Returns:
#   - 0 on successful execution
#   - Non-zero exit code indicating specific error condition:
#     * Exit_Status_Usage (2): Argument parsing error
#     * Exit_Status_General (1): Generic script failure
#
# Error Handling:
#   - Stops execution if argument processing fails
#   - Provides granular error reporting through exit codes
#   - Preserves error context for caller
#
# Example Usage:
#   main "$@"
#   exit $?
#----------------------------------------------------------------------#
function main() {
    typeset -i ReturnCode=$Exit_Status_Success

    # Process global arguments and set script mode
    z_parse_Initial_Arguments "$@"
    ReturnCode=$?

    # Handle script-specific arguments if initial processing succeeds
    if (( ReturnCode == 0 )); then
        parse_Remaining_Arguments "$@"
        ReturnCode=$?
    fi

    # Execute core logic if no errors occurred
    if (( ReturnCode == 0 )); then
        core_Logic
        ReturnCode=$?
    fi

    return $ReturnCode
}

########################################################################
## SECTION: SCRIPT EXECUTION GATEWAY
##--------------------------------------------------------------------##
## DESCRIPTION:
##   This section determines how and when the script actually executes.
##   Specifically, it checks if the file is being run directly (as a main
##   program) or if it's merely being sourced by another script/library.
##   If it's run directly, we set up signal traps, do any required
##   script-scope initialization that must happen exactly once, and
##   finally call `main()`.
##
## DESIGN PHILOSOPHY:
##   - Keep initialization code in one place so it's obvious what runs
##     only when invoked as a standalone script.
##   - Avoid surprising side effects if a user just wants to source the
##     file for its functions (no automatic `main()` call in that case).
##   - Maintain a clear boundary: everything above is the declaration of
##     variables and functions; everything below is the actual "driver"
##     code if run standalone.
##
## SCRIPT-SCOPED CODE:
##   - Code here typically includes trap setup, environment checks, or
##     dependency checks that must only happen once, at runtime.
##
## EXPLANATION:
##   - `if [[ "${(%):-%N}" == "$0" ]]; then ... fi`
##     This assures we only run `main` if the script is executed directly,
##     not sourced. That way, no surprise side effects occur for users
##     who just want to reuse these functions.
##
## CRITICAL NOTES:
##   - The final `exit` after `main` assures the script returns an
##     appropriate status code, aligning with the design set above.
########################################################################

# Check if script is being sourced or executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    # Ensure we're running in zsh
    if [[ ! -n "$ZSH_VERSION" ]]; then
        print -u2 "Error: Must run in zsh"
        exit $Exit_Status_General
    fi

    # Explicitly initialize global variables
    typeset -i Z_SUCCESS=0
    typeset -i _Cleanup_Running=0

    # Prevent recursive execution 
    typeset -i ScriptRunning=${ScriptRunning:-0}
    if (( ScriptRunning )); then
        print -u2 "Error: Recursive script execution detected"
        exit $Exit_Status_General
    fi
    ScriptRunning=1

    # Initialize execution state
    typeset -ga ArgsUnprocessed=()  # New array to store unprocessed arguments
    typeset Repo_Path=""  # Will be set by argument processing

    # Set up signal handlers
    trap 'z_Signal_Handler INT' INT
    trap 'z_Signal_Handler TERM' TERM
    trap 'z_Script_Cleanup $? ""' EXIT

    # Final call to main, allowing its implementation to handle details
    main "$@"
    exit $?
else
    # Script is being sourced
    # Initialize if not already set
    typeset -i _Script_Running=${_Script_Running:-0}
    typeset -i _Cleanup_Running=${_Cleanup_Running:-0}
fi

########################################################################
## END of Script `z_min_frame.sh`
########################################################################
