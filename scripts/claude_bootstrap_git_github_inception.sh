#!/bin/bash
# claude_bootstrap_git_github_inception.sh
#
# A comprehensive script to bootstrap a new project with:
# - Local Git repository with proper SSH signing configuration
# - Specialized inception commit establishing a SHA-1 root of trust
# - GitHub remote repository with branch protection
# - Claude Code CLI workflow structure and documentation

set -e

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print a colored message
print_message() {
  local color=$1
  local message=$2
  echo -e "${color}${message}${NC}"
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Validate prerequisites
validate_prerequisites() {
  print_message "$BLUE" "Validating prerequisites..."

  # Check for git
  if ! command_exists git; then
    print_message "$RED" "Error: git is not installed. Please install git and try again."
    exit 1
  fi

  # Check for GitHub CLI
  if ! command_exists gh; then
    print_message "$RED" "Error: GitHub CLI (gh) is not installed. Please install it and try again."
    exit 1
  fi
  
  # Check for jq (needed for GitHub API responses)
  if ! command_exists jq; then
    print_message "$RED" "Error: jq is not installed. Please install jq and try again."
    print_message "$YELLOW" "You can install it with: brew install jq (macOS) or apt install jq (Linux)"
    exit 1
  fi

  # Check git version (needs 2.34.0+ for SSH signing)
  git_version=$(git --version | awk '{print $3}')
  if ! [[ $(echo "$git_version 2.34.0" | awk '{print ($1 >= $2)}') -eq 1 ]]; then
    print_message "$RED" "Error: git version $git_version is too old. Version 2.34.0 or newer is required for SSH signing."
    exit 1
  fi

  # Check GitHub CLI authentication
  if ! gh auth status >/dev/null 2>&1; then
    print_message "$RED" "Error: GitHub CLI is not authenticated. Please run 'gh auth login' and try again."
    exit 1
  fi
  
  # Check git user configuration
  if [[ -z "$(git config --get user.name)" ]]; then
    print_message "$RED" "Error: git user.name is not configured."
    print_message "$YELLOW" "Please set it with: git config --global user.name \"Your Name\""
    exit 1
  fi
  
  if [[ -z "$(git config --get user.email)" ]]; then
    print_message "$RED" "Error: git user.email is not configured."
    print_message "$YELLOW" "Please set it with: git config --global user.email \"your.email@example.com\""
    exit 1
  fi

  # Check for existing SSH signing key configuration
  existing_signing_key=$(git config --get user.signingkey)
  
  if [[ -n "$existing_signing_key" && -f "$existing_signing_key" ]]; then
    print_message "$GREEN" "Found existing SSH signing key: $existing_signing_key"
  # Fall back to checking for standard Ed25519 key
  elif [[ -f ~/.ssh/id_ed25519 ]]; then
    print_message "$GREEN" "Found standard Ed25519 key at ~/.ssh/id_ed25519"
  else
    print_message "$RED" "Error: No SSH signing key found"
    print_message "$YELLOW" "Either:"
    print_message "$YELLOW" "1. Configure git with an existing SSH key: git config --global user.signingkey /path/to/your/key"
    print_message "$YELLOW" "2. Generate a new Ed25519 key: ssh-keygen -t ed25519 -C \"your_email@example.com\""
    print_message "$YELLOW" "For security best practices, we strongly recommend using Ed25519 keys."
    exit 1
  fi
  
  # Check SSH signing configuration
  if [[ "$(git config --get --global gpg.format)" != "ssh" ]]; then
    print_message "$YELLOW" "Warning: Git is not configured to use SSH for signing."
    print_message "$YELLOW" "Will configure git for SSH signing during setup."
  fi
  
  # Check specifically for Ed25519 key in git config
  signing_key=$(git config --get --global user.signingkey)
  if [[ -z "$signing_key" || "$signing_key" != *"id_ed25519"* ]]; then
    print_message "$YELLOW" "Warning: Git signing key is not set to your Ed25519 key."
    print_message "$YELLOW" "Will configure signing key during setup."
  fi
  
  if [[ -z "$(git config --get --global gpg.ssh.allowedSignersFile)" ]]; then
    print_message "$YELLOW" "Warning: Git allowed signers file is not configured."
    print_message "$YELLOW" "Will configure allowed signers file during setup."
  fi
  
  if [[ "$(git config --get --global commit.gpgsign)" != "true" ]]; then
    print_message "$YELLOW" "Warning: Git is not configured to sign commits by default."
    print_message "$YELLOW" "Will enable commit signing during setup."
  fi

  print_message "$GREEN" "All prerequisites validated successfully."
}

# Configure git for SSH signing
configure_git_signing() {
  print_message "$BLUE" "Configuring git for SSH signing..."

  # Check for existing SSH signing key configuration
  local ssh_key_path=$(git config --get user.signingkey)
  
  # If no existing key is configured, try to find an Ed25519 key
  if [[ -z "$ssh_key_path" || ! -f "$ssh_key_path" ]]; then
    if [[ -f ~/.ssh/id_ed25519 ]]; then
      # Use standard Ed25519 key location
      ssh_key_path=~/.ssh/id_ed25519
    else
      # Search for any Ed25519 key in the ~/.ssh directory
      local potential_key=$(find ~/.ssh -type f -name "*ed25519*" | grep -v "\.pub$" | head -1)
      if [[ -n "$potential_key" ]]; then
        ssh_key_path="$potential_key"
      else
        print_message "$RED" "Error: No SSH signing key found"
        print_message "$YELLOW" "Please generate a key with: ssh-keygen -t ed25519 -C \"your.email@example.com\""
        exit 1
      fi
    fi
  fi
  
  print_message "$GREEN" "Using SSH key for signing: $ssh_key_path"

  # Configure git for SSH signing
  git config --global gpg.format ssh
  git config --global user.signingkey "$ssh_key_path"
  git config --global commit.gpgsign true

  # Create allowed signers file if it doesn't exist
  local allowed_signers_dir=~/.config/git
  local allowed_signers_file="$allowed_signers_dir/allowed_signers"
  
  if [[ ! -d "$allowed_signers_dir" ]]; then
    mkdir -p "$allowed_signers_dir"
    chmod 700 "$allowed_signers_dir"
  fi
  
  # Get user email from git config
  local email=$(git config --global user.email)
  local name=$(git config --global user.name)
  
  if [[ -z "$email" || -z "$name" ]]; then
    print_message "$RED" "Error: git user.email or user.name not configured."
    print_message "$YELLOW" "Please set them with:"
    print_message "$YELLOW" "  git config --global user.email \"your.email@example.com\""
    print_message "$YELLOW" "  git config --global user.name \"Your Name\""
    exit 1
  fi
  
  # Create or update allowed signers file
  print_message "$BLUE" "Setting up allowed signers file at $allowed_signers_file..."
  
  # Write to allowed signers file with proper format (email followed by key)
  # Get the corresponding public key path
  local pub_key_path=""
  if [[ "$ssh_key_path" == *".pub" ]]; then
    # If somehow the signing key was set to the public key, use it
    pub_key_path="$ssh_key_path"
  elif [[ -f "${ssh_key_path}.pub" ]]; then
    # Standard format: private key + .pub
    pub_key_path="${ssh_key_path}.pub"
  else
    # Try to find the corresponding public key
    pub_key_path=$(echo "$ssh_key_path" | sed 's/\.[^.]*$/.pub/')
    if [[ ! -f "$pub_key_path" ]]; then
      # Last resort: search for public keys matching the pattern
      local base_name=$(basename "$ssh_key_path")
      local dir_name=$(dirname "$ssh_key_path")
      pub_key_path=$(find "$dir_name" -type f -name "${base_name}*.pub" | head -1)
    fi
  fi
  
  if [[ -z "$pub_key_path" || ! -f "$pub_key_path" ]]; then
    print_message "$YELLOW" "Warning: Could not find public key for $ssh_key_path"
    print_message "$YELLOW" "Will try to use existing allowed_signers file if available"
    
    if [[ -f "$allowed_signers_file" ]]; then
      print_message "$GREEN" "Using existing allowed_signers file: $allowed_signers_file"
    else
      print_message "$RED" "Error: No allowed_signers file exists and could not create one"
      print_message "$YELLOW" "Please manually create $allowed_signers_file with format: \"$email ssh-ed25519 AAAA...\""
      exit 1
    fi
  else
    print_message "$GREEN" "Using public key for allowed signers: $pub_key_path"
    echo -n "$email " > "$allowed_signers_file"
    cat "$pub_key_path" >> "$allowed_signers_file"
    chmod 600 "$allowed_signers_file"
  fi
  
  # Configure git to use the allowed signers file
  git config --global gpg.ssh.allowedSignersFile "$allowed_signers_file"

  # Verify configuration
  print_message "$BLUE" "Verifying SSH signing configuration..."
  if [[ "$(git config --get --global gpg.format)" == "ssh" && \
        "$(git config --get --global user.signingkey)" == "$ssh_key_path" && \
        "$(git config --get --global commit.gpgsign)" == "true" && \
        "$(git config --get --global gpg.ssh.allowedSignersFile)" == "$allowed_signers_file" ]]; then
    print_message "$GREEN" "Git configured successfully for SSH signing."
  else
    print_message "$YELLOW" "Warning: Some git configuration settings may not have been applied correctly."
    print_message "$YELLOW" "Please verify your git configuration with 'git config --global --list | grep gpg'"
  fi
}

# Create and initialize local repository
create_local_repo() {
  local repo_name=$1
  local repo_dir=$2
  
  print_message "$BLUE" "Creating local repository: $repo_name..."
  
  # Create directory if it doesn't exist
  if [[ ! -d "$repo_dir" ]]; then
    mkdir -p "$repo_dir"
  fi
  
  # Initialize git repository
  cd "$repo_dir"
  git init --initial-branch=main
  
  # Get signing key and author information
  local SIGNING_KEY=$(git config --get user.signingkey)
  local GIT_AUTHOR_NAME=$(git config --get user.name)
  local GIT_AUTHOR_EMAIL=$(git config --get user.email)
  local GIT_AUTHOR_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  # Get key fingerprint for committer name
  local GIT_COMMITTER_NAME=$(ssh-keygen -E sha256 -lf "$SIGNING_KEY" | awk '{print $2}')
  local GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
  local GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE"
  
  # Step 1: Create EMPTY inception commit with specialized format (no files)
  print_message "$BLUE" "Creating empty inception commit with SHA-1 root of trust..."
  env GIT_AUTHOR_NAME="$GIT_AUTHOR_NAME" GIT_AUTHOR_EMAIL="$GIT_AUTHOR_EMAIL" \
      GIT_COMMITTER_NAME="$GIT_COMMITTER_NAME" GIT_COMMITTER_EMAIL="$GIT_COMMITTER_EMAIL" \
      GIT_AUTHOR_DATE="$GIT_AUTHOR_DATE" GIT_COMMITTER_DATE="$GIT_COMMITTER_DATE" \
      git -c gpg.format=ssh -c user.signingkey="$SIGNING_KEY" \
        commit --allow-empty --no-edit --gpg-sign \
        -m "Initialize repository and establish a SHA-1 root of trust" \
        -m "This key also certifies future commits' integrity and origin. Other keys can be authorized to add additional commits via the creation of a ./.repo/config/verification/allowed_commit_signers file. This file must initially be signed by this repo's inception key, granting these keys the authority to add future commits to this repo, including the potential to remove the authority of this inception key for future commits. Once established, any changes to ./.repo/config/verification/allowed_commit_signers must be authorized by one of the previously approved signers." --signoff
  
  # Verify the inception commit succeeded
  if [[ $? -eq 0 ]]; then
    print_message "$GREEN" "Empty inception commit created successfully."
    # Create the .repo/config/verification directory
    mkdir -p ./.repo/config/verification
    chmod -R 755 ./.repo
  else
    print_message "$RED" "Error: Failed to create empty inception commit. Check Git configuration."
    exit 1
  fi
  
  # Step 2: Create README.md for second commit
  print_message "$BLUE" "Creating initial repository files..."
  cat > README.md << EOF
# $repo_name

Project description goes here.

## Getting Started

Instructions for getting started with the project.

## Features

- Feature 1
- Feature 2
- Feature 3

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and contribution process.

## License

This project is licensed under the [LICENSE](LICENSE) file in the repository.
EOF

  # Create .gitignore
  cat > .gitignore << EOF
# Compiled output
/dist
/build
/out
/target

# Dependencies
/node_modules
/.pnp
.pnp.js

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE files
/.idea
/.vscode
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Project specific
/untracked
EOF

  # Stage files for second commit
  git add README.md .gitignore
  
  # Create second commit with initial files
  print_message "$BLUE" "Creating second commit with initial project files..."
  git commit -S -s -m "Add initial repository structure with README and .gitignore"
  
  # Verify the second commit succeeded
  if [[ $? -eq 0 ]]; then
    print_message "$GREEN" "Initial file commit created successfully."
  else
    print_message "$RED" "Error: Failed to create initial file commit. Check Git configuration."
    exit 1
  fi

  print_message "$GREEN" "Local repository created successfully."
}

# Create GitHub repository
create_github_repo() {
  local repo_name=$1
  local visibility=$2
  
  print_message "$BLUE" "Creating GitHub repository: $repo_name..."
  
  # Create GitHub repository
  gh repo create "$repo_name" --"$visibility" --source=. --push
  
  print_message "$GREEN" "GitHub repository created successfully."
}

# Configure GitHub branch protection
configure_branch_protection() {
  local repo_owner=$1
  local repo_name=$2
  
  print_message "$BLUE" "Configuring branch protection for $repo_owner/$repo_name..."
  
  # GitHub API call to set up branch protection
  if ! gh api --method PUT "/repos/$repo_owner/$repo_name/branches/main/protection" \
    -f required_status_checks='{"strict":true,"contexts":[]}' \
    -f enforce_admins=true \
    -f required_pull_request_reviews='{"dismissal_restrictions":{},"dismiss_stale_reviews":true,"require_code_owner_reviews":false,"required_approving_review_count":1}' \
    -f restrictions='null' \
    -f required_signatures=true; then
    
    print_message "$YELLOW" "Warning: Could not configure branch protection via API."
    print_message "$YELLOW" "You may need to configure branch protection manually:"
    print_message "$YELLOW" "1. Go to https://github.com/$repo_owner/$repo_name/settings/branches"
    print_message "$YELLOW" "2. Click 'Add branch protection rule'"
    print_message "$YELLOW" "3. Enter 'main' as the branch name pattern"
    print_message "$YELLOW" "4. Check 'Require a pull request before merging'"
    print_message "$YELLOW" "5. Check 'Require signed commits'"
    print_message "$YELLOW" "6. Click 'Create' to save the rule"
    return 1
  fi
  
  print_message "$GREEN" "Branch protection configured successfully."
  return 0
}

# Copy template files to repository
copy_template_files() {
  local repo_dir=$1
  local template_dir="$(dirname "$0")/.."
  
  print_message "$BLUE" "Copying template files to repository..."
  
  # Create core directory structure
  mkdir -p "$repo_dir/requirements"
  mkdir -p "$repo_dir/templates"
  mkdir -p "$repo_dir/context"
  
  # Copy CLAUDE.md
  cp "$template_dir/CLAUDE.md" "$repo_dir/"
  chmod 644 "$repo_dir/CLAUDE.md"
  
  # Copy WORK_STREAM_TASKS.md
  cp "$template_dir/WORK_STREAM_TASKS.md" "$repo_dir/"
  chmod 644 "$repo_dir/WORK_STREAM_TASKS.md"
  
  # Copy requirements files
  cp "$template_dir/requirements/"*.md "$repo_dir/requirements/"
  find "$repo_dir/requirements" -type f -name "*.md" -exec chmod 644 {} \;
  
  # Copy context files
  # First create a main branch context file adapted for the new repository
  cat > "$repo_dir/context/main-CONTEXT.md" << EOF
# main Branch Context

> _created: $(date +"%Y-%m-%d") by $(git config --get user.name)_  
> _status: ACTIVE_  
> _purpose: Provide context for Claude CLI sessions working on the main branch_  

## Branch Overview

The \`main\` branch is the primary branch for this project. It contains the stable, production-ready code and documentation that has passed all necessary reviews and tests.

## Current Status

1. **Project initialization:** Project has been initialized with core documents
2. **Documentation:** Core documentation is being established
3. **Development infrastructure:** Basic development infrastructure is in place
4. **Next steps:** Begin implementing tasks defined in WORK_STREAM_TASKS.md

## Key Documents

**Core documents:**
- \`README.md\` - Project overview and getting started guide
- \`CONTRIBUTING.md\` - Guidelines for contributors (to be created)
- \`CODE_OF_CONDUCT.md\` - Community code of conduct (to be created)
- \`WORK_STREAM_TASKS.md\` - Master task tracking document for all branches

## Special Notes for Claude

1. **Main branch responsibilities:**
   - The main branch should always be stable
   - All merges to main must come through reviewed PRs
   - Documentation in main branch is the single source of truth
   - WORK_STREAM_TASKS.md in main is the authoritative version

2. **Development approach:**
   - Work directly on main only for minor documentation fixes
   - Create feature branches for all substantive changes
   - Follow the branch creation process when starting new work

## Useful Commands

\`\`\`bash
# Branch management
git checkout main
git pull origin main
git push origin main

# Check project status
git status
git log --oneline -n 10

# View branches
git branch -a
\`\`\`

## Next Actions

1. Complete initial setup tasks in WORK_STREAM_TASKS.md
2. Create core documentation files
3. Plan first feature branch
EOF

  # Also copy branch context template to context directory
  cat > "$repo_dir/context/branch_context_template.md" << EOF
# [branch-name] Branch Context

> _created: [DATE] by [AUTHOR]_  
> _Note: Replace [DATE] with current date and [AUTHOR] with your name when using this template_
> _status: DRAFT (not committed to git)_  
> _purpose: Provide context for Claude CLI sessions working on this branch_  

## Branch Overview

The \`[branch-name]\` branch is focused on [brief description of branch purpose]. This branch addresses [specific project goals or requirements].

## Current Status

1. **Branch creation:** [Status of branch creation and setup]
2. **Task planning:** [Status of task planning in WORK_STREAM_TASKS.md]
3. **Initial commit:** [Status of first commit to branch]
4. **Next steps:** [Immediate next actions]

## Key Documents

**Core documents reviewed:**
- [List relevant documents that provide context for this branch's work]
- [Include paths to requirements documents and other critical references]

**Supporting documents:**
- [List any documents created specifically for this branch]
- [Include any templates or scripts specific to this branch's work]

## Branch Challenges

1. **[Challenge Category 1]:** 
   - [Specific challenge or issue]
   - [Another specific challenge or issue]

2. **[Challenge Category 2]:**
   - [Specific challenge or issue]
   - [Another specific challenge or issue]

## Task Plan Summary

The branch work is organized into [X] stages:

1. **[Stage 1 Name]** [Status]
2. **[Stage 2 Name]** [Status]
3. **[Stage 3 Name]** [Status]
4. **[Stage 4 Name]** [Status]

## Special Notes for Claude

1. **Branch specific priorities:**
   - [Priority 1]
   - [Priority 2]
   - [Priority 3]

2. **Cross-branch considerations:**
   - [Consideration 1]
   - [Consideration 2]
   - [Consideration 3]

3. **Development approach:**
   - [Approach guideline 1]
   - [Approach guideline 2]
   - [Approach guideline 3]

## Useful Commands

\`\`\`bash
# Branch management
git checkout [branch-name]
git pull origin main
git push origin [branch-name]

# [Category] commands
[command example 1]
[command example 2]

# [Another category] commands
[command example 1]
[command example 2]
\`\`\`

## Next Actions

1. [Next specific action to take]
2. [Second next action to take]
3. [Third next action to take]

## References

- [Reference 1]
- [Reference 2]
- [Reference 3]
EOF

  # Set proper permissions
  find "$repo_dir/context" -type f -name "*.md" -exec chmod 644 {} \;
  
  # Copy templates directory
  cp -r "$template_dir/templates/"* "$repo_dir/templates/" 2>/dev/null || true
  find "$repo_dir/templates" -type f -name "*.md" -exec chmod 644 {} \; 2>/dev/null || true
  
  # Create .github directory for GitHub templates if it doesn't exist
  if [[ ! -d "$repo_dir/.github" ]]; then
    mkdir -p "$repo_dir/.github/ISSUE_TEMPLATE"
    mkdir -p "$repo_dir/.github/workflows"
    chmod 755 "$repo_dir/.github"
    chmod 755 "$repo_dir/.github/ISSUE_TEMPLATE"
    chmod 755 "$repo_dir/.github/workflows"
  fi
  
  # Ensure all directories have correct permissions
  find "$repo_dir/requirements" "$repo_dir/templates" "$repo_dir/context" -type d -exec chmod 755 {} \;
  
  # Create initial commit with template files
  cd "$repo_dir"
  git add CLAUDE.md WORK_STREAM_TASKS.md requirements/ context/ templates/
  git commit -S -s -m "Add initial project workflow files

- Add CLAUDE.md for Claude CLI guidance and context management
- Add WORK_STREAM_TASKS.md for structured task tracking
- Add requirements/ directory with process definitions
- Add context/ directory with branch context files
- Add templates/ directory for project documentation

These files establish a requirements-driven development process with
clear documentation, branch management, and context preservation for
AI-assisted development using Claude Code CLI."
  
  git push origin main
  
  print_message "$GREEN" "Template files copied successfully."
}

# Main function
main() {
  local repo_name=$1
  local visibility=${2:-"private"} # Default to private if not specified
  
  # Validate input parameters
  if [[ -z "$repo_name" ]]; then
    print_message "$RED" "Error: Repository name is required."
    print_message "$YELLOW" "Usage: $0 <repo-name> [public|private]"
    exit 1
  fi
  
  if [[ "$visibility" != "public" && "$visibility" != "private" ]]; then
    print_message "$RED" "Error: Visibility must be either 'public' or 'private'."
    print_message "$YELLOW" "Usage: $0 <repo-name> [public|private]"
    exit 1
  fi
  
  # Get the full path for the repository directory
  local repo_dir=$(realpath "$repo_name")
  
  # Validate prerequisites
  validate_prerequisites
  
  # Configure git for SSH signing
  configure_git_signing
  
  # Create local repository
  create_local_repo "$repo_name" "$repo_dir"
  
  # Create GitHub repository
  create_github_repo "$repo_name" "$visibility"
  
  # Get GitHub username
  local github_username=$(gh api user | jq -r '.login')
  
  # Configure GitHub branch protection
  if ! configure_branch_protection "$github_username" "$repo_name"; then
    print_message "$YELLOW" "Continuing with repository setup despite branch protection issue."
    print_message "$YELLOW" "You should configure branch protection manually after setup is complete."
  fi
  
  # Copy template files to repository
  copy_template_files "$repo_dir"
  
  print_message "$GREEN" "Repository initialization complete!"
  print_message "$BLUE" "GitHub Repository: https://github.com/$github_username/$repo_name"
  print_message "$BLUE" "Local Repository: $repo_dir"
  print_message "$YELLOW" "Next steps:"
  print_message "$YELLOW" "1. Review and customize README.md"
  print_message "$YELLOW" "2. Review and complete tasks in WORK_STREAM_TASKS.md"
  print_message "$YELLOW" "3. Create your first feature branch"
}

# Call main function with command line arguments
main "$@"