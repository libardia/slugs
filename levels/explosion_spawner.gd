extends Node2D


@export var explosion_scene: PackedScene
@export var camera_reference: CustomCamera


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        event = event as InputEventMouseButton
        if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
            var explosion = explosion_scene.instantiate() as Node2D
            explosion.position = camera_reference.viewport_pos_to_scene(event.position)
            add_child(explosion)
