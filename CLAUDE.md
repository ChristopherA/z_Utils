# Claude CLI Agent Guidelines

This document provides essential guidance for the Claude CLI agent when working with this project. It references detailed requirements documents for specific processes.

## Project Overview

This project uses a structured development approach with parallel work streams managed through branches. Each work stream follows a requirements-driven process where tasks are defined based on specific requirements documents.

## Initialization Process

When first starting with a new project using this bootstrap:

1. Begin by asking the user if they have existing files, code, or resources that should be incorporated into the project structure
2. Help the user create or update project-specific documentation (README.md, etc.) with accurate information
3. Guide the user through the initial tasks in WORK_STREAM_TASKS.md, customizing them as needed
4. Suggest repository structure improvements based on the project's specific needs

## Core Files to Reference

Claude should always reference the following files to understand the project context:

1. `WORK_STREAM_TASKS.md` - The primary task tracking document for all branches
2. `requirements/*.md` - All requirement documents for complete process understanding
3. `context/[branch-name]-CONTEXT.md` - Branch-specific context files 
4. `templates/*` - Template files for project documentation (when implementing tasks)

Note: Branch context files in the `context/` directory may contain detailed information about the branch's development history, current status, and planned work. These files are essential for maintaining continuity across Claude sessions.

## Essential Git Workflow Principles

1. **Check repository state before making changes:**
   - Run `git status` to understand current branch and file state
   - Verify you're on the correct branch for the current task

2. **Handle files safely:**
   - Check if files/directories exist before creating them using `test -f` or `test -d`
   - Use `git ls-files <path>` to check if a file is tracked before removal
   - Use `git rm` for tracked files instead of `rm`

3. **Commit approval process (CRITICAL):**
   - ALWAYS request explicit human confirmation before executing any commit
   - Present the commit message for review before committing
   - Never commit automatically or without explicit approval
   - Wait for explicit confirmation before executing the commit command

4. **Commit process:**
   - Review specific commit message requirements in `requirements/commit_standards.md`
   - Always sign commits with SSH/GPG key and add DCO sign-off as required
   - Stage files individually, not in batches
   - Human author must personally review all changes before staging

## Branch Context Management

When starting work on a repository:

1. **First, identify the current branch:**
   ```bash
   git branch --show-current
   ```

2. **Then load the appropriate context file:**
   - For main branch: `context/main-CONTEXT.md` or `config/main-CONTEXT.md`
   - For feature branches: `context/[branch-name]-CONTEXT.md`
   - Convention: Branch context files use hyphenated names (e.g., `feature-name-CONTEXT.md`)

3. **If no context file exists for the current branch:**
   - Suggest creating one based on `config/branch_context_template.md`
   - Example: `cp config/branch_context_template.md context/[branch-name]-CONTEXT.md`

4. **Reference corresponding section in WORK_STREAM_TASKS.md:**
   - Find the branch's section (e.g., `## Branch: [branch-name]`)
   - Focus on uncompleted tasks for that branch
   - Recommend next actions based on task priorities

5. **Update WORK_STREAM_TASKS.md as tasks are completed:**
   - Mark completed tasks with [x] and add completion dates (YYYY-MM-DD)
   - Ensure task updates are committed properly

## Requirements Documents

The actual processes, standards, and workflows are defined in dedicated requirements files. Claude should load and follow these files based on the current task:

- `requirements/git_workflow.md` - Git process requirements
- `requirements/commit_standards.md` - Commit formatting and signing requirements
- `requirements/branch_management.md` - Branch strategy and process
- `requirements/github_issues.md` or `requirements/repository_issues.md` - Issue tracking requirements (as selected by user)
- `requirements/pr_process.md` - Pull request process requirements

## Guidelines for Claude When Working on Tasks

1. **Start with context:**
   - Load ALL requirements documents for complete understanding
   - Check branch context file if available
   - Review WORK_STREAM_TASKS.md for current task status

2. **Follow a methodical approach:**
   - First assess what files need to be modified and their current state
   - Create a plan before making any changes
   - Follow processes defined in the appropriate requirements docs

3. **When in doubt, ask for clarification:**
   - Reference specific requirements or documentation when asking questions
   - Provide options with pros and cons when multiple approaches exist