@tool
extends Sprite2D


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		texture = (get_parent() as Ground).ground_texture
