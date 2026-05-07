# State Management

> How game state is organized and accessed in this project.

---

## Overview

Godot state lives in three scopes: **node-local** (on individual nodes), **scene-scoped** (shared within a scene tree), and **global** (autoload singletons). Prefer the narrowest scope possible.

---

## State Categories

### Node-Local State (Default)
State that belongs to a single node. Declare as `var` on the script:
```gdscript
extends CharacterBody2D

var input_dir: Vector2 = Vector2.ZERO
var facing_right: bool = true
const SPEED: int = 400
```
**Rule**: If only one node needs it, keep it on that node.

### Scene-Scoped State
State shared between nodes in the same scene tree. Access via parent coordination:
```gdscript
# Parent manages shared state
var score: int = 0

func _on_enemy_defeated(points: int) -> void:
    score += points
    score_changed.emit(score)
```

### Global State (Autoloads)
State that must persist across scene transitions and be accessible everywhere.

---

## Autoload Usage Rules

Autoloads are **global singletons** that survive scene transitions. Use sparingly.

### When to Autoload
- System must persist across scene changes (game state, audio manager)
- System manages its own data and doesn't modify other objects' internals
- System has broad scope (quest system, dialogue system, save system)

### When NOT to Autoload
- State only needed in one scene → use node-local or scene-scoped
- Data that multiple systems read/write → creates hidden coupling, hard to debug
- "Convenient access" → use signals or dependency injection instead

### Autoload Alternatives
| Need | Solution |
|------|----------|
| Shared functions | `class_name` script class (accessible everywhere without autoload) |
| Shared data | Custom `Resource` type |
| Shared constants | `class_name` with `const` values |
| Static utilities | `static func` / `static var` on a class |

### Autoload Pattern
```gdscript
# Autoload named "GameManager" in Project Settings
extends Node

var current_level: int = 1
var total_score: int = 0

func reset() -> void:
    current_level = 1
    total_score = 0
```

---

## Preload vs Load

| Use | When | Trade-off |
|-----|------|-----------|
| `preload("path")` | Path is constant, resource always needed | Loaded at script load, can't unload individually |
| `load("path")` | Path is dynamic, resource may change | Loaded at runtime, can set `null` to release |
| `@export var res: Resource` | Path may change, editor-configurable | Most flexible, overridden by scene instances |

```gdscript
# Constants — use preload
const BulletScene = preload("res://entities/bullet/bullet.tscn")

# Dynamic — use load or @export
@export var enemy_scene: PackedScene
```

---

## Data Structure Choice

| Structure | Best For | Avoid For |
|-----------|----------|-----------|
| `Array` | Sequential iteration, index access | Frequent insert/delete in middle |
| `Dictionary` | Key-value lookup, frequent add/remove | Large datasets needing iteration |
| `Object` (custom class) | Encapsulation, signals, complex behavior | Simple data bags (use Resource instead) |
| `Resource` | Serializable data, editor-editable values | Runtime-only transient state |

---

## Common Mistakes

- **Autoload for convenience**: Creates hidden dependencies, hard to test and debug
- **Global state for scene-local data**: Pollutes global scope, causes scene transition bugs
- **Direct autoload access from deep node trees**: Use dependency injection or signals
- **Using `_process` to poll state changes**: Use signals to react to state changes
