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

@onready var ground_bg: Sprite2D = $GroundBG
var texture_image: Image
var alpha_bitmap: BitMap


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
	var i = 0
	for x in kernel_steps_width:
		for y in kernel_steps_height:
			kernel.position = Vector2i(x, y) * quadrant_size
			var bitmap_polys: Array[PackedVector2Array] = alpha_bitmap.opaque_to_polygons(kernel, 0)
			for raw_poly in bitmap_polys:
				for p in split_if_necessary(kernel, raw_poly, true):
					add_poly_and_coll(p.bounds, p.polygon, i)
					i += 1


func add_poly_and_coll(kernel: Rect2i, polygon: PackedVector2Array, id: int) -> void:
	var static_body = StaticBody2D.new()
	var poly = Polygon2D.new()
	var poly_coll = CollisionPolygon2D.new()
	if debug_colors and OS.is_debug_build():
		poly.color = Color(randf(), randf(), randf())
	else:
		poly.texture = ground_texture
	poly.polygon = polygon
	poly_coll.polygon = polygon
	poly.offset = kernel.position
	poly_coll.position = kernel.position
	poly.name = str("Quad", id)
	poly_coll.name = str("Coll", id)
	static_body.collision_layer = 0b1
	static_body.collision_mask = 0b111
	static_body.name = str("GroundBody", id)
	add_child(static_body)
	static_body.add_child(poly)
	static_body.add_child(poly_coll)


func detect_missing_holes(kernel: Rect2i, polygon: PackedVector2Array) -> Vector2i:
	for x in kernel.size.x:
		for y in kernel.size.y:
			var test_pos = Vector2i(x, y) + kernel.position
			if not Vector2Ex.cw_less_than(test_pos, alpha_bitmap.get_size()):
				continue
			if not alpha_bitmap.get_bitv(test_pos) and Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), polygon):
				return test_pos
	return -Vector2i.ONE


func split_if_necessary(kernel: Rect2i, polygon: PackedVector2Array, vertical: bool) -> Array[PolygonWithBounds]:
	var results: Array[PolygonWithBounds] = []
	var hole_pos: Vector2i = detect_missing_holes(kernel, polygon)
	if hole_pos != -Vector2i.ONE:
		var subkernel_a: Rect2i = Rect2i(kernel)
		var subkernel_b: Rect2i = Rect2i(kernel)

		vertical = decide_cut(kernel, hole_pos)
		if vertical:
			subkernel_a.end.x = hole_pos.x
			subkernel_b.size.x = kernel.size.x - subkernel_a.size.x
			subkernel_b.position.x = hole_pos.x
		else:
			subkernel_a.end.y = hole_pos.y
			subkernel_b.size.y = kernel.size.y - subkernel_a.size.y
			subkernel_b.position.y = hole_pos.y
		# print(subkernel_a, subkernel_b)
		for p in alpha_bitmap.opaque_to_polygons(subkernel_a, 0):
			results.append_array(split_if_necessary(subkernel_a, p, not vertical))
		for p in alpha_bitmap.opaque_to_polygons(subkernel_b, 0):
			results.append_array(split_if_necessary(subkernel_b, p, not vertical))
	else:
		results.append(PolygonWithBounds.new(polygon, kernel))
	return results


func decide_cut(kernel: Rect2i, cut_pos: Vector2i) -> bool:
	cut_pos -= kernel.position
	kernel.position = Vector2i.ZERO
	var diff = (kernel.size / 2) - cut_pos
	return abs(diff.x) <= abs(diff.y)
