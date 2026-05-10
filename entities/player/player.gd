class_name Player
extends CharacterBody2D

## 玩家实体
## Debuff 暂时硬编码在 player.gd 中，后续考虑拆分模块

const PaintLayerScript = preload("res://entities/terrain/paint/paint_layer.gd")

# state
enum State {IDLE, MOVE, ATTACK, THROW, DODGE, HITTED, DEAD}
enum FaceDirection {RIGHT, LEFT, UP, DOWN}

# Movement
const BASE_SPEED: int = 400
const ACCELERATION: int = 50

const ACTION_ANIMS: Array[StringName] = [&"attack", &"throw", &"dodge", &"idle_right", &"idle_up", &"idle_down", &"move_right", &"move_up", &"move_down"]

@export var character_config: CharacterConfig = CharacterConfig.new() # 角色基础配置

var state: State = State.IDLE

var input_dir: Vector2 = Vector2.ZERO
var face_dir: FaceDirection = FaceDirection.RIGHT

var speed: int
var _acceleration: int
# Debuff state
var current_debuff: PaintLayerScript.PaintType = PaintLayerScript.PaintType.NONE
var debuff_timer: float = 0.0

# Current paint type (set default type for MVP)
var paint_type: PaintLayerScript.PaintType = PaintLayerScript.PaintType.ICE

# Dodge state
# const DODGE_DURATION: float = 0.25
# var is_dodging: bool = false
# var dodge_start: Vector2 = Vector2.ZERO
# var dodge_timer: float = 0.0
var dodge_handler: DodgeHandler

# Debuff constants
const VINE_SPEED_MULT: float = 0.4 # 60% slow
const LAVA_DOT_INTERVAL: float = 0.5 # damage every 0.5s
const LAVA_DOT_DAMAGE: int = 5
const ICE_ACCELERATION: int = 10 # much slower acceleration on ice
# const STORM_KNOCKBACK_STRENGTH: float = 200.0

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $Anim

func _ready() -> void:
	self.dodge_handler = DodgeHandler.new(character_config.dodge_speed, character_config.dodge_distance, character_config.dodge_cooldown)
	self.speed = character_config.base_speed
	self._acceleration = character_config.acceleration


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	elif state == State.ATTACK: # 攻击硬直
		velocity = Vector2.ZERO
		move_and_slide()
		return
	elif state == State.DODGE: # 闪避状态
		velocity = dodge_handler.update(global_position, delta)
		if dodge_handler.is_active: # 还在闪避中
			move_and_slide()
			return
		else:
			state = State.IDLE

	# Input
	input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = velocity.lerp(input_dir.normalized() * speed, _acceleration * delta)

	# 移动和待机动画
	if velocity.length() > 50:
		if abs(velocity.x) < abs(velocity.y):
			animation_sprite.flip_h = false
			if velocity.y > 0:
				animation_sprite.play("move_down")
				face_dir = FaceDirection.DOWN
			else:
				animation_sprite.play("move_up")
				face_dir = FaceDirection.UP
		else:
			if velocity.x > 0:
				animation_sprite.play("move_right")
				animation_sprite.flip_h = false
				face_dir = FaceDirection.RIGHT
			else:
				animation_sprite.play("move_right")
				animation_sprite.flip_h = true
				face_dir = FaceDirection.LEFT
	else:
		match face_dir:
			FaceDirection.RIGHT:
				animation_sprite.play("idle_right")
				animation_sprite.flip_h = false
			FaceDirection.LEFT:
				animation_sprite.play("idle_right")
				animation_sprite.flip_h = true
			FaceDirection.DOWN:
				animation_sprite.play("idle_down")
			FaceDirection.UP:
				animation_sprite.play("idle_up")
	# TODO: 拆分 buff 系统
	# Detect paint underfoot
	# _update_debuff()
	# Calculate effective speed based on debuff
	# var effective_speed := BASE_SPEED
	# var effective_accel := ACCELERATION
	# match current_debuff:
	# 	PaintLayerScript.PaintType.VINE:
	# 		effective_speed = int(BASE_SPEED * VINE_SPEED_MULT)
	# 	PaintLayerScript.PaintType.ICE:
	# 		effective_accel = ICE_ACCELERATION
	# 	PaintLayerScript.PaintType.LAVA:
	# 		_apply_lava_dot(delta)
		# PaintLayerScript.PaintType.STORM:
		# 	_apply_storm_knockback(delta)
	# Flip sprite
	# if input_dir.x != 0:
	# 	if input_dir.x > 0 and not facing_right:
	# 		flip()
	# 		facing_right = true
	# 	elif input_dir.x < 0 and facing_right:
	# 		flip()
	# 		facing_right = false
	# # Movement: dodge impulse overrides input/lerp until duration ends
	# if is_dodging:
	# 	velocity = dodge_velocity
	# 	dodge_timer -= delta
	# 	if dodge_timer <= 0.0:
	# 		is_dodging = false
	# 		var paint_mgr: PaintManager = PaintManager
	# 		if paint_mgr != null:
	# 			paint_mgr.paint_path(dodge_start, global_position, paint_type, 1)
	# else:
	# 	velocity = velocity.lerp(input_dir.normalized() * effective_speed, effective_accel * delta)
	# # Animation: don't interrupt non-looping action animations while playing
	# if animation_sprite.animation in ACTION_ANIMS and animation_sprite.is_playing():
	# 	pass
	# else:
	# 	if velocity.length() > 50:
	# 		animation_sprite.play("run")
	# 	else:
	# 		animation_sprite.play("idle")
	move_and_slide()
	# 冷却缩短
	dodge_handler.update(global_position, delta)


func _update_debuff() -> void:
	var paint_mgr: PaintManager = PaintManager
	if paint_mgr == null or paint_mgr.paint_layer == null:
		return
	var paint: PaintLayerScript.PaintType = paint_mgr.get_paint_at(global_position)
	if paint != current_debuff:
		current_debuff = paint
		debuff_timer = 0.0

## 应用熔岩 DOT 效果
func _apply_lava_dot(delta: float) -> void:
	debuff_timer += delta
	if debuff_timer >= LAVA_DOT_INTERVAL:
		debuff_timer -= LAVA_DOT_INTERVAL
		# TODO: emit damage signal when health system exists.
		# Use push_warning so the tick is visible in the editor without
		# spamming stdout from _physics_process.
		push_warning("Lava DOT tick: %d damage" % LAVA_DOT_DAMAGE)


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
		# var dir := Vector2.RIGHT if facing_right else Vector2.LEFT
		# paint_mgr.paint_fan(global_position, dir, paint_type, 180.0, 8)
		animation_sprite.play("attack")

	elif event.is_action_pressed("throw"):
		# Paint area at mouse cursor (throw landing)
		# var mouse_pos := get_global_mouse_position()
		# paint_mgr.paint_area(mouse_pos, paint_type, 3)
		animation_sprite.play("throw")

	elif event.is_action_pressed("dodge"):
		# Start dodge — record start position, velocity, and timer
		# var dodge_dir := input_dir.normalized() if input_dir != Vector2.ZERO else (Vector2.RIGHT if facing_right else Vector2.LEFT)
		# is_dodging = true
		# dodge_start = global_position
		# dodge_timer = DODGE_DURATION
		# dodge_velocity = dodge_dir * BASE_SPEED * 2.0
		animation_sprite.play("dodge")


# Dodge handler - 闪避处理类
# 处理角色的闪避行为，包括闪避距离、速度、冷却时间等
class DodgeHandler:
	var start_pos: Vector2 = Vector2.ZERO
	var end_pos: Vector2 = Vector2.ZERO
	var direction: Vector2 = Vector2.ZERO
	var is_active: bool = false
	var on_complete: Callable

	var speed: float = 0.0
	var distance: float = 0.0

	# 冷却时间
	var cooldown: float = 0.0
	var cooldown_timer: float = 0.0

	# 闪避持续时间
	var duration: float = 0.0
	var duration_timer: float = 0.0

	func _init(speed_: float, distance_: float, cooldown_: float):
		self.speed = speed_
		self.distance = distance_
		self.cooldown = cooldown_
		self.duration = distance_ / speed_

	func _can_dodge() -> bool:
		return not is_active and cooldown_timer <= 0.0

	func start(from: Vector2, toward: Vector2, callback: Callable) -> void:
		if not _can_dodge():
			return
		if toward == Vector2.ZERO:
			return
		is_active = true
		# is_blocking = false
		direction = toward.normalized()
		start_pos = from
		end_pos = from + direction * distance
		on_complete = callback
		duration_timer = duration


	# 返回 velocity，由外部 move_and_slide 处理
	func update(current_pos: Vector2, delta: float) -> Vector2:
		if cooldown_timer > 0.0:
			cooldown_timer -= delta

		if not is_active:
			return Vector2.ZERO

		duration_timer -= delta
		if duration_timer <= 0.0:
			on_complete.call()
			_finish()
			return Vector2.ZERO

		# 正常闪避：检查是否到达终点
		var to_end = end_pos - current_pos
		if speed * delta >= to_end.length(): # 到达终点
			is_active = false
			on_complete.call()
			_finish()
			return Vector2.ZERO

		return direction * speed
	# 取消闪避
	func cancel() -> void:
		_finish()
	func _finish() -> void:
		is_active = false
		cooldown_timer = cooldown # 进入冷却
		on_complete = Callable()
