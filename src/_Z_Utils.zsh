#!/usr/bin/env zsh
# _Z_Utils.zsh - Core Zsh utility functions library
# 
# Version:       0.1.00 (2025-03-19)
# Origin:        https://github.com/ChristopherA/z_Utils
# Description:   A collection of reusable Zsh utility functions designed to provide
#                consistent, robust, and efficient scripting capabilities.
# License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
# Copyright:     (c) 2025 Christopher Allen
# Attribution:   Authored by @ChristopherA <ChristopherA@LifeWithAlacrity.com>

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options for strict error handling
setopt errexit nounset pipefail localoptions warncreateglobal

# Initialize environment variables
# These should be explicitly set by scripts that use this library
# Setting defaults for safety
typeset -g Output_Verbose_Mode=0
typeset -g Output_Quiet_Mode=0
typeset -g Output_Debug_Mode=0
typeset -g Output_Prompt_Enabled=1

# Define TRUE/FALSE constants
typeset -r -g TRUE=1
typeset -r -g FALSE=0

# Exit status constants
typeset -r -g Exit_Status_Success=0
typeset -r -g Exit_Status_General=1
typeset -r -g Exit_Status_Usage=2
typeset -r -g Exit_Status_IO=3
typeset -r -g Exit_Status_Git_Failure=5
typeset -r -g Exit_Status_Config=6
typeset -r -g Exit_Status_Dependency=127

# Initialize terminal formatting codes
# These are used for colored output in various functions
typeset -r -g Term_Black="$(tput setaf 0 2>/dev/null || echo '')"
typeset -r -g Term_Red="$(tput setaf 1 2>/dev/null || echo '')"
typeset -r -g Term_Green="$(tput setaf 2 2>/dev/null || echo '')"
typeset -r -g Term_Yellow="$(tput setaf 3 2>/dev/null || echo '')"
typeset -r -g Term_Blue="$(tput setaf 4 2>/dev/null || echo '')"
typeset -r -g Term_Magenta="$(tput setaf 5 2>/dev/null || echo '')"
typeset -r -g Term_Cyan="$(tput setaf 6 2>/dev/null || echo '')"
typeset -r -g Term_White="$(tput setaf 7 2>/dev/null || echo '')"

# Bright variants
typeset -r -g Term_BrightBlack="$(tput setaf 8 2>/dev/null || echo '')"
typeset -r -g Term_BrightRed="$(tput setaf 9 2>/dev/null || echo '')"
typeset -r -g Term_BrightGreen="$(tput setaf 10 2>/dev/null || echo '')"
typeset -r -g Term_BrightYellow="$(tput setaf 11 2>/dev/null || echo '')"
typeset -r -g Term_BrightBlue="$(tput setaf 12 2>/dev/null || echo '')"
typeset -r -g Term_BrightMagenta="$(tput setaf 13 2>/dev/null || echo '')"
typeset -r -g Term_BrightCyan="$(tput setaf 14 2>/dev/null || echo '')"
typeset -r -g Term_BrightWhite="$(tput setaf 15 2>/dev/null || echo '')"

# Text effects
typeset -r -g Term_Bold="$(tput bold 2>/dev/null || echo '')"
typeset -r -g Term_Underline="$(tput smul 2>/dev/null || echo '')"
typeset -r -g Term_NoUnderline="$(tput rmul 2>/dev/null || echo '')"
typeset -r -g Term_Standout="$(tput smso 2>/dev/null || echo '')"
typeset -r -g Term_NoStandout="$(tput rmso 2>/dev/null || echo '')"
typeset -r -g Term_Dim="$(tput dim 2>/dev/null || echo '')"
typeset -r -g Term_Blink="$(tput blink 2>/dev/null || echo '')"
typeset -r -g Term_Reverse="$(tput rev 2>/dev/null || echo '')"
typeset -r -g Term_Invisible="$(tput invis 2>/dev/null || echo '')"
typeset -r -g Term_Reset="$(tput sgr0 2>/dev/null || echo '')"

#----------------------------------------------------------------------#
# Function: z_Output
#----------------------------------------------------------------------#
# Description:
#   A utility function for formatted output in Zsh scripts. Supports
#   multiple message types, text formatting, emoji, indentation,
#   verbosity levels, and interactive prompts.
#
# Version: 1.0.00 (2025-02-27)
#
# Parameters:
#   $1 - Message type (string): Determines message behavior and visibility
#        Values: print, info, verbose, success, warn, error, debug,
#                vdebug, prompt
#   Remaining parameters - Either message text or Key=Value options
#
# Options (Key=Value):
#   - Color="<ANSI Code>" - Override default message color
#   - Emoji="=9" - Set a custom emoji (default varies by type)
#   - Wrap=<int> - Maximum line width (default: terminal width)
#   - Indent=<int> - Left indentation (enables wrapping)
#   - Force=1 - Overrides quiet mode for all message types
#   - Default="value" - Pre-set response for non-interactive prompts
#
# Returns:
#   0 for standard messages
#   1 for errors
#   2 for invalid message types
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
        "info"    "=�"
        "verbose" "=�"
        "success" ""
        "warn"    "�"
        "error"   "L"
        "debug"   "=�"
        "vdebug"  "="
        "prompt"  "S"
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
# Function: z_Convert_Path_To_Relative
#----------------------------------------------------------------------#
# Description:
#   Converts an absolute path to a relative path from the current directory.
#   If the current directory is the path, returns "./" instead of just "."
#   for improved usability and readability.
#
# Parameters:
#   $1 - Path to convert (string)
#
# Returns:
#   Prints the relative path to stdout
#   Returns 0 on success
#----------------------------------------------------------------------#
function z_Convert_Path_To_Relative() {
    typeset InputPath="${1:?Missing path parameter}"
    
    # Use :A modifier to get absolute path
    typeset AbsolutePath="${InputPath:A}"
    typeset CurrentPath="${PWD:A}"
    
    # If the path is the current directory, return "./" instead of "."
    if [[ "$AbsolutePath" == "$CurrentPath" ]]; then
        print -- "./"
        return 0
    fi
    
    # If the path is a subdirectory of the current directory
    if [[ "$AbsolutePath" == "$CurrentPath"/* ]]; then
        # Remove current directory prefix and leading slash
        print -- "./${AbsolutePath#$CurrentPath/}"
        return 0
    fi
    
    # If the path is a parent directory or elsewhere
    # Get relative path using :P modifier
    typeset RelativePath="${AbsolutePath:P}"
    
    # If the result is just ".", return "./" for consistency
    if [[ "$RelativePath" == "." ]]; then
        print -- "./"
    else
        print -- "$RelativePath"
    fi
    
    return 0
}

#----------------------------------------------------------------------#
# Function: z_Report_Error
#----------------------------------------------------------------------#
# Description:
#   Centralized error reporting with consistent formatting.
#   Uses z_Output when available, falls back to print if needed.
#
# Parameters:
#   $1 - Error message
#   $2 - Optional exit code (defaults to Exit_Status_General)
#
# Returns:
#   Prints error to stderr with consistent formatting
#   Returns specified or default error code
#----------------------------------------------------------------------#
function z_Report_Error() {
    typeset ErrorMessage="${1:?Missing error message parameter}"
    typeset -i ErrorCode="${2:-$Exit_Status_General}"
    
    # Use z_Output if the function is defined and callable
    if typeset -f z_Output >/dev/null; then
        z_Output error "$ErrorMessage" Force=1
    else
        # Fall back to basic error output if z_Output isn't available
        print -u2 "❌ ERROR: $ErrorMessage"
    fi
    
    return $ErrorCode
}

#----------------------------------------------------------------------#
# Function: z_Check_Dependencies
#----------------------------------------------------------------------#
# Description:
#   Checks for the presence of required external commands and tools.
#   This function can verify both mandatory and optional dependencies.
#
# Parameters:
#   $1 - Array name containing command dependencies (required)
#   $2 - Optional array name containing optional commands (not required for success)
#
# Returns:
#   Exit_Status_Success (0) if all required dependencies are available
#   Exit_Status_Dependency (127) if any required dependency is missing
#
# Usage Examples:
#   # Check required dependencies only
#   typeset -a RequiredCmds=("git" "ssh" "tput")
#   z_Check_Dependencies "RequiredCmds" || return $?
#
#   # Check both required and optional dependencies
#   typeset -a RequiredCmds=("git" "ssh")
#   typeset -a OptionalCmds=("gpg" "gh")
#   z_Check_Dependencies "RequiredCmds" "OptionalCmds" || return $?
#----------------------------------------------------------------------#
function z_Check_Dependencies() {
    typeset RequiredArrayName="${1:?Missing required dependencies array parameter}"
    typeset OptionalArrayName="${2:-}"
    
    # Use nameref to access the array by name
    typeset -n RequiredArray="$RequiredArrayName"
    
    typeset -i ErrorCount=0
    typeset Command
    
    # Check required commands
    for Command in "${RequiredArray[@]}"; do
        if ! command -v "$Command" >/dev/null 2>&1; then
            z_Report_Error "Required command not found: $Command"
            (( ErrorCount++ ))
        fi
    done
    
    # If optional array is provided, check those commands too
    if [[ -n "$OptionalArrayName" ]]; then
        typeset -n OptionalArray="$OptionalArrayName"
        
        for Command in "${OptionalArray[@]}"; do
            if ! command -v "$Command" >/dev/null 2>&1; then
                # Just print a warning for optional dependencies
                if typeset -f z_Output >/dev/null; then
                    z_Output warn "Optional command not found: $Command"
                else
                    print -u2 "⚠️ WARNING: Optional command not found: $Command"
                fi
            fi
        done
    fi
    
    # Return appropriate exit status
    if (( ErrorCount > 0 )); then
        return $Exit_Status_Dependency
    fi
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: z_Ensure_Parent_Path_Exists
#----------------------------------------------------------------------#
# Description:
#   Creates parent directories for a given file path if they don't
#   already exist. Useful for ensuring a file can be written to a
#   specific location.
#
# Parameters:
#   $1 - File or directory path whose parent directories should exist
#   $2 - Optional permissions to set on created directories (default: 755)
#
# Returns:
#   Exit_Status_Success (0) if parent directories exist or were created
#   Exit_Status_IO (3) if directory creation fails
#
# Usage Examples:
#   z_Ensure_Parent_Path_Exists "/path/to/file.txt" || return $?
#   z_Ensure_Parent_Path_Exists "/path/to/dir/" 700 || return $?
#----------------------------------------------------------------------#
function z_Ensure_Parent_Path_Exists() {
    typeset TargetPath="${1:?Missing target path parameter}"
    typeset DirPerms="${2:-755}"
    
    # Extract the parent directory path
    typeset ParentDir
    
    # If the path ends with a slash, it's already a directory
    if [[ "$TargetPath" == */ ]]; then
        ParentDir="${TargetPath%/}"
    else
        # Otherwise, get the directory containing the file
        ParentDir="${TargetPath:h}"
    fi
    
    # No need to create anything if parent dir is just '.'
    if [[ "$ParentDir" == "." ]]; then
        return $Exit_Status_Success
    fi
    
    # Create the directory if it doesn't exist
    if [[ ! -d "$ParentDir" ]]; then
        # Use mkdir with -p to create parent directories as needed
        if ! mkdir -p "$ParentDir"; then
            z_Report_Error "Failed to create directory: $ParentDir" $Exit_Status_IO
            return $Exit_Status_IO
        fi
        
        # Set permissions on the created directory
        if ! chmod "$DirPerms" "$ParentDir"; then
            z_Report_Error "Failed to set permissions on directory: $ParentDir" $Exit_Status_IO
            return $Exit_Status_IO
        fi
    fi
    
    # Verify the directory is writable
    if [[ ! -w "$ParentDir" ]]; then
        z_Report_Error "Directory exists but is not writable: $ParentDir" $Exit_Status_IO
        return $Exit_Status_IO
    fi
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: z_Setup_Environment
#----------------------------------------------------------------------#
# Description:
#   Initializes the script environment with safe defaults, verifies
#   required dependencies, and sets up necessary environment variables.
#   This is typically called near the start of a script after setting
#   the basic Zsh options.
#
# Parameters:
#   None - Can be customized by modifying the internal constants if needed
#
# Returns:
#   Exit_Status_Success (0) on successful environment setup
#   Exit_Status_Dependency (127) if environment requirements are not met
#
# Usage Examples:
#   z_Setup_Environment || exit $?
#----------------------------------------------------------------------#
function z_Setup_Environment() {
    # Define minimum required version
    typeset -r RequiredZshMajor=5
    typeset -r RequiredZshMinor=8
    
    # Verify Zsh version first
    function check_Zsh_Version() {
        typeset ZshOutput MinVer
        typeset -i Major=0 Minor=0
        
        ZshOutput="$(zsh --version 2>/dev/null)"
        if [[ -z "$ZshOutput" ]]; then
            z_Report_Error "Failed to get Zsh version"
            return 1
        }
        
        # Extract version numbers using parameter expansion
        MinVer="${ZshOutput#*zsh }"
        MinVer="${MinVer%% *}"
        Major="${MinVer%%.*}"
        Minor="${MinVer#*.}"
        Minor="${Minor%%.*}"  # Handle cases like 5.8.1
        
        if (( Major < RequiredZshMajor || (Major == RequiredZshMajor && Minor < RequiredZshMinor) )); then
            z_Report_Error "Zsh version ${RequiredZshMajor}.${RequiredZshMinor} or later required (found ${Major}.${Minor})"
            return 1
        fi
        return 0
    }
    
    # Check basic command dependencies
    function check_Core_Dependencies() {
        typeset -a RequiredCmds=("printf" "zsh" "tput")
        
        typeset Command
        typeset -i ErrorCount=0
        
        for Command in "${RequiredCmds[@]}"; do
            if ! command -v "${Command}" >/dev/null 2>&1; then
                z_Report_Error "Required command not found: ${Command}"
                (( ErrorCount++ ))
            fi
        done
        
        return $ErrorCount
    }
    
    # Set up terminal capabilities if not already set
    function setup_Terminal_Capabilities() {
        # Only initialize if they aren't already defined
        if [[ -z "$Term_Reset" ]]; then
            # Initialize terminal capabilities
            typeset -g Term_Reset="$(tput sgr0 2>/dev/null || echo '')"
            typeset -g Term_Bold="$(tput bold 2>/dev/null || echo '')"
            typeset -g Term_Red="$(tput setaf 1 2>/dev/null || echo '')"
            typeset -g Term_Green="$(tput setaf 2 2>/dev/null || echo '')"
            typeset -g Term_Yellow="$(tput setaf 3 2>/dev/null || echo '')"
            typeset -g Term_Blue="$(tput setaf 4 2>/dev/null || echo '')"
            typeset -g Term_Magenta="$(tput setaf 5 2>/dev/null || echo '')"
            typeset -g Term_Cyan="$(tput setaf 6 2>/dev/null || echo '')"
        fi
    }
    
    # Run all setup checks
    typeset -i ErrorCount=0
    
    # Check Zsh version
    check_Zsh_Version || (( ErrorCount++ ))
    
    # Check basic dependencies
    check_Core_Dependencies || (( ErrorCount += $? ))
    
    # Set up terminal capabilities
    setup_Terminal_Capabilities
    
    # Initial environment variables with safe defaults
    # Output control flags (only set if not already defined)
    typeset -g Output_Verbose_Mode=${Output_Verbose_Mode:-0}
    typeset -g Output_Quiet_Mode=${Output_Quiet_Mode:-0}
    typeset -g Output_Debug_Mode=${Output_Debug_Mode:-0}
    typeset -g Output_Prompt_Enabled=${Output_Prompt_Enabled:-1}
    
    # Define Script_Running flag if it doesn't exist
    typeset -g Script_Running=${Script_Running:-$TRUE}
    
    # Return appropriate exit status
    if (( ErrorCount > 0 )); then
        return $Exit_Status_Dependency
    fi
    
    return $Exit_Status_Success
}

#----------------------------------------------------------------------#
# Function: z_Cleanup
#----------------------------------------------------------------------#
# Description:
#   Performs cleanup operations when the script exits, handling both
#   successful and error conditions. This function is designed to be
#   registered via a trap to ensure it runs even if the script exits
#   abnormally.
#
# Parameters:
#   $1 - Success flag (boolean) - $TRUE for normal exit, $FALSE for error
#   $2 - Optional error message - Details about an error condition
#
# Returns:
#   Returns the same value as the success flag passed to it
#
# Required Script Variables:
#   Script_Running - Flag to track and prevent recursive script execution
#   TRUE/FALSE - Boolean constants
#
# Usage Example:
#   # In your main script:
#   typeset -g Script_Running=$TRUE
#   trap 'z_Cleanup $FALSE "Script interrupted"' INT TERM
#   trap 'z_Cleanup $TRUE' EXIT
#
#   # For manual cleanup:
#   z_Cleanup $TRUE ""  # Normal successful completion
#   z_Cleanup $FALSE "Script terminated due to error"  # Error condition
#----------------------------------------------------------------------#
function z_Cleanup() {
    typeset Success=${1:?Missing success flag parameter}
    typeset ErrorMsg="${2:-}"
    
    # Prevent recursive execution
    if [[ "$Script_Running" != "$TRUE" ]]; then
        return $Success
    fi
    
    # Reset the script running flag
    typeset -g Script_Running=$FALSE
    
    # Perform any required cleanup actions here
    # This is where you would remove temporary files, release resources, etc.
    
    # Remove temporary files if a pattern is defined
    if [[ -n "${Temp_Files_Pattern:-}" ]]; then
        if typeset -f z_Output >/dev/null; then
            z_Output debug "Cleaning up temporary files matching: $Temp_Files_Pattern"
        fi
        # Use safer -name approach for rm (avoid expanding wildcards too broadly)
        find /tmp -type f -name "$Temp_Files_Pattern" -mmin -60 -delete 2>/dev/null || :
    fi
    
    # Report cleanup status
    if typeset -f z_Output >/dev/null; then
        if (( Success == TRUE )); then
            # On success, report cleanup completion in debug mode
            z_Output debug "Cleanup completed successfully."
        else
            # On failure, use warning type which respects quiet mode
            z_Output warn Emoji="" ""
            z_Output warn "Script terminated with errors. Cleanup completed."
            if [[ -n "$ErrorMsg" ]]; then
                z_Output error "$ErrorMsg"
            fi
        fi
    else
        # Fallback if z_Output function isn't available
        if (( Success != TRUE )) && [[ -n "$ErrorMsg" ]]; then
            print -u2 "ERROR: $ErrorMsg"
        fi
    fi
    
    return $Success
}