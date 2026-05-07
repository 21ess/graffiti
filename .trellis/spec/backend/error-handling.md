# Error Handling

> How errors are detected, reported, and handled in this project.

---

## Overview

GDScript doesn't have try/catch. Error handling relies on **return values**, **assertions**, **null checks**, and **configuration warnings**. Design code to fail visibly during development.

---

## Error Handling Patterns

### 1. Return Value Checks
Many Godot methods return `Error` enum or `null` on failure:
```gdscript
var error = ResourceLoader.load_threaded_request(path)
if error != OK:
    push_error("Failed to load resource: %s" % path)
    return

var scene = get_tree().change_scene_to_file(path)
# change_scene_to_file doesn't return error — check scene validity
```

### 2. Null Safety
Always check for `null` when accessing potentially missing nodes or data:
```gdscript
var node = get_node_or_null("SomeNode")
if node == null:
    push_warning("Expected SomeNode not found")
    return

# Or use safe navigation
if has_node("SomeNode"):
    $SomeNode.do_something()
```

### 3. Assertions for Development
Use `assert()` for conditions that should never be false if the code is correct:
```gdscript
func take_damage(amount: int) -> void:
    assert(amount >= 0, "Damage amount must be non-negative")
    health -= amount

# Note: assertions are stripped in release builds
# Don't rely on them for runtime validation
```

### 4. Configuration Warnings
For scene setup errors, use `_get_configuration_warnings()`:
```gdscript
@tool
extends CharacterBody2D

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray = []
    if not has_node("CollisionShape2D"):
        warnings.append("CharacterBody2D requires a CollisionShape2D child")
    return warnings
```

### 5. Type Checking
Use `is` for runtime type checks when dealing with polymorphism:
```gdscript
func _on_body_entered(body: Node2D) -> void:
    if body is CharacterBody2D:
        body.take_damage(10)
    elif body is StaticBody2D:
        # Handle wall collision
```

---

## What NOT to Do

| Anti-Pattern | Why | Alternative |
|--------------|-----|-------------|
| Ignoring return values | Silently swallows errors | Always check `Error` returns |
| `push_error` without handling | Logs error but continues with broken state | Handle the error or return early |
| Using `assert` for runtime validation | Stripped in release builds | Use `if` checks + `push_error` |
| Catching all errors with generic handler | Hides specific issues | Handle each error case specifically |

---

## Logging Errors

Use Godot's built-in logging:
```gdscript
push_error("Critical: failed to save game data")    # Red in editor
push_warning("Node not found, using fallback")       # Yellow in editor
print("Debug: state changed to %s" % state)          # Output panel only
printerr("Error on stdout")                           # Stderr output
```

---

## Common Mistakes

- **Not checking `get_node()` returns**: Use `get_node_or_null()` or `has_node()`
- **Ignoring `ResourceLoader` errors**: Always check if loading succeeded
- **Using `assert` for user-facing validation**: Assertions are dev-only
- **Swallowing errors silently**: At minimum, `push_warning` so it's visible in the editor
