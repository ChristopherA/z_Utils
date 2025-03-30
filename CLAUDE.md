# Z_Utils: Zsh Utility Library - Claude Guidance

> - _created: 2025-03-19_
> - _last-updated: 2025-03-31_
> - _development-model: Team_

<!-- 
============================================================================
DEVELOPER GUIDE: PROCESS FRAMEWORK OVERVIEW
============================================================================
This section provides an overview of the process framework used in this project.
It is intended for developers to understand how Claude engages with the
repository and how the different process components work together.
-->

## For Developers: Understanding the Process Framework

The process framework in this file serves as the core intelligence that guides Claude's behavior when interacting with the Z_Utils project. It provides structured patterns for branch detection, context management, planning approval, and implementation validation.

### Key Process Framework Components

1. **Branch Context Management** - The central framework that detects the current branch and activates appropriate sub-processes:
   - Main branch protection to prevent direct modifications
   - Working branch context loading for task implementation
   - Planning phase approval gate for controlled implementation
   - Implementation and completion phase tracking

2. **Sub-Process Blocks** - Self-contained process modules that handle specific scenarios:
   - Branch Selection Facilitation - Helps select or create branches from main
   - Planning Phase Management - Validates planning completeness and manages approval
   - PR Review Facilitation - Guides PR reviews on the main branch
   - Context Lifecycle Management - Handles context transitions (future → active → archived)

### How to Interact with the Process Framework

- **Command Patterns** - The framework supports both explicit and natural language commands:

  **Explicit Command Pattern:**
  ```
  claude "load CLAUDE.md, verify current branch is feature/user-auth, and continue implementation"
  ```
  
  **Natural Language Pattern:**
  ```
  claude "our project is user authentication, let's continue the implementation"
  ```

- **Using Natural Language Patterns** - The framework recognizes these common patterns:
  - "Our project is [goal]" - Indicates the primary goal of your session
  - "Let's continue [action]" - Initiates action with contextual awareness 
  - "I need to [task]" - Expresses direct intent for specific tasks
  - "Help me with [activity]" - Requests assistance with particular activities

- **Working with Branches** - The framework enforces branch-based workflows:
  - Main branch is protected - all changes require PR approval
  - Working branches follow the pattern: [type]/[name] (e.g., feature/enhance-functionality)
  - Each branch has an associated context file for tracking progress

- **Planning Phase Approval** - Implementation security gate:
  - All work begins in a planning phase requiring explicit approval
  - Approval is granted with the phrase "I APPROVE THE PLANNING PHASE"
  - This prevents accidental or premature implementation

### Process Framework Architecture

The framework employs a hierarchical structure:
- Global Framework (Branch Context Management) - Entry point for all interactions
- Process Blocks - Sub-modules with specific responsibilities
- Validation Functions - Security and consistency checks
- Error Recovery - Fallback mechanisms for handling issues
- Pattern Recognition - Natural language detection for intent

<!-- 
============================================================================
DEVELOPER REFERENCE SECTION
============================================================================
This section provides essential reference information for developers.
For comprehensive documentation, see PROJECT_GUIDE.md.
-->

## Reference Information for Developers

> **Note:** For detailed project structure, development workflows, and examples of working with Claude using both explicit commands and natural language patterns, refer to [PROJECT_GUIDE.md](./PROJECT_GUIDE.md). The content below contains essential information required for understanding Claude's process frameworks.

### Role Distinctions

This documentation uses specific terminology to distinguish between different roles:

- **User**: Someone using a script or tool built with Z_Utils (but not modifying it)
- **Developer**: Someone contributing to Z_Utils code or implementing Z_Utils in their scripts
- **Maintainer**: Someone responsible for Z_Utils infrastructure and repository management

These distinctions help clarify the intended audience for different sections of documentation.

### Project Overview

Z_Utils is a collection of reusable Zsh utility functions designed to provide consistent, robust, and efficient scripting capabilities. The library includes standardized:

- Output formatting and error handling
- Script environment setup and validation
- Dependency checking
- Path management and cleanup routines

### Development Model Reference

The current development model for this project is: **_development-model: Team_** (see header metadata)

Key process implications:
- Main branch is protected - all changes require PR approval
- Working branches follow the pattern: [type]/[name]
- Each branch requires a corresponding context file
- Planning phases require explicit approval

See `PROJECT_GUIDE.md` for the complete development model details.

<!-- 
============================================================================
ESSENTIAL GUIDELINES SECTION
============================================================================
This section contains critical guidelines for Claude's operation.
For example commands, refer to PROJECT_GUIDE.md which contains both
explicit command patterns and natural language patterns for all operations.
-->

## Essential Guidelines 

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

### Cross-References

For detailed information on specific topics, refer to these files:
- **Command Examples**: See PROJECT_GUIDE.md for both explicit and natural language patterns
- **Context Management**: See requirements/guides/context_guide.md for detailed procedures
- **Task Tracking**: See requirements/guides/task_tracking_guide.md for task organization standards

<!-- 
============================================================================
CLAUDE-FOCUSED PROCESS FRAMEWORK SECTION
============================================================================
This section contains the detailed process framework that Claude uses to
manage the project. It is structured for Claude's processing efficiency.
-->

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
    IMPLEMENTATION_ALLOWED = FALSE  // CRITICAL GATE FLAG
    project_goal = ""               // Extracted from natural language
    conversation_context = ""       // Context of the conversation
    command_style = ""              // "ceremonial" or "conversational"
    
PATTERN_DETECTION:
    // Detect command style - supports both ceremonial and conversational patterns
    // Ceremonial patterns are explicit, structured commands (backward compatible)
    // Conversational patterns are natural language expressions of intent
    
    // Detect ceremonial command style
    IF message contains "load CLAUDE.md" or "verify current branch" or "identify branch as":
        SET command_style = "ceremonial"
        PARSE command using traditional parameter extraction
    ELSE:
        SET command_style = "conversational"
        
    // Goal-based activation patterns (conversational style)
    DETECT "our project is [goal]" -> project_goal
    DETECT "I need to [task]" -> requested_action
    DETECT "let's [action]" -> requested_action
    DETECT "help me [task]" -> requested_action
    
    // Intent-specific patterns
    DETECT intent matches:
        "create branch", "new branch", "start feature" -> requested_action = "branch_creation"
        "continue", "resume", "pick up" -> requested_action = "context_resumption"
        "implement", "code", "develop" -> requested_action = "implementation"
        "review PR", "pull request", "PR #" -> requested_action = "pr_review"
        "activate context", "start work on [context]" -> requested_action = "context_lifecycle"
        "archive", "completed work" -> requested_action = "context_lifecycle"
        "modify", "edit", "update file", "change" -> requested_action = "file_modification"
        "test", "run tests" -> requested_action = "testing"
        "document", "add docs" -> requested_action = "documentation"
    
    // Branch-specific context detection
    DETECT branch references:
        "branch [branch-name]" -> verify branch exists
        "verify branch" -> confirms current_branch check needed
    
    // Extract conversation context for better response targeting
    DETECT content focus:
        "contexts", "files", "code", "tests", "infrastructure" -> conversation_context
        
INITIALIZATION:
    EXECUTE "git branch --show-current" -> current_branch
    
BRANCH DETECTION:
    IF current_branch == "main":
        EXECUTE main_branch_protection_process
    ELSE:
        EXECUTE working_branch_context_process

PROCESS main_branch_protection_process:
    // Enhanced action detection using both explicit and natural language patterns
    DETECT requested_action from user_request using PATTERN_DETECTION
    
    IF requested_action == "file_modification":
        SET protection_violation = TRUE
        RESPOND with branch_protection_warning
        OFFER branch_selection_options
    ELSE IF requested_action == "pr_review":
        EXECUTE pr_review_facilitation
    ELSE IF requested_action == "context_lifecycle":
        EXECUTE context_lifecycle_facilitation
    ELSE IF requested_action == "branch_creation":
        EXTRACT branch_name from user_request or project_goal
        EXECUTE branch_creation_facilitation
    ELSE:
        EXECUTE general_facilitation
        
    // File modification guard - critical security mechanism for main branch
    BEFORE ANY Edit/Replace/Bash tool use:
        BLOCK TOOL EXECUTION
        RESPOND "⛔ Modification blocked: The main branch is protected.
                 Please use a working branch for implementation tasks.
                 I can help you select or create an appropriate branch."
        EXECUTE branch_selection_facilitation
        EXIT FUNCTION

PROCESS working_branch_context_process:
    LOAD context_file for current_branch
    DETECT context_phase from context_file
    
    // Initialize the critical implementation gate flag
    SET IMPLEMENTATION_ALLOWED = FALSE
    
    // Enhanced pattern detection for working branch
    DETECT requested_action from user_request using PATTERN_DETECTION
    EXTRACT project_phase from project_goal
    
    // Implementation permission check with enhanced approval detection
    IF context_phase == "Planning":
        DETECT planning_approval from context_file
        IF planning_approval == FALSE:
            // Natural language approval pattern detection - multiple variants
            IF any pattern matches in latest_user_message:
                "I APPROVE THE PLANNING PHASE"
                "approve the plan"
                "planning looks good"
                "planning phase is approved"
                "approve planning"
                "the plan is approved":
                
                SET planning_approval = TRUE
                SET IMPLEMENTATION_ALLOWED = TRUE
                UPDATE context_file planning_approval_section
                RESPOND "✅ Planning phase approved! The implementation gate has been unlocked."
            ELSE:
                // Action depends on user intent
                IF requested_action contains "implement" or "code" or "develop":
                    // User trying to implement without approval
                    RESPOND with planning_approval_request
                    // Block implementation until approved
                    RETURN
                ELSE IF requested_action contains "review" or "plan" or "check":
                    // User just reviewing planning - can proceed
                    PRESENT planning_review_summary
                    ASK for approval 
                ELSE:
                    // Default behavior
                    RESPOND with planning_approval_request
                    RETURN
        ELSE:
            SET IMPLEMENTATION_ALLOWED = TRUE
            CONTINUE with requested_work
    ELSE:
        SET IMPLEMENTATION_ALLOWED = TRUE
        
        // Task-specific response based on natural language intent
        IF requested_action == "implementation":
            EXTRACT specific_feature from project_goal
            SUGGEST next implementation step based on context_file
        ELSE IF requested_action == "testing":
            SUGGEST test approach based on context_file
        ELSE IF requested_action == "documentation":
            SUGGEST documentation focus based on context_file
        ELSE:
            CONTINUE with requested_work
        
    // File modification guard - critical security mechanism
    BEFORE ANY Edit/Replace/Bash tool use:
        IF context_phase == "Planning" && IMPLEMENTATION_ALLOWED == FALSE:
            BLOCK TOOL EXECUTION
            RESPOND "⛔ Implementation blocked: Planning phase requires approval.
                     Please review the plan and approve with phrase:
                     'I APPROVE THE PLANNING PHASE'"
            EXIT FUNCTION

VALIDATION:
    VERIFY correct_branch_detection = (current_branch matches git status)
    VERIFY correct_context_loading = (context_file exists for branch)
    VERIFY correct_phase_detection = (context_phase matches context file)
    
    // Command style specific validation
    IF command_style == "ceremonial":
        // Traditional strict parameter verification
        VERIFY parameter_completeness = (all required parameters are present)
        VERIFY parameter_validity = (all parameters have valid values)
    ELSE IF command_style == "conversational":
        // Natural language intent validation
        VERIFY intent_detection_success = (requested_action is not empty)
        VERIFY intent_consistency = (requested_action is compatible with project_goal)
        VERIFY branch_intent_alignment = (current_branch aligns with requested_action and project_goal)
        
        // Handle ambiguity in conversational style
        IF intent_detection_confidence < THRESHOLD:
            ASK clarifying question based on detected intent
    
    // Project goal context awareness
    IF project_goal is detected:
        VERIFY project_goal_branch_alignment = (project_goal is relevant to current_branch)
        IF !project_goal_branch_alignment:
            SUGGEST branch_corrective_action based on project_goal
    
    // Enhanced error detection
    IF any verification fails:
        CREATE detailed_verification_error_report
        EXECUTE recovery_process with error_report
        
    // Enhanced security validation
    IF context_phase == "Implementation" && planning_approval == FALSE:
        // Detect potential bypass attempt
        SET IMPLEMENTATION_ALLOWED = FALSE
        SET context_phase = "Planning"
        RECORD security_event = {
            type: "approval_bypass_attempt",
            branch: current_branch,
            requested_action: requested_action,
            timestamp: current_timestamp
        }
        RESPOND "⚠️ Security alert: Implementation phase detected without planning approval.
                 Resetting to Planning phase for proper review."
                 
    // Conversational context preservation
    STORE conversation_state = {
        project_goal: project_goal,
        requested_action: requested_action,
        current_branch: current_branch,
        context_phase: context_phase,
        implementation_allowed: IMPLEMENTATION_ALLOWED
    }

ON ERROR:
    SET IMPLEMENTATION_ALLOWED = FALSE  // Default to safe state
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
    Please review the planning details above and if you approve, respond with the exact phrase:
    'I APPROVE THE PLANNING PHASE'"
    
    // Patterns for both explicit and natural language styles
    
    goal_based_branch_mismatch = "I notice your goal is related to [project_goal], but we're currently on the [current_branch] branch.
    Would you like to:
    1. Switch to a more appropriate branch for this goal
    2. Create a new branch specifically for [project_goal]
    3. Continue working on the current branch with this new focus"
    
    context_resumption_confirmation = "It looks like we're continuing work on [project_goal] in the [current_branch] branch.
    The current context phase is [context_phase] and the next steps are:
    [next_steps from context_file]
    
    Should we proceed with these next steps?"
    
    planning_review_summary = "Here's a summary of the planning for [current_branch]:
    
    Problem: [problem_statement from context_file]
    Approach: [approach from context_file]
    Success Criteria: [success_criteria from context_file]
    Implementation Phases: [implementation_phases from context_file]
    
    Does this plan look good to you? If so, you can approve it to begin implementation."
    
    implementation_suggestion = "Based on your goal to [project_goal], here's what I recommend for the next implementation step:
    [next_step from context_file]
    
    Would you like me to help you implement this?"
    
    conversational_branch_creation = "Let's create a new branch for [project_goal].
    
    What type of branch would be most appropriate?
    1. feature/ - For new features or enhancements
    2. fix/ - For bug fixes or corrections
    3. docs/ - For documentation improvements
    4. cleanup/ - For code cleanup or refactoring
    5. other/ - For other types of changes"
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

<!-- 
============================================================================
DEVELOPER REFERENCE SECTION
============================================================================
This section provides reference information for developers about
the Z_Utils project structure, code organization, and workflow processes.
-->

## Project Reference Information

### Project Overview

Z_Utils is a collection of reusable Zsh utility functions designed to provide consistent, robust, and efficient scripting capabilities. The library includes standardized:

- Output formatting and error handling
- Script environment setup and validation
- Dependency checking
- Path management and cleanup routines

### Development Model

The current development model for this project is: **_development-model: Team_** (see header metadata)

This means:
- Structured branch protection is in place
- Required code reviews and PRs for changes
- Detailed context sharing between team members
- Formal task assignment and tracking

See `PROJECT_GUIDE.md` for the full description of development models and detailed workflows.

### Repository Structure

This repository contains the Z_Utils Zsh utility library and associated documentation:

- `CLAUDE.md` - This file with guidance for Claude and human developers
- `README.md` - Documentation about the Z_Utils library
- `PROJECT_GUIDE.md` - Guide for project state and workflows
- `WORK_STREAM_TASKS.md` - Task tracking file
- `contexts/` - Context management files
  - `futures/` - Future feature contexts
  - `archived.md` - Archived context information
- `requirements/` - Function specifications and development guidelines
  - `project/` - Project-specific requirements
  - `shared/` - Shared scripting best practices
  - `guides/` - Detailed workflow guides
- `src/` - Source code for the Z_Utils library
  - `_Z_Utils.zsh` - Main library file
  - `examples/` - Example scripts demonstrating usage
  - `function_tests/` - Tests for individual functions
  - `tests/` - Full regression tests
- `untracked/` - Files not included in version control

### Key Code Locations

- Main library: `src/_Z_Utils.zsh`
- Examples: `src/examples/`
- Function tests: `src/function_tests/`
- Project requirements: `requirements/project/functions/`

### Guides and References

For detailed guidance, refer to:
- Development models: `PROJECT_GUIDE.md`
- Task tracking: `requirements/guides/task_tracking_guide.md`
- Context management: `requirements/guides/context_guide.md`
- Git workflow: `requirements/guides/git_workflow_guide.md`

## Working with Z_Utils

### Session Management

When working on this project:
1. Start development sessions with proper context loading
2. End sessions by updating context files with current progress
3. For long-running tasks, maintain updated context files for easy resumption

### Quick Reference Commands

Run these commands to check the project status:

```bash
git status                 # Check branch and file status
git branch --show-current  # Show current branch
git log --oneline -n 10    # View recent commit history
```

<!-- 
============================================================================
TASK EXECUTION PATTERNS SECTION
============================================================================
This section provides example commands for interacting with Claude for
various common development tasks with natural language examples.
-->

## Common Development Patterns

### Conversational Task Patterns

Here are examples of both ceremonial and natural language patterns for common development tasks:

#### Starting a New Feature

**Ceremonial pattern:**
```
claude "load CLAUDE.md, create branch feature/[feature-name] from main, and implement [specific functionality]"
```

**Natural language alternative:**
```
claude "our project is implementing [feature-name], let's create a branch and begin planning"
```

#### Working on an Existing Branch

**Ceremonial pattern:**
```
claude "load CLAUDE.md, verify current branch is [branch-type]/[branch-name], create context file, and begin work"
```

**Natural language alternative:**
```
claude "our project is [branch-name], let's continue the implementation we started"
```

#### Facilitating Context Creation

**Ceremonial pattern:**
```
claude "load CLAUDE.md, verify current branch is [branch-type]/[branch-name], perform context creation facilitation, and begin work"
```

**Natural language alternative:**
```
claude "our project is [branch-name], we need to set up a context file for our work"
```

#### Implementing Tests

**Ceremonial pattern:**
```
claude "load CLAUDE.md, identify branch as feature/test-infrastructure, and implement tests for [specific function]"
```

**Natural language alternative:**
```
claude "our project is testing [specific function], let's implement the test suite"
```

#### Updating Documentation

**Ceremonial pattern:**
```
claude "load CLAUDE.md, identify branch as docs/[docs-task-name], and update documentation for [specific topic]"
```

**Natural language alternative:**
```
claude "our project is improving documentation for [specific topic], let's enhance the docs"
```

### Context Lifecycle Management

#### Activating a Future Context

**Ceremonial pattern:**
```
claude "load CLAUDE.md, verify current branch is main, help activate future context [context-name]"
```

**Natural language alternative:**
```
claude "I need to start work on [context-name], help me activate this future context"
```

#### Archiving a Completed Context

**Ceremonial pattern:**
```
claude "load CLAUDE.md, verify current branch is main, archive completed context [context-name], and update documentation"
```

**Natural language alternative:**
```
claude "our work on [context-name] is complete, help me archive this context properly"
```

#### Synchronizing Task Tracking

**Ceremonial pattern:**
```
claude "load CLAUDE.md, verify current branch is main, synchronize WORK_STREAM_TASKS.md with context changes, and continue work"
```

**Natural language alternative:**
```
claude "our task tracking needs synchronization, help me update WORK_STREAM_TASKS.md"
```

<!-- 
============================================================================
IMPORTANT GUIDELINES SECTION
============================================================================
This section provides critical guidelines for content creation and attribution.
-->

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

<!-- Note for developers: For detailed processes regarding context archiving and task synchronization, refer to the appropriate guide files (context_guide.md and task_tracking_guide.md). This ensures consistency in development practices across the project. -->

<!-- Note for Claude: When helping developers with ongoing project work, ALWAYS refer to the appropriate guide for detailed instructions rather than inventing your own approach. This ensures consistency in development practices. For context archiving and task synchronization, follow the detailed processes in context_guide.md and task_tracking_guide.md. When managing context files, ensure that you maintain the proper context lifecycle (Future → Active → Archived) and keep all references synchronized across the repository. -->