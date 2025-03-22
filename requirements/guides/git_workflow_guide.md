# Git Workflow Quick Reference

> - _did-original-source_: `did:repo:ca85b5ea9bc63cc8229c073d8f6a3faae8062a77/blob/main/requirements/guides/git_workflow_guide.md`
> - _github-original-source_: `https://github.com/ChristopherA/Claude-Code-CLI-Toolkit/blob/main/requirements/guides/git_workflow_guide.md`
> - _purpose_: Provide standard Git commands and workflows for the project
> - _copyright_: ©2025 by @ChristopherA, licensed under the [BSD 2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
> - _created_: 2025-03-19 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>
> - _last-updated_: 2025-03-22 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>

## Essential Git Commands

```bash
# Check status
git status                     # Show current branch and changes
git branch --show-current      # Show only current branch name
git diff --staged              # View staged changes before commit

# Branch operations
git checkout main              # Switch to main branch
git pull                       # Get latest changes
git checkout -b feature/name   # Create new branch
git branch -a                  # List all branches

# Commit workflow
git add file.js                # Stage specific file
git add .                      # Stage all changes (use carefully)
git commit -S -s -m "Message"  # Create signed commit
git push -u origin branch-name # Push new branch
git push                       # Push existing branch
```

<!-- Note for Claude: When helping users with Git operations, always guide them through these specific commands rather than suggesting alternatives that might not follow the project's established practices -->

## Branch Types

| Type | Purpose | Naming | Example |
|------|---------|--------|---------|
| feature | New functionality | feature/name | feature/function-documentation |
| fix | Bug fixes | fix/description | fix/output-format |
| docs | Documentation | docs/area | docs/api-reference |
| process | Workflow improvements | process/area | process/update-toolkit |

## Commit Standards

Every commit must:

1. **Be signed** with SSH/GPG keys using `-S` flag
2. **Include DCO sign-off** using `-s` flag
3. **Follow standard message format** (see below)
4. **Be logically atomic** (one conceptual change per commit)

```bash
git commit -S -s -m "Add user authentication feature" -m "- Implement login form
- Add validation logic"
```

## Commit Message Format

Commit messages MUST follow this format:

```
Add feature X                  # First line: Brief summary in present tense (50 chars max)
                               # Second line: Blank
- Implement login component    # Body: Bullet points of key changes (if needed)
- Add form validation          # Keep each bullet concise and focused
- Create authentication service
```

### Commit Message Requirements

1. **First line must be**:
   - Present tense (Add/Fix/Update, not Added/Fixed/Updated)
   - Maximum 50 characters
   - Descriptive but concise
   - No periods at the end

2. **Body (if needed)**:
   - Separated from summary by blank line
   - Bullet points for complex changes
   - Explain what and why, not how
   - No references to AI assistance

### Logical Atomicity

Commits should represent a single logical change:

1. **Single purpose** - Each commit should do exactly one thing
2. **File cohesion** - Typically involves related files for one feature/fix
3. **Separate unrelated changes** - Create multiple commits for unrelated changes
4. **Reviewable** - Small enough to be easily reviewed

## Standard Workflows

### Feature Development

```bash
# Start feature branch
git checkout main
git pull
git checkout -b feature/function-documentation

# Make changes and commit
git add src/_Z_Utils.zsh
git commit -S -s -m "Add documentation for z_Output function"

# Push and create PR
git push -u origin feature/function-documentation
gh pr create
```

### Bug Fixing

```bash
# Start fix branch
git checkout main
git pull
git checkout -b fix/output-format

# Make changes and commit
git add src/_Z_Utils.zsh
git commit -S -s -m "Fix output formatting in z_Output"

# Push and create PR
git push -u origin fix/output-format
gh pr create
```

### Documentation Updates

```bash
# Start docs branch
git checkout main
git pull
git checkout -b docs/function-usage

# Make changes and commit
git add docs/function-usage.md
git commit -S -s -m "Add function usage documentation"

# Push and create PR
git push -u origin docs/function-usage
gh pr create
```

### Process Updates

```bash
# Start process branch
git checkout main
git pull
git checkout -b process/update-workflow

# Make changes and commit
git add requirements/guides/*.md
git commit -S -s -m "Update workflow process documentation"

# Push and create PR
git push -u origin process/update-workflow
gh pr create
```

## Pull Request Process

1. **Prepare PR**
   - Make sure all tests pass
   - Update documentation if needed

2. **Create PR**
   ```bash
   # Create PR with template
   gh pr create --title "Add login feature" --body-file .github/PULL_REQUEST_TEMPLATE.md
   
   # Alternative: Create PR with inline description
   gh pr create --title "Add login feature" \
     --body "Implements user login with form validation"
   ```

3. **PR Template**
   ```
   ## Summary
   Brief description of the change
   
   ## Changes
   - Change 1
   - Change 2
   - Change 3
   
   ## Motivation
   Why this change was needed
   
   ## Testing
   - Test scenario 1
   - Test scenario 2
   - All unit tests passing
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation
   - [ ] Code improvement
   
   ## Checklist
   - [ ] Tests pass
   - [ ] Documentation updated (if needed)
   - [ ] Code follows project style
   ```

   When creating PRs:
   - Check applicable "Type of Change" boxes that reflect your PR's purpose
   - Leave "Checklist" items unchecked - these will be checked during review

## Safety Tips

- Always check which branch you're on before making changes
- Review changes before committing (`git diff --staged`)
- Never force push to main branch
- Keep commits focused on single logical changes
- Write descriptive commit messages
- Test changes before pushing

<!-- Note for Claude: When helping users with Git operations, emphasize these safety practices, especially verifying the current branch and reviewing changes before committing -->

## Special Workflows

### Urgent Main Branch Changes

When branch protection prevents direct commits to main:

```bash
# 1. Create a temporary fix branch
git checkout main
git pull
git checkout -b fix/urgent-hotfix

# 2. Make the necessary changes
git add path/to/files
git commit -S -s -m "Fix urgent issue X"

# 3. Create a temporary PR
git push -u origin fix/urgent-hotfix
gh pr create --title "URGENT: Fix issue X" --body "Critical fix that needs immediate attention"

# 4. Request admin review for expedited merge
# Note: Only repository admins can bypass branch protection rules

# 5. After merge, clean up
git checkout main
git pull
git branch -D fix/urgent-hotfix
```

Key points for urgent changes:
- Always use a branch, even for small changes
- Clearly mark PRs as urgent in the title
- Use the same signing and review standards
- Request admin override only when truly necessary
- Document the emergency process in the PR

### PR Approval and Admin Merge

For PRs requiring admin override of branch protection:

```bash
# Approve the PR (if not your own)
gh pr review <PR-NUMBER> --approve

# Merge with admin override
gh pr merge <PR-NUMBER> --admin --merge

# Verify merge and clean up
git checkout main
git pull
git branch -D feature/branch-name
```

Important notes:
- Use admin merge ONLY when necessary and authorized
- Cannot approve your own PRs (will receive error)
- Document the reason for admin override in PR comments

### Checking PR Status

```bash
# View PR details
gh pr view <PR-NUMBER>

# List all open PRs
gh pr list
```

### Z_Utils-Specific Workflows

When working with Z_Utils, consider these specific approaches:

1. **Function Documentation**:
   ```bash
   git checkout -b feature/function-documentation
   # Add documentation to _Z_Utils.zsh and commit
   ```

2. **Test Development**:
   ```bash
   git checkout -b feature/test-coverage
   # Create test file in src/function_tests/ and commit
   ```

3. **Script Modernization**:
   ```bash
   git checkout -b feature/modernize-scripts
   # Update scripts and commit
   ```

This guidance helps maintain consistency across the Z_Utils codebase and ensures proper organization of feature development.

<!-- Note for Claude: The special workflows section is particularly important for Team development models, but less critical for Solo development. Adjust your guidance based on the project's development model. -->