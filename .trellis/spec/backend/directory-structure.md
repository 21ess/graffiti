# Systems Directory Structure

> How game systems and shared infrastructure are organized.

---

## Overview

Game systems (autoloads, shared resources, utilities) live alongside gameplay code. There's no strict "backend" folder — systems are organized by responsibility, with autoloads registered in `project.godot`.

---

## Recommended Layout (as project grows)

```
res://
├── systems/                   # Shared game systems (create as needed)
│   ├── audio/                 # Audio manager (if needed)
│   ├── save/                  # Save/load system
│   └── events/                # Global event bus (if needed)
├── resources/                 # Custom Resource types
│   ├── character_data.gd      # CharacterData resource class
│   └── level_config.gd        # LevelConfig resource class
├── autoloads/                 # Autoload scripts (if needed)
│   └── game_manager.gd
└── addons/                    # Third-party plugins only
    └── rider-plugin/
```

**Note**: This structure is aspirational — create directories only when the project needs them. Don't pre-create empty folders.

---

## Current Project State

The project is early-stage. Current structure:
- `main.gd` — Root scene controller (sets player start position)
- `entities/` — All game entities (player, terrain)
- `addons/` — JetBrains Rider plugin

No autoloads, systems, or custom resources yet. Add them when the project needs cross-scene functionality.

---

## Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Files/folders | `snake_case` | `game_manager.gd`, `character_data.tres` |
| Autoload names | `PascalCase` | `GameManager`, `AudioManager` |
| Resource class names | `PascalCase` (via `class_name`) | `CharacterData`, `LevelConfig` |
| Node names | `PascalCase` | `Player`, `GroundLayer` |

---

## When to Create a System Directory

Create a new system directory under `systems/` when:
- Multiple scenes need the same non-visual functionality
- The system manages its own state and persists across scenes
- The system is complex enough to warrant its own files

Otherwise, keep logic in the entity/scene that owns it.

---

## Third-Party Addons

All third-party plugins go in `addons/` — never mix with project code. Currently:
- `addons/rider-plugin/` — JetBrains Rider IDE integration
