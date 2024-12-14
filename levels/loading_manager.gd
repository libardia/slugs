class_name LoadManager
extends Control


@export var loading_targets: Array[Node2D]

var mutex: Mutex = Mutex.new()
var load_points: int
var total_load_points: int
@onready var progress_bar: ProgressBar = $ProgressBar


signal done_loading


func _ready():
	# Hide the nodes to be loaded
	for node in loading_targets:
		node.process_mode = Node.PROCESS_MODE_DISABLED
		node.visible = false

	# Set up control
	position = Vector2.ZERO
	size = get_viewport_rect().size


func _process(_delta: float) -> void:
	progress_bar.value = (float(load_points) / float(total_load_points)) * 100
	if load_points >= total_load_points:
		done()


func register_load_points(points: int) -> void:
	mutex.lock()
	total_load_points += points
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
