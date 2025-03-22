# Z_Utils: Zsh Utility Library - Claude Guidance

> - _created: 2025-03-19_
> - _last-updated: 2025-03-21_
> - _development-model: Team_

This document provides essential guidance for Claude when working with the Z_Utils Zsh utility library project.

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

## Project Setup Process

There are two states for this repository:

1. **Starting state**: No .git folder - user has cloned the toolkit and deleted .git to start fresh
2. **Running state**: When set up as a user's own project with its own Git repository

When a user first runs Claude with this toolkit:
- This repository is now in running state with an active Git repository.
- Refer to PROJECT_GUIDE.md for ongoing work and project management.

<!-- Note for Claude: The repository is now in running state. Initial setup has been completed. -->

### Project Setup Note

This project has been properly set up with:
- An initialized Git repository
- Configured directory structure
- Project documentation
- Development workflows established

For any new development work, refer to PROJECT_GUIDE.md for guidance on the development model and workflow processes.

<!-- Note for Claude: The initial setup has been completed. Always refer to PROJECT_GUIDE.md for ongoing work. -->

## Toolkit Usage

There are two main ways to use this repository:

1. **As a Reference**: Help users understand Claude-assisted development practices
2. **As a Starting Point**: Help users set up new projects based on these files

## Development Model

The current development model for this project is: **_development-model: Team_** (see header metadata)

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

## File Organization
   - `contexts/` - Branch-specific context files
   - `requirements/guides/` - Development workflow guides
   - `scripts/` - Utility scripts for Git and GitHub operations

## Guides and References

For detailed guidance, refer to:
- Development models: `PROJECT_GUIDE.md`
- Task tracking: `requirements/guides/task_tracking_guide.md`
- Context management: `requirements/guides/context_guide.md`
- Git workflow: `requirements/guides/git_workflow_guide.md`

<!-- Note for Claude: When helping users with ongoing project work, ALWAYS refer to the appropriate guide for detailed instructions rather than inventing your own approach. This ensures consistency in development practices. -->