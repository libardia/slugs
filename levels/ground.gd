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
@export var load_manager: LoadManager
@export_group("Placement")
@export var water: Node2D
@export var water_depth: float = 10
@export_group("Debug")
@export var skip_placement: bool = false
@export var debug_colors: bool = false
@export var no_background: bool = false

const EPSILON: float = 0
@onready var ground_bg: Sprite2D = $GroundBG
var texture_image: Image
var alpha_bitmap: BitMap
var load_thread: Thread
var ground_quad_scene: PackedScene = preload("res://levels/ground_quadrant.tscn")

var kernel_steps_width: int
var kernel_steps_height: int


func _ready() -> void:
    if not no_background or not OS.is_debug_build():
        ground_bg.texture = ground_texture
    texture_image = ground_texture.get_image()
    alpha_bitmap = BitMap.new()
    alpha_bitmap.create_from_image_alpha(texture_image, transparency_threshold)

    var img_size = texture_image.get_size()
    if not skip_placement or not OS.is_debug_build():
        position = Vector2(
            water.position.x - img_size.x / 2,
            water.position.y - img_size.y + water_depth
        )

    kernel_steps_width = ceili(alpha_bitmap.get_size().x as float / quadrant_size)
    kernel_steps_height = ceili(alpha_bitmap.get_size().y as float / quadrant_size)

    load_manager.register_load_points(kernel_steps_width * kernel_steps_height)

    load_thread = Thread.new()
    load_thread.start(find_polygons)


func _exit_tree():
    load_thread.wait_to_finish()


func find_polygons() -> void:
    var kernel = Rect2i(Vector2i(), Vector2i.ONE * quadrant_size)
    for x in kernel_steps_width:
        for y in kernel_steps_height:
            kernel.position = Vector2i(x, y) * quadrant_size
            var bitmap_polys: Array[PackedVector2Array] = alpha_bitmap.opaque_to_polygons(kernel, EPSILON)
            for raw_poly in bitmap_polys:
                for p in split_if_necessary(kernel, raw_poly):
                    add_poly_and_coll(p.bounds.position, p.polygon)
            load_manager.points_done(1)


func add_poly_and_coll(create_at: Vector2i, polygon: PackedVector2Array) -> void:
    var ground_quad: GroundQuadrant = ground_quad_scene.instantiate()
    ground_quad.position = create_at
    ground_quad.ground_texture_offset = create_at
    ground_quad.polygon_data = polygon
    add_child.call_deferred(ground_quad)


func detect_missing_holes(kernel: Rect2i, polygon: PackedVector2Array) -> Vector2i:
    for x in kernel.size.x:
        for y in kernel.size.y:
            var test_pos = Vector2i(x, y) + kernel.position
            if test_pos.x >= alpha_bitmap.get_size().x:
                continue
            elif test_pos.y >= alpha_bitmap.get_size().y:
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
        if subkernel_a.has_area() and subkernel_b.has_area():
            for p in alpha_bitmap.opaque_to_polygons(subkernel_a, EPSILON):
                results.append_array(split_if_necessary(subkernel_a, p))
            for p in alpha_bitmap.opaque_to_polygons(subkernel_b, EPSILON):
                results.append_array(split_if_necessary(subkernel_b, p))
    if results.is_empty():
        results.append(PolygonWithBounds.new(polygon, kernel))
    return results
