# Logging & Debug Guidelines

> How debugging and logging is done in this project.

---

## Overview

Godot provides built-in logging functions and debugging tools. Use them strategically — too much logging clutters the output, too little makes bugs invisible.

---

## Log Functions

| Function | Level | When to Use |
|----------|-------|-------------|
| `print()` | Info | General status messages, temporary debug output |
| `prints()` | Info | Multiple values separated by spaces |
| `printt()` | Info | Multiple values separated by tabs |
| `print_rich()` | Info | BBCode-formatted output (colors, bold) |
| `push_warning()` | Warning | Non-critical issues, fallbacks used |
| `push_error()` | Error | Critical failures, broken invariants |
| `printerr()` | Error | Stderr output |

---

## Logging Conventions

### Temporary Debug Output
Prefix with `[DEBUG]` and remove before committing:
```gdscript
print("[DEBUG] Player position: ", position)
print("[DEBUG] Health: %d / %d" % [health, max_health])
```

### Persistent Status Logs
Use for important game events that help diagnose issues:
```gdscript
print("Level loaded: %s" % level_name)
print("Game saved to: %s" % save_path)
```

### Warnings for Graceful Degradation
```gdscript
var config = load_config()
if config == null:
    push_warning("Config file not found, using defaults")
    config = DEFAULT_CONFIG
```

### Errors for Broken Invariants
```gdscript
func set_health(value: int) -> void:
    if value < 0:
        push_error("Health cannot be negative: %d" % value)
        value = 0
    health = value
```

---

## Godot Editor Debug Tools

### Debugger Panel
- **Monitors**: Track FPS, memory, physics objects, nodes
- **Stack Trace**: View call stack on errors
- **Profiler**: CPU/GPU performance per frame
- **Network Profiler**: Bandwidth and RPC tracking

### Remote Scene Tree
- Inspect live scene tree while game runs
- Modify properties in real-time
- View node memory usage

### Output Panel
- All `print`, `push_warning`, `push_error` output
- Filter by type (errors, warnings, info)

---

## Performance Logging

For profiling specific operations:
```gdscript
var start_time = Time.get_ticks_usec()

# ... operation to measure ...

var elapsed = Time.get_ticks_usec() - start_time
print("Operation took: %d microseconds" % elapsed)
```

---

## What NOT to Log

| Don't Log | Why |
|-----------|-----|
| Every frame updates | Clutters output, kills readability |
| Sensitive data | Player credentials, API keys |
| Raw binary data | Unreadable in output panel |
| Redundant state changes | Log state transitions, not every mutation |

---

## Common Mistakes

- **Leaving `[DEBUG]` prints in committed code**: Remove before committing
- **Using `print` for errors**: Use `push_error` so it shows as an error in the editor
- **Logging in `_process`**: Logs every frame, overwhelms output
- **Not logging important state changes**: Makes debugging impossible
