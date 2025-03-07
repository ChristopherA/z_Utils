# Git Workflow Requirements

This document defines the requirements and processes for git workflow in this project.

## Overview

This project uses a structured git workflow to ensure code quality, traceability, and maintainability. All contributors must follow these workflow requirements to maintain project integrity.

## Core Requirements

1. **Signed Commits**
   - All commits MUST be cryptographically signed using Ed25519 SSH keys
   - Use `git commit -S` for all commits
   - Configure git globally or per-repository for automatic signing

2. **Developer Certificate of Origin (DCO)**
   - All commits MUST include a DCO sign-off
   - Use `git commit -s` to add the sign-off automatically
   - This certifies you have the right to submit the code under the project's license

3. **Branch-Based Development**
   - All development work must happen in dedicated branches, not directly on main
   - Branch from main, merge back to main via pull requests
   - Follow branch naming conventions in branch_management.md

4. **Pull Request Review Process**
   - All changes to main must go through pull requests
   - PRs require review and approval before merging
   - Status checks and tests must pass before merging

## Git Configuration

### Required Git Configuration

Configure your git environment with the following settings:

1. **User Information**
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

2. **Signing Configuration**
   ```bash
   # For SSH key signing (recommended)
   git config --global gpg.format ssh
   git config --global user.signingkey ~/.ssh/id_ed25519.pub
   git config --global commit.gpgsign true
   
   # OR for GPG key signing
   git config --global user.signingkey YOUR_GPG_KEY_ID
   git config --global commit.gpgsign true
   ```

3. **SSH Signing Setup**
   - Create and configure SSH allowed signers file
   - Add to git configuration:
   ```bash
   git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
   ```

4. **Core Settings**
   ```bash
   # Configure line ending behavior
   git config --global core.autocrlf input  # for macOS/Linux
   # or
   git config --global core.autocrlf true   # for Windows
   
   # Configure default branch name
   git config --global init.defaultBranch main
   ```

## Daily Git Workflow

### Starting Work

1. **Update Main Branch**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Create or Checkout Feature Branch**
   ```bash
   # Create new branch
   git checkout -b feature-name main
   
   # OR checkout existing branch
   git checkout feature-name
   git pull origin main  # Sync with main
   ```

### During Development

1. **Regular Commits**
   - Make frequent, small, focused commits
   - Always sign commits and include DCO sign-off:
   ```bash
   git commit -S -s -m "Clear commit message"
   ```

2. **Synchronize with Main**
   - Regularly sync feature branch with main:
   ```bash
   git checkout feature-name
   git pull origin main
   # Resolve any conflicts
   git push origin feature-name
   ```

3. **Pushing Changes**
   - Push changes to remote branch:
   ```bash
   git push origin feature-name
   ```

### Code Review and Merge Process

1. **Prepare for Pull Request**
   - Ensure all tests pass locally
   - Review code changes with `git diff main`
   - Update documentation as needed

2. **Create Pull Request**
   - Create PR through GitHub interface or CLI
   - Provide comprehensive description
   - Reference related issues
   - Request appropriate reviewers

3. **Address Review Feedback**
   - Make requested changes
   - Push additional commits to the same branch
   - Use `git commit --amend` only for minor fixes to the most recent commit

4. **Merge Process**
   - Wait for CI checks to pass
   - Ensure required approvals are received
   - Merge via GitHub interface or CLI
   - Delete branch after successful merge (optional)

## Git Best Practices

### Commit Messages

1. **Structure**
   - See detailed requirements in commit_standards.md
   - Short, descriptive title (50 chars or less)
   - Detailed body explaining what and why
   - Reference issues when applicable

2. **Examples**
   ```
   Add user authentication module
   
   - Implement JWT token generation and validation
   - Add user login and registration endpoints
   - Create authentication middleware
   
   This implementation provides secure, stateless authentication
   for the API, addressing the requirements in FEATURE-001.
   ```

### File Management

1. **Large Files**
   - Do not commit large binary files (>5MB)
   - Use external storage or specific git-lfs for large files
   - Add large file patterns to .gitignore

2. **Sensitive Information**
   - Never commit secrets, credentials, or API keys
   - Use environment variables or secret management tools
   - Add sensitive file patterns to .gitignore

### Git Etiquette

1. **Keep Branches Focused**
   - Each branch should address a single feature or fix
   - Don't mix unrelated changes in a single branch
   - Create separate branches for separate concerns

2. **Clean History**
   - Don't rewrite history (rebase/force push) on shared branches
   - Use merge commits to maintain clear history
   - Consider squashing only for very trivial commits

3. **Communication**
   - Write clear commit messages and PR descriptions
   - Update related issues with progress
   - Communicate branch intention in WORK_STREAM_TASKS.md

## Advanced Git Techniques

### Conflict Resolution

1. **Preventing Conflicts**
   - Sync frequently with main
   - Communicate with team on shared files
   - Break large changes into smaller, manageable PRs

2. **Resolving Conflicts**
   ```bash
   git checkout feature-branch
   git pull origin main
   # Resolve conflicts in editor
   git add <resolved-files>
   git commit -S -s -m "Merge main into feature-branch and resolve conflicts"
   git push origin feature-branch
   ```

### Temporary Work Management

1. **Work in Progress**
   - Use git stash for temporary work:
   ```bash
   git stash save "WIP: Description of work"
   git stash list
   git stash apply stash@{0}
   ```

2. **Branch Switching with Changes**
   - Commit or stash changes before switching branches
   - Use `git checkout -m` only when necessary

### History Investigation

1. **Log Viewing**
   ```bash
   # View commit history
   git log --oneline --graph --decorate
   
   # View history for specific file
   git log --follow -p -- path/to/file
   
   # View changes between branches
   git log --oneline main..feature-branch
   ```

2. **Blame and Annotation**
   ```bash
   # See who changed which line and when
   git blame path/to/file
   
   # See change evolution over time
   git log -p path/to/file
   ```

## Git Hooks

Consider implementing git hooks for quality assurance:

1. **Pre-commit Hook**
   - Verify commit message format
   - Run linters and formatters
   - Prevent committing sensitive data
   - Ensure SSH signing is enabled

2. **Pre-push Hook**
   - Run tests before pushing
   - Validate branch naming conventions
   - Check for open issues in WORK_STREAM_TASKS.md

## Troubleshooting

Common git issues and solutions:

1. **Commit Signing Problems**
   - Verify SSH key configuration
   - Check allowed signers file
   - Ensure GPG keys are properly set up

2. **Merge Conflicts**
   - Pull main first, then resolve conflicts
   - Use visual merge tools when available
   - When in doubt, seek help from team members

3. **Accidental Commits**
   - For unstaged changes: `git reset HEAD <file>`
   - For last commit: `git reset --soft HEAD~1`
   - Never use force push on shared branches

## Educational Resources

Recommended resources for improving git skills:

1. **Documentation**
   - [Pro Git Book](https://git-scm.com/book/en/v2)
   - [GitHub Docs](https://docs.github.com/)

2. **Interactive Learning**
   - [Git Branching](https://learngitbranching.js.org/)
   - [GitHub Skills](https://skills.github.com/)