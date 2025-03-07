# main Branch Context

> _created: 2025-03-07 by @ChristopherA_  
> _status: ACTIVE_  
> _purpose: Provide context for Claude CLI sessions working on the main branch_  

## Branch Overview

The `main` branch is the primary branch for the z_Utils project. It contains the stable, production-ready code and documentation that has passed all necessary reviews and tests.

## Current Status

1. **Project initialization:** Project has been initialized with core documents (2025-03-07)
2. **Repository setup:** Git and GitHub repos set up with proper signing and structure (2025-03-07)
3. **Branch structure:** Created docs/initial-requirements branch for requirements work (2025-03-07)
4. **Next steps:** Set up GitHub remote and continue with requirements documentation

## Key Documents

**Core documents:**
- `README.md` - Basic project overview (to be updated with z_Utils specifics)
- `CLAUDE.md` - Guidelines for Claude CLI working with this project
- `WORK_STREAM_TASKS.md` - Master task tracking document for all branches

**Requirements documents:**
- `requirements/git_workflow.md` - Git process requirements
- `requirements/commit_standards.md` - Commit formatting and signing requirements
- `requirements/branch_management.md` - Branch strategy and process
- `requirements/work_stream_management.md` - Work stream management process

## Project Phases

The project is currently in the initial setup phase, focusing on:

1. **Repository infrastructure** - Setting up Git/GitHub properly
2. **Requirements documentation** - Defining z_Utils function requirements
3. **Project organization** - Establishing proper branch structure

## Task Plan Summary

The main branch tasks are organized by categories in WORK_STREAM_TASKS.md:

1. **Repository Setup** - Setting up Git/GitHub infrastructure
2. **Documentation** - Establishing project documentation
3. **Requirements Definition** - Defining requirements for z_Utils
4. **Feature Planning** - Planning the initial function set

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

1. Configure GitHub remote (git remote add origin)
2. Verify remote connection (git push -u origin main)
3. Add LICENSE file to the repository
4. Review and merge work from the docs/initial-requirements branch

## References

- Zsh documentation: https://zsh.sourceforge.io/Doc/
- Open Integrity Project standards for secure development
- Shell scripting best practices