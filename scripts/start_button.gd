extends Button


@export var scene_file: String


func _pressed():
    get_tree().change_scene_to_file(scene_file)