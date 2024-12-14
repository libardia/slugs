class_name GroundQuadrant
extends StaticBody2D


@onready var polygon_img: Polygon2D = get_child(0)
@onready var polygon_coll: CollisionPolygon2D = get_child(1)
@onready var ground: Ground = get_parent()


var polygon_data: PackedVector2Array
var ground_texture_offset: Vector2


func _ready():
    if ground.debug_colors and OS.is_debug_build():
        polygon_img.color = Color(randf(), randf(), randf())
    else:
        polygon_img.texture = ground.ground_texture
        polygon_img.texture_offset = ground_texture_offset
        polygon_img.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    polygon_img.polygon = polygon_data
    polygon_coll.polygon = polygon_data


func clip(clip_polygon: PackedVector2Array, clip_polygon_offset: Vector2):
    var offset_poly: PackedVector2Array = PolygonUtil.offset_polygon(clip_polygon, clip_polygon_offset)

    var new_polys = Geometry2D.clip_polygons(polygon_img.polygon, offset_poly)
    var enclosed = false
    for p in new_polys:
        if Geometry2D.is_polygon_clockwise(p):
            enclosed = true
            break
    if enclosed:
        new_polys = []
        var sides = PolygonUtil.cut_polygon(polygon_img.polygon, clip_polygon_offset)
        for p in sides.side_a:
            new_polys.append_array(Geometry2D.clip_polygons(p, offset_poly))
        for p in sides.side_b:
            new_polys.append_array(Geometry2D.clip_polygons(p, offset_poly))
    if new_polys.is_empty():
        queue_free()
    else:
        polygon_img.set_deferred("polygon", new_polys[0])
        polygon_coll.set_deferred("polygon", new_polys[0])
        if new_polys.size() > 1:
            for i in range(1, new_polys.size()):
                ground.add_poly_and_coll(position, new_polys[i])
