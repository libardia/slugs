extends Camera2D


enum AnchorVert { CENTER, TOP, BOTTOM }
enum AnchorHorz { CENTER, LEFT, RIGHT }


@export var camera_anchor: Node2D
@export var anchor_vertical: AnchorVert
@export var anchor_horizontal: AnchorHorz
@export var anchor_offset: Vector2


func _ready() -> void:
	position = camera_anchor.position + anchor_offset
	var half_size = get_viewport_rect().size * 0.5
	match anchor_vertical:
		AnchorVert.TOP:
			position.y += half_size.y
		AnchorVert.BOTTOM:
			position.y -= half_size.y
	match anchor_horizontal:
		AnchorHorz.LEFT:
			position.x += half_size.x
		AnchorHorz.RIGHT:
			position.x -= half_size.x
