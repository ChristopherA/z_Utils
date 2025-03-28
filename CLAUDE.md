# Z_Utils: Zsh Utility Library - Claude Guidance

> - _created: 2025-03-19_
> - _last-updated: 2025-03-31_
> - _development-model: Team_

## For Claude: Process Detection and Execution Framework

### Global Framework
```
FUNCTION: Branch Context Management
TRIGGER: Any request requiring branch context awareness

STATE_VARIABLES:
    current_branch = ""
    context_phase = ""
    planning_approval = FALSE
    requested_action = ""
    protection_violation = FALSE

INITIALIZATION:
    EXECUTE "git branch --show-current" -> current_branch
    
BRANCH DETECTION:
    IF current_branch == "main":
        EXECUTE main_branch_protection_process
    ELSE:
        EXECUTE working_branch_context_process

PROCESS main_branch_protection_process:
    DETECT requested_action from user_request
    IF requested_action == "file_modification":
        SET protection_violation = TRUE
        RESPOND with branch_protection_warning
        OFFER branch_selection_options
    ELSE IF requested_action == "pr_review":
        EXECUTE pr_review_facilitation
    ELSE IF requested_action == "context_lifecycle":
        EXECUTE context_lifecycle_facilitation
    ELSE:
        EXECUTE general_facilitation

PROCESS working_branch_context_process:
    LOAD context_file for current_branch
    DETECT context_phase from context_file
    
    IF context_phase == "Planning":
        DETECT planning_approval from context_file
        IF planning_approval == FALSE:
            RESPOND with planning_approval_request
        ELSE:
            CONTINUE with requested_work
    ELSE:
        CONTINUE with requested_work

VALIDATION:
    VERIFY correct_branch_detection = (current_branch matches git status)
    VERIFY correct_context_loading = (context_file exists for branch)
    VERIFY correct_phase_detection = (context_phase matches context file)
    
    IF any verification fails:
        EXECUTE recovery_process

ON ERROR:
    IF current_branch == "main":
        RESPOND "I encountered an issue while processing your request on the main branch.
                 Since this is a protected branch, I'll help you select a working branch
                 where we can proceed with your task safely."
        EXECUTE branch_selection_facilitation
    ELSE:
        RESPOND "I encountered an issue while processing your request.
                 Let me try to recover the context state."
        EXECUTE context_recovery_process

PATTERNS:
    branch_protection_warning = "I notice we're attempting to modify files while on the protected main branch. 
    The main branch cannot be directly modified - all changes require pull requests.
    Instead, I can help you:
    1. Select an existing branch to work on
    2. Create a new branch for this work
    3. Prepare a PR from another branch"

    planning_approval_request = "The planning phase for this work needs approval before we can proceed with implementation.
    Please review the planning details above and confirm if you approve this approach."
```

### Self-Contained Process Blocks

#### PROCESS_BLOCK: Branch Selection Facilitation
```
FUNCTION: Facilitate branch selection when on main branch
TRIGGER: User requests work on a feature/task while on main

STATE_VARIABLES:
    existing_branches = []
    future_contexts = []
    selected_option = ""
    selected_branch = ""
    branch_type = ""
    branch_name = ""
    
INITIALIZATION:
    EXECUTE "git branch" -> existing_branches
    EXECUTE "ls contexts/futures/" -> future_contexts_files
    PARSE future_contexts_files -> future_contexts

PROCESS option_presentation:
    RESPOND "Since we're on the main branch which is protected, we need to select a working branch. Here are your options:
    
    1. Continue work on an existing branch
    2. Create a new branch from main for this work
    3. Start work on a planned feature from a future context
    
    Which option would you prefer?"
    
    DETECT user_selection from response
    SET selected_option = user_selection

PROCESS option_handling:
    IF selected_option == "1" || selected_option contains "existing":
        EXECUTE existing_branch_selection
    ELSE IF selected_option == "2" || selected_option contains "new":
        EXECUTE new_branch_creation
    ELSE IF selected_option == "3" || selected_option contains "future":
        EXECUTE future_context_activation
    ELSE:
        RESPOND "I didn't understand your selection. Let's try again."
        RESTART option_presentation

PROCESS existing_branch_selection:
    PRESENT existing_branches to user
    DETECT selected_branch from user response
    
    VERIFY branch_exists = (selected_branch in existing_branches)
    IF !branch_exists:
        RESPOND "That branch doesn't appear to exist. Let's try again."
        RESTART existing_branch_selection
    
    GUIDE user: "To switch to this branch, use: git checkout [selected_branch]"
    AFTER user confirms switch:
        EXECUTE "git branch --show-current" -> current_branch
        VERIFY current_branch == selected_branch
        LOAD corresponding context file

PROCESS new_branch_creation:
    ASK "What type of branch is this? (feature, fix, docs, etc.)"
    DETECT branch_type from user response
    
    ASK "What name would you like for this branch?"
    DETECT branch_name from user response
    
    GUIDE user: "To create this branch, use: git checkout -b [branch_type]/[branch_name]"
    AFTER user confirms creation:
        EXECUTE "git branch --show-current" -> current_branch
        VERIFY current_branch == "[branch_type]/[branch_name]"
        CREATE new context file
        BEGIN planning phase

PROCESS future_context_activation:
    PRESENT future_contexts to user
    DETECT selected_context from user response
    
    VERIFY context_exists = (selected_context in future_contexts)
    IF !context_exists:
        RESPOND "That context doesn't appear to exist. Let's try again."
        RESTART future_context_activation
    
    EXTRACT branch_name from selected_context
    GUIDE user: "To create this branch, use: git checkout -b [branch_name]"
    AFTER user confirms creation:
        EXECUTE "git branch --show-current" -> current_branch
        VERIFY current_branch == branch_name
        GUIDE user: "Now move the context file with: git mv contexts/futures/[selected_context] contexts/"
        LOAD moved context file
        BEGIN planning phase verification

VALIDATION:
    VERIFY branch_transition_successful = (current_branch != "main")
    IF !branch_transition_successful:
        RESPOND "It appears we're still on the main branch. Let's try another approach."
        RESTART option_presentation

ON ERROR:
    RESPOND "I encountered an issue while helping you select a branch. Let's try a simpler approach."
    PRESENT basic_branch_options to user
    GUIDE user through manual branch selection/creation

EXPECTED OUTPUTS:
    successful_transition = "Great! You're now on the [branch_name] branch and ready to work.
                           I've loaded the corresponding context file and we can continue with [specific_task]."
    
    creation_success = "Your new branch [branch_type]/[branch_name] has been created.
                      I've created a new context file with the planning phase ready for you to complete."
                      
    future_activation = "You've successfully activated the future context [selected_context].
                        Let's review the planning details and proceed with implementation."
```

#### PROCESS_BLOCK: Planning Phase Management
```
FUNCTION: Manage planning phase approval and transition
TRIGGER: Context in Planning phase requires approval

STATE_VARIABLES:
    context_file_path = ""
    planning_section_complete = FALSE
    planning_section = {}
    missing_elements = []
    has_problem_statement = FALSE
    has_approach = FALSE
    has_success_criteria = FALSE
    has_implementation_phases = FALSE
    user_approval = FALSE
    current_date = ""
    
INITIALIZATION:
    EXECUTE "git branch --show-current" -> current_branch
    SET context_file_path = "contexts/[branch-type]-[branch-name]-context.md"
    EXECUTE "date +%Y-%m-%d" -> current_date
    
PROCESS planning_verification:
    LOAD context_file_path -> context_content
    EXTRACT "Planning" section -> planning_section
    
    VERIFY has_problem_statement = planning_section contains "What We're Solving" with content
    VERIFY has_approach = planning_section contains "Our Approach" with content
    VERIFY has_success_criteria = planning_section contains "Definition of Done" with at least 2 items
    VERIFY has_implementation_phases = planning_section contains "Implementation Phases" with sequence
    
    IF !has_problem_statement:
        ADD "Problem Statement" to missing_elements
    IF !has_approach:
        ADD "Approach Description" to missing_elements
    IF !has_success_criteria:
        ADD "Success Criteria (at least 2 items)" to missing_elements
    IF !has_implementation_phases:
        ADD "Implementation Phases" to missing_elements
        
    IF missing_elements is empty:
        SET planning_section_complete = TRUE

PROCESS completion_request:
    IF !planning_section_complete:
        RESPOND "The planning section needs to be completed before implementation can begin.
                 Please add the following missing elements:
                 [missing_elements formatted as list]"
                 
        PROVIDE example_planning_section
        RETURN
    
PROCESS approval_request:
    IF planning_section_complete:
        EXTRACT problem_statement from planning_section
        EXTRACT approach from planning_section
        EXTRACT success_criteria from planning_section
        EXTRACT implementation_phases from planning_section
        
        RESPOND "I've reviewed the planning for [current_branch]:
                
                 Problem: [problem_statement]
                 Approach: [approach]
                 Success Criteria: [success_criteria formatted as list]
                 Implementation Phases: [implementation_phases formatted as list]
                
                 Do you approve this plan so we can begin implementation?"
                 
        DETECT user_approval from response
        
PROCESS plan_approval:
    IF user_approval == TRUE:
        UPDATE context_file:
            SET "Planning approved - Ready to implement ([current_date])" to checked
            SET "Phase: Implementation" in Current Status section
            
        RESPOND "Great! The plan has been approved and we're now in the Implementation phase.
                 Let's begin with the first implementation phase: [first_implementation_phase]"
                 
        BEGIN implementation of first phase

VALIDATION:
    VERIFY context_file_updated = (context_file contains approval date)
    VERIFY phase_updated = (context_file contains "Phase: Implementation")
    
    IF !context_file_updated || !phase_updated:
        RESPOND "I had trouble updating the context file. Let's try again."
        EXECUTE context_file_update_recovery

ON ERROR:
    RESPOND "I encountered an issue while processing the planning phase.
             Let me try an alternative approach to verify and update the planning status."
    EXECUTE simplified_planning_process

EXPECTED OUTPUTS:
    missing_elements_response = "The planning section needs to be completed before implementation can begin.
                                Please add the following missing elements:
                                - Problem Statement
                                - Approach Description
                                - Success Criteria (at least 2 items)
                                - Implementation Phases"
                                
    approval_request = "I've reviewed the planning for [current_branch]:
                       
                       Problem: [problem_statement]
                       Approach: [approach]
                       Success Criteria:
                       - [criterion 1]
                       - [criterion 2]
                       Implementation Phases:
                       1. [phase 1]
                       2. [phase 2]
                       
                       Do you approve this plan so we can begin implementation?"
                       
    approval_confirmation = "Great! The plan has been approved and we're now in the Implementation phase.
                            Let's begin with the first implementation phase: [first_implementation_phase]"
```

#### PROCESS_BLOCK: PR Review Facilitation
```
FUNCTION: Help review a pull request while on main branch
TRIGGER: "help review PR #X" command while on main branch

STATE_VARIABLES:
    pr_number = 0
    pr_details = {}
    pr_files = []
    pr_checks = {}
    review_decision = ""
    selected_option = ""
    selected_files = []
    feedback_points = []
    potential_issues = []
    
INITIALIZATION:
    EXTRACT pr_number from trigger command
    VERIFY pr_number is valid integer
    
PROCESS pr_examination:
    EXECUTE "gh pr view [pr_number]" -> pr_details
    EXECUTE "gh pr diff [pr_number]" -> pr_diff
    EXECUTE "gh pr checks [pr_number]" -> pr_checks
    EXECUTE "gh pr files [pr_number]" -> pr_files
    
    VERIFY pr_exists = (pr_details contains PR title and description)
    IF !pr_exists:
        RESPOND "I couldn't find PR #[pr_number]. Please verify the PR number and try again."
        EXIT FUNCTION

PROCESS structured_overview:
    EXTRACT pr_title from pr_details
    EXTRACT pr_description from pr_details
    EXTRACT pr_author from pr_details
    EXTRACT pr_branch from pr_details
    EXTRACT files_changed from pr_files
    
    SCAN pr_description and pr_diff for:
        implementation_choices
        major_changes
        potential_issues
    
    GENERATE pr_summary = {
        title: pr_title,
        author: pr_author,
        branch: pr_branch,
        files_changed: files_changed,
        key_changes: major_changes,
        implementation_choices: implementation_choices
    }
    
    RESPOND "PR #[pr_number]: [pr_title] by [pr_author]
            
             Branch: [pr_branch]
             Files Changed: [files_changed formatted as list]
             
             Key Changes:
             [major_changes formatted as list]
             
             Implementation Choices:
             [implementation_choices formatted as list]
             
             Would you like me to:
             1. Examine specific files in detail
             2. Check for potential issues
             3. Help you approve the PR
             4. Help you request changes to the PR"
             
    DETECT selected_option from user response

PROCESS review_guidance:
    IF selected_option == "1" || selected_option contains "files" || selected_option contains "examine":
        PRESENT files_changed to user
        DETECT selected_files from user response
        
        FOR each file in selected_files:
            EXECUTE "gh pr diff [pr_number] -- [file]" -> file_diff
            ANALYZE file_diff for:
                code_patterns
                potential_issues
                logic_changes
            PRESENT analysis to user
        
        RETURN to option presentation
        
    ELSE IF selected_option == "2" || selected_option contains "issues" || selected_option contains "check":
        CHECK pr_diff and pr_files for:
            code_style_issues
            test_coverage
            documentation_updates
            attribution_standards
        
        RESPOND with findings
        RETURN to option presentation
        
    ELSE IF selected_option == "3" || selected_option contains "approve":
        SET review_decision = "approve"
        EXECUTE decision_process
        
    ELSE IF selected_option == "4" || selected_option contains "changes" || selected_option contains "request":
        SET review_decision = "request_changes"
        EXECUTE decision_process
        
    ELSE:
        RESPOND "I didn't understand your selection. Let's try again."
        RESTART option presentation

PROCESS decision_process:
    IF review_decision == "approve":
        ASK "Would you like to add any comments to your approval?"
        DETECT approval_comment from user response
        
        GUIDE user "To approve this PR, use: gh pr review [pr_number] --approve -c \"[approval_comment]\""
        
    ELSE IF review_decision == "request_changes":
        ASK "What changes would you like to request for this PR?"
        DETECT feedback_points from user response
        
        GUIDE user "To request changes, use: gh pr review [pr_number] --request-changes -c \"[feedback_points formatted as list]\""

VALIDATION:
    VERIFY command_execution = (gh commands executed successfully)
    IF !command_execution:
        RESPOND "There was an issue executing the gh commands. Please ensure the GitHub CLI is correctly installed and configured."
        PROVIDE alternative_instructions

ON ERROR:
    RESPOND "I encountered an issue while helping you review the PR. Let's try a more direct approach."
    PRESENT simplified_pr_review_options
    GUIDE user through manual review process

EXPECTED OUTPUTS:
    pr_overview = "PR #12: Add user authentication by johndoe
                  
                  Branch: feature/user-auth
                  Files Changed:
                  - src/auth/user.js
                  - src/auth/tests/user.test.js
                  - src/config/auth.js
                  
                  Key Changes:
                  - Added JWT-based authentication
                  - Implemented password hashing
                  - Added user session management
                  
                  Implementation Choices:
                  - Used bcrypt for password handling
                  - Implemented stateless JWT approach
                  - Added test cases for auth failures
                  
                  Would you like me to:
                  1. Examine specific files in detail
                  2. Check for potential issues
                  3. Help you approve the PR
                  4. Help you request changes to the PR"
```

#### PROCESS_BLOCK: Context Lifecycle Management
```
FUNCTION: Facilitate context lifecycle transitions
TRIGGER: Context lifecycle management request while on main branch

STATE_VARIABLES:
    current_branch = ""
    future_contexts = []
    active_contexts = []
    completed_contexts = []
    operation_type = ""
    selected_context = ""
    branch_name = ""
    
INITIALIZATION:
    EXECUTE "git branch --show-current" -> current_branch
    
    VERIFY current_branch == "main"
    IF current_branch != "main":
        RESPOND "Context lifecycle management should be performed from the main branch. You are currently on [current_branch]."
        EXIT FUNCTION
        
    EXECUTE "ls contexts/futures/" -> future_contexts_files
    EXECUTE "ls contexts/ | grep -v 'archived\|futures'" -> active_contexts_files
    
    PARSE future_contexts_files -> future_contexts
    PARSE active_contexts_files -> active_contexts
    
PROCESS operation_selection:
    RESPOND "What type of context lifecycle operation would you like to perform?
    
             1. Activate a future context
             2. Archive a completed context
             3. Synchronize task tracking with contexts"
            
    DETECT operation_type from user response
    
PROCESS lifecycle_operation:
    IF operation_type == "1" || operation_type contains "activate" || operation_type contains "future":
        EXECUTE future_context_activation
        
    ELSE IF operation_type == "2" || operation_type contains "archive" || operation_type contains "completed":
        EXECUTE context_archiving
        
    ELSE IF operation_type == "3" || operation_type contains "synchronize" || operation_type contains "tracking":
        EXECUTE task_synchronization
        
    ELSE:
        RESPOND "I didn't understand your selection. Let's try again."
        RESTART operation_selection

PROCESS future_context_activation:
    IF future_contexts is empty:
        RESPOND "There are no future contexts available for activation."
        EXIT FUNCTION
    
    PRESENT future_contexts to user
    DETECT selected_context from user response
    
    VERIFY context_exists = (selected_context in future_contexts)
    IF !context_exists:
        RESPOND "That context doesn't appear to exist. Let's try again."
        RESTART future_context_activation
    
    EXTRACT branch_name from selected_context
    
    GUIDE user: "To activate this context:
                 1. First create the branch: git checkout -b [branch_name]
                 2. Then move the context file: git mv contexts/futures/[selected_context] contexts/
                 3. Finally commit the change: git commit -m 'Activate [selected_context]'"
                 
    PROVIDE work_stream_update_suggestion based on selected_context

PROCESS context_archiving:
    FOR each context in active_contexts:
        EXTRACT completion_status = CHECK if context contains "Phase: Completion" and all tasks marked complete
        IF completion_status == TRUE:
            ADD context to completed_contexts
    
    IF completed_contexts is empty:
        RESPOND "There are no completed contexts ready for archiving. A context must be in Completion phase with all tasks completed."
        EXIT FUNCTION
    
    PRESENT completed_contexts to user
    DETECT selected_context from user response
    
    VERIFY context_exists = (selected_context in completed_contexts)
    IF !context_exists:
        RESPOND "That context doesn't appear to be a completed context. Let's try again."
        RESTART context_archiving
    
    EXTRACT context_details from selected_context including:
        branch_name
        completion_date
        pr_number if available
        key_accomplishments
        categories
        
    GENERATE archive_entry based on context_details
    
    GUIDE user: "To archive this context:
                 1. First update contexts/archived.md with this entry:
                    [archive_entry formatted per template]
                 2. Then remove the original file: git rm contexts/[selected_context]
                 3. Update WORK_STREAM_TASKS.md to mark the task as completed
                 4. Finally commit these changes: git commit -m 'Archive [selected_context]'"

PROCESS task_synchronization:
    EXECUTE "cat WORK_STREAM_TASKS.md" -> work_stream_tasks
    
    DETECT active_branches from active_contexts
    DETECT tracked_tasks from work_stream_tasks
    
    IDENTIFY untracked_contexts = active_contexts not in tracked_tasks
    IDENTIFY completed_tasks = tasks marked complete in work_stream_tasks but context still active
    
    GENERATE synchronization_plan = {
        add_to_work_stream: untracked_contexts,
        mark_as_completed: completed_tasks,
        update_references: tasks with incorrect branch references
    }
    
    PRESENT synchronization_plan to user
    GUIDE user through implementing synchronization_plan

VALIDATION:
    VERIFY user_understanding = ASK "Does this guidance make sense for managing the context lifecycle?"
    IF !user_understanding:
        PROVIDE simplified_instructions
        
    REMIND user "Remember that these operations should be committed to maintain proper history tracking."

ON ERROR:
    RESPOND "I encountered an issue while facilitating context lifecycle management. Let's try a more basic approach."
    PRESENT simplified_lifecycle_options
    GUIDE user through manual lifecycle management

EXPECTED OUTPUTS:
    future_activation_guidance = "To activate this context:
                                 1. First create the branch: git checkout -b feature/user-auth
                                 2. Then move the context file: git mv contexts/futures/feature-user-auth-context.md contexts/
                                 3. Finally commit the change: git commit -m 'Activate feature-user-auth-context.md'"
                                 
    archive_entry_template = "## feature-user-auth-context.md
                             
                             **Status:** Completed  
                             **Branch:** feature/user-auth  
                             **Completed:** 2025-03-15  
                             **Archived:** 2025-03-31  
                             **PR:** #42 (Merged 2025-03-16)  
                             **Categories:** Authentication, Security
                             
                             Added JWT-based user authentication with secure password handling
                             and comprehensive test coverage for all authentication flows.
                             
                             **Key Accomplishments:**
                             - Implemented secure password hashing with bcrypt
                             - Added JWT token generation and validation
                             - Created comprehensive test suite for auth flows
                             - Added user session management
                             
                             **Related Contexts:** feature-user-profile, feature-permissions
                             
                             [View archived context](https://github.com/org/repo/blob/commit-hash/contexts/feature-user-auth-context.md)"
```

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

### Creating a Context File for Existing Branch

```bash
claude "load CLAUDE.md, verify current branch is [branch-type]/[branch-name], create context file, and begin work"
```

### Facilitating Context Creation

```bash
claude "load CLAUDE.md, verify current branch is [branch-type]/[branch-name], perform context creation facilitation, and begin work"
```

### Working on Testing

```bash
claude "load CLAUDE.md, identify branch as feature/test-infrastructure, and implement tests for [specific function]"
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

### Context Lifecycle Management

```bash
# Get help starting work on a future context
claude "load CLAUDE.md, verify current branch is main, help activate future context [context-name]"

# Get help with context archiving
claude "load CLAUDE.md, verify current branch is main, help archive completed context [context-name]"
```

## Important Guidelines

### Attribution Standards

When creating content with Claude's assistance, NEVER include Claude self-references:

1. **Commit Messages**
   - NEVER include "Generated with Claude Code"
   - NEVER include "Co-Authored-By: Claude"
   - ALWAYS use only the user's attribution

2. **Pull Request Descriptions**
   - NEVER include Claude references or attribution
   - NEVER add Claude logos or markers

3. **Documentation**
   - NEVER refer to Claude as the author or contributor
   - ALWAYS present content as the user's work

Check all generated content carefully before finalizing to remove any self-references or attribution to Claude.

<!-- Note for Claude: When helping users with ongoing project work, ALWAYS refer to the appropriate guide for detailed instructions rather than inventing your own approach. This ensures consistency in development practices. For context archiving and task synchronization, follow the detailed processes in context_guide.md and task_tracking_guide.md. When managing context files, ensure that you maintain the proper context lifecycle (Future → Active → Archived) and keep all references synchronized across the repository. -->