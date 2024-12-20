class_name CustomCamera
extends Camera2D


enum AnchorVert { CENTER, TOP, BOTTOM }
enum AnchorHorz { CENTER, LEFT, RIGHT }


static var inst: CustomCamera

@export_group("Initial positioning")
@export var camera_anchor: Node2D
@export var anchor_vertical: AnchorVert
@export var anchor_horizontal: AnchorHorz
@export var anchor_offset: Vector2
@export_group("Control")
@export var zoom_enabled := true
@export var zoom_step := 0.1


var dragging := false
@onready var zoom_mult := 1 - zoom_step
@onready var zoom_mult_inv := 1 / zoom_mult


func _ready() -> void:
    inst = self
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


func _exit_tree() -> void:
    inst = null


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("camera-drag"):
        dragging = true
    elif event.is_action_released("camera-drag"):
        dragging = false
    elif event.is_action_pressed("camera-zoom-in") and zoom_enabled:
        var orig_pos = get_global_mouse_position()
        zoom *= zoom_mult_inv
        var new_pos = get_global_mouse_position()
        position += orig_pos - new_pos
    elif event.is_action_pressed("camera-zoom-out") and zoom_enabled:
        var orig_pos = get_global_mouse_position()
        zoom *= zoom_mult
        var new_pos = get_global_mouse_position()
        position += orig_pos - new_pos
    elif event is InputEventMouseMotion and dragging:
        event = event as InputEventMouseMotion
        position -= event.relative / zoom


func viewport_pos_to_scene(viewport_position: Vector2) -> Vector2:
    return ((viewport_position - get_viewport_rect().size * 0.5) / zoom) + position


static func global_mouse_position() -> Vector2:
    assert(is_instance_valid(inst), "Camera instance was invalid; you can only call this method in a scene that includes this camera")
    return inst.get_global_mouse_position()
