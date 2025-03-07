# Repository-Stored Issues Requirements

This document defines the requirements and processes for managing issues as Markdown files stored directly in the repository.

## Overview

This project stores issues as Markdown files within the repository itself, typically in an `issues/` directory. This approach makes issues version-controlled, distributable, and accessible alongside the code they relate to.

## Repository Issues vs. GitHub Issues

### Repository Issues Advantages
- Issues are stored directly within the git repository
- Full version control for issue history
- Issues are available offline and in disconnected environments
- Platform-agnostic (works the same on GitHub, GitLab, local git, etc.)
- AI assistants like Claude can directly access, search, and update issues
- Issues can be branched, merged, and handled like any other file
- Complete project context available in a single git clone

### Repository Issues Limitations
- Less familiar to developers accustomed to platform issue trackers
- No built-in notification system
- Manual linking between issues and PRs
- Less discoverable for new contributors
- Requires custom processes and documentation
- No built-in UI for filtering, sorting, or visualizing issues

### When to Choose Repository Issues
- Projects that need to work across multiple git platforms
- Teams using AI assistance heavily in their workflow
- Projects that prioritize offline or distributed development
- Teams that prefer keeping all project assets in version control
- Projects seeking platform independence
- When complete project context is needed in a single clone

## Issue Management Structure

### Directory Structure

```
project-root/
  ├── issues/
  │   ├── INDEX.md
  │   ├── BUG-[issue-identifier].md
  │   ├── FEATURE-[issue-identifier].md
  │   ├── DOCS-[issue-identifier].md
  │   └── QUESTION-[issue-identifier].md
  └── ...
```

### Issue Identifiers

- Use sequential numbers (e.g., `BUG-001.md`, `FEATURE-007.md`)
- Alternatively, use short descriptor slugs (e.g., `BUG-login-validation.md`)
- Keep identifiers consistent and unique
- Use the INDEX.md file to track issue numbering

## Issue Management Process

### Issue Creation

1. **Create New Issue File**
   - Use appropriate issue type prefix (BUG, FEATURE, DOCS, QUESTION)
   - Assign unique identifier
   - Place in issues/ directory
   - Follow issue template format

2. **Update Issue Index**
   - Add entry to INDEX.md
   - Include title, status, and creation date
   - Assign to person if applicable

3. **Commit Issue**
   - Commit the new issue file and updated index
   - Use descriptive commit message: `Add FEATURE-003: User authentication`

### Issue Tracking

1. **Status Updates**
   - Update status in both issue file and INDEX.md
   - Add dated comments/updates to the issue file
   - Commit changes with clear message: `Update status of BUG-002 to IN PROGRESS`

2. **Assignment**
   - Indicate assignment in issue file header and INDEX.md
   - Update when assignment changes

3. **Cross-referencing**
   - Use file paths to link related issues: `Related to [issues/FEATURE-001.md]`
   - Reference issues in commit messages: `Fix login validation (BUG-002)`
   - Include issue references in PR descriptions

### Issue Resolution

1. **Resolution Process**
   - Update issue with resolution details
   - Change status to RESOLVED or CLOSED
   - Include reference to resolving PR or commit
   - Update INDEX.md status

2. **Final Commit**
   - Commit final status update: `Close FEATURE-003: Implementation complete`
   - If appropriate, move to `issues/closed/` directory

## Issue Templates

### Bug Report Template

```markdown
# BUG-[identifier]: [Brief Title]

## Metadata
- **Status:** OPEN|IN PROGRESS|RESOLVED|CLOSED
- **Created:** YYYY-MM-DD
- **Updated:** YYYY-MM-DD
- **Assigned to:** [Name or username, if any]
- **Priority:** Critical|High|Medium|Low

## Description
A clear, concise description of the bug.

## Steps to Reproduce
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## Expected Behavior
A clear description of what should happen.

## Actual Behavior
A clear description of what actually happens.

## Environment
- OS: [e.g. macOS, Windows, Linux]
- Browser/Version: [if applicable]
- Project Version: [e.g. 1.0.0]

## Additional Context
Any other relevant information, screenshots, etc.

## Updates
- **YYYY-MM-DD**: Initial creation
- **YYYY-MM-DD**: [Update notes]
- **YYYY-MM-DD**: [Update notes]

## Resolution
[To be completed when issue is resolved]
```

### Feature Request Template

```markdown
# FEATURE-[identifier]: [Brief Title]

## Metadata
- **Status:** OPEN|IN PROGRESS|RESOLVED|CLOSED
- **Created:** YYYY-MM-DD
- **Updated:** YYYY-MM-DD
- **Assigned to:** [Name or username, if any]
- **Priority:** High|Medium|Low

## Description
A clear, concise description of the feature being requested.

## Problem Statement
What problem does this feature solve? Why is it needed?

## Proposed Solution
Description of the solution you'd like to see implemented.

## Alternatives Considered
Any alternative solutions or features you've considered.

## Acceptance Criteria
- [ ] Criteria 1
- [ ] Criteria 2
- [ ] Criteria 3

## Additional Context
Any other context, mockups, or examples that help explain the feature.

## Updates
- **YYYY-MM-DD**: Initial creation
- **YYYY-MM-DD**: [Update notes]
- **YYYY-MM-DD**: [Update notes]

## Resolution
[To be completed when feature is implemented]
```

### Documentation Issue Template

```markdown
# DOCS-[identifier]: [Brief Title]

## Metadata
- **Status:** OPEN|IN PROGRESS|RESOLVED|CLOSED
- **Created:** YYYY-MM-DD
- **Updated:** YYYY-MM-DD
- **Assigned to:** [Name or username, if any]
- **Priority:** High|Medium|Low

## Documentation Location
Path or link to the documentation with issues.

## Issue Description
A clear description of what is wrong or missing in the documentation.

## Proposed Changes
Specific suggestions for improving the documentation.

## Additional Context
Any other relevant information.

## Updates
- **YYYY-MM-DD**: Initial creation
- **YYYY-MM-DD**: [Update notes]
- **YYYY-MM-DD**: [Update notes]

## Resolution
[To be completed when documentation is updated]
```

### Question Template

```markdown
# QUESTION-[identifier]: [Brief Title]

## Metadata
- **Status:** OPEN|ANSWERED|CLOSED
- **Created:** YYYY-MM-DD
- **Updated:** YYYY-MM-DD
- **Asked by:** [Name or username]

## Question
Clear, concise question being asked.

## Context
Any context that helps understand the question.

## Attempts Made
What has been tried already to find the answer.

## References
Any relevant references, links, or documentation.

## Updates
- **YYYY-MM-DD**: Initial question
- **YYYY-MM-DD**: [Update notes]
- **YYYY-MM-DD**: [Update notes]

## Answer
[To be completed when question is answered]
```

## Issue Index

The INDEX.md file serves as a central registry of all issues:

```markdown
# Issue Index

Last updated: YYYY-MM-DD

## Open Issues

| ID | Type | Title | Status | Priority | Assigned To | Created | Updated |
|----|------|-------|--------|----------|-------------|---------|---------|
| [BUG-001](BUG-001.md) | Bug | Login validation fails | IN PROGRESS | High | @username | 2023-01-01 | 2023-01-05 |
| [FEATURE-003](FEATURE-003.md) | Feature | User profile page | OPEN | Medium | - | 2023-01-02 | 2023-01-02 |
| [DOCS-002](DOCS-002.md) | Documentation | API reference outdated | OPEN | Low | @username | 2023-01-03 | 2023-01-03 |

## Closed Issues

| ID | Type | Title | Resolution | Closed By | Closed Date |
|----|------|-------|------------|-----------|-------------|
| [BUG-002](closed/BUG-002.md) | Bug | CSS broken on mobile | Fixed in PR #45 | @username | 2023-01-04 |
| [FEATURE-001](closed/FEATURE-001.md) | Feature | User registration | Implemented in v1.2 | @username | 2022-12-15 |
```

## Integration with WORK_STREAM_TASKS.md

1. **Reference Issues in Tasks**
   - Link issues in WORK_STREAM_TASKS.md tasks
   - Format: `- [ ] Task description [BUG-001]`

2. **Update Both Places**
   - When updating task status in WORK_STREAM_TASKS.md, also update the issue file
   - When updating issue files, check if related tasks need updates

3. **Branch Creation**
   - When creating branches for specific issues, use:
   - `feature-issue-001` or `fix-bug-002` naming patterns
   - Reference the issue identifier in the branch name

## PR to Issue Linking

1. **PR Creation**
   - Reference issues in PR descriptions
   - Format: `Fixes BUG-001` or `Implements FEATURE-003`
   - Include links to issue files

2. **PR Description**
   - Include detailed references to specific issue items
   - Reference acceptance criteria from issue file
   - Use the issue's requirements as a checklist

3. **Issue Updates Post-PR**
   - After PR is merged, update issue file with resolution
   - Update INDEX.md status
   - Include PR number and merge date in issue update

## Working with Repository Issues

### Command Line Tools

Consider creating small helper scripts:

1. **Create Issue Script**
   ```bash
   # Example: ./scripts/new-issue.sh bug "Login validation fails"
   # Creates issues/BUG-XXX.md with template and updates INDEX.md
   ```

2. **List Issues Script**
   ```bash
   # Example: ./scripts/list-issues.sh open
   # Lists all open issues from INDEX.md
   ```

3. **Update Status Script**
   ```bash
   # Example: ./scripts/update-issue.sh BUG-001 in-progress @username
   # Updates status and assignment
   ```

### Collaborative Workflows

1. **Issue Discussion**
   - Add updates chronologically in the Updates section
   - Include timestamps and author for each update
   - Use git history to track discussion timeline

2. **Issue Reviews**
   - Request reviews for new issues and major updates
   - Use PR process for collaborative issue refinement when appropriate

## AI Assistance Integration

Repository issues are particularly well-suited for AI assistance:

1. **Claude Access to Context**
   - Claude can directly read and analyze all issues
   - Issues and code changes can be reviewed together
   - AI can suggest links between issues and code

2. **Issue Analysis**
   - AI can help identify duplicate or related issues
   - Claude can suggest categorization and prioritization
   - AI can help draft acceptance criteria

3. **Automated Updates**
   - Claude can assist with updating issue statuses
   - AI can help maintain index consistency
   - AI can suggest issue resolution notes based on PRs

## GitHub Integration Considerations

If using repository issues with GitHub:

1. **README References**
   - Add clear documentation about the issue process
   - Explain repository issues approach in CONTRIBUTING.md
   - Point new contributors to issues/ directory

2. **Maintain Minimal GitHub Issues**
   - Consider disabling GitHub Issues or
   - Use GitHub Issues only for external contributors, then migrate to repository issues
   - Create a standard process for migrating between formats

3. **PR Template References**
   - Include reference format for repository issues in PR template
   - Add example of proper issue referencing
   
## Issue Archiving

1. **When to Archive**
   - After issue is closed and no longer relevant
   - When moving to a new milestone or version
   - During repository cleanup

2. **How to Archive**
   - Move to `issues/closed/` or `issues/archive/` directory
   - Update INDEX.md to reflect archived status
   - Consider periodic archive cleanup for very old issues