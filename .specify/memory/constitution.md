<!--
=============================================================================
SYNC IMPACT REPORT
=============================================================================
Version Change: N/A → 1.0.0
Rationale: Initial constitution ratification for darts_scorer project

Modified Principles:
- N/A (initial creation)

Added Sections:
- Core Principles (5 principles)
  1. Modular Component Design
  2. Test-First Development (TDD)
  3. Clear Contracts & Interfaces
  4. Simplicity & Maintainability
  5. User-Centric Design
- Development Standards
- Quality Gates
- Governance

Removed Sections:
- N/A (initial creation)

Templates Status:
- ✅ spec-template.md: Reviewed - compatible with constitution
- ✅ plan-template.md: Reviewed - constitution check section aligns
- ✅ tasks-template.md: Reviewed - task structure supports principles
- ⚠ checklist-template.md: Not reviewed (command-specific, low risk)
- ⚠ agent-file-template.md: Not reviewed (command-specific, low risk)

Follow-up TODOs:
- None - all critical placeholders filled

Created: 2025-10-20
=============================================================================
-->

# Darts Scorer Constitution

## Core Principles

### I. Modular Component Design

Each feature MUST be implemented as a standalone, cohesive module with:
- Clear boundaries and single responsibility
- Well-defined public interfaces
- Minimal coupling to other modules
- Independent testability

**Rationale**: Modular design enables parallel development, easier testing, and better maintainability. Components can evolve independently without cascading changes across the codebase.

**Non-negotiable rules**:
- Modules MUST NOT directly access internal implementation details of other modules
- All inter-module communication MUST go through defined interfaces
- Circular dependencies between modules are PROHIBITED

---

### II. Test-First Development (TDD)

Test-Driven Development is MANDATORY for all features:

1. **Write tests first**: Tests MUST be written before implementation
2. **Verify failure**: Tests MUST fail initially (red phase)
3. **Implement**: Write minimal code to make tests pass (green phase)
4. **Refactor**: Clean up code while keeping tests green
5. **User approval**: Tests MUST be approved by stakeholders before implementation begins

**Rationale**: TDD ensures requirements are understood before coding begins, creates living documentation, prevents regression, and produces testable designs by necessity.

**Non-negotiable rules**:
- Implementation work MUST NOT begin until tests are written and failing
- Test suites MUST be run and pass before code review/merge
- Code coverage MUST NOT decrease with new changes

**Test hierarchy**:
- **Contract tests**: Verify public API contracts and interfaces
- **Integration tests**: Validate component interactions and user journeys
- **Unit tests**: Test individual functions and methods in isolation

---

### III. Clear Contracts & Interfaces

All module boundaries MUST be defined by explicit contracts:

- **API contracts**: Document inputs, outputs, error conditions
- **Data contracts**: Define data structures, validation rules, constraints
- **Behavior contracts**: Specify expected behaviors, side effects, guarantees

**Rationale**: Explicit contracts enable independent development, facilitate mocking/testing, and serve as living documentation. They make assumptions visible and prevent integration surprises.

**Non-negotiable rules**:
- Public interfaces MUST be documented before implementation
- Breaking changes to contracts MUST be versioned and communicated
- Contract tests MUST exist for all public interfaces

---

### IV. Simplicity & Maintainability

Code MUST prioritize clarity and simplicity over cleverness:

- **YAGNI (You Aren't Gonna Need It)**: Don't build features until they're actually needed
- **Readable > Compact**: Choose clarity over brevity
- **Boring solutions first**: Prefer well-understood patterns over novel approaches
- **Delete > Add**: Removing code is better than adding it

**Rationale**: Simple code is easier to understand, debug, test, and modify. Complexity is a liability that compounds over time.

**Non-negotiable rules**:
- Complexity MUST be justified in writing (see Complexity Tracking in plan.md)
- Code reviews MUST reject unnecessary abstractions
- Premature optimization is PROHIBITED without performance data

---

### V. User-Centric Design

Features MUST be designed from the user's perspective:

- **User stories first**: Start with concrete user scenarios
- **Prioritize user journeys**: Order implementation by user value (P1, P2, P3...)
- **Independent deliverables**: Each user story MUST be independently testable and valuable
- **Real feedback loops**: Validate assumptions with actual user testing

**Rationale**: User-centric design ensures we build the right thing, not just build things right. Prioritization by user value enables MVP delivery and faster feedback cycles.

**Non-negotiable rules**:
- Features MUST begin with prioritized user stories
- Each user story MUST be independently deliverable as an MVP
- Acceptance criteria MUST be validated with stakeholders
- Technical implementation MUST NOT dictate user-facing design

---

## Development Standards

### Code Organization

- **Single project structure**: Use `src/` for source code, `tests/` for tests at repository root
- **Module structure**: Group related functionality in modules under `src/`
- **Test mirroring**: Test structure SHOULD mirror source structure for easy navigation

### Documentation Requirements

- **Inline documentation**: Public interfaces MUST have docstrings/comments
- **README files**: Modules SHOULD include README.md explaining purpose and usage
- **Design artifacts**: Features MUST have spec.md, plan.md, and tasks.md in `/specs/[###-feature-name]/`

### Version Control Practices

- **Feature branches**: Use pattern `###-feature-name` for feature work
- **Atomic commits**: Commits SHOULD represent single logical changes
- **Meaningful messages**: Commit messages MUST clearly describe the change and why

---

## Quality Gates

All code MUST pass these gates before merge:

1. **Tests pass**: All tests (unit, integration, contract) MUST pass
2. **TDD verified**: Implementation MUST have followed test-first approach
3. **Code review**: At least one team member MUST review and approve
4. **Contract compliance**: Public interfaces MUST have documented contracts
5. **Complexity justified**: Any complexity MUST be documented in plan.md
6. **User story complete**: Feature MUST satisfy acceptance criteria

---

## Governance

### Authority & Compliance

This Constitution supersedes all other development practices and guidelines. All development activities MUST comply with the principles and standards defined herein.

### Amendment Process

1. **Propose changes**: Document proposed amendments with rationale
2. **Impact analysis**: Assess impact on existing code and templates
3. **Approval required**: Team consensus MUST be achieved before adoption
4. **Migration plan**: Breaking changes MUST include migration strategy
5. **Version update**: Constitution version MUST be incremented per semantic versioning:
   - **MAJOR**: Backward-incompatible principle changes or removals
   - **MINOR**: New principles or substantial expansions
   - **PATCH**: Clarifications, wording fixes, non-semantic changes

### Enforcement

- All pull requests MUST verify compliance with constitution principles
- Code reviews MUST reference specific principles when requesting changes
- Plan.md MUST include "Constitution Check" section validating compliance
- Violations MUST be either corrected or justified in Complexity Tracking

### Exception Handling

Exceptions to constitutional principles MAY be granted when:
- Documented in plan.md Complexity Tracking section
- Includes rationale explaining why the principle cannot be followed
- Describes what simpler alternatives were considered and why they were rejected
- Receives explicit approval from team leads

---

**Version**: 1.0.0 | **Ratified**: 2025-10-20 | **Last Amended**: 2025-10-20
