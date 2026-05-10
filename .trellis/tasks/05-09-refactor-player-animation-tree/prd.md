# Refactor Player Animation System to AnimationTree + BlendSpace2D

## Goal

Replace the current `AnimatedSprite2D` + manual `animation.play()` calls with a proper `AnimationTree` + `BlendSpace2D` + `StateMachine` architecture, enabling 4-direction animation for all action types (idle, move, attack, dodge, hitted).

## Current State

- `entities/player/player.tscn`: AnimatedSprite2D with SpriteFrames (5 animations: attack/dodge/idle/run/throw)
- All animations are horizontal-only; vertical direction is not shown
- `entities/player/player.gd` manually plays animations via `animation.play()` + `ACTION_ANIMS` guard for idle/run override
- Flip is done via `scale.x *= -1` hack
- No AnimationPlayer or AnimationTree nodes exist yet

## Requirements (evolving)

- **Idle**: 4-direction idle animation (up/down/left/right), horizontal priority when both axes active
- **Move**: 4-direction run animation, horizontal priority
- **Attack**: 4-direction attack animation, player immobile during attack, direction tied to facing (not weapon aim direction)
- **Dodge**: 4/8-direction dodge animation, tied to facing direction
- **Hitted**: 4-direction hit reaction animation, tied to facing direction
- **Sprite transition**: AnimatedSprite2D → Sprite2D + AnimationPlayer (required for AnimationTree)
- **AnimationTree structure**: StateMachine (Locomotion/Attack/Dodge/Hitted) with BlendSpace2D inside Locomotion for idle↔move blending
- **throw animation**: Merged into attack scope for v0.0.1 (no separate throw in new system)

> v0.0.1: attack and throw are combined (no distinction between normal/special attack)
> shot animation is weapon-bound, not character-bound (out of scope)

## Decision (ADR-lite)

**Context**: AnimatedSprite2D cannot be blended via AnimationTree; BlendSpace2D requires AnimationPlayer driving Sprite2D.

**Decision**: Replace AnimatedSprite2D with Sprite2D + AnimationPlayer + AnimationTree.

**Consequences**:
- Art pipeline changes: each direction needs its own sprite sheet or frame group
- AnimationPlayer drives `Sprite2D.texture` and `Sprite2D.region_rect` directly
- BlendSpace2D allows smooth transitions between idle↔move in any direction
- StateMachine handles action state transitions (Locomotion → Attack → Locomotion)
- Old `ACTION_ANIMS` guard in player.gd is replaced by StateMachine transitions

## Open Questions

- **Sprite assets**: Are 4-direction sprite sheets ready, or do we keep horizontal-flip for v0.0.1 and implement 4-dir art later?
- **Dodge directions**: Is 4-direction (same as other actions) sufficient, or must dodge support 8-directions with separate art?
- **hitted scope**: Is hitted animation in v0.0.1 scope, or can we defer to a later task?

## Acceptance Criteria (evolving)

- [ ] AnimationTree with StateMachine (Locomotion/Attack/Dodge/Hitted states)
- [ ] BlendSpace2D inside Locomotion state for idle↔move blending based on input_dir
- [ ] 4-direction animation selection for each action type (or 4-dir with flip if art not ready)
- [ ] `player.gd` drives animations via `tree.set("parameters/...")` instead of `animation.play()`
- [ ] Dodge impulse (0.25s) still works independently of animation duration
- [ ] Paint triggers (attack/throw/dodge) still fire correctly from `_unhandled_input`
- [ ] `scale.x *= -1` flip replaced by proper direction selection (or deferred if art not ready)
- [ ] No regressions in player movement or debuff system

## Out of Scope (explicit)

- Shot/throw animation (weapon-bound, separate system)
- Special attack variants
- Enemy animation system
- Particle/VFX integration
- Animation sound effects (SFX)
- 8-direction art assets (unless user confirms readiness)

## Technical Notes

- Godot 4.6 AnimationTree type: `AnimationTree`
- StateMachine node: `AnimationNodeStateMachine`
- BlendSpace2D node: `AnimationNodeBlendSpace2D`
- AnimationPlayer must drive `Sprite2D.texture` or `Sprite2D.region_rect` for frame changes
- Current sprite sheets: `Warrior_Blue.png` (192x192 per frame, multiple rows for animations)
- Horizontal priority: when both x and y input active, prefer x direction (spec: "水平(x轴)优先")
- player.gd `input_dir` is `Input.get_vector("left","right","up","down")` — normalized Vector2

## Research References

(To be filled by trellis-research if needed)
