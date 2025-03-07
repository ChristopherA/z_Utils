# main Branch Context

> _created: [DATE] by [AUTHOR]_  
> _Note: Replace [DATE] with current date and [AUTHOR] with your name when using this template_
> _status: ACTIVE_  
> _purpose: Provide context for Claude CLI sessions working on the main branch_  

## Branch Overview

The `main` branch is the primary branch for this project. It contains the stable, production-ready code and documentation that has passed all necessary reviews and tests.

## Current Status

1. **Project initialization:** Project has been initialized with core documents
2. **Documentation:** Core documentation has been established
3. **Development infrastructure:** Basic development infrastructure is in place
4. **Next steps:** Continue implementing tasks as defined in WORK_STREAM_TASKS.md

## Key Documents

**Core documents:**
- `README.md` - Project overview and getting started guide
- `CONTRIBUTING.md` - Guidelines for contributors
- `CODE_OF_CONDUCT.md` - Community code of conduct
- `WORK_STREAM_TASKS.md` - Master task tracking document for all branches

**Requirements documents:**
- `requirements/git_workflow.md` - Git process requirements
- `requirements/commit_standards.md` - Commit formatting and signing requirements
- `requirements/branch_management.md` - Branch strategy and process
- `requirements/[selected issue tracking approach].md` - Issue tracking requirements
- `requirements/pr_process.md` - Pull request process requirements

## Project Phases

The project is currently in the [phase name] phase, focusing on:

1. **[Current focus area 1]**
2. **[Current focus area 2]**
3. **[Current focus area 3]**

## Task Plan Summary

The main branch tasks are organized by categories in WORK_STREAM_TASKS.md:

1. **Core Infrastructure** - Setting up the development infrastructure
2. **Documentation** - Establishing project documentation
3. **Feature Development** - Implementing core features
4. **Testing** - Creating and running tests
5. **Community Building** - Creating community engagement processes

## Special Notes for Claude

1. **Main branch responsibilities:**
   - The main branch should always be stable
   - All merges to main must come through reviewed PRs
   - Documentation in main branch is the single source of truth
   - WORK_STREAM_TASKS.md in main is the authoritative version

2. **Cross-branch coordination:**
   - Main branch WORK_STREAM_TASKS.md maintains sections for all branches
   - Feature branches should regularly sync with main
   - Status updates to WORK_STREAM_TASKS.md should be merged to main regularly

3. **Development approach:**
   - Work directly on main only for minor documentation fixes
   - Create feature branches for all substantive changes
   - Follow the branch creation process when starting new work

## Useful Commands

```bash
# Branch management
git checkout main
git pull origin main
git push origin main

# Check project status
git status
git log --oneline -n 10

# View branches
git branch -a
```

## Next Actions

1. Complete any remaining setup tasks in WORK_STREAM_TASKS.md
2. Review and update requirements documents as needed
3. Create feature branches for upcoming development work

## References

- Project planning documents
- External reference materials
- Community guidelines and standards