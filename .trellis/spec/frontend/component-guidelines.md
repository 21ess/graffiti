# Scene & Node Guidelines

> How scenes are composed and nodes are structured in this project.

---

## Overview

Godot scenes are the equivalent of "components" — reusable, composable, self-contained units. Each scene is a tree of nodes with an optional script on the root.

---

## Scene vs Script: When to Use Which

| Use Case | Choice | Why |
|----------|--------|-----|
| Game entity with visual + collision + behavior | **Scene** | Declarative structure, editor-friendly, better performance for complex nodes |
| Simple utility or behavior extension | **Script** | Lightweight, no scene overhead |
| Reusable game concept (player, enemy, item) | **Scene** | Can be instanced, inherited, edited visually |
| Cross-project tool or plugin | **Script (class_name)** | Registerable as custom type, better for distribution |
| Complex node composition (3+ child nodes) | **Scene** | Engine batch-processes scene instantiation faster than scripted node creation |

**Rule of thumb**: If it has children or needs visual editing in the editor, make it a scene. If it's pure behavior on a single node, a script is fine.

---

## Scene Composition Patterns

### Root Node Type
Choose the most specific built-in type for the root node:
- Physics body → `CharacterBody2D`, `RigidBody2D`, `StaticBody2D`
- Visual-only → `Sprite2D`, `AnimatedSprite2D`
- Container → `Node2D`, `Node`
- UI → `Control` subclass

### Child Node Structure
```
Player (CharacterBody2D)           ← Root: most specific type
├── AnimatedSprite2D               ← Visual representation
├── CollisionShape2D               ← Physics collision
└── Camera2D                       ← Camera following
```

### Naming Nodes
- Use `PascalCase` for all node names
- Names should describe the node's role, not its type (e.g., `StartPosition` not `Marker2D2`)

---

## Dependency Injection Between Scenes

Prefer **loose coupling** — a scene should work independently. When interaction is needed:

| Method | When to Use | Safety |
|--------|-------------|--------|
| **Signal connection** | Response behavior (non-initiator) | Safest — child emits, parent connects |
| **Callable property** | Initiation behavior, no owned method needed | Safe — parent injects implementation |
| **Method call** | Initiation behavior | Medium — caller must know target API |
| **Node reference** | Need specific node access | Medium — use `@export` or `@onready` |
| **NodePath** | Delayed node resolution | Medium — resolved at runtime |

### Signal Pattern (Preferred)
```gdscript
# Child: emit signal, don't know who listens
signal health_changed(new_health: int)

func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health)

# Parent: connect in _ready or via editor
func _ready() -> void:
    $Player.health_changed.connect(_on_player_health_changed)
```

### Callable Pattern
```gdscript
# Child: has a callable property
var on_death: Callable

func die() -> void:
    on_death.call()

# Parent: inject in _ready
func _ready() -> void:
    $Player.on_death = _handle_player_death
```

---

## Sibling Node Communication

**Never let sibling nodes reference each other directly.** The common parent coordinates communication:

```
Main
├── Player          ← doesn't reference Enemy
├── Enemy           ← doesn't reference Player
└── GameManager     ← coordinates between Player and Enemy
```

---

## Node Tree Structure Guidelines

### Recommended Top-Level Layout
```
Main (main.gd)
├── World (Node2D)         ← Game world, swapped on level change
│   ├── Terrain
│   ├── Entities
│   └── Effects
└── GUI (CanvasLayer)      ← Persistent UI, survives scene transitions
```

### Parent-Child Rule
Ask: "If I remove the parent, should the children also be removed?" If yes → child. If no → sibling or separate scene.

### Transform Inheritance
- Children inherit parent transform by default
- To break inheritance: insert a plain `Node` (no transform) between parent and child, or use `top_level = true` on CanvasItem/Node3D
- Use `RemoteTransform2D` for conditional transform inheritance

---

## Configuration Warnings

For scenes with external dependencies, implement `_get_configuration_warnings()`:
```gdscript
@tool
extends Node2D

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []
    if not has_node("CollisionShape2D"):
        warnings.append("Missing required CollisionShape2D child node")
    return warnings
```

This makes the scene **self-documenting** — the editor shows a warning icon when dependencies are missing.

---

## Common Mistakes

- **Direct sibling references**: Use parent coordination or signals instead
- **Hardcoded node paths in deep trees**: Use `@export` or `@onready` with short paths
- **Scenes depending on specific parent type**: Scenes should work when instanced anywhere
- **Using `$` deep paths like `$"../../SomeNode"`**: Indicates poor scene structure
