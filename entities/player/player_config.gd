class_name CharacterConfig
extends Resource
# 角色基础配置资源类

@export var name: String = "Default" # 角色名称
@export var base_speed: int = 400 # 基础速度
@export var acceleration: int = 50 # 加速度
@export var dodge_speed: int = 800 # 闪避速度
@export var dodge_distance: float = 150.0 # 闪避距离
@export var dodge_cooldown: float = 0.5 # 闪避冷却时间