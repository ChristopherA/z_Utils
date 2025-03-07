# Work Stream Management Requirements

This document defines the requirements and processes for managing parallel work streams in this project.

## Overview

The project uses a structured approach to manage parallel development across multiple branches, with WORK_STREAM_TASKS.md as the central coordination document. Each branch (work stream) follows a defined lifecycle from creation to completion and archiving.

## Core Principles

1. **Single Source of Truth**
   - WORK_STREAM_TASKS.md in the `main` branch is the official record of all work streams
   - All branches refer to this document for definitive task status
   - Regular synchronization ensures consistency

2. **Clear Ownership**
   - Each task is tagged with its branch name: `[branch-name]`
   - Branches own specific sections of the document
   - Only branch owners update their sections (except for cross-branch coordination)

3. **Structured Organization**
   - Tasks are organized by development stages
   - Each stage has a clear purpose and expected outcomes
   - Priorities guide work sequencing

4. **Transparent Status**
   - Completed tasks are clearly marked with dates
   - In-progress work is visibly identified
   - Blockers and dependencies are documented

## Document Structure

WORK_STREAM_TASKS.md must maintain the following structure:

1. **Header**
   - Document title
   - Brief purpose statement
   - Quick reference to this requirements document

2. **Active Work Streams**
   - One section per active branch
   - Branch name as section header
   - Related issues and requirements links
   - Tasks organized by stages

3. **Unassigned Tasks**
   - Tasks not yet assigned to specific branches
   - Organized by category or priority
   - Tagged with `[unassigned]`

4. **Recently Completed**
   - Tasks completed in the last 30-60 days
   - Includes completion dates
   - Provides quick reference for recent accomplishments

5. **Archived Work Streams**
   - Fully completed and merged branches
   - High-level summary with key achievements
   - Completion dates and final status

## Work Stream Lifecycle

### 1. Creation Phase

1. **Branch Creation**
   - Create a new git branch from main
   - Add a new section to WORK_STREAM_TASKS.md
   - Include branch name, description, and related documents

2. **Task Definition**
   - Define tasks organized by stages
   - Tag all tasks with branch name: `[branch-name]`
   - Prioritize tasks (High, Medium, Low)
   - Link to relevant requirements and issues

3. **Initial PR**
   - Create a small PR just to update WORK_STREAM_TASKS.md
   - Get approval to ensure alignment with project goals
   - Merge to main to establish task ownership

### 2. Development Phase

1. **Progress Tracking**
   - Mark tasks as in-progress while working
   - Update subtasks with status notes as needed
   - Document any blockers or dependencies

2. **Status Updates**
   - When making significant progress, update task status
   - Mark completed tasks with completion dates: `(YYYY-MM-DD)`
   - Add new subtasks discovered during implementation

3. **Status Synchronization**
   - Create focused PRs just for WORK_STREAM_TASKS.md updates
   - Keep status updates separate from code changes
   - Ensure main branch has current status information

### 3. Completion Phase

1. **Task Completion**
   - Ensure all tasks are either completed or moved to future work
   - Move completed tasks to "Completed in this Branch" section
   - Include completion dates for all items

2. **Final PR**
   - Include updated WORK_STREAM_TASKS.md in the final PR
   - Summarize achievements in PR description
   - Reference all completed requirements and issues

3. **Archiving**
   - After merge, move branch section to "Archived Work Streams"
   - Include branch name, completion date, and key achievements
   - Retain only high-level summary, not detailed tasks
   - Prune detailed tasks to keep document manageable

## Task Structure

Each task should follow a consistent format:

1. **Task Syntax**
   - Use Markdown checkbox syntax: `- [ ]` for incomplete, `- [x]` for complete
   - Include branch tag: `[branch-name]`
   - Optional priority level: `(High Priority)`, `(Medium Priority)`, `(Low Priority)`

2. **Task Content**
   - Begin with verb (Create, Implement, Review, etc.)
   - Be specific and measurable
   - Include subtasks as needed for clarity

3. **Task Status**
   - Incomplete: `- [ ]`
   - In Progress: `- [ ] (IN PROGRESS)`
   - Completed: `- [x] (YYYY-MM-DD)`
   - Blocked: `- [ ] (BLOCKED: reason)`

## Status Update Process

1. **When to Update**
   - After completing significant milestones
   - When discovering new subtasks
   - When reprioritizing work
   - Before creating development PRs

2. **How to Update**
   - Create a separate branch for status updates
   - Make focused changes to WORK_STREAM_TASKS.md only
   - Create a small PR specifically for the status update
   - Use a clear commit message: "Update [branch-name] status in WORK_STREAM_TASKS.md"

3. **Status Update Schedule**
   - Long-running branches: update at least weekly
   - Short-term branches: update at beginning and completion
   - Blocked work: update immediately when blocked

## Archiving Guidelines

1. **When to Archive**
   - After branch is fully merged to main
   - When all tasks are either completed or explicitly moved to future work
   - As part of branch cleanup

2. **How to Archive**
   - Move the entire branch section to "Archived Work Streams"
   - Condense detailed tasks into summary achievements
   - Maintain chronological order (newest archives at top)
   - Include completion date and summary stats

3. **Archive Pruning**
   - For large projects, consider creating ARCHIVE.md after 1+ year
   - Very old archives (2+ years) can be moved to ARCHIVE.md
   - Always maintain at least 6 months of archives in main document

## Conflict Resolution

1. **Merge Conflicts**
   - Always resolve in favor of most recent task status
   - Preserve all task entries, even if priorities change
   - When in doubt, consult branch owners

2. **Task Ownership Conflicts**
   - Tasks should be owned by exactly one branch
   - If multiple branches need similar work, create distinct tasks
   - Cross-reference related tasks across branches

## Example Usage

See the template WORK_STREAM_TASKS.md for a practical example of this structure in use.

## Tools and Automation

Consider developing or using tools to:

1. Generate status reports from WORK_STREAM_TASKS.md
2. Automate archiving of completed branches
3. Verify correct tagging and formatting
4. Track metrics on completion rates and timelines