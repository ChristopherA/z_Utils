# Commit Standards

This document defines the standards and requirements for creating commits in this project.

## Overview

All commits in this project must follow these standards to ensure consistency, traceability, and security. These standards apply to all branches and all contributors.

## Core Requirements

1. **Cryptographic Signing**
   - All commits MUST be cryptographically signed using Ed25519 SSH keys
   - Use `git commit -S` for all commits
   - Configure git globally or per-repository for automatic signing

2. **Developer Certificate of Origin (DCO)**
   - All commits MUST include a DCO sign-off
   - Use `git commit -s` to add the sign-off automatically
   - This certifies you have the right to submit the code under the project's license

3. **Atomic Commits**
   - Each commit should represent a single logical change
   - Prefer smaller, focused commits over large, multi-purpose commits
   - One specific change or fix per commit

4. **Clear and Descriptive Messages**
   - Follow the commit message format defined below
   - Be specific about what changed and why
   - Make messages understandable without requiring context

## Commit Message Format

All commit messages must follow this structure:

```
Subject line (50 chars or less)

- Bullet point describing specific change
- Another specific change
- Third specific change

Paragraph providing context and explaining rationale
behind the changes. This explains WHY the changes
were needed, not just what was changed.

Co-authored-by: Name <email> (if applicable)
```

### Subject Line Requirements

1. Start with a capitalized verb in imperative mood (Add, Fix, Update, Remove, etc.)
2. Keep to 50 characters or less
3. Do not end with a period
4. Be specific about what component or area is affected
5. Provide a concise summary of the change

### Examples:

✅ **Good subject lines:**
- `Add SSH key verification to pre-commit hook`
- `Fix buffer overflow in parsing routine`
- `Update documentation for API endpoints`
- `Refactor authentication module for better performance`

❌ **Poor subject lines:**
- `Fixed bug` (too vague)
- `Updated code to make it better and fixed some bugs along the way` (too long and unfocused)
- `WIP` (non-descriptive)
- `Adding a new feature for users to be able to reset their passwords through email verification` (too long)

## Handling Quoting in Commit Messages

When your commit message needs to contain quotes:

1. **For messages with double quotes:**
   - Use single quotes for the entire message
   ```
   git commit -S -s -m 'Update "Error Handling" section in docs'
   ```

2. **For messages with single quotes:**
   - Use double quotes for the entire message
   ```
   git commit -S -s -m "Fix issue with user's input validation"
   ```

3. **For complex messages with both types of quotes:**
   - Use a heredoc format
   ```
   git commit -S -s -m "$(cat <<'EOF'
   Add "Quote Handling" to user's guide

   - Document proper handling of both 'single' and "double" quotes
   - Fix formatting issues in code samples
   - Add examples for shell scripting

   These changes improve documentation clarity for users working with
   text that contains quotation marks of various types.
   EOF
   )"
   ```

## File-Specific Commits

When implementing changes that span multiple files:

1. If the changes are part of a single logical unit, they can be committed together
2. If the changes address different concerns, create separate commits for each logical unit
3. When implementing architectural changes, create separate commits for each file when possible

## Staging Process

The staging process is critical for creating proper commits:

1. **Never stage files in batches:**
   - Always use `git add <single-file>` for each file separately
   - Never use `git add .` or similar wildcards
   - Exception: test scripts and their output files can be staged together

2. **Review before staging:**
   - Use `git diff <file>` to review changes before staging
   - **CRITICAL:** The human author must personally review all changes
   - AI tools may assist with changes, but cannot perform the final review

3. **Only stage intended changes:**
   - Avoid staging unrelated changes or debug code
   - Use `git add -p` for partial file staging if needed
   - Be cautious about whitespace and formatting changes

## Commit Approval and Sign-off Process

For each commit:

1. **Human approval requirement (CRITICAL)**
   - ALWAYS obtain explicit human confirmation before executing any commit
   - Present the full commit message for review before committing
   - Never execute a commit command without explicit human approval
   - Wait for clear confirmation before proceeding with the commit
   - For Claude and other AI tools: always pause and request explicit permission

2. **Configure Ed25519 SSH signing**
   - Set up an Ed25519 SSH key for signing
   - Configure `gpg.format` to "ssh" for SSH signing
   - Configure `user.signingKey` to point to your Ed25519 public key
   - Set `commit.gpgsign` to true for automatic signing
   - Configure your allowed signers file

3. **Add sign-off certification**
   - Use `-s` flag to add DCO sign-off
   - This adds your name and email as a signed certification

4. **Create the commit (only after human approval)**
   - Always use both flags: `git commit -S -s -m "Your message"`
   - Verify the commit is signed with `git log --show-signature`

## Pre-Commit Review Requirements

Before committing:

1. **Run appropriate quality checks:**
   - Execute linters if configured
   - Run tests that are relevant to the changes
   - Verify formatting meets project standards

2. **Review the changes:**
   - The author must personally review all changes before staging
   - Ensure changes meet requirements and coding standards
   - Verify all changes are intentional (no debug code, comments, etc.)

## Special Commit Types

### Merge Commits

Merge commits should clearly indicate:
1. Which branch is being merged
2. The purpose of the merge
3. Any conflict resolution strategies used

Example: `Merge feature-branch into main`

### Revert Commits

When reverting previous changes:
1. Use `git revert` to create a proper revert commit
2. Include the original commit hash in the message
3. Explain why the revert is necessary

Example: `Revert "Add feature X" (abc1234)`

## Common Issues and Solutions

1. **Forgot to sign a commit:**
   ```
   git commit --amend -S -s --no-edit
   ```

2. **Committed to the wrong branch:**
   ```
   git reset HEAD~1
   git stash
   git checkout correct-branch
   git stash pop
   # Then create properly signed commit
   ```

3. **Need to update the most recent commit:**
   ```
   git add <file>
   git commit --amend -S -s
   ```

4. **Need to split a commit:**
   ```
   git reset HEAD~1
   # Stage and commit files individually
   ```

## Verification

To verify a commit's signature:
```
git log --show-signature
```

To verify DCO sign-off:
```
git log --show-signature | grep "Signed-off-by"
```