extends Node2D


@export var explosion_scene: PackedScene
@export var camera_reference: Camera2D


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			var explosion = explosion_scene.instantiate() as Node2D
			var cam_topleft = camera_reference.position - camera_reference.get_viewport_rect().size / 2
			explosion.position = event.global_position + cam_topleft
			add_child(explosion)
