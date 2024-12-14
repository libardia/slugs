class_name LoadManager
extends CanvasLayer


@export var loading_targets: Array[Node]

var mutex: Mutex = Mutex.new()
var load_points: int
var total_load_points: int
@onready var progress_bar: ProgressBar = $CenterContainer/ProgressBar


signal done_loading


func _ready():
    # Hide the nodes to be loaded
    for node in loading_targets:
        node.process_mode = Node.PROCESS_MODE_DISABLED
        node.visible = false


func _process(_delta: float) -> void:
    progress_bar.value = load_points
    if load_points >= total_load_points:
        done()


func register_load_points(points: int) -> void:
    mutex.lock()
    total_load_points += points
    progress_bar.max_value = total_load_points
    mutex.unlock()


func points_done(points: int) -> void:
    mutex.lock()
    load_points += points
    mutex.unlock()


func done():
    for node in loading_targets:
        node.process_mode = Node.PROCESS_MODE_INHERIT
        node.visible = true
    done_loading.emit()
    queue_free()
