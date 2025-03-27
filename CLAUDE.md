# Z_Utils: Zsh Utility Library - Claude Guidance

> - _created: 2025-03-19_
> - _last-updated: 2025-03-27_
> - _development-model: Team_

This document provides essential guidance for Claude when working with the Z_Utils Zsh utility library project.

## Project Overview

Z_Utils is a collection of reusable Zsh utility functions designed to provide consistent, robust, and efficient scripting capabilities. The library includes standardized:

- Output formatting and error handling
- Script environment setup and validation
- Dependency checking
- Path management and cleanup routines

## Repository Structure

This repository contains the Z_Utils Zsh utility library and associated documentation:

- CLAUDE.md - This file with guidance for Claude
- README.md - Documentation about the Z_Utils library
- PROJECT_GUIDE.md - Guide for project state and workflows
- WORK_STREAM_TASKS.md - Task tracking file
- contexts/ - Context management files
- requirements/ - Function specifications and development guidelines
  - project/ - Project-specific requirements
  - shared/ - Shared scripting best practices
  - guides/ - Detailed workflow guides
- scripts/ - Utility scripts for Git operations
- src/ - Source code for the Z_Utils library
  - _Z_Utils.zsh - Main library file
  - examples/ - Example scripts demonstrating usage
  - function_tests/ - Tests for individual functions
  - tests/ - Full regression tests
- untracked/ - Files not included in version control

<!-- Note for Claude: This section helps you understand the overall repository structure. You should familiarize yourself with each component to provide effective assistance. -->

## Development Model

The current development model for this project is: **_development-model: Team_** (see header metadata)

This means:
- Structured branch protection is in place
- Required code reviews and PRs for changes
- Detailed context sharing between team members
- Formal task assignment and tracking

See PROJECT_GUIDE.md for the full description of development models and detailed workflows.

## Quick Reference Commands

Run these commands to check the project status:

```bash
git status                 # Check branch and file status
git branch --show-current  # Show current branch
git log --oneline -n 10    # View recent commit history
```

## Project Session Management

When working on this project:
1. Start development sessions with proper context loading
2. End sessions by updating context files with current progress
3. For long-running tasks, maintain updated context files for easy resumption

## Key Code Locations

- Main library: `src/_Z_Utils.zsh`
- Examples: `src/examples/`
- Function tests: `src/function_tests/`
- Project requirements: `requirements/project/functions/`

## Guides and References

For detailed guidance, refer to:
- Development models: `PROJECT_GUIDE.md`
- Task tracking: `requirements/guides/task_tracking_guide.md`
- Context management: `requirements/guides/context_guide.md`
- Git workflow: `requirements/guides/git_workflow_guide.md`

## Common Development Tasks

### Starting a New Feature

```bash
claude "load CLAUDE.md, create branch feature/[feature-name] from main, and implement [specific functionality]"
```

### Working on Testing

```bash
claude "load CLAUDE.md, identify branch as feature/test-coverage, and implement tests for [specific function]"
```

### Updating Documentation

```bash
claude "load CLAUDE.md, identify branch as docs/[docs-task-name], and update documentation for [specific topic]"
```

### Archiving Completed Contexts

```bash
claude "load CLAUDE.md, verify current branch is main, archive completed context [context-name], and update documentation"
```

### Synchronizing Task Tracking

```bash
claude "load CLAUDE.md, verify current branch is main, synchronize WORK_STREAM_TASKS.md with context changes, and continue work"
```

<!-- Note for Claude: When helping users with ongoing project work, ALWAYS refer to the appropriate guide for detailed instructions rather than inventing your own approach. This ensures consistency in development practices. For context archiving and task synchronization, follow the detailed processes in context_guide.md and task_tracking_guide.md. -->