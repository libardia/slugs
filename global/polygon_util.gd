class_name PolygonUtil


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
	var min_point: Vector2
	var max_point: Vector2
	var first = true
	for point in polygon:
		if first:
			first = false
			min_point = point
			max_point = point
			continue
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


static func rect_to_polygon(rect: Rect2) -> PackedVector2Array:
	return PackedVector2Array([
		rect.position,
		Vector2(rect.position.x, rect.end.y),
		rect.end,
		Vector2(rect.end.x, rect.position.y)
	])


static func polygon_bounds_as_polygon(polygon: PackedVector2Array) -> PackedVector2Array:
	return rect_to_polygon(polygon_bounds(polygon))


# Returns an array of PackedVector2Arrays, representing the two pieces the polygon will be cut into.
# First result is the top or left side, the second result is the bottom or right side (depending on vertical).
static func cut_polygon(polygon: PackedVector2Array, cut_point: Vector2, vertical: bool) -> Array[Array]:
	var bounds: Rect2 = polygon_bounds(polygon)
	if vertical:
		bounds.end.x = cut_point.x
		bounds = bounds.grow_individual(1, 1, 0, 1)
	else:
		bounds.end.y = cut_point.y
		bounds = bounds.grow_individual(1, 1, 1, 0)
	var clip = rect_to_polygon(bounds)
	var first_side: Array[PackedVector2Array] = Geometry2D.intersect_polygons(polygon, clip)
	var second_side: Array[PackedVector2Array] = Geometry2D.clip_polygons(polygon, clip)
	return [first_side, second_side]
