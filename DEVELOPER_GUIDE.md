# Z_Utils: Zsh Utility Library - Project Guide

> - _purpose_: Provide project state overview and development workflow
> - _copyright_: ©2025 by @ChristopherA, licensed under the [BSD 2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html)
> - _created_: 2025-03-19 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>
> - _last-updated_: 2025-03-22 by @ChristopherA <ChristopherA@LifeWithAlacrity.com>

This guide serves as the central reference for development processes for the Z_Utils Zsh utility library.

> **Purpose**: This document provides developers with an overview of project state and workflows.
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

Claude supports both traditional explicit commands ("ceremonial pattern") and more natural conversational language ("natural language pattern") for all operations.

### Starting Work

**Explicit Command Pattern:**
```bash
# Start Claude with project context - explicit command
claude "load CLAUDE.md, verify current branch is correct, load appropriate context, and continue Z_Utils development"
```

**Natural Language Pattern:**
```bash
# Start Claude with project context - natural language
claude "our project is Z_Utils development, let's continue where we left off"
```

### During Development

Common Claude commands shown in both patterns:

**Working on a Feature:**

```bash
# Explicit Command Pattern:
claude "load CLAUDE.md, verify current branch is feature/name, and continue working on Z_Utils function X"

# Natural Language Pattern:
claude "our project is implementing function X, let's continue the development"
```

**Switching Tasks:**

```bash
# Explicit Command Pattern:
claude "load CLAUDE.md, check out branch feature/name, and help me implement Z_Utils function X"

# Natural Language Pattern:
claude "I need to implement function X in Z_Utils, help me switch to the right branch and start coding"
```

**Troubleshooting:**

```bash
# Explicit Command Pattern:
claude "load CLAUDE.md, verify current branch is correct, and help me debug the error in Z_Utils function X"

# Natural Language Pattern:
claude "help me debug this error in Z_Utils function X"
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

### Repository Structure

This repository is organized with a clear separation of code, documentation, and process management files:

#### Core Files
- `CLAUDE.md` - Process frameworks and Claude-specific instructions
- `DEVELOPER_GUIDE.md` - This file with development workflows and guidelines
- `README.md` - Overview documentation about the Z_Utils library
- `WORK_STREAM_TASKS.md` - Task tracking and work stream management

#### Documentation Directories
- `contexts/` - Context management files
  - `futures/` - Future feature contexts
  - `archived.md` - Archived context information
- `requirements/` - Function specifications and development guidelines
  - `project/` - Project-specific requirements
  - `shared/` - Shared scripting best practices
  - `guides/` - Detailed workflow guides

#### Source Code
- `src/_Z_Utils.zsh` - Main library file containing all utility functions
- `src/examples/` - Example scripts demonstrating library usage
- `src/function_tests/` - Individual test scripts for each function
- `src/tests/` - Full regression test suite

#### Non-tracked Directories
- `untracked/` - Files not included in version control
  - Used for experimental code, local configurations, etc.
  - Perfect for development-only scripts and temporary files

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

Each workflow can be invoked using either explicit commands or natural language patterns.

### PR Review and Merge Process

**Explicit Command Pattern:**
```bash
claude "load CLAUDE.md, verify current branch is main, review PR #[number], and merge if approved"
```

**Natural Language Pattern:**
```bash
claude "help me review PR #[number], I need to understand if it's ready to merge"
```

### Branch Switching

**Explicit Command Pattern:**
```bash
claude "load CLAUDE.md, verify current branch is main, switch to branch [branch-name], and continue work"
```

**Natural Language Pattern:**
```bash
claude "I need to work on [branch-name] now, help me switch to that branch and continue"
```

### Work Stream Management

**Explicit Command Pattern:**
```bash
claude "load CLAUDE.md, verify current branch is main, and organize WORK_STREAM_TASKS.md"
```

**Natural Language Pattern:**
```bash
claude "our task tracking needs updating, help me organize the work stream tasks"
```

### Context Archiving

**Explicit Command Pattern:**
```bash
claude "load CLAUDE.md, verify current branch is main, archive completed context [context-name], and update documentation"
```

**Natural Language Pattern:**
```bash
claude "our work on [context-name] is complete, help me archive this context properly"
```

## Understanding Natural Language Patterns

The project now supports natural language interaction patterns that make working with Claude more intuitive. Instead of memorizing exact command structures, you can express your intent in more conversational language.

### Key Natural Language Patterns

1. **Goal Expression**: Start with "our project is..." to set the context
   ```bash
   claude "our project is implementing error handling in Z_Utils"
   ```

2. **Action Initiation**: Use phrases like "let's..." to indicate what you want to do
   ```bash
   claude "let's continue working on the output formatting functions"
   ```

3. **Need Expression**: Start with "I need to..." for specific task requests
   ```bash
   claude "I need to debug this error in the path handling function"
   ```

4. **Help Requests**: Use "help me..." for assistance with specific tasks
   ```bash
   claude "help me understand how this function works"
   ```

For more details on how Claude processes these commands, refer to the process frameworks in CLAUDE.md.

## Specialized Process Guides

This document provides an overview of workflows. For detailed technical procedures, refer to these specialized guides:

- [CLAUDE.md](./CLAUDE.md) - Process frameworks and Claude-specific information
- [Git Workflow Guide](./requirements/guides/git_workflow_guide.md) - Complete Git operations reference
- [Context Management Guide](./requirements/guides/context_guide.md) - Detailed context management procedures
- [Task Tracking Guide](./requirements/guides/task_tracking_guide.md) - Comprehensive task organization

> **Note**: CLAUDE.md contains the technical process frameworks that Claude uses to interpret commands and manage project workflows. While developers should generally refer to this DEVELOPER_GUIDE.md, CLAUDE.md provides deeper insights into Claude's behavior if needed.