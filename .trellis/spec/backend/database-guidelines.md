# Resource & Data Guidelines

> How data is structured, stored, and shared in this project.

---

## Overview

Godot's `Resource` system is the primary way to define reusable data structures. Resources are serializable, editor-editable, and can be shared across scenes.

---

## Custom Resources

### When to Create a Resource
- Data needs to be **reusable** across multiple scenes/nodes
- Data should be **editable in the inspector**
- Data needs to be **saved/loaded** (`.tres` or `.res` files)
- Data is a **configuration** for gameplay (character stats, level config)

### How to Define
```gdscript
# character_data.gd
class_name CharacterData
extends Resource

@export var max_health: int = 100
@export var speed: float = 300.0
@export var sprite_frames: SpriteFrames
```

### How to Use
```gdscript
# In a scene script
@export var character_data: CharacterData

func _ready() -> void:
    health = character_data.max_health
    SPEED = character_data.speed
```

### Resource vs Node vs Object

| Type | Use For | Avoid For |
|------|---------|-----------|
| `Resource` | Serializable data, editor-configurable values, shared configs | Runtime-only transient state |
| `Object` | Dynamic data containers, custom data structures (trees, graphs) | Data that needs serialization |
| `Node` | Scene tree entities with behavior and visuals | Pure data storage |

---

## Data Structure Selection

| Need | Use | Why |
|------|-----|-----|
| Ordered list, iterate fast | `Array` | Contiguous memory, fastest iteration |
| Key-value lookup | `Dictionary` | O(1) insert/delete/lookup |
| Complex behavior + data | Custom `Object`/`class_name` | Encapsulation, signals, methods |
| Editor-editable config | `Resource` | Inspector integration, serialization |
| Enum-like categories | `enum` | Type-safe, editor-friendly |

### Array vs Dictionary Performance
- `Array`: fastest for iteration and index access, slow for insert/delete in middle
- `Dictionary`: fastest for key-based insert/delete/lookup, also fast iteration
- Use `Array` when order matters and you iterate often
- Use `Dictionary` when you look up by key frequently

---

## Enums

```gdscript
# Integer enum (fast comparison, editor-friendly)
enum Direction { UP, DOWN, LEFT, RIGHT }
enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

# Usage
var current_state: GameState = GameState.PLAYING

match current_state:
    GameState.MENU:
        show_menu()
    GameState.PLAYING:
        update_game()
```

---

## Data Access Patterns

### Passing Data Between Nodes
1. **Signals with parameters**: Best for event-driven data flow
2. **Resource sharing**: Multiple nodes reference the same Resource instance
3. **Method calls**: Direct data retrieval from known nodes
4. **Callable injection**: Parent provides data-fetching function to child

### Avoid
- Global variables (use autoloads or signals instead)
- `meta` data for structured data (use Resource or custom class)
- Stringly-typed keys (use enums or constants)

---

## Serialization (Save/Load)

For save systems, use Godot's built-in serialization:
```gdscript
# Save
var save_data = {
    "player_pos": player.position,
    "health": player.health,
    "level": current_level,
}
var json_string = JSON.stringify(save_data)
# Write to file...

# Load
var data = JSON.parse_string(json_string)
player.position = data["player_pos"]
```

For complex data, create a `Resource` subclass and use `ResourceSaver`/`ResourceLoader`.

---

## Common Mistakes

- **Using `Object` when `Resource` works**: Resources are serializable and editor-friendly
- **Using `Node` for pure data**: Nodes have scene tree overhead, use Resource or Object
- **Stringly-typed data access**: Use enums or constants for keys
- **Sharing mutable Resource instances without awareness**: Multiple nodes modifying the same Resource affects all references — use `duplicate()` for independent copies
