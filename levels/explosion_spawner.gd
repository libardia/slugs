extends Node2D


@export var explosion_scene: PackedScene
@export var camera_reference: Camera2D


@export var click: bool = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and click:
		event = event as InputEventMouseButton
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			var explosion = explosion_scene.instantiate() as Node2D
			var cam_topleft = camera_reference.position - camera_reference.get_viewport_rect().size / 2
			explosion.position = cam_topleft + event.position
			add_child(explosion)


func _process(_delta: float) -> void:
	if not click:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var explosion = explosion_scene.instantiate() as Node2D
			var cam_topleft = camera_reference.position - camera_reference.get_viewport_rect().size / 2
			explosion.position = cam_topleft + get_viewport().get_mouse_position()
			add_child(explosion)
