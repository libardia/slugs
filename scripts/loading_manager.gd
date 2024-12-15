class_name LoadManager
extends CanvasLayer


static var inst: LoadManager = null

@export var loading_targets: Array[Node]

var mutex := Mutex.new()
var load_points: int
var total_load_points: int
@onready var progress_bar: ProgressBar = $CenterContainer/ProgressBar
var waiting_for := {}
signal done_loading


func _ready():
    # Make sure the loading screen is shown
    visible = true
    # Hide the nodes to be loaded
    for node in loading_targets:
        node.process_mode = Node.PROCESS_MODE_DISABLED
    # Set static instance
    inst = self


func _exit_tree() -> void:
    print("Cleaning up instance of LoadManager")
    inst = null


func _process(_delta: float) -> void:
    progress_bar.value = load_points
    if waiting_for.is_empty():
        for node in loading_targets:
            node.process_mode = Node.PROCESS_MODE_INHERIT
        done_loading.emit()
        queue_free()


static func has_instance() -> bool:
    return inst != null


static func assert_valid():
    assert(has_instance(), "No instance of LoadManager currently exists.")


static func register_load_points(source: Node, points: int) -> void:
    assert_valid()
    inst.mutex.lock()
    if source in inst.waiting_for:
        inst.waiting_for[source] += points
    else:
        inst.waiting_for[source] = points
    inst.total_load_points += points
    inst.progress_bar.max_value = inst.total_load_points
    inst.mutex.unlock()


static func points_done(source: Node, points: int) -> void:
    assert_valid()
    inst.mutex.lock()
    if source in inst.waiting_for:
        inst.waiting_for[source] -= points
        if inst.waiting_for[source] <= 0:
            inst.waiting_for.erase(source)
    inst.load_points += points
    inst.mutex.unlock()


static func report_done(source: Node) -> void:
    inst.mutex.lock()
    if has_instance():
        if source in inst.waiting_for:
            inst.load_points += inst.waiting_for[source]
            inst.waiting_for.erase(source)
    inst.mutex.unlock()
