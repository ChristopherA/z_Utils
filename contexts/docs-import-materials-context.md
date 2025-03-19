# docs-import-materials Context

## Current Status
- Current branch: docs-import-materials
- Started: 2025-03-19
- Progress: In progress - source material organized, directory structure defined

## Completed Work
- [x] Created `untracked/source-material` directory for source documents (2025-03-19)
- [x] Imported documents from existing sources (2025-03-19)

## Current Tasks
- [~] **Document Collection** (2025-03-19)
  - [x] Create `untracked/source-material` directory for source documents (2025-03-19)
  - [x] Import documents from existing sources (2025-03-19)
  - [x] Document origins and sources (2025-03-19) - completed function inventory in source_materials_inventory.md
  - [x] Organize by preliminary categories (2025-03-19)

- [~] **Document Inventory** (2025-03-19)
  - [x] Create document inventory in markdown table (2025-03-19)
  - [x] Record metadata for each document (2025-03-19)
  - [x] Identify documentation gaps (2025-03-19)
  - [x] Prioritize documents for processing (2025-03-19)

- [~] **Documentation Structure** (2025-03-19)
  - [x] Evaluate appropriate structure for this specific project (2025-03-19)
  - [x] Determine complex structure is needed (2025-03-19)
  - [x] Create documentation directory structure (2025-03-19)
  - [ ] Define documentation standards

- [ ] **Documentation Processing**
  - Convert priority documents to standard format
  - Create index documents if needed
  - Implement cross-references
  - Review converted documents

- [ ] **Process Documentation**
  - Document the maintenance process
  - Create contribution guidelines if needed
  - Define review procedures
  - Prepare branch for PR

<!-- Task format: 
- [ ] Not started
- [~] In progress (with start date in YYYY-MM-DD format)
- [x] Completed (with completion date in YYYY-MM-DD format)
-->

## Key Decisions

### Base File Organization
1. First commit should include the base project files:
   - CLAUDE.md
   - PROJECT_GUIDE.md
   - README.md (updated for z_Utils)
   - WORK_STREAM_TASKS.md
   - contexts/main-context.md
   - requirements/guides/* files
   - Initial src/ directory structure

2. Second commit should organize the source materials:
   - Import key requirements documents to appropriate locations
   - Create initial src/ files based on reference implementations
   - Organize documentation structure
   - Update inventories and references

### Documentation Structure
For the z_Utils project, we'll use the following structure:

```
requirements/                                      # Requirements documents
├── shared/
│   └── zsh_scripting/                             # Zsh scripting requirements
│       ├── zsh_core_scripting.md                  # Core scripting requirements
│       ├── zsh_snippet_scripting.md               # Snippet script requirements
│       ├── zsh_framework_scripting.md             # Framework script requirements
│       ├── zsh_test_scripting.md                  # Test script requirements
│       └── zsh_progressive_trust_terminology.md   # Terminology definitions
├── project/                                       # z_Utils library specific requirements
│   ├── z_utils_functions.md                       # General function requirements
│   └── functions/                                 # Individual function requirements
└── guides/                                        # Process and workflow guides

src/                                               # Source code
├── _Z_Utils.zsh                                   # Main library file
├── examples/                                      # Example scripts
├── function_tests/                                # Tests for specific functions
└── tests/                                         # Full regression tests
```

### Document Processing Priority
The following documents should be processed in this order:

1. **Tier 1 - Essential Base Files** (Create in initial commit)
   - Update README.md with focus on z_Utils purpose
   - CLAUDE.md - verify info is appropriate for this project
   - contexts/main-context.md - verify info is appropriate

2. **Tier 2 - Core Requirements** (Import & process after base commit)
   - REQUIREMENTS-z_Utils_Functions.md → requirements/project/z_utils_functions.md
   - REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md → requirements/shared/zsh_scripting/zsh_core_scripting.md
   - REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md → requirements/shared/zsh_scripting/zsh_snippet_scripting.md
   - REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md → requirements/shared/zsh_scripting/zsh_framework_scripting.md

3. **Tier 3 - Function Implementation**
   - audit_inception_commit-POC.sh (extract z_Output function) → src/_Z_Utils.zsh and src/function_tests/z_Output_test.zsh
   - z_output_demo.sh (adapt test function) → src/function_tests/z_Output_test.zsh
   - Extract other utility functions from source scripts → src/_Z_Utils.zsh

4. **Tier 4 - Templates & Examples**
   - snippet_template.sh → src/examples/snippet_template.zsh
   - get_repo_did.sh → src/examples/get_repo_did.zsh
   - Other script examples as appropriate

5. **Tier 5 - Supporting Documentation**
   - REQUIREMENTS-Regression_Test_Scripts.md → requirements/shared/zsh_scripting/zsh_test_scripting.md
   - REQUIREMENTS-Progressive_Trust_Terminology.md → requirements/shared/zsh_scripting/zsh_progressive_trust_terminology.md

## Notes
### Documentation Structure Options
#### Simple Structure
```
docs/
└── *.md           # All documentation files in single directory
```

#### Comprehensive Structure
```
docs/
├── api/           # API documentation
├── development/   # Development guides
├── usage/         # Usage tutorials
├── reference/     # Reference documentation
└── media/         # Images and other media
```

## Restart Instructions
To continue this work:
```bash
claude "load CLAUDE.md, identify branch as docs/import-materials, and continue working on documentation import and organization"
```

<!-- When ready to create PR for this branch:
```bash
claude "load CLAUDE.md, identify branch as docs/import-materials, and create a PR to merge into main"
```
-->