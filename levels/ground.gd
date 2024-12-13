class_name Ground
extends Node2D


class PolygonWithBounds:
	func _init(_polygon: PackedVector2Array, _bounds: Rect2i) -> void:
		self.polygon = _polygon
		self.bounds = _bounds
	var polygon: PackedVector2Array
	var bounds: Rect2i


@export_group("Generation")
@export var ground_texture: Texture2D
@export var transparency_threshold: float = 0.8
@export var quadrant_size: int = 128
@export_group("Placement")
@export var water: Node2D
@export var water_depth: float = 10
@export_group("Debug")
@export var skip_placement: bool = false
@export var debug_colors: bool = false
@export var no_background: bool = false

@onready var ground_bg: Sprite2D = $GroundBG
var texture_image: Image
var alpha_bitmap: BitMap
var total_polygons: int
const epslion: float = 0


func _ready() -> void:
	ground_bg.texture = ground_texture
	texture_image = ground_texture.get_image()
	alpha_bitmap = BitMap.new()
	alpha_bitmap.create_from_image_alpha(texture_image, transparency_threshold)

	find_polygons()

	var img_size = texture_image.get_size()
	if not skip_placement or not OS.is_debug_build():
		position = Vector2(
			water.position.x - img_size.x / 2,
			water.position.y - img_size.y + water_depth
		)


func find_polygons() -> void:
	var kernel = Rect2i(Vector2i(), Vector2i.ONE * quadrant_size)
	var kernel_steps_width = ceili(alpha_bitmap.get_size().x as float / quadrant_size)
	var kernel_steps_height = ceili(alpha_bitmap.get_size().y as float / quadrant_size)
	total_polygons = 0
	for x in kernel_steps_width:
		for y in kernel_steps_height:
			kernel.position = Vector2i(x, y) * quadrant_size
			var bitmap_polys: Array[PackedVector2Array] = alpha_bitmap.opaque_to_polygons(kernel, epslion)
			for raw_poly in bitmap_polys:
				for p in split_if_necessary(kernel, raw_poly):
					add_poly_and_coll(p.bounds.position, p.polygon, total_polygons)
					total_polygons += 1


func add_poly_and_coll(create_at: Vector2i, polygon: PackedVector2Array, id: int, runtime: bool = false) -> void:
	var name_postfix = "_run" if runtime else ""

	var static_body = StaticBody2D.new()
	static_body.position = create_at
	static_body.collision_layer = 0b1
	static_body.collision_mask = 0b111
	static_body.name = str("GroundBody", id, name_postfix)
	call_deferred("add_child", static_body)

	var poly = Polygon2D.new()
	if debug_colors and OS.is_debug_build():
		poly.color = Color(randf(), randf(), randf())
	else:
		poly.texture = ground_texture
		poly.texture_offset = create_at
		poly.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	poly.set_deferred("polygon", polygon)
	poly.name = str("GroundPoly", id, name_postfix)
	static_body.call_deferred("add_child", poly)

	var poly_coll = CollisionPolygon2D.new()
	poly_coll.set_deferred("polygon", polygon)
	poly_coll.name = str("GroundColl", id, name_postfix)
	static_body.call_deferred("add_child", poly_coll)


func detect_missing_holes(kernel: Rect2i, polygon: PackedVector2Array) -> Vector2i:
	for x in kernel.size.x:
		for y in kernel.size.y:
			var test_pos = Vector2i(x, y) + kernel.position
			if not Vector2Ex.cw_less_than(test_pos, alpha_bitmap.get_size()):
				continue
			if not alpha_bitmap.get_bitv(test_pos) and Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), polygon):
				return test_pos
	return -Vector2i.ONE


func split_if_necessary(kernel: Rect2i, polygon: PackedVector2Array) -> Array[PolygonWithBounds]:
	var results: Array[PolygonWithBounds] = []
	var hole_pos: Vector2i = detect_missing_holes(kernel, polygon)
	if hole_pos != -Vector2i.ONE:
		var subkernel_a: Rect2i = Rect2i(kernel)
		var subkernel_b: Rect2i = Rect2i(kernel)

		if PolygonUtil.decide_cut_direction_by_aspect(kernel):
			subkernel_a.end.x = hole_pos.x
			subkernel_b.size.x = kernel.size.x - subkernel_a.size.x
			subkernel_b.position.x = hole_pos.x
		else:
			subkernel_a.end.y = hole_pos.y
			subkernel_b.size.y = kernel.size.y - subkernel_a.size.y
			subkernel_b.position.y = hole_pos.y
		for p in alpha_bitmap.opaque_to_polygons(subkernel_a, epslion):
			results.append_array(split_if_necessary(subkernel_a, p))
		for p in alpha_bitmap.opaque_to_polygons(subkernel_b, epslion):
			results.append_array(split_if_necessary(subkernel_b, p))
	else:
		results.append(PolygonWithBounds.new(polygon, kernel))
	return results


func cut_section(ground_body: StaticBody2D, clip_polygon: PackedVector2Array) -> void:
	if ground_body not in get_children():
		push_error("Tried to clip something that wasn't a ground quadrant")
		return
