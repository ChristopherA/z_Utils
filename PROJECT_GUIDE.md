# Z_Utils: Zsh Utility Library - Project Guide

> - _purpose_: Provide project state overview and development workflow
> - _copyright_: ©2025 by @ChristopherA, licensed under the [BSD 2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
> - _created_: 2025-03-19 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>
> - _last-updated_: 2025-03-22 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>

This guide serves as the central reference for development processes for the Z_Utils Zsh utility library.

> **Purpose**: This document provides an overview of project state and workflows.
> For detailed Git operations, context management, and task tracking, follow links to specialized guides.

## Development Models

The toolkit supports two development models:

### Solo Development Model
- **Intended for**: Individual developers, personal projects, prototypes
- **Features**: 
  - Simplified workflows with less ceremony
  - Direct commits to main allowed
  - Reduced PR requirements 
  - Streamlined context management
  - Focus on rapid iteration

### Team Development Model
- **Intended for**: Multi-developer teams, collaborative projects
- **Features**:
  - Structured branch protection
  - Required code reviews and PRs
  - Detailed context sharing between team members
  - Formal task assignment and tracking
  - Enhanced security practices

Z_Utils uses a **Team development model**, which means more structured processes are followed for all changes.

## Working with Claude

### Starting Work

```bash
# Start Claude with project context
claude "load CLAUDE.md, verify current branch is correct, load appropriate context, and continue Z_Utils development"
```

### During Development

Common Claude commands:

```bash
# For continuing work on a branch
claude "load CLAUDE.md, verify current branch is feature/name, and continue working on Z_Utils function X"

# For switching to a new task
claude "load CLAUDE.md, check out branch feature/name, and help me implement Z_Utils function X"

# For troubleshooting issues
claude "load CLAUDE.md, verify current branch is correct, and help me debug the error in Z_Utils function X"
```

## Core Process Reference

### Git Workflow

1. Create a branch for your work
   ```bash
   git checkout -b feature/name
   ```

2. Make changes and commit regularly
   ```bash
   git commit -S -s -m "Clear message"
   ```

3. Create a PR when ready
   ```bash
   git push -u origin feature/name
   gh pr create
   ```

### Context Management

1. Create a context file for each branch
   ```
   contexts/[branch-type]-[branch-name]-context.md
   ```

2. Update the context file:
   - At the start of each session
   - Before using /compact
   - Before ending a session with /exit

3. Use standard format for context files:
   - Current Status
   - Scope Boundaries
   - Completed Work
   - Current Tasks
   - Key Decisions
   - Error Recovery
   - Restart Instructions

### Task Tracking

1. Track all tasks in WORK_STREAM_TASKS.md

2. Organize tasks by:
   - Active Tasks (by category)
   - Branch-specific sections
   - Completed Tasks

3. Update task status with:
   - [ ] Not started
   - [~] In progress (with start date in YYYY-MM-DD format)
   - [x] Completed (with completion date in YYYY-MM-DD format)

## Z_Utils Development Guidelines

### Directory Structure

- `src/_Z_Utils.zsh` - Main library file containing all utility functions
- `src/examples/` - Example scripts demonstrating library usage
- `src/function_tests/` - Individual test scripts for each function
- `src/tests/` - Full regression test suite

### Code Style

1. **Function Documentation**
   - Every function must have a complete header comment
   - Document parameters, return values, and examples
   - Follow the established format in existing functions

2. **Error Handling**
   - Use `z_Report_Error` for consistent error reporting
   - Return appropriate exit status codes
   - Leverage the defined exit status constants

3. **Output Standards**
   - Use `z_Output` for all user-facing messages
   - Respect verbosity settings (`Output_Verbose_Mode`, etc.)
   - Follow established message type conventions

### Testing

1. **Function Tests**
   - Create at least one test script per function
   - Test both success and failure cases
   - Verify correct return values

2. **Example Scripts**
   - Provide usage examples for all major features
   - Keep examples simple and focused
   - Include comments explaining key points

## Special Workflows

### PR Review and Merge Process
```bash
claude "load CLAUDE.md, verify current branch is main, review PR #[number], and merge if approved"
```

### Branch Switching
```bash
claude "load CLAUDE.md, verify current branch is main, switch to branch [branch-name], and continue work"
```

### Work Stream Management
```bash
claude "load CLAUDE.md, verify current branch is main, and organize WORK_STREAM_TASKS.md"
```

### Context Archiving
```bash
claude "load CLAUDE.md, verify current branch is main, archive completed context [context-name], and update documentation"
```

## Specialized Process Guides

This document provides an overview of workflows. For detailed technical procedures, refer to these specialized guides:

- [Git Workflow Guide](./requirements/guides/git_workflow_guide.md) - Complete Git operations reference
- [Context Management Guide](./requirements/guides/context_guide.md) - Detailed context management procedures
- [Task Tracking Guide](./requirements/guides/task_tracking_guide.md) - Comprehensive task organization

> **Note**: Each specialized guide contains technical details and commands that are not duplicated here. 
> This structure keeps the main workflow reference concise while providing detailed technical procedures when needed.