#!/usr/bin/env zsh
########################################################################
## Script:        get_repo_did.zsh
## Version:       0.1.00 (2025-03-19)
## Origin:        https://github.com/ChristopherA/z_Utils/blob/main/src/examples/get_repo_did.zsh
## DID:           did:repo:b0c5cd0d85b29543c604c093dd83a1a20eb17af1/blob/main/src/examples/get_repo_did.zsh
## Description:   Retrieves the first commit (Inception Commit) hash of a Git 
##                repository and formats it as a W3C Decentralized Identifier (DID).
## License:       BSD-2-Clause-Patent (https://spdx.org/licenses/BSD-2-Clause-Patent.html)
## Copyright:     (c) 2025 Christopher Allen
## Attribution:   Authored by @ChristopherA <ChristopherA@LifeWithAlacrity.com>
## Usage:         get_repo_did.zsh [-C|--chdir <path>]
## Examples:      get_repo_did.zsh -C /path/to/repo
##                touch "/path/to/repo/$(get_repo_did.zsh -C /path/to/repo)"
## Security:      Git uses SHA-1 for commit identifiers, which has known  
##                cryptographic weaknesses. This DID should only be trusted 
##                when verified through complete audit of the inception commit.
########################################################################

# Reset the shell environment to a known state
emulate -LR zsh

# Safe shell scripting options for strict error handling
setopt errexit nounset pipefail localoptions warncreateglobal

typeset -r Exit_Status_Success=0
typeset -r Exit_Status_General=1
typeset -r Exit_Status_Usage=2

function show_Usage() {
    cat << EOT
Usage: ${0:t} [-C|--chdir <path>]
  -C, --chdir <path>    Path to Git repository (default: current directory)
  -h, --help            Show this help message
EOT
    exit $Exit_Status_Success
}

function get_First_Commit_Hash() {
    typeset RepoPath="$1"
    typeset OriginalDir="$PWD"
    
    cd "$RepoPath" || return $Exit_Status_General
    
    # Verify this is a git repository
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
        print -u2 "Error: Not a git repository: $RepoPath"
        cd "$OriginalDir"
        return $Exit_Status_General
    }
    
    # Get the first commit hash
    typeset FirstCommit
    FirstCommit=$(git rev-list --max-parents=0 HEAD 2>/dev/null | head -n1)
    
    if [[ -z "$FirstCommit" ]]; then
        print -u2 "Error: Could not determine inception commit. Repository may be empty."
        cd "$OriginalDir"
        return $Exit_Status_General
    fi
    
    cd "$OriginalDir"
    print -- "$FirstCommit"
    return $Exit_Status_Success
}

function format_Commit_As_DID() {
    typeset CommitHash="$1"
    
    # Validate commit hash format (should be 40 characters of hex)
    if [[ ! "$CommitHash" =~ ^[0-9a-f]{40}$ ]]; then
        print -u2 "Error: Invalid commit hash format: $CommitHash"
        return $Exit_Status_General
    }
    
    print -- "did:repo:$CommitHash"
    return $Exit_Status_Success
}

function core_Logic() {
    typeset RepoPath="${1:-$PWD}"
    
    # Get the first commit hash
    typeset FirstCommit
    FirstCommit=$(get_First_Commit_Hash "$RepoPath") || return $?
    
    # Format as DID
    format_Commit_As_DID "$FirstCommit"
}

function main() {
    typeset RepoPath="$PWD"
    
    # Parse arguments
    while (( $# > 0 )); do
        case "$1" in
            -C|--chdir)
                [[ -z "$2" || "$2" == -* ]] && {
                    print -u2 "Error: $1 requires a path argument"
                    return $Exit_Status_Usage
                }
                RepoPath="$2"
                shift 2
                ;;
            -h|--help)
                show_Usage
                ;;
            *)
                print -u2 "Error: Unknown option: $1"
                print -u2 "Use --help for usage information"
                return $Exit_Status_Usage
                ;;
        esac
    done
    
    core_Logic "$RepoPath"
}

# Run the main function if executed directly
if [[ "${(%):-%N}" == "$0" ]]; then
    main "$@"
fi