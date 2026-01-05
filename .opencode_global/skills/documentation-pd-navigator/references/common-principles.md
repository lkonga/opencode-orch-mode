# Common Progressive Disclosure Principles

## Progressive Disclosure Definition

Progressive disclosure is a design pattern that **surfaces information incrementally** based on user needs, preventing information overload while maintaining access to deeper content when required.

### Core Tenets

1. **Start Shallow**: Always begin with high-level overview (D0)
2. **Navigate Intentionally**: Only dive deeper when explicitly needed
3. **Stop Early**: Trust "Stop here if" conditions - don't over-read
4. **Load Selectively**: Read only sections relevant to current task
5. **Preserve Context**: Keep token usage minimal and surgical

## Depth Level Specifications

### D0 - Hub Entry Point
**Purpose**: Navigation and orientation
**Token Budget**: 500-1,000 tokens
**Read Time**: 30 seconds
**Line Count**: 200-400 lines
**Stop Condition**: Located relevant component/document

**Content**: Quick orientation, project map, task-based navigation, component references

### D1 - Component Overview
**Purpose**: What/Why/How + Quick Reference
**Token Budget**: 1,000-2,000 tokens
**Read Time**: 2-5 minutes
**Line Count**: 300-600 lines
**Stop Condition**: Have entry points and basic patterns

**Content**: Component purpose, entry points, common operations, integration patterns

### D2 - Implementation Details
**Purpose**: Patterns, code examples, integration
**Token Budget**: 2,000-5,000 tokens
**Read Time**: 5-15 minutes
**Line Count**: 600-1,500 lines
**Stop Condition**: Have implementation patterns needed

**Content**: Detailed patterns, code examples, integration scenarios, testing

### D3 - Architecture & Design
**Purpose**: System design, decisions, relationships
**Token Budget**: 5,000-10,000 tokens
**Read Time**: 15-30 minutes
**Line Count**: 1,500-3,000 lines
**Stop Condition**: Understand architecture for complex work

**Content**: System design, architectural decisions, patterns, data flow

### D4 - Complete Reference
**Purpose**: Exhaustive specifications and API docs
**Token Budget**: 10,000-20,000 tokens
**Read Time**: 30-60 minutes
**Line Count**: 3,000-6,000 lines
**Stop Condition**: Have complete technical reference

**Content**: Complete API, all configurations, error codes, edge cases

### D5 - Historical Context
**Purpose**: Evolution, migrations, legacy decisions
**Token Budget**: 5,000-10,000 tokens
**Read Time**: As needed
**Line Count**: 1,500-3,000 lines
**Stop Condition**: Understand system evolution

**Content**: Evolution timeline, migrations, legacy decisions, technical debt

## Token Efficiency Guidelines

### Do's
✓ Start at D0 always
✓ Read only relevant sections
✓ Stop at first sufficient depth
✓ Use "Stop here if" conditions
✓ Skip optional sections

### Don'ts
✗ Never read all docs preemptively
✗ Never skip D0 (hub)
✗ Never jump to D3+ without D1
✗ Never ignore stop conditions
✗ Never read "just in case"
