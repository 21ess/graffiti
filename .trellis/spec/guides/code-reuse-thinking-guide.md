# Code Reuse Thinking Guide

> **Purpose**: Stop and think before creating new code — does it already exist?

---

## The Problem

**Duplicated code is the #1 source of inconsistency bugs.**

When you copy-paste or rewrite existing logic:
- Bug fixes don't propagate
- Behavior diverges over time
- Codebase becomes harder to understand

---

## Before Writing New Code

### Step 1: Search First

```bash
# Search for similar function names
grep -r "function_name" .

# Search for similar patterns
grep -r "extends CharacterBody2D" .

# Search for existing scenes of a type
grep -r "class_name" .
```

### Step 2: Ask These Questions

| Question | If Yes... |
|----------|-----------|
| Does a similar scene/script exist? | Instance or extend it |
| Is this pattern used elsewhere? | Follow the existing pattern |
| Could this be a shared Resource? | Create it in the right place |
| Am I copying code from another file? | **STOP** — extract to shared |
| Does a `class_name` already cover this? | Use it instead of rewriting |

---

## Common Duplication Patterns in Godot

### Pattern 1: Copy-Paste Movement Logic

**Bad**: Each enemy type has its own copy of movement code

**Good**: Base enemy scene/script with shared movement, child scenes override specifics

### Pattern 2: Similar Entity Scenes

**Bad**: Creating a new scene that's 80% similar to existing

**Good**: Instance the existing scene, or use scene inheritance

### Pattern 3: Repeated Constants

**Bad**: Defining `SPEED = 400` in multiple scripts

**Good**: Shared `class_name` with constants, or a `Resource` for configurable values

### Pattern 4: Duplicated Signal Handling

**Bad**: Same signal connection logic in multiple scenes

**Good**: Extract to a shared base script or utility function

---

## When to Abstract

**Abstract when**:
- Same code appears 3+ times
- Logic is complex enough to have bugs
- Multiple entity types share behavior

**Don't abstract when**:
- Only used once
- Trivial one-liner
- Abstraction would be more complex than duplication

---

## Godot Reuse Mechanisms

| Mechanism | Use For |
|-----------|---------|
| `class_name` script | Shared behavior, constants, utility functions |
| Scene inheritance | Entity variants (base enemy → flying enemy) |
| `Resource` subclass | Shared configuration data |
| `@export` properties | Configurable scene behavior |
| Autoload | Cross-scene systems |
| Composition | Combining independent behaviors (child nodes) |

---

## Checklist Before Commit

- [ ] Searched for existing similar code (`grep`, file search)
- [ ] No copy-pasted logic that should be shared
- [ ] Constants defined in one place
- [ ] Similar patterns follow same structure
- [ ] Considered scene inheritance or `class_name` for reuse
