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
