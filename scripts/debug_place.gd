class_name DebugPlace
extends Node2D


var player_ref: Slug


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("debug-place"):
        player_ref.position = CustomCamera.global_mouse_position()
        player_ref.velocity = Vector2.ZERO
