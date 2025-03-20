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
        "info"    "=¡"
        "verbose" "=Ø"
        "success" ""
        "warn"    " "
        "error"   "L"
        "debug"   "=à"
        "vdebug"  "="
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