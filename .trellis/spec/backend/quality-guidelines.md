# Systems Quality Guidelines

> Code quality standards for game systems, data, and infrastructure.

---

## Overview

Quality standards for the systems/data layer — autoloads, resources, shared utilities, and infrastructure code.

---

## Required Patterns

### Autoloads
- Manage their own state, don't modify other objects' internals
- Provide clear API (signals + methods), not direct property access from everywhere
- Document what they do and why they need to be global

### Resources
- Use `class_name` for custom resources so they appear in the editor
- Export all configurable properties with type hints
- Include sensible defaults for all exported properties
- Use `duplicate()` when multiple independent copies are needed

### Data Flow
- Signals for event-driven communication
- Method calls for request-response patterns
- Resources for shared configuration
- No circular dependencies between systems

---

## Forbidden Patterns

| Pattern | Why | Alternative |
|---------|-----|-------------|
| Autoload modifying other nodes' properties | Hidden coupling, hard to trace | Emit signal, let consumers react |
| Global variables (not autoload) | No lifecycle control, scope confusion | Autoload or class with static vars |
| String-based data access | Typos cause silent failures | Enums or constants |
| Circular autoload dependencies | Initialization order bugs | Use signals to break cycles |
| Loading resources without error checking | Silent failures | Check return value |
| Assert for runtime user validation | Stripped in release | Use `if` + `push_error` |

---

## Autoload Checklist

Before creating an autoload, verify:
- [ ] Multiple scenes need this functionality
- [ ] It must persist across scene transitions
- [ ] It manages its own data (doesn't need to modify others' internals)
- [ ] Node-local or `class_name` alternatives don't work
- [ ] No simpler solution (signals, resources) exists

---

## Code Review Checklist for Systems

- [ ] No circular dependencies between systems
- [ ] Autoloads don't directly modify other nodes
- [ ] Resources use `class_name` and proper type hints
- [ ] Error conditions are handled (null checks, return value checks)
- [ ] Data access uses enums/constants, not strings
- [ ] No `[DEBUG]` print statements left in committed code
- [ ] Complex logic has `assert()` checks for invariant validation
