class_name PolygonUtil


static var cache: Dictionary = {}


static func generate_circle(position: Vector2, radius: float, num_sides: int) -> PackedVector2Array:
	var k = [position, radius, num_sides]
	if k in cache:
		return cache[k]

	var angle_delta: float = (PI * 2) / num_sides
	var vector: Vector2 = Vector2(radius, 0)
	var polygon: PackedVector2Array

	for _i in num_sides:
		polygon.append(vector + position)
		vector = vector.rotated(angle_delta)

	cache[k] = polygon
	return polygon


static func offset_polygon(polygon: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var result: PackedVector2Array = polygon.duplicate()
	for i in result.size():
		result[i] += offset
	return result


# Returns an array of PackedVector2Arrays, representing the two pieces the polygon will be cut into.
# First result is the top or left side, the second result is the bottom or right side (depending on vertical).
static func cut_polygon(polygon: PackedVector2Array, cut_point: Vector2, vertical: bool) -> Array[Array]:
	# TODO: Clip off one side, clip off other side
	# TODO: Make the polygon bounding util also, that will help here
	return []
