# Cleanup Task Tracking Framework Context

<!-- 
IMPORTANT DESIGN DECISIONS:
1. This template prioritizes Claude processing efficiency over human readability
2. Direct command execution (git status, etc.) is used for reliable state detection
3. Process blocks use a single, consistent format for Claude's internal use
4. Instructions are self-contained without requiring cross-referencing
-->

## For Claude: Context Processing Framework
```
FUNCTION: Context State Management
TRIGGER: Any context-related operation

STATE_VARIABLES:
    current_branch = ""
    context_path = ""
    context_phase = "Planning"  // Values: "Planning", "Implementation", "Completion"
    planning_approval = FALSE
    completed_tasks_count = 0
    total_tasks_count = 0
    completion_percentage = 0.0
    phase_transition_needed = FALSE
    
INITIALIZATION:
    EXECUTE "git branch --show-current" -> current_branch
    SET context_path = "contexts/cleanup-task-tracking-framework-context.md"
    
    VERIFY file_exists = (context_path exists)
    IF !file_exists:
        RESPOND "Context file not found for branch cleanup/task-tracking-framework. Would you like me to create one?"
        EXIT FUNCTION
    
DETECT state_variables:
    EXECUTE "cat [context_path]" -> context_content
    
    EXTRACT phase from context_content matching "Phase: (Planning|Implementation|Completion)"
    SET context_phase = extracted phase
    
    SCAN for "Planning approved - (\d{4}-\d{2}-\d{2})" in Planning section
    IF found:
        SET planning_approval = TRUE
    ELSE:
        SET planning_approval = FALSE
        
    COUNT [x] and [ ] in Current Tasks section
    SET completed_tasks_count = count of [x]
    SET total_tasks_count = count of [x] + count of [ ]
    
    IF total_tasks_count > 0:
        SET completion_percentage = (completed_tasks_count / total_tasks_count) * 100
    ELSE:
        SET completion_percentage = 0
        
PROCESS state_transitions:
    IF context_phase == "Planning" && planning_approval == TRUE:
        SET phase_transition_needed = TRUE
        NEW_PHASE = "Implementation"
    
    IF context_phase == "Implementation" && completion_percentage >= 95:
        SET phase_transition_needed = TRUE
        NEW_PHASE = "Completion"
        
    IF phase_transition_needed:
        RESPOND "I notice this context is ready to transition from [context_phase] to [NEW_PHASE] phase. Would you like me to update the context file?"

VALIDATION:
    IF current_branch != "cleanup/task-tracking-framework" && current_branch != "main":
        RESPOND "Warning: Current branch [current_branch] doesn't match the context file's branch (cleanup/task-tracking-framework)."
        
    IF context_phase == "Planning" && planning_approval == FALSE:
        VERIFY planning_section_complete = ("What We're Solving" and "Our Approach" and "Definition of Done" and "Implementation Phases" all exist in Planning section)
        IF planning_section_complete:
            RESPOND "The planning section appears complete. Would you like to approve it to move to implementation?"

ON ERROR:
    RESPOND "I encountered an issue processing the context state. Let's continue with the available information."
    USE branch_name "cleanup/task-tracking-framework" as fallback
    USE context_phase "Planning" as fallback
```

## Current Status
- Current branch: cleanup/task-tracking-framework
- Started: 2025-03-31
- Last updated: 2025-03-31
- Progress: Planning phase - preparing for implementation
- Phase: Planning

## Scope Boundaries
- Primary Purpose: Update the Task Tracking Framework in WORK_STREAM_TASKS.md for better task management and archiving
- In Scope: 
  - Analyze current task tracking process
  - Identify improvements for task archiving, conciseness, and context referencing
  - Update task tracking framework in WORK_STREAM_TASKS.md
  - Test and validate the updated process
- Out of Scope:
  - Implement automated tools for task tracking
  - Modify any existing archived contexts
  - Restructure other aspects of the project beyond task tracking
- Dependencies:
  - Understanding of current task tracking process
  - Analysis of WORK_STREAM_TASKS.md-to-archived.md relationship
  - Knowledge of recently completed cleanup work

## Planning

### What We're Solving
The current Task Tracking Framework in WORK_STREAM_TASKS.md needs improvements to better handle several aspects of task management. Our recent cleanup work revealed significant gaps in the process:

1. **Conciseness Guidelines**: The process lacks explicit instructions for maintaining concise task entries:
   - Active tasks contain excessive detail that duplicates information in context files
   - No guidance on what information belongs in WORK_STREAM_TASKS.md vs. context files
   - No standard format for concise task entries (current status, focus, progress)
   - No specified character or line count limits for task descriptions

2. **Future Tasks Management**: Insufficient handling of future tasks:
   - No explicit process for referencing contexts/futures/ files
   - Inconsistent format between active tasks and future projects
   - Duplicate information between WORK_STREAM_TASKS.md and future context files
   - No guidance on how detailed future task entries should be

3. **Cross-Repository Tasks**: No explicit handling for tasks spanning multiple repositories:
   - No way to indicate tasks that require changes in multiple repositories
   - No tracking of dependencies between repositories
   - No process for handling untracked directories with external repositories
   - No standard format for documenting cross-repository requirements

4. **Task Prioritization**: Inadequate process for task prioritization:
   - No consistent way to reflect High/Medium/Low priorities in task representation
   - No framework for automatically sorting tasks by priority
   - No process for elevating priority based on dependencies
   - No standardized verbiage for priority levels

5. **Redundancy Detection**: No mechanism to detect and eliminate redundancies:
   - No process to identify when task details duplicate context files
   - No tool to suggest when task entries should be trimmed
   - No guidelines on what constitutes acceptable vs. excessive redundancy
   - No feedback mechanism when redundancy is detected

6. **Archiving Process**: Need for clearer guidelines on task archiving:
   - No specific process for when to move tasks to Completed Tasks
   - No standard format for archived task references
   - No explicit procedure for linking to archived.md entries
   - No mechanism for verifying archived references are correct
   - No guidance on how much detail to retain vs. move to archived.md

7. **Inconsistent Implementation**: Our current practice doesn't follow the process:
   - We found numerous completed projects still in Active Tasks
   - Projects in archived.md had duplicate detailed entries in WORK_STREAM_TASKS.md
   - Future tasks had inconsistent formats and unnecessary details
   - Cross-repository tasks (like deprecate_setup_local_git_inception.sh) lacked clear indicators

These issues lead to:
- Bloated WORK_STREAM_TASKS.md with duplicate information (reaching 650+ lines)
- Inconsistent task descriptions between active tasks and future projects
- Confusion about how to handle tasks that span multiple repositories
- Inefficient archiving process that requires manual intervention
- Difficulty in quickly identifying true active tasks vs. completed ones
- Excessive context switching between WORK_STREAM_TASKS.md and archived.md

### Our Approach
We'll update the Task Tracking Framework in WORK_STREAM_TASKS.md to address these issues by implementing comprehensive improvements:

1. **Enhancing the State Variables**:
   - Add `task_conciseness_metrics` to track verbosity levels of task entries
     ```
     task_conciseness_metrics = {
         active_tasks: {max_lines: 3, recommended_format: "focus/status/branch"},
         future_tasks: {max_lines: 3, reference_required: TRUE},
         completed_tasks: {max_lines: 2, archive_reference_required: TRUE}
     }
     ```
   - Include `cross_repository_tasks` tracking structure
     ```
     cross_repository_tasks = [
         {
             task_name: "",
             primary_repo: "",
             secondary_repos: [],
             dependencies: [],
             special_handling: ""
         }
     ]
     ```
   - Add explicit `context_file_references` mapping
     ```
     context_file_references = {
         active_tasks: {task: "context_path"},
         future_tasks: {task: "futures_context_path"}
     }
     ```
   - Create `redundancy_detection` metrics
     ```
     redundancy_detection = {
         threshold: 50,  // percentage of content duplicated
         ignore_sections: ["task_title", "branch_name"],
         suggest_trim: TRUE
     }
     ```

2. **Improving the Process Blocks**:
   - Create `PROCESS task_conciseness_management`:
     ```
     PROCESS task_conciseness_management:
         FOR each task in active_tasks + future_tasks + completed_tasks:
             CALCULATE verbosity_score based on lines and duplication
             IF verbosity_score > task_conciseness_metrics[task_type].max_lines:
                 ADD task to verbose_tasks
                 GENERATE conciseness_suggestion with:
                     - Current task entry
                     - Suggested trimmed entry
                     - Content to move to context file
         
         IF verbose_tasks not empty:
             PRESENT verbose_tasks with conciseness_suggestions
             FOR each accepted suggestion:
                 UPDATE task entry with concise format
                 IF context_update_needed:
                     SUGGEST context file update
     ```
   
   - Enhance `PROCESS task_archival` with specific guidelines:
     ```
     PROCESS task_archival:
         IF user_request contains "archive tasks" or "clean up completed tasks":
             FOR each completed_task in active_tasks:
                 CHECK archived.md for existing entry
                 IF entry exists:
                     GENERATE minimal_reference = {
                         title: task.title,
                         completion_date: task.completion_date,
                         archive_link: "archived.md#section",
                         pr_reference: "PR #X"
                     }
                     SUGGEST replacing detailed entry with minimal_reference
                 ELSE:
                     GENERATE archive_entry from task details
                     SUGGEST adding to archived.md
                     AFTER archive_entry added:
                         SUGGEST replacing detailed entry with minimal_reference
     ```
   
   - Add `PROCESS redundancy_detection`:
     ```
     PROCESS redundancy_detection:
         FOR each task in active_tasks:
             LOCATE corresponding context_file from context_file_references
             IF context_file exists:
                 EXTRACT task_details from task
                 EXTRACT context_details from context_file
                 CALCULATE overlap_percentage between task_details and context_details
                 
                 IF overlap_percentage > redundancy_detection.threshold:
                     ADD task to redundant_tasks with overlap_metrics
         
         IF redundant_tasks not empty:
             PRESENT redundancy_report with specific suggestions
             FOR each task in redundant_tasks:
                 SUGGEST specific content to remove from task entry
                 PROVIDE concise replacement format
     ```
   
   - Implement `PROCESS cross_repository_task_handling`:
     ```
     PROCESS cross_repository_task_handling:
         FOR each task containing cross-repository indicators:
             EXTRACT primary_repo and secondary_repos
             ADD to cross_repository_tasks
             
             SUGGEST standardized format:
                 - Clear "Cross-repo" label
                 - Primary repo identification
                 - Secondary repo listing
                 - Dependencies between repos
                 - Special handling requirements
     ```

3. **Updating Validation**:
   - Add validation for task conciseness:
     ```
     VERIFY task_conciseness = (
         all active_tasks follow conciseness guidelines AND
         all future_tasks have context references AND
         all completed_tasks have minimal archive references
     )
     ```
   
   - Include checks for proper context file references:
     ```
     VERIFY context_references_valid = (
         all referenced context files exist AND
         context_file_references mapping is complete AND
         referenced sections in archived.md exist
     )
     ```
   
   - Validate archived task references:
     ```
     VERIFY archived_references_valid = (
         all completed tasks have valid archived.md links AND
         archived references follow standard format AND
         PR numbers are correctly referenced
     )
     ```

4. **Adding Example Patterns**:
   - Include templates for concise active tasks:
     ```
     active_task_template = {
         title: "**Task Title** (Priority level)",
         current_focus: "Current focus: Specific aspect being worked on",
         status: "Status: Concrete progress indicator",
         branch: "Branch: branch-name",
         context_reference: "[Optional] Context: link-to-context-file"
     }
     ```
   
   - Add patterns for future task references:
     ```
     future_task_template = {
         title: "**Future Task Title** (Priority level)",
         one_line_description: "Brief task description (1 line)",
         context_reference: "See details in [context-file-link]",
         branch: "Branch: planned-branch-name"
     }
     ```
   
   - Include examples of cross-repository task handling:
     ```
     cross_repo_task_template = {
         title: "**Cross-Repo Task Title** (Priority level)",
         current_focus: "Current focus: Specific aspect being worked on",
         repo_indicator: "Cross-repo: primary-repo → secondary-repos",
         status: "Status: Progress in each repository",
         branch: "Branch: branch-name(s)",
         context_reference: "Context: link-to-context-file"
     }
     ```

### Definition of Done
- [ ] Enhanced state variables added to the Task Tracking Framework
  - [ ] `task_conciseness_metrics` with max lines and format requirements
  - [ ] `cross_repository_tasks` structure for tracking multi-repo tasks
  - [ ] `context_file_references` mapping for linking tasks to contexts
  - [ ] `redundancy_detection` metrics for measuring duplicated content
  - [ ] `archivable_tasks` tracking with archive section references

- [ ] Improved process blocks implemented
  - [ ] `PROCESS task_conciseness_management` with verbosity scoring
  - [ ] Enhanced `PROCESS task_archival` with specific guidelines
  - [ ] `PROCESS redundancy_detection` with percentage calculation
  - [ ] `PROCESS cross_repository_task_handling` with standardized formats
  - [ ] Updated `PROCESS task_synchronization` for archive references

- [ ] Updated validation mechanisms
  - [ ] `VERIFY task_conciseness` for length and reference requirements
  - [ ] `VERIFY context_references_valid` for file existence and correctness
  - [ ] `VERIFY archived_references_valid` for proper links and PR numbers
  - [ ] `VERIFY cross_repo_task_format` for consistent cross-repo indicators
  - [ ] `VERIFY redundancy_levels` to check duplication percentages

- [ ] Example patterns and templates created
  - [ ] `active_task_template` with focus/status/branch format
  - [ ] `future_task_template` with one-line description and context reference
  - [ ] `cross_repo_task_template` with primary/secondary repo indicators
  - [ ] `archive_reference_template` for completed tasks
  - [ ] `task_priority_indicator_format` with visual priority markers

- [ ] Documentation and formatting guidelines
  - [ ] Detailed explanation of task formats in WORK_STREAM_TASKS.md header
  - [ ] Clear rules for when to use links vs. inline details
  - [ ] Maximum line count guidelines for each task type
  - [ ] Examples of good vs. bad task entries
  - [ ] Instructions for linking to archived.md with anchor references

- [ ] Testing and validation with specific scenarios
  - [ ] Creating a new task with proper conciseness
  - [ ] Converting verbose active tasks to concise format
  - [ ] Properly archiving a completed task
  - [ ] Handling a cross-repository task
  - [ ] Finding and addressing redundancies between tasks and contexts

### Implementation Phases
1. Analysis → Deep dive into current task tracking issues
   - Analyze redundancies in current WORK_STREAM_TASKS.md
   - Review recent cleanup work and approach
   - Document all identified issues and their impact

2. Framework Design → Enhance the Task Tracking Framework
   - Update state variables to handle new requirements
   - Design new process blocks for identified issues
   - Create validation mechanisms for task management

3. Process Implementation → Update WORK_STREAM_TASKS.md
   - Implement the enhanced framework
   - Add documentation and examples
   - Ensure backward compatibility

4. Testing → Validate the updated framework
   - Test with various task scenarios
   - Verify handling of cross-repository tasks
   - Confirm proper archiving process

5. Documentation → Finalize process documentation
   - Update all relevant documentation
   - Add usage examples and best practices
   - Ensure clear guidance for maintainers

### Approval
- [ ] Planning approved - Ready to implement

## Current Tasks
- [ ] Analyze current task tracking process
  - [ ] Review WORK_STREAM_TASKS.md framework implementation
  - [ ] Identify all process blocks and their functions
  - [ ] Document current state variables and their usage
  - [ ] Analyze process flow for task management

- [ ] Identify improvement opportunities
  - [ ] Document issues with task conciseness
  - [ ] Analyze challenges with cross-repository tasks
  - [ ] Review process for referencing context files
  - [ ] Identify redundancies between tasks and contexts

- [ ] Design enhanced framework
  - [ ] Update state variables for new requirements
  - [ ] Design new process blocks for identified issues
  - [ ] Create validation mechanisms for task management
  - [ ] Develop example patterns for different task types

- [ ] Implement framework updates
  - [ ] Update WORK_STREAM_TASKS.md framework
  - [ ] Add documentation and examples
  - [ ] Ensure backward compatibility

## Notes
### Current Framework Analysis
The current Task Tracking Framework has these key components:

- State variables for tracking tasks and contexts
- Process blocks for task detection, update, synchronization
- Validation mechanisms for format and consistency
- Error handling for process issues

Key strengths:
- Solid structure for basic task management
- Good separation of concerns in process blocks
- Robust validation for task format

Areas for improvement:
- Add explicit conciseness guidelines
- Enhance cross-repository task handling
- Improve context file referencing
- Add redundancy detection

### Reference Information
- WORK_STREAM_TASKS.md contains the Task Tracking Framework
- contexts/archived.md stores completed task details
- contexts/futures/ contains future task details

### Untracked Files References
This branch does not create/use any untracked files.

## Error Recovery
- If inconsistencies are found: Document them and address individually
- If branch synchronization issues arise: Verify current branch with `git branch --show-current`
- If context file becomes out of sync: Use `git checkout cleanup/task-tracking-framework` to ensure correct branch

## Restart Instructions
If you need to restart work on this context:
```bash
claude "our project is updating the Task Tracking Framework, let's continue the work"
```

## Next Steps
1. Complete planning phase
2. Get approval for implementation
3. Begin implementing framework enhancements