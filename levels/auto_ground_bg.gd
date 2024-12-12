@tool
extends Sprite2D


@onready var ground: Ground = $".."


func _process(_delta: float) -> void:
	texture = ground.ground_texture
