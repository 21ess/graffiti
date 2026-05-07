# Cross-Layer Thinking Guide

> **Purpose**: Think through data flow across layers before implementing.

---

## The Problem

**Most bugs happen at layer boundaries**, not within layers.

Common cross-layer bugs in Godot projects:
- Scene A emits signal with format X, Scene B expects format Y
- Autoload stores data one way, consumers expect another
- Resource properties don't match what scenes assume
- Node tree structure doesn't match script expectations

---

## Before Implementing Cross-Layer Features

### Step 1: Map the Data Flow

Draw out how data moves:

```
Input → Script Logic → State Change → Signal → Consumer → Visual Update
```

For each arrow, ask:
- What format is the data in?
- What could go wrong?
- Who is responsible for validation?

### Step 2: Identify Boundaries

| Boundary | Common Issues |
|----------|---------------|
| Signal → Listener | Parameter type mismatch, missing connection |
| Script → Child Node | Node not ready, wrong path, type mismatch |
| Autoload → Scene | Scene assumes autoload state, race condition on load |
| Resource → Consumer | Missing export, wrong resource type, null reference |
| Scene → Sub-scene | Interface mismatch, missing required children |

### Step 3: Define Contracts

For each boundary:
- What signals are emitted and with what parameters?
- What methods must exist on child/sub nodes?
- What properties are required vs optional?

---

## Common Cross-Layer Mistakes

### Mistake 1: Implicit Node Structure Assumptions

**Bad**: Script assumes child exists without checking
```gdscript
$HealthBar.update(health)  # Crashes if HealthBar removed
```

**Good**: Check or use configuration warnings
```gdscript
if has_node("HealthBar"):
    $HealthBar.update(health)
```

### Mistake 2: Signal Parameter Mismatches

**Bad**: Signal declared with one signature, connected handler expects different
```gdscript
# Emitter
signal health_changed(new_health: int)
# Receiver (wrong)
func _on_health_changed(new_health: float):  # Type mismatch
```

**Good**: Consistent types across signal and handler

### Mistake 3: Autoload State Assumptions

**Bad**: Scene assumes autoload is initialized in specific state
```gdscript
func _ready():
    score = GameManager.score  # What if GameManager not loaded yet?
```

**Good**: Autoload provides safe defaults, scenes check state

---

## Checklist for Cross-Layer Features

Before implementation:
- [ ] Mapped the complete data flow (input → logic → state → signal → consumer)
- [ ] Identified all boundaries (signals, node access, resource sharing)
- [ ] Defined types at each boundary
- [ ] Decided where validation happens

After implementation:
- [ ] Tested with missing nodes (editor warnings)
- [ ] Verified signal parameter types match
- [ ] Checked scene works when instanced in isolation
- [ ] Tested scene transitions (does state survive?)
