extends Node


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("debug-quit") and OS.is_debug_build():
        get_tree().quit()
