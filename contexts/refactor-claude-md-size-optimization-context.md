# Refactor CLAUDE.md Size Optimization

> - _created: 2025-03-31_
> - _focus-area: Claude Performance Optimization_
> - _branch: refactor/claude-md-size-optimization_
> - _context-type: active_

## Current Status

- [x] Problem identification (2025-03-31)
- [x] Initial planning phase started (2025-03-31)
- [ ] Planning approved - Ready to implement
- [ ] Implementation in progress
- [ ] Ready for review
- [ ] Completed
- [ ] Archived

**Phase: Planning**

## Background

The Claude CLI is reporting performance concerns when loading CLAUDE.md due to its large size:
```
Large CLAUDE.md will impact performance (50k chars > 40k)
```

Current CLAUDE.md contains approximately 50,013 bytes (49,995 characters), which exceeds the recommended limit of 40,000 characters for optimal performance.

## What We're Solving

We need to optimize the size of CLAUDE.md to improve Claude CLI performance by:

1. Analyzing the current content structure
2. Identifying sections that can be moved to separate files
3. Refactoring the file to keep essential process frameworks while moving detailed documentation to referenced files
4. Ensuring all functionality remains intact through the refactoring
5. Designing the solution so it can be backported to the original template in ./untracked/Claude-Code-CLI-Toolkit

## Our Approach

1. **Content Analysis**: Assess which sections are essential for Claude's operation versus which are primarily documentation/guides
2. **Modular Structure Design**: Create a leaner core process framework with appropriate references to external files
3. **File Organization**: Decide on logical file structure for extracted content
4. **Reference System**: Implement clear reference patterns so Claude can find information when needed
5. **Testing**: Verify Claude functionality remains intact after refactoring
6. **Template Backporting**: Ensure our solution can be adapted for the original template

## Definition of Done

- [ ] CLAUDE.md reduced to under 40,000 characters
- [ ] No loss of functionality compared to previous version
- [ ] Clearly documented references to all extracted content
- [ ] Claude CLI no longer reports performance warnings
- [ ] Process framework continues to support both ceremonial and natural language patterns
- [ ] All required functionality still accessible to Claude
- [ ] Solution is compatible with backporting to the original template

## Implementation Phases

1. **Analysis Phase**: ✅
   - Measure current CLAUDE.md size metrics (50,013 bytes, exceeding 40k limit)
   - Identify sections that are essential vs. supplementary
   - Map dependencies between different sections
   - Compare with the original template to identify differences and commonalities

2. **Strategy Development**: ✅
   - Based on our analysis, we've identified several key differences between z_Utils' CLAUDE.md and the template CLAUDE.md:
     1. z_Utils' CLAUDE.md is more focused on the specific Z_Utils project
     2. The template is more general and includes bootstrap process functionality
     3. z_Utils' file has larger process blocks
     4. The template has dedicated sections for bootstrap guidance which z_Utils doesn't need
   
   - Our recommended structure is:
     
     **Core File: CLAUDE.md (reduced to ~18k characters)**
     - Keep header/metadata
     - For Developers: Understanding the Process Framework
     - Reference Information for Developers
     - Essential Guidelines
     - Global Framework (core process detection)
     - References to process block implementations

     **New Files:**
     - **claude_process_blocks.md** (~19k characters)
       - Branch Selection Facilitation
       - Planning Phase Management
       - PR Review Facilitation
       - Context Lifecycle Management
     
     - **claude_development_patterns.md** (~4k characters)
       - Common Development Patterns
       - Session Management
       - Quick Reference Commands
     
     - **claude_project_reference.md** (~2.5k characters)
       - Project Reference Information
       - Repository Structure
       - Key Code Locations
       - Guides and References

3. **Content Refactoring**:
   - Extract Self-Contained Process Blocks to claude_process_blocks.md
   - Move Common Development Patterns to claude_development_patterns.md
   - Move Project Reference Information to claude_project_reference.md
   - Remove duplicate Important Guidelines section
   - Update cross-references in CLAUDE.md to point to these new files

4. **Verification**:
   - Test Claude with refactored structure
   - Confirm all functionality still works
   - Measure performance improvements

5. **Backport Planning**:
   - Create a mapping between our new structure and the template structure
   - Identify which parts of our solution can be directly applied to the template
   - Plan template-specific modifications

## Comparison with Original Template

The original template in ./untracked/Claude-Code-CLI-Toolkit/CLAUDE.md has several key differences:

1. **Bootstrap Process**: The template includes extensive bootstrap process functionality that doesn't exist in z_Utils' CLAUDE.md
2. **Project Scope**: The template is focused on helping set up new projects, while z_Utils' CLAUDE.md is specific to the Z_Utils project
3. **Content Organization**: The template has different section ordering and emphasis
4. **File Size**: The template is already smaller than z_Utils' CLAUDE.md (approximately 35-40k characters)

## Backport Strategy

To ensure our solution can be backported to the original template:

1. Use the same file naming and structural conventions for both projects
2. Create clean interfaces between core functionality and project-specific details
3. Keep template-specific content (like bootstrap process) separate from common process blocks
4. Ensure referencing mechanisms are consistent between both implementations
5. Document the backport process for future reference

## Related Tasks

- No direct related tasks at this time, as this is a standalone optimization.

## Notes

- This task is focused solely on reorganizing CLAUDE.md for performance optimization without changing how the system works
- The key objective is to preserve all functionality while reducing the file size below the performance threshold
- The modular structure will have the added benefit of making each aspect of Claude's functionality more maintainable
- We need to keep references to related files clear to ensure Claude can access needed information