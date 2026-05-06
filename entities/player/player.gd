extends CharacterBody2D

const SPEED: int = 400
const ACCELERATION: int = 50 # 加速

var input_dir: Vector2 = Vector2.ZERO # 玩家输出方向
var facing_right: bool = true
@onready var animation = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")

	# 只有在有输入，且输入方向与当前记录朝向不一致时，才翻转
	if input_dir.x != 0:
		if input_dir.x > 0 and not facing_right:
			flip()
			facing_right = true
		elif input_dir.x < 0 and facing_right:
			flip()
			facing_right = false

	velocity = velocity.lerp(input_dir.normalized() * SPEED, ACCELERATION * delta)
	if velocity.length() > 50:
		animation.play("run")
	else:
		animation.play("idle")
	move_and_slide()

func flip() -> void:
	scale.x *= -1
