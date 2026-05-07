# Quality Guidelines

> Code quality standards for scene and script development.

---

## Overview

Quality standards for GDScript and scene composition, based on Godot best practices and this project's conventions.

---

## Required Patterns

### Scene Composition
- Root node uses the most specific built-in type (e.g., `CharacterBody2D` not `Node2D`)
- Child nodes named in `PascalCase` describing their role
- Scripts attached to root node of their scene
- Scenes are self-contained — no references to siblings or specific parents

### GDScript
- All variables, parameters, and return values are **type-annotated**
- Constants use `UPPER_SNAKE_CASE`
- Functions use `snake_case`
- Signal names use **past tense** (`health_changed`, not `change_health`)
- Node references cached with `@onready` or `@export`
- Input handled via `_unhandled_input`, not polled in `_process`

### Dependency Direction
- Parent → Child: direct node access via `$` or `@onready`
- Child → Parent: emit signals (parent connects)
- Sibling → Sibling: never direct — coordinate through common parent
- Scene → External: `@export` properties or signals

---

## Forbidden Patterns

| Pattern | Why | Alternative |
|---------|-----|-------------|
| Direct sibling node references | Creates tight coupling, breaks instancing | Signals via parent |
| `$"../../deep/path"` | Fragile, breaks on tree restructuring | `@export` or `@onready` with short path |
| Untyped variables | Reduces readability, hides bugs | Always annotate types |
| Autoload for scene-local state | Global pollution, hard to debug | Node-local vars or scene signals |
| Polling input in `_process` | Wastes CPU, misses edge timing | `_unhandled_input` callback |
| Accessing children in `_init()` | Children don't exist yet | Use `_ready()` |
| Setting properties after `add_child()` | Triggers setters/notifications twice | Set before adding to tree |
| Using `_process` for physics | Frame-rate-dependent | `_physics_process` |
| Using `_process` for infrequent checks | Wastes per-frame cycles | `Timer` node |

---

## OOP Principles for Scenes

- **Single Responsibility**: One scene = one concept (player, enemy, bullet)
- **Open/Closed**: Extend via scene inheritance or composition, not modification
- **DRY**: Extract shared behavior to base scenes or `class_name` scripts
- **KISS**: Prefer simple node trees over deep hierarchies
- **YAGNI**: Don't add nodes/scripts for hypothetical features

---

## Testing & Verification

Since this project doesn't have automated tests, verify by:
1. **Run the game** — test the golden path and edge cases manually
2. **Check the editor** — look for configuration warnings on scenes
3. **Inspect scene tree at runtime** — use Godot's remote scene tree debugger
4. **Check for orphaned nodes** — use the Monitors tab in the debugger

---

## Code Review Checklist

- [ ] All variables and functions are type-annotated
- [ ] No direct sibling references
- [ ] No deep `$` paths (3+ levels)
- [ ] Signals use past tense naming
- [ ] Input uses callbacks, not polling
- [ ] Properties set before `add_child()` for runtime-created nodes
- [ ] Node access uses `@onready` or `@export`, not repeated `get_node()`
- [ ] Scene works when instanced in any context (no parent-type dependency)
- [ ] No autoload used for scene-local state
