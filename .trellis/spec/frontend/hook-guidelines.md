# Signal & Notification Guidelines

> How signals, notifications, and lifecycle hooks are used in this project.

---

## Overview

Godot has two primary communication mechanisms: **signals** (pub/sub events) and **notifications** (engine lifecycle callbacks). Use signals for game logic communication, notifications/overrides for lifecycle management.

---

## Signal Conventions

### Naming
- Signal names use **past tense** verbs: `entered`, `died`, `health_changed`, `item_picked_up`
- NOT present tense: ~~`enter`~~, ~~`die`~~, ~~`change_health`~~
- Rationale: Signals indicate something that already happened

### Declaring
```gdscript
# Type signal parameters for clarity
signal health_changed(new_health: int)
signal died()
signal item_picked_up(item: Item)
```

### Emitting
- Only the owning node emits its own signals
- Never emit another node's signals from outside

### Connecting
- Prefer connecting in `_ready()` or via the editor's Node panel
- Use `connect()` with typed Callable for safety:
```gdscript
func _ready() -> void:
    $Player.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(new_health: int) -> void:
    # Update UI
```

---

## Lifecycle Notification Order

When a scene is instanced, nodes receive notifications in this order:

1. `_init()` — Object initialization, before entering scene tree. No scene tree access.
2. `_enter_tree()` — Node added to scene tree. Called **top-down** (parent before children).
3. `_ready()` — Node and all children are ready. Called **bottom-up** (children before parent).

### When to Use Each

| Hook | Use For | Avoid |
|------|---------|-------|
| `_init()` | Initializing data that doesn't need scene tree | Accessing child nodes, `$` paths |
| `_enter_tree()` | Responding to being added to tree (e.g., connecting to parent signals) | Accessing children (they may not be ready yet) |
| `_ready()` | Accessing children, connecting signals, setting up initial state | Heavy computation that could be deferred |
| `_process(delta)` | Frame-rate-dependent logic, UI updates, checks | Physics, movement (use `_physics_process`) |
| `_physics_process(delta)` | Movement, physics, collision checks | Visual updates tied to frame rate |
| `_input(event)` / `_unhandled_input(event)` | Input handling | Polling input in `_process` |

---

## Input Handling

**Always use input callbacks, not polling in `_process`:**
```gdscript
# GOOD: Event-driven input
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("jump"):
        jump()

# BAD: Polling every frame
func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("jump"):
        jump()
```

### Input Callback Priority
1. `_input()` — Highest priority, GUI nodes consume first
2. `_unhandled_input()` — After GUI, for game world input
3. `_unhandled_key_input()` — Key-specific, lowest priority

---

## NOTIFICATION_PARENTED / UNPARENTED

Use these for dynamic node attachment scenarios where `_enter_tree` is too coarse:
- Triggered when a node is reparented at any time, not just initial scene load
- Useful for nodes that need to react to their parent changing

---

## Timer Pattern for Non-Per-Frame Logic

Don't use `_process` for logic that doesn't need every frame:
```gdscript
# GOOD: Timer-based check
func _ready() -> void:
    var timer := Timer.new()
    timer.wait_time = 1.0
    timer.timeout.connect(_check_status)
    add_child(timer)
    timer.start()

# BAD: Checking every frame when once per second is enough
func _process(_delta: float) -> void:
    _check_status()
```

---

## Common Mistakes

- **Polling input in `_process`**: Use `_unhandled_input` instead
- **Accessing children in `_init()`**: They don't exist yet
- **Accessing children in `_enter_tree()`**: Children may not be ready (bottom-up order)
- **Connecting signals in `_init()`**: Scene tree not available
- **Using `_process` for physics**: Use `_physics_process` for frame-rate-independent movement
- **Using `_process` for infrequent checks**: Use a `Timer` instead
