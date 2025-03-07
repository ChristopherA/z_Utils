# Source Materials Inventory

This document tracks the status of source materials imported into the z_Utils project.

## Requirements Documents

| Filename | Status | Notes |
|----------|--------|-------|
| REQUIREMENTS-z_Utils_Functions.md | Current | Main function requirements document. Needs references updated to z_Utils repo |
| REQUIREMENTS-Zsh_Core_Scripting_Best_Practices.md | Current | Core scripting standards. Contains Open Integrity references that need updating |
| REQUIREMENTS-Zsh_Snippet_Script_Best_Practices.md | Current | Standards for smaller scripts. Contains Open Integrity references that need updating |
| REQUIREMENTS-Zsh_Framework_Scripting_Best_Practices.md | Current | Standards for larger frameworks. Contains Open Integrity references that need updating |
| REQUIREMENTS-Progressive_Trust_Terminology.md | Current | Terminology standards. May contain Open Integrity specific content to review |
| REQUIREMENTS-Regression_Test_Scripts.md | Current | Testing requirements. May contain Open Integrity specific content to review |
| REQUIREMENTS-get_repo_did.md | Current | Specific function requirement. May need update for z_Utils context |

## Script Examples

| Filename | Status | Conformance | Notes |
|----------|--------|-------------|-------|
| audit_inception_commit-POC.sh | Current | Conforms to Core & Framework Best Practices | Contains most current version of z_Output() and other z_Utils functions |
| create_inception_commit.sh | Current | Conforms to Snippet Script Best Practices | Contains draft z_Utils functions without z_Output |
| get_repo_did.sh | Current | Conforms to Snippet Script Best Practices | Contains draft z_Utils functions without z_Output |
| snippet_template.sh | Current | Conforms to Snippet Script Best Practices | Template for snippet scripts |
| z_frame.sh | Outdated | Partially conforms to Core & Framework Best Practices | Early framework template; has "Map semantic meanings to terminal colors" concept to incorporate |
| z_min_frame.sh | Outdated | Partially conforms to Core & Framework Best Practices | Second attempt at template; has minimal z_Output() version (may not keep) |
| z_output_demo.sh | Outdated | Does NOT conform to Best Practices | Contains oldest version of z_Output but has useful test function to adapt |

## Test Scripts

| Filename | Status | Conformance | Notes |
|----------|--------|-------------|-------|
| TEST-audit_inception_commit.sh | Current | Conforms to Core, Snippet & Test Best Practices | Regression test for audit_inception_commit-POC.sh |
| TEST-create_inception_commit.sh | Current | Conforms to Core, Snippet & Test Best Practices | Regression test for create_inception_commit.sh |

## Integration Plan

1. Add all requirements documents to the `requirements/` directory
2. Add script examples to `src/` with appropriate subdirectories
3. Add test scripts to `src/tests/`
4. Create documentation for functions based on requirements
5. Update references to Open Integrity with z_Utils equivalents

## Function Inventory

The following functions have been identified in the source materials as candidates for the z_Utils library:

| Function Name | Source File | Status | Notes |
|---------------|-------------|--------|-------|
| z_Output() | audit_inception_commit-POC.sh | Current | Most complete version to use as reference |
| z_Output() | z_output_demo.sh | Outdated | Contains useful test function to preserve |
| z_Output() | z_frame.sh | Outdated | Contains "semantic meanings to colors" concept to incorporate |
| [Additional functions to be inventoried] | | | |

## Next Steps

1. Copy requirements documents to appropriate locations
2. Extract and document key functions
3. Create updated templates based on best examples
4. Develop tests for all functions