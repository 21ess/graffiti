extends Node

## 涂鸦层(paint_layer)管理器
##
## 解耦 paint_layer 和 玩家/敌人/物品等的依赖关系
## 管理器是 AutoLoad 的，在场景加载时自动初始化
## 提供绘制区域的方法
const PaintLayerScript = preload("res://entities/terrain/paint/paint_layer.gd")

## paint_layer 由持有 PaintLayer 节点的场景（如 main.gd）在 _ready 中显式赋值
## 这样无需依赖 autoload 与 main scene 的初始化时序，也不再靠脆弱的节点搜索
var paint_layer: TileMapLayer


## 绘制一个以 world_pos 为中心，大小为 brush_size 的正方形涂鸦区域
func paint_at(world_pos: Vector2, paint_type: PaintLayerScript.PaintType, brush_size: int = 3) -> void:
	if paint_layer == null:
		return
	var half := brush_size >> 1
	var center_cell: Vector2i = paint_layer.local_to_map(paint_layer.to_local(world_pos))
	var cells: Array[Vector2i] = []
	for x in range(-half, half + 1):
		for y in range(-half, half + 1):
			cells.append(center_cell + Vector2i(x, y))
	paint_layer.paint_cells(cells, paint_type)


## 绘制一个以 origin 为中心，角度为 angle_degrees ，半径为 radius 的扇形涂鸦区域
func paint_fan(origin: Vector2, direction: Vector2, paint_type: PaintLayerScript.PaintType, angle_degrees: float = 90.0, radius: int = 4) -> void:
	if paint_layer == null:
		return
	var half_angle := deg_to_rad(angle_degrees / 2.0) # 角度转弧度
	var center_cell: Vector2i = paint_layer.local_to_map(paint_layer.to_local(origin)) # 转化为 TileMap 的网格坐标
	var cells: Array[Vector2i] = []
	var seen: Dictionary = {}

	for r in range(1, radius + 1):
		for angle_step in range(-10, 11): # [-10, 10] abs = 10，将一半弧度10 等分
			var angle := angle_step * half_angle / 10.0
			var dir := direction.rotated(angle)
			var offset := Vector2i(dir.normalized() * r)
			var cell := center_cell + offset
			if not seen.has(cell):
				seen[cell] = true
				cells.append(cell)

	paint_layer.paint_cells(cells, paint_type)


## 绘制一个圆心为 center ，半径为 radius 的圆形涂鸦区域
func paint_area(center: Vector2, paint_type: PaintLayerScript.PaintType, radius: int = 3) -> void:
	if paint_layer == null:
		return
	var center_cell: Vector2i = paint_layer.local_to_map(paint_layer.to_local(center))
	var cells: Array[Vector2i] = []

	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			if Vector2(x, y).length() <= radius:
				cells.append(center_cell + Vector2i(x, y))

	paint_layer.paint_cells(cells, paint_type)


## 绘制一条从 start 到 end 的涂鸦路径
func paint_path(start: Vector2, end: Vector2, paint_type: PaintLayerScript.PaintType, width: int = 1) -> void:
	if paint_layer == null:
		return

	## 转换为 paint_layer 层 的网格坐标
	var start_cell: Vector2i = paint_layer.local_to_map(paint_layer.to_local(start))
	var end_cell: Vector2i = paint_layer.local_to_map(paint_layer.to_local(end))
	var line_cells := _bresenham_line(start_cell, end_cell)
	var half_w := width >> 1
	var cells: Array[Vector2i] = []
	var seen: Dictionary = {}

	for cell in line_cells:
		for x in range(-half_w, half_w + 1):
			for y in range(-half_w, half_w + 1):
				var c := cell + Vector2i(x, y)
				if not seen.has(c):
					seen[c] = true
					cells.append(c)

	paint_layer.paint_cells(cells, paint_type)


## 根据世界坐标world_pos获取涂鸦类型
func get_paint_at(world_pos: Vector2) -> PaintLayerScript.PaintType:
	if paint_layer == null:
		return PaintLayerScript.PaintType.NONE
	return paint_layer.get_paint_at(world_pos)


## Bresenham line algorithm 获取从 start 到 end 的路径上的所有网格坐标
func _bresenham_line(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var dx := absi(end.x - start.x)
	var dy := -absi(end.y - start.y)
	var sx := 1 if start.x < end.x else -1
	var sy := 1 if start.y < end.y else -1
	var err := dx + dy
	var current := start

	while true:
		cells.append(current)
		if current == end:
			break
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			current.x += sx
		if e2 <= dx:
			err += dx
			current.y += sy

	return cells
