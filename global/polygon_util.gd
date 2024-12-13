class_name PolygonUtil


class CutResult:
	var side_a: Array[PackedVector2Array]
	var side_b: Array[PackedVector2Array]


static var circle_cache: Dictionary = {}


static func generate_circle(position: Vector2, radius: float, num_sides: int) -> PackedVector2Array:
	var k = [position, radius, num_sides]
	if k in circle_cache:
		return circle_cache[k]

	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var polygon: PackedVector2Array

	for _i in num_sides:
		polygon.append(vector + position)
		vector = vector.rotated(angle_delta)

	circle_cache[k] = polygon
	return polygon


static func offset_polygon(polygon: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var result: PackedVector2Array = polygon.duplicate()
	for i in result.size():
		result[i] += offset
	return result


static func polygon_bounds(polygon: PackedVector2Array) -> Rect2:
	var min_point: Vector2 = polygon[0]
	var max_point: Vector2 = polygon[0]
	for point in polygon:
		if min_point.x > point.x:
			min_point.x = point.x
		if min_point.y > point.y:
			min_point.y = point.y
		if max_point.x < point.x:
			max_point.x = point.x
		if max_point.y < point.y:
			max_point.y = point.y
	var result = Rect2()
	result.position = min_point
	result.end = max_point
	return result


static func find_top_left(polygon: PackedVector2Array) -> Vector2:
	var min_point = polygon[0]
	for point in polygon:
		if min_point.x > point.x:
			min_point.x = point.x
		if min_point.y > point.y:
			min_point.y = point.y
	return min_point


static func rect_to_polygon(rect: Rect2) -> PackedVector2Array:
	return PackedVector2Array([
		rect.position,
		Vector2(rect.position.x, rect.end.y),
		rect.end,
		Vector2(rect.end.x, rect.position.y)
	])


static func polygon_bounds_as_polygon(polygon: PackedVector2Array) -> PackedVector2Array:
	return rect_to_polygon(polygon_bounds(polygon))


# Returns an array of arrays of PackedVector2Arrays, representing the two pieces the polygon will be cut into.
# First result is the top or left side, the second result is the bottom or right side (depending on vertical).
static func cut_polygon(polygon: PackedVector2Array, cut_point: Vector2) -> CutResult:
	var bounds: Rect2 = polygon_bounds(polygon)
	if decide_cut_direction_by_aspect(bounds):
		bounds.end.x = cut_point.x
		bounds = bounds.grow_individual(1, 1, 0, 1)
	else:
		bounds.end.y = cut_point.y
		bounds = bounds.grow_individual(1, 1, 1, 0)
	var clip = rect_to_polygon(bounds)
	var cut_result: CutResult = CutResult.new()
	cut_result.side_a = Geometry2D.intersect_polygons(polygon, clip)
	cut_result.side_b = Geometry2D.clip_polygons(polygon, clip)
	return cut_result


static func decide_cut_direction_by_center(rect: Rect2, cut_pos: Vector2) -> bool:
	cut_pos -= rect.position
	rect.position = Vector2.ZERO
	var diff = (rect.size / 2) - cut_pos
	return abs(diff.x) <= abs(diff.y)


static func decide_cut_direction_by_aspect(rect: Rect2) -> bool:
	return rect.size.x > rect.size.y
