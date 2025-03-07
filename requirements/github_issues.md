# GitHub Issues Requirements

This document defines the requirements and processes for managing issues using GitHub's built-in Issues system.

## Overview

This project uses GitHub Issues for tracking bugs, feature requests, enhancements, and other tasks. This approach leverages GitHub's integrated tools for issue management, notifications, and workflow automation.

## GitHub Issues vs. Repository-Stored Issues

### GitHub Issues Advantages
- Well understood by the broader developer community
- Integrated with GitHub's interface, search, and filtering tools
- Built-in notification system for team members
- Seamless integration with PRs and GitHub project boards
- Better visibility and discoverability for new contributors
- No custom tooling required

### GitHub Issues Limitations
- Limited access for AI assistants like Claude (can't directly read or search issues)
- Platform-dependent (tied to GitHub specifically)
- Not available in offline or disconnected environments
- Not easily portable to other git platforms (GitLab, Bitbucket, etc.)
- Not included in git clones, requiring separate access

### When to Choose GitHub Issues
- Projects primarily or exclusively hosted on GitHub
- Open source projects with many external contributors
- Teams already familiar with GitHub's workflow
- Projects prioritizing low friction for new contributors
- When integration with GitHub's other features is important

## Issue Management Process

### Issue Creation

1. **Required Information**
   - Clear, descriptive title
   - Detailed description of the issue
   - Steps to reproduce (for bugs)
   - Expected vs. actual behavior (for bugs)
   - Screenshots or error messages (if applicable)
   - Environment information (if applicable)

2. **Issue Templates**
   - Bug Report template
   - Feature Request template
   - Documentation Issue template
   - General Question template

3. **Labels**
   - Apply appropriate labels for categorization
   - Use labels for priority, type, status, etc.
   - Do not use too many labels (aim for 3-5 per issue)

### Issue Tracking

1. **Status Updates**
   - Update issue status with comments
   - Use GitHub project boards for visual status tracking
   - Link to relevant PRs or commits

2. **Assignment**
   - Assign issues to specific individuals
   - Set milestone if applicable
   - Indicate priority

3. **Cross-referencing**
   - Link related issues
   - Reference issues in commits using `#issue-number`
   - Link PRs to issues using GitHub keywords

### Issue Resolution

1. **Resolution Process**
   - Verify issue is fixed with testing
   - Link to PR that resolves the issue
   - Close issue with appropriate comment

2. **Keywords**
   - Use GitHub keywords in PR descriptions:
   - "Fixes #123" - Automatically closes issue when PR is merged
   - "Resolves #123" - Automatically closes issue when PR is merged
   - "Closes #123" - Automatically closes issue when PR is merged
   - "Relates to #123" - Creates a reference without closing

## Issue Types

1. **Bug Reports**
   - Description of the bug
   - Steps to reproduce
   - Expected vs. actual behavior
   - Environment information
   - Priority level

2. **Feature Requests**
   - Description of the requested feature
   - Rationale/use case
   - Acceptance criteria
   - Priority level

3. **Documentation Issues**
   - Description of documentation problem
   - Suggested improvements
   - References to relevant documentation
   - Priority level

4. **Questions/Discussions**
   - Clear question or topic for discussion
   - Context information
   - References to relevant code or documentation

## GitHub Issue Configuration

### Issue Templates

Configure the following issue templates in `.github/ISSUE_TEMPLATE/`:

1. **Bug Report Template**
```markdown
---
name: Bug Report
about: Report a bug to help us improve
title: 'Bug: '
labels: bug
assignees: ''
---

**Description**
A clear and concise description of the bug.

**Steps to Reproduce**
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected Behavior**
A clear and concise description of what you expected to happen.

**Actual Behavior**
A clear and concise description of what actually happened.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment:**
 - OS: [e.g. macOS, Windows, Linux]
 - Browser/Version: [e.g. Chrome 91, Firefox 89]
 - Project Version: [e.g. 1.0.0]

**Additional Context**
Add any other context about the problem here.
```

2. **Feature Request Template**
```markdown
---
name: Feature Request
about: Suggest an idea for this project
title: 'Feature: '
labels: enhancement
assignees: ''
---

**Is your feature request related to a problem? Please describe.**
A clear and concise description of what the problem is. E.g., I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Acceptance Criteria**
List the requirements that must be met for this feature to be considered complete.
- [ ] Requirement 1
- [ ] Requirement 2
- [ ] Requirement 3

**Additional context**
Add any other context or screenshots about the feature request here.
```

3. **Documentation Issue Template**
```markdown
---
name: Documentation Issue
about: Report issues with documentation or suggest improvements
title: 'Docs: '
labels: documentation
assignees: ''
---

**Which documentation has issues?**
Provide links or paths to the documentation with issues.

**What is the issue with the documentation?**
A clear and concise description of what is wrong or missing.

**Suggested improvements**
If you have specific suggestions for improvement, please describe them here.

**Additional context**
Add any other context about the documentation issue here.
```

4. **Question Template**
```markdown
---
name: Question
about: Ask a question about the project
title: 'Question: '
labels: question
assignees: ''
---

**Your Question**
A clear and concise question.

**Context**
Any context that might help others understand or answer your question.

**What you've tried already**
Describe what you've already tried to find the answer.

**References**
Links to related documentation, code, or other resources.
```

### GitHub Labels

Configure the following labels in the repository:

1. **Type Labels**
   - `bug` - Something isn't working
   - `enhancement` - New feature or request
   - `documentation` - Improvements or additions to documentation
   - `question` - Further information is requested
   - `refactor` - Code change that neither fixes a bug nor adds a feature
   - `test` - Adding missing tests or correcting existing tests

2. **Priority Labels**
   - `priority: critical` - Must be fixed as soon as possible
   - `priority: high` - Should be fixed in the next iteration
   - `priority: medium` - Should be fixed soon
   - `priority: low` - Nice to have

3. **Status Labels**
   - `status: confirmed` - Issue has been confirmed
   - `status: in progress` - Work has started on this issue
   - `status: needs review` - Issue needs review
   - `status: duplicate` - This issue already exists
   - `status: wontfix` - This issue won't be fixed
   - `good first issue` - Good for newcomers

## Integration with WORK_STREAM_TASKS.md

1. **Reference Issues in Tasks**
   - Link GitHub issues in WORK_STREAM_TASKS.md tasks
   - Format: `- [ ] Task description [#123]`

2. **Update Issues from Tasks**
   - When updating task status in WORK_STREAM_TASKS.md, also update the linked GitHub issue
   - Include links to PRs in both the issue and WORK_STREAM_TASKS.md

3. **Branch Creation**
   - When creating branches for specific issues, use:
   - `feature-issue-123` or `fix-issue-123` naming pattern
   - Reference the issue number in the branch name when applicable

## PR to Issue Linking

1. **PR Creation**
   - Link PRs to issues using GitHub keywords:
   - `Fixes #123`
   - `Resolves #123`
   - `Closes #123`
   - `Addresses #123` (references without closing)

2. **PR Description**
   - Include links to relevant issues
   - Describe how the PR addresses the issue
   - Use the issue's acceptance criteria as a checklist

## GitHub Project Configuration

1. **Project Board Setup**
   - Create a project board for tracking issues
   - Configure automated workflows
   - Set up columns for To Do, In Progress, Review, and Done

2. **Project Board Automation**
   - "To Do": New issues
   - "In Progress": Issues with assigned developers or "status: in progress" label
   - "Review": PRs that address issues
   - "Done": Closed issues

## AI Assistance Considerations

When using GitHub Issues with Claude or other AI assistants:

1. **Issue Summaries in Branch Context**
   - Include key issue details in `config/[branch-name]-CONTEXT.md`
   - Copy relevant issue descriptions, requirements, and context
   - Update branch context file when major issue details change

2. **Issue References in WORK_STREAM_TASKS.md**
   - When referencing GitHub issues, include enough context for Claude
   - Consider adding short summaries: `- [ ] Implement user authentication [#123: Add OAuth login]`

3. **Update Documentation for AI Review**
   - For issues involving substantial design decisions, update requirements docs
   - This ensures Claude can access the complete context when reviewing related PRs