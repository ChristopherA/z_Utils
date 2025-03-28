# Main Branch Facilitation Context

## For Claude: Main Branch Facilitation Decision Tree
```
FUNCTION: Main Branch Process Selection
TRIGGER: Any user request while on main branch

STATE_VARIABLES:
    current_branch = ""
    file_modification_attempt = FALSE
    request_type = ""
    
INITIALIZATION:
    EXECUTE "git branch --show-current" -> current_branch
    
    IF current_branch != "main":
        EXIT FUNCTION // Not on main branch, no protection needed
    
DETECT file_modification_attempt:
    SCAN user_request for file_modification_patterns
    IF file_modification_patterns_found == TRUE:
        SET file_modification_attempt = TRUE
    
PROCESS protection_check:
    IF file_modification_attempt == TRUE:
        RESPOND with branch_protection_warning
        EXECUTE branch_selection_facilitation
        RETURN

DETECT request_intent:
    SCAN user_request for:
        CONTAINS "help select" -> SET request_type = "branch_selection" 
        CONTAINS "help review PR" -> SET request_type = "pr_review"
        CONTAINS "help plan context" -> SET request_type = "context_lifecycle"
        CONTAINS "help activate" -> SET request_type = "context_activation"
        CONTAINS "help archive" -> SET request_type = "context_archiving"
        DEFAULT -> SET request_type = "general_facilitation"

EXECUTE process_block_selection:
    LOAD corresponding_process_block from CLAUDE.md based on request_type
    EXECUTE corresponding_process_block

ON ERROR:
    RESPOND "I encountered an issue while processing your request on the main branch.
             Since this is a protected branch, I'll help you select a working branch
             where we can proceed with your task safely."
    EXECUTE branch_selection_facilitation

PATTERNS:
    branch_protection_warning = "I notice we're on the main branch which is protected. 
    The main branch cannot be directly modified - all changes require pull requests.
    Let me help you select or create an appropriate working branch for this task."
    
    file_modification_patterns = [
        "create file", "edit file", "modify", "change", "update file",
        "add new", "delete file", "remove file", "rename file"
    ]
```

## Purpose
To guide users in navigating from the protected main branch to appropriate working branches and facilitating PR reviews.

## Branch Protection
The main branch cannot be directly modified. All changes require PRs from working branches.

## Facilitation Role
When on main branch, Claude should:
1. Help users select or create appropriate working branches
2. Guide PR review processes without making changes
3. Assist with context lifecycle planning
4. Never attempt direct file modifications

## Key Facilitation Commands

```bash
# Help select a working branch
claude "load CLAUDE.md, verify current branch is main, help select working branch"

# Help review pull request
claude "load CLAUDE.md, verify current branch is main, help review PR #[number]"

# Help plan context lifecycle
claude "load CLAUDE.md, verify current branch is main, help plan context lifecycle"
```