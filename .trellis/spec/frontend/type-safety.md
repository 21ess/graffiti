# GDScript Coding Standards

> GDScript conventions, type safety, and coding patterns for this project.

---

## Overview

This project uses **GDScript** with Godot 4.6. Follow these conventions for consistent, maintainable code.

---

## Variable Declarations

### Typed Variables (Required)
Always declare types for variables, parameters, and return values:
```gdscript
# GOOD: Explicit types
var health: int = 100
var velocity: Vector2 = Vector2.ZERO
var facing_right: bool = true

# BAD: Untyped
var health = 100
var velocity = Vector2.ZERO
```

### Constants
Use `const` for values that never change. Use `UPPER_SNAKE_CASE`:
```gdscript
const SPEED: int = 400
const ACCELERATION: int = 50
const MAX_HEALTH: int = 100
```

### Exported Variables
Use `@export` for editor-configurable values with type hints:
```gdscript
@export var speed: float = 300.0
@export var jump_force: float = -500.0
@export_range(0, 100) var health: int = 100
```

---

## Function Conventions

### Naming
- Functions: `snake_case` — `take_damage()`, `flip()`, `_on_player_died()`
- Signal callbacks: `_on_<sender>_<signal_name>` — `_on_player_health_changed()`
- Private-like: prefix with `_` for internal use — `_update_animation()`

### Type Annotations
```gdscript
func take_damage(amount: int) -> void:
    health -= amount

func get_health() -> int:
    return health

func calculate_velocity(direction: Vector2, delta: float) -> Vector2:
    return velocity.lerp(direction * SPEED, ACCELERATION * delta)
```

### Signal Declarations
```gdscript
signal health_changed(new_health: int)
signal died()
```

---

## Node Access Patterns

### Preferred Order (fastest to slowest)
1. `@onready` cached reference — fastest, safe if node moves:
   ```gdscript
   @onready var animation: AnimatedSprite2D = $AnimatedSprite2D
   ```
2. `@export` node reference — editor-configurable, most flexible:
   ```gdscript
   @export var target: Node2D
   ```
3. `$NodePath` syntax — fast inline access, GDScript-specific:
   ```gdscript
   $AnimatedSprite2D.play("idle")
   ```
4. `get_node("path")` — slowest, avoid when possible

---

## Preload vs Load

```gdscript
# Preload: constant paths, always needed
const BulletScene = preload("res://entities/bullet/bullet.tscn")

# Load: dynamic paths, may change at runtime
var scene = load(path).instantiate()

# @export: editor-configurable, most flexible
@export var packed_scene: PackedScene
```

---

## Initialization Order

When creating nodes at runtime, **set properties before adding to scene tree**:
```gdscript
# GOOD: Set properties first
var enemy = enemy_scene.instantiate()
enemy.position = spawn_position
enemy.health = base_health * difficulty_multiplier
add_child(enemy)

# BAD: Add then set (triggers setter logic multiple times)
var enemy = enemy_scene.instantiate()
add_child(enemy)  # _enter_tree, _ready fired
enemy.position = spawn_position  # setter triggers update
```

Exception: world-space coordinates that require being in the tree.

---

## Editor Conventions

- Use `@tool` scripts sparingly — only for editor plugins and configuration warnings
- Use `.gdignore` files in folders that shouldn't be imported by Godot (e.g., documentation, build outputs)

---

## Common Mistakes

- **Untyped variables**: Always use type annotations
- **`get_node()` when `@onready` works**: Cache node references
- **Setting properties after `add_child()`**: Set before adding to tree
- **Using `_process` for input**: Use `_unhandled_input` instead
- **`$"../../long/path"`**: Indicates poor scene structure, refactor instead
