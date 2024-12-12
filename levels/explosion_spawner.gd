extends Node2D


@export var explosion_scene: PackedScene


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			var explosion = explosion_scene.instantiate() as Node2D
			explosion.position = event.position
			add_child(explosion)
