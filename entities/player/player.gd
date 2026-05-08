extends CharacterBody2D

## 玩家实体 — 用于移动和攻击的实体
## Debuff 暂时硬编码在 player.gd 中

const PaintLayerScript = preload("res://entities/terrain/paint/paint_layer.gd")

# Movement
const BASE_SPEED: int = 400
const ACCELERATION: int = 50

# Action animations that should not be interrupted by idle/run
const ACTION_ANIMS: Array[StringName] = [&"attack", &"throw", &"dodge"]

var input_dir: Vector2 = Vector2.ZERO
var facing_right: bool = true # TODO: 改为朝向变量

# Debuff state
var current_debuff: PaintLayerScript.PaintType = PaintLayerScript.PaintType.NONE
var debuff_timer: float = 0.0

# Current paint type (set default type for MVP)
var paint_type: PaintLayerScript.PaintType = PaintLayerScript.PaintType.ICE

# Dodge state
const DODGE_DURATION: float = 0.25
var is_dodging: bool = false
var dodge_start: Vector2 = Vector2.ZERO
var dodge_timer: float = 0.0
var dodge_velocity: Vector2 = Vector2.ZERO

# Debuff constants
const VINE_SPEED_MULT: float = 0.4 # 60% slow
const LAVA_DOT_INTERVAL: float = 0.5 # damage every 0.5s
const LAVA_DOT_DAMAGE: int = 5
const ICE_ACCELERATION: int = 10 # much slower acceleration on ice
# const STORM_KNOCKBACK_STRENGTH: float = 200.0

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	# Detect paint underfoot
	_update_debuff()

	# Calculate effective speed based on debuff
	var effective_speed := BASE_SPEED
	var effective_accel := ACCELERATION

	match current_debuff:
		PaintLayerScript.PaintType.VINE:
			effective_speed = int(BASE_SPEED * VINE_SPEED_MULT)
		PaintLayerScript.PaintType.ICE:
			effective_accel = ICE_ACCELERATION
		PaintLayerScript.PaintType.LAVA:
			_apply_lava_dot(delta)
		# PaintLayerScript.PaintType.STORM:
		# 	_apply_storm_knockback(delta)

	# Input
	input_dir = Input.get_vector("left", "right", "up", "down")

	# Flip sprite
	if input_dir.x != 0:
		if input_dir.x > 0 and not facing_right:
			flip()
			facing_right = true
		elif input_dir.x < 0 and facing_right:
			flip()
			facing_right = false

	# Movement: dodge impulse overrides input/lerp until duration ends
	if is_dodging:
		velocity = dodge_velocity
		dodge_timer -= delta
		if dodge_timer <= 0.0:
			is_dodging = false
			var paint_mgr: PaintManager = PaintManager
			if paint_mgr != null:
				paint_mgr.paint_path(dodge_start, global_position, paint_type, 1)
	else:
		velocity = velocity.lerp(input_dir.normalized() * effective_speed, effective_accel * delta)

	# Animation: don't interrupt non-looping action animations while playing
	if animation.animation in ACTION_ANIMS and animation.is_playing():
		pass
	else:
		if velocity.length() > 50:
			animation.play("run")
		else:
			animation.play("idle")

	move_and_slide()


func _update_debuff() -> void:
	var paint_mgr: PaintManager = PaintManager
	if paint_mgr == null or paint_mgr.paint_layer == null:
		return
	var paint: PaintLayerScript.PaintType = paint_mgr.get_paint_at(global_position)
	if paint != current_debuff:
		current_debuff = paint
		debuff_timer = 0.0


func _apply_lava_dot(delta: float) -> void:
	debuff_timer += delta
	if debuff_timer >= LAVA_DOT_INTERVAL:
		debuff_timer -= LAVA_DOT_INTERVAL
		# TODO: emit damage signal when health system exists
		# For now, just print
		print("Lava DOT: %d damage" % LAVA_DOT_DAMAGE)


# func _apply_storm_knockback(_delta: float) -> void:
# 	# Apply random knockback each frame while on storm terrain
# 	var knockback_dir := Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
# 	velocity += knockback_dir * STORM_KNOCKBACK_STRENGTH * _delta


func flip() -> void:
	scale.x *= -1


func _unhandled_input(event: InputEvent) -> void:
	var paint_mgr: PaintManager = PaintManager
	if paint_mgr == null:
		return

	# if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
	# 	# Paint at mouse cursor position
	# 	var mouse_pos := get_global_mouse_position()
	# 	paint_mgr.paint_at(mouse_pos, paint_type, 3)

	if paint_mgr.paint_layer == null:
		push_warning("PaintManager.paint_layer is null — main.gd needs to wire it up")
		return

	if event.is_action_pressed("attack"):
		# Fan-shaped paint in facing direction
		var dir := Vector2.RIGHT if facing_right else Vector2.LEFT
		paint_mgr.paint_fan(global_position, dir, paint_type, 180.0, 8)
		animation.play("attack")

	elif event.is_action_pressed("throw"):
		# Paint area at mouse cursor (throw landing)
		var mouse_pos := get_global_mouse_position()
		paint_mgr.paint_area(mouse_pos, paint_type, 3)
		animation.play("throw")

	elif event.is_action_pressed("dodge"):
		# Start dodge — record start position, velocity, and timer
		var dodge_dir := input_dir.normalized() if input_dir != Vector2.ZERO else (Vector2.RIGHT if facing_right else Vector2.LEFT)
		is_dodging = true
		dodge_start = global_position
		dodge_timer = DODGE_DURATION
		dodge_velocity = dodge_dir * BASE_SPEED * 2.0
		animation.play("dodge")
