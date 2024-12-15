extends Node2D


@export var player_ref: Slug
var place_tool: DebugPlace

func _ready() -> void:
    if not OS.is_debug_build():
        queue_free()
        return
    place_tool = $Place
    place_tool.player_ref = player_ref
