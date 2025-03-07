# main Branch Context

> _created: 2025-03-07 by @ChristopherA_  
> _status: ACTIVE_  
> _purpose: Provide context for Claude CLI sessions working on the main branch_  

## Branch Overview

The `main` branch is the primary branch for the z_Utils project. It contains the stable, production-ready code and documentation that has passed all necessary reviews and tests.

## Current Status

1. **Project initialization:** Project has been initialized with core documents (2025-03-07)
2. **Repository setup:** Git and GitHub repos set up with proper signing and structure (2025-03-07)
3. **Requirements imported:** Merged docs/initial-requirements branch with foundational documents (2025-03-07)
4. **Feature branch creation:** Created docs/update-readme branch from main for README development (2025-03-07)
5. **Process improvements:** Enhanced commit approval requirements to ensure explicit human confirmation (2025-03-07)
6. **Next steps:** Continue with docs/update-readme branch to create comprehensive README.md

## Key Documents

**Core documents:**
- `README.md` - Basic project overview (to be updated with z_Utils specifics)
- `CLAUDE.md` - Guidelines for Claude CLI working with this project
- `WORK_STREAM_TASKS.md` - Master task tracking document for all branches

**Requirements documents:**
- `requirements/REQUIREMENTS-z_Utils_Functions.md` - Core function requirements
- `requirements/REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md` - Zsh standards
- `requirements/REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md` - Small script standards
- `requirements/REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md` - Framework standards
- `requirements/git_workflow.md` - Git process requirements
- `requirements/commit_standards.md` - Commit formatting and signing requirements
- `requirements/branch_management.md` - Branch strategy and process
- `requirements/work_stream_management.md` - Work stream management process

**Source examples:**
- `src/audit_inception_commit-POC.sh` - Example with z_Output function
- `src/z_frame.sh` and `src/z_min_frame.sh` - Framework examples
- `src/snippet_template.sh` - Snippet script template

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

1. Complete the docs/update-readme branch to create a comprehensive README.md
2. Add LICENSE file to the repository
3. Plan next branch for function specification templates
4. Set up remaining GitHub repository settings

## References

- Zsh documentation: https://zsh.sourceforge.io/Doc/
- Open Integrity Project standards for secure development
- Shell scripting best practices