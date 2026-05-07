# Implement Graffiti/Paint System

## Goal

Implement the core graffiti (涂鸦) system for a roguelike game. The player's weapon determines graffiti type, and graffiti interacts with game actions (attack, throw, dodge) via affixes (词条). Painted terrain applies debuffs to entities standing on it.

## Game Context

- **Genre**: Roguelike with graffiti theme
- **Graffiti type**: Determined by the player's initial weapon choice
- **Graffiti effects**: Modified by affixes (词条) and triggered/modified by actions (attack, throw, dodge)
- **Paint layer**: `entities/terrain/print/paint_layer.tscn` — empty TileMapLayer, 8x8 tiles
- **4 paint textures**: vine, lava, ice, storm (2048x2048 each)
- **Ground layer**: 32x32 tiles; paint layer 8x8 = 4x4 paint grid per ground tile

## Decisions

- **Paint trigger**: Each game action (attack, throw, dodge) leaves graffiti; mouse click is also an option
- **Debuff effects**: vine=减速, lava=灼烧DOT, ice=打滑惯性, storm=击退偏移
- **Brush size**: 3x3 (3x3 8px tiles per click, 24x24 pixel area)
- **Action-paint interaction**: Directional + range mode
  - Attack: fan-shaped (扇形) paint in front of player
  - Throw: paint around landing point (落点周围)
  - Dodge: paint along dodge path (闪避路径)
- **Resource cost**: MVP = no cost, free painting

## MVP Scope

This task focuses on the **paint/debuff infrastructure only**:

### Requirements
- PaintLayer TileMapLayer with 8x8 tileset from the 4 textures
- Paint terrain API: `paint(position, type, brush_size)` — sets tiles on paint layer
- Mouse click triggers painting at cursor position (within range of player)
- Each game action triggers painting in its pattern (fan/area/path)
- Entities on painted terrain detect terrain type underfoot
- Debuff system: apply effect when on paint, remove when leaving
- 4 debuff effects: vine (slow), lava (DOT), ice (slippery), storm (knockback)

### Acceptance Criteria

- [ ] PaintLayer configured with 8x8 tileset from vine/lava/ice/storm textures
- [ ] Mouse click paints 3x3 area at cursor position
- [ ] Attack action paints fan shape in facing direction
- [ ] Throw action paints area around target position
- [ ] Dodge action paints along dodge path
- [ ] Painted tiles visually render on the map
- [ ] Standing on vine terrain slows player movement
- [ ] Standing on lava terrain deals damage over time
- [ ] Standing on ice terrain increases inertia/slippery movement
- [ ] Standing on storm terrain applies knockback/position offset
- [ ] Debuffs remove cleanly when leaving painted terrain
- [ ] No regressions in player movement

### Definition of Done

- All acceptance criteria met
- Tested in editor: paint visually, debuff on/off for each type
- No regressions in player movement

## Out of Scope (explicit)

- Weapon system (separate task — determines graffiti type)
- Affix/词条 system (separate task — modifies graffiti effects)
- Enemy AI interaction with paint (future)
- Paint decay/expiration
- Paint mixing/blending
- Resource consumption for painting
- Multiplayer sync
- UI for paint/weapon selection

## Technical Notes

- TileMapLayer API: `set_cell()`, `get_cell_tile_data()`, `map_to_local()`, `local_to_map()`
- 8x8 paint tiles on 32x32 ground = 4x4 paint grid per ground cell
- Player collision shape is CapsuleShape2D (radius 6, height 32)
- Physics layer on ground_layer has collision_layer = 1
- Need to detect which paint tile the player is standing on (check paint layer at player position each frame)
