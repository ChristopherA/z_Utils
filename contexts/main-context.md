# Main Branch Context

## Current Status
- Current branch: main
- Started: 2025-03-19
- Progress: Ready for workflow management and branch orchestration

## Branch Protection Notice
**IMPORTANT**: The main branch has protection rules that prevent direct commits. All changes must be made via feature branches and pull requests.

## Main Branch Purpose
The main branch serves as the coordination point for project management and should NOT contain direct development work. Its primary functions are:

1. PR review and merge management
2. Branch orchestration and context switching
3. Work stream task organization and planning

## Active Pull Requests
<!-- List active PRs that need review/merge attention -->
<!-- Example:
- [ ] PR #12: "Add user authentication" - Ready for review
- [~] PR #15: "Fix header styling" - In review (2025-03-15)
-->
<!-- No active PRs at this time -->

## Active Branches
<!-- List active branches with their status -->
- [~] process/update-toolkit - Updating toolkit processes (2025-03-22)
- [ ] docs/project-focus-and-task-organization - Documentation refinement (waiting)
- [ ] feature/function-documentation - Function documentation (planned)
- [ ] feature/test-coverage - Test implementation (planned)
- [ ] feature/modernize-scripts - Script modernization (planned)
- [ ] feature/enhanced-functionality - Enhanced features (planned)
- [ ] feature/ci-cd-setup - CI/CD implementation (planned)

## Available Context Files
<!-- List context files without branches that can be started -->
<!-- No available context files at this time -->

## Completed Contexts
<!-- List context files for completed work that can be archived -->
- [x] docs-import-materials - Completed (2025-03-19)
- [x] cleanup-project-docs-and-structure - Completed (2025-03-21)

## Work Stream Management
- [ ] Review and prioritize items in WORK_STREAM_TASKS.md
- [ ] Create new context files for upcoming work
- [ ] Archive completed context files
- [ ] Update project documentation

## Core Z_Utils Tasks
- [x] Create project README (2025-03-19)
- [x] Set up basic project structure (2025-03-19)
- [x] Define initial architecture (2025-03-19)
- [x] Implement core utility functions (2025-03-19)

<!-- Task format: 
- [ ] Not started
- [~] In progress (with start date in YYYY-MM-DD format)
- [x] Completed (with completion date in YYYY-MM-DD format)
-->

## Key Decisions
- [2025-03-19] Project will follow team development model
- [2025-03-19] Branch protection rules enabled for main branch
- [2025-03-19] All Z_Utils functions maintained in _Z_Utils.zsh file
- [2025-03-22] Process updates from Claude-Code-CLI-Toolkit will be incorporated

## Notes
<!-- Optional section for reference information, diagrams, etc. -->

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