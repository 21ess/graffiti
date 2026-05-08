@tool
extends TileMapLayer

## Paint layer — 8x8 瓦片的涂鸦层
##
## 该层用于在画面上显示玩家绘制的涂鸦

## PaintType — 涂鸦类型
enum PaintType {
	NONE = -1,
	ICE = 0, # tscn terrain_0
	LAVA = 1, # tscn terrain_1
	VINE = 2, # tscn terrain_2
}

const TILE_SIZE := Vector2i(8, 8)

## Index of the terrain set in the TileSet. The tscn defines exactly one set.
const TERRAIN_SET_ID := 0


func _ready() -> void:
	if tile_set == null:
		push_warning("PaintLayer: tile_set is null. Instantiate via paint_layer.tscn so the configured TileSet is available.")


## 根据传入的世界位置 world_pos 绘制涂鸦
func paint_at(world_pos: Vector2, paint_type: PaintType) -> void:
	if paint_type == PaintType.NONE:
		return
	var cell_pos := local_to_map(to_local(world_pos))
	set_cells_terrain_connect([cell_pos], TERRAIN_SET_ID, int(paint_type))


## 根据传入的 paint_layer 的瓦片坐标 cells 绘制涂鸦
func paint_cells(cells: Array[Vector2i], paint_type: PaintType) -> void:
	if cells.is_empty() or paint_type == PaintType.NONE:
		return
	set_cells_terrain_connect(cells, TERRAIN_SET_ID, int(paint_type))


## 获取传入的世界位置 world_pos 处的涂鸦类型
## 如果该位置没有涂鸦或没有地形，则返回 PaintType.NONE
func get_paint_at(world_pos: Vector2) -> PaintType:
	var cell_pos := local_to_map(to_local(world_pos))
	var data := get_cell_tile_data(cell_pos)
	if data == null:
		return PaintType.NONE
	var terrain_id := data.terrain
	if terrain_id == -1:
		return PaintType.NONE
	return terrain_id as PaintType


## 根据传入的世界位置 world_pos 删除涂鸦
func erase_at(world_pos: Vector2) -> void:
	var cell_pos := local_to_map(to_local(world_pos))
	set_cells_terrain_connect([cell_pos], TERRAIN_SET_ID, -1)
