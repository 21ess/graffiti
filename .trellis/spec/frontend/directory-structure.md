# Directory Structure

> How the Godot project is organized.

---

## Overview

This project follows Godot's recommended project organization: assets grouped near the scenes that use them, `snake_case` for files/folders, `PascalCase` for nodes.

---

## Directory Layout

```
res://
├── addons/                  # Third-party plugins (rider-plugin, etc.)
├── assets/                  # Shared art/audio assets (gitignored, Tiny Swords pack)
│   └── Tiny Swords (Update 010)/
│       ├── Factions/        # Character sprites
│       ├── Terrain/         # Tileset textures
│       ├── UI/              # UI elements (buttons, ribbons, icons)
│       └── Resources/       # Environment props (trees, sheep, etc.)
├── entities/                # Game entities (scenes + scripts co-located)
│   ├── player/              # Player entity
│   │   ├── player.tscn
│   │   └── player.gd
│   └── terrain/             # Terrain layers
│       ├── ground_layer.tscn
│       ├── object_layer.tscn
│       └── print/           # Terrain paint textures
├── main.tscn                # Root scene
├── main.gd                  # Root script
└── project.godot            # Project configuration
```

---

## Key Conventions

### File & Folder Naming
- **Files/folders**: `snake_case` (e.g., `player.gd`, `ground_layer.tscn`)
- **Nodes in scene tree**: `PascalCase` (e.g., `Player`, `GroundLayer`, `StartPosition`)
- **Rationale**: Prevents cross-platform issues (Windows/macOS case-insensitive, Linux case-sensitive). Godot exports use case-sensitive PCK virtual filesystem.

### Asset Organization
- Assets live in `assets/` at project root (gitignored — external art packs)
- Entity-specific textures should be co-located with the entity scene when practical
- Third-party plugins go in `addons/` only

### Entity Pattern
Each game entity is a self-contained directory under `entities/`:
```
entities/<entity_name>/
├── <entity_name>.tscn       # Scene definition
├── <entity_name>.gd         # Root node script
└── (optional textures, sub-scenes)
```

### Scene Co-location
Scenes and their scripts live together. The script is attached to the scene's root node. Sub-scenes for complex entities go in the same directory.

---

## Current Project State

- `entities/player/` — CharacterBody2D with AnimatedSprite2D, CollisionShape2D, Camera2D
- `entities/terrain/` — TileMapLayer nodes for ground and object layers
- `main.tscn` — Root Node that instances Player and terrain, sets start position

---

## Examples

- `entities/player/player.tscn` — Well-organized entity: scene + script co-located, sub-nodes (AnimatedSprite2D, CollisionShape2D, Camera2D) as children
- `entities/terrain/ground_layer.tscn` — TileMapLayer with embedded TileSet and multiple atlas sources
