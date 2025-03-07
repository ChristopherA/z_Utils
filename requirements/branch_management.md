# Branch Management Requirements

This document defines the requirements and processes for branch management in this project.

## Overview

This project uses a structured branching model where each feature, enhancement, or fix is developed in a dedicated branch before being merged back to the main branch. This document defines the requirements for creating, managing, and merging branches.

For general Git workflow requirements (including commit signing, DCO sign-off, and other Git processes), refer to [git_workflow.md](git_workflow.md).

## Branch Types

The project utilizes the following branch types:

1. **main**
   - The primary branch containing production-ready code
   - Always stable and deployable
   - Protected from direct commits through GitHub branch protection rules
   - All changes must come through reviewed and approved PRs
   - Requires signed commits and passing status checks

2. **feature branches**
   - Created for developing new features or enhancements
   - Named using the pattern: `feature-[feature-name]`
   - Branch from main, merge back to main when complete
   - Each branch has its own section in WORK_STREAM_TASKS.md

3. **fix branches**
   - Created for bug fixes
   - Named using the pattern: `fix-[issue-identifier]`
   - Branch from main, merge back to main when complete
   - Each branch has its own section in WORK_STREAM_TASKS.md

4. **docs branches**
   - Created for documentation improvements
   - Named using the pattern: `docs-[topic]`
   - Branch from main, merge back to main when complete
   - Each branch has its own section in WORK_STREAM_TASKS.md

## Branch Naming

1. **Format Requirements**
   - Use lowercase letters and hyphens only
   - Start with branch type (feature, fix, docs)
   - Include descriptive name or issue identifier
   - Keep names concise but descriptive

2. **Examples**
   - `feature-user-authentication`
   - `fix-login-validation`
   - `docs-api-reference`

3. **Prohibited Names**
   - Avoid generic names like `update` or `changes`
   - Do not use developer names (e.g., `john-feature`)
   - Avoid temporary names like `temp` or `wip`

## Branch Lifecycle

### 1. Branch Creation

1. **Prerequisites**
   - Ensure main branch is up to date: `git pull origin main`
   - Identify the specific purpose of the branch
   - Check WORK_STREAM_TASKS.md for related tasks

2. **Creation Process**
   - Create new branch from main: `git checkout -b [branch-name] main`
   - Push branch to remote: `git push -u origin [branch-name]`
   - Update WORK_STREAM_TASKS.md with new branch section
   - Create PR to update WORK_STREAM_TASKS.md in main

3. **Branch Context File**
   - Create `config/[branch-name]-CONTEXT.md` for Claude CLI
   - Use `config/branch_context_template.md` as a template
   - Document purpose, challenges, and approach

### 2. Branch Development

1. **Staying Current**
   - Regularly sync with main: `git pull origin main`
   - Resolve conflicts promptly
   - Keep branch focused on its specific purpose

2. **Status Updates**
   - Update WORK_STREAM_TASKS.md as tasks progress
   - Create small PRs for status updates to main
   - Document important decisions and changes

3. **Context Management**
   - Keep branch context file updated
   - Document major decisions in context file
   - Track useful commands in context file

### 3. Branch Completion

1. **Completion Checklist**
   - All tasks completed or explicitly moved to future work
   - Tests passing (if applicable)
   - Documentation updated
   - WORK_STREAM_TASKS.md updated with final status

2. **Merge Preparation**
   - Sync with main one final time
   - Resolve any conflicts
   - Run final tests/checks
   - Review all changes with `git diff main`

3. **Pull Request**
   - Create PR to merge branch into main
   - Include comprehensive description of changes
   - Reference related issues/requirements
   - Request appropriate reviewers

4. **Post-Merge Cleanup**
   - After successful merge, update WORK_STREAM_TASKS.md
   - Move branch section to "Archived Work Streams"
   - Delete branch when appropriate (not required)

## Branch Protection

1. **Main Branch Protection**
   - **CRITICAL:** Main branch MUST be protected via GitHub repository settings
   - Direct pushes to main are completely prohibited, no exceptions
   - All changes to main MUST go through Pull Requests
   - Pull Requests MUST be reviewed and approved before merging
   - All commits MUST be signed with SSH/GPG keys
   - Status checks (CI/tests) MUST pass before merging is allowed
   - Branch protection must be configured immediately after repository creation
   - This applies to ALL changes, including documentation fixes

2. **Branch Protection Configuration**
   - Enable "Require a pull request before merging"
   - Enable "Require approvals" (typically at least 1 reviewer)
   - Enable "Require status checks to pass before merging" 
   - Enable "Require signed commits"
   - Enable "Include administrators" to ensure rules apply to everyone
   - Consider enabling "Require linear history" for cleaner git history

3. **Feature Branch Guidelines**
   - Feature branches are not protected by default
   - Consider branch-specific protection for critical features
   - Always use signed commits regardless of protection

## Conflict Resolution

1. **Handling Merge Conflicts**
   - Resolve conflicts promptly when they occur
   - Prefer resolving on feature branch, not main
   - Document complex conflict resolutions in commit messages

2. **Resolving Process Conflicts**
   - WORK_STREAM_TASKS.md conflicts: preserve all tasks
   - If multiple branches update the same section, reconcile changes
   - When in doubt, consult branch owners

## Branch Synchronization

1. **When to Sync**
   - At the beginning of each work session
   - When main has significant updates
   - Before creating a PR
   - When resolving conflicts

2. **How to Sync**
   ```bash
   git checkout [branch-name]
   git pull origin main
   # Resolve any conflicts
   git push origin [branch-name]
   ```

3. **Conflict Detection**
   - To check for potential conflicts before merging:
   ```bash
   git checkout [branch-name]
   git merge --no-commit --no-ff main
   # Review conflicts, then abort
   git merge --abort
   ```

## Special Branch Scenarios

### Long-running Branches

For branches that will exist for extended periods:

1. **Regular Synchronization**
   - Sync with main at least weekly
   - Consider periodic integration PRs to main

2. **Milestone Planning**
   - Break work into milestones
   - Consider partial merges at milestones
   - Update WORK_STREAM_TASKS.md to reflect milestones

### Emergency Fixes

For critical bug fixes that can't wait for normal process:

1. **Expedited Process**
   - Create fix branch directly from main
   - Implement minimal required changes
   - Fast-track PR review and merge
   - Document as emergency fix in commit message

2. **Post-fix Documentation**
   - Update WORK_STREAM_TASKS.md after the fact
   - Document emergency fix in "Recently Completed" section

## Branch Protection Bootstrapping

In new repositories, there's a bootstrapping challenge: setting up branch protection requires at least one commit to create the main branch. Follow this procedure:

1. Create repository with initial commit
2. Immediately configure branch protection for main before any other work
3. After protection is in place, create feature branches for all work
4. Never commit directly to main after the initial commit