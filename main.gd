extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PaintManager.paint_layer = $PaintLayer
	$StartPosition.position = Vector2(500, 300)
	$Player.position = $StartPosition.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
