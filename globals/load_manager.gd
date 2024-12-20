extends Node


enum LoadingType { NOT_LOADING, FILE, READY}


signal progress_changed(progress: float)
signal loading_done
signal set_message(message: String)

# For file loading
var loading_screen: PackedScene = preload(GlobalData.SCENEPATH_LOADING_SCREEN)
var loading_screen_root: LoadingScreen
var loaded_scene_path: String
var loaded_scene: PackedScene
var sub_threads: bool
var currently_loading := LoadingType.NOT_LOADING
var file_load_progress := []

# For scene ready loading
var mutex := Mutex.new()
var nodes_waiting: Array[Node] = []
var ready_loading_points_total := 0.0
var ready_loading_points := 0.0


func _ready():
    process_mode = PROCESS_MODE_DISABLED


func load_scene(scene_path: String, use_sub_threads: bool = false):
    sub_threads = use_sub_threads
    loaded_scene_path = scene_path
    loading_screen_root = loading_screen.instantiate()
    currently_loading = LoadingType.FILE
    # Lots of signals
    progress_changed.connect(loading_screen_root._on_progress_changed)
    loading_done.connect(loading_screen_root._on_loading_done)
    set_message.connect(loading_screen_root._on_set_message)
    loading_screen_root.loading_screen_ready.connect(start_load)
    loading_screen_root.loading_screen_finished.connect(cleanup_loading_scene)
    # Finally add the loading screen
    add_child(loading_screen_root)
    set_message.emit("Loading...")


func start_load():
    var state := ResourceLoader.load_threaded_request(loaded_scene_path, "", sub_threads)
    if state == OK:
        ResourceLoader.load_threaded_get_status(loaded_scene_path, file_load_progress)
        process_mode = PROCESS_MODE_ALWAYS


func register_load_points(source: Node, points: float):
    mutex.lock()
    if source not in nodes_waiting:
        nodes_waiting.append(source)
    ready_loading_points_total += points
    mutex.unlock()


func report_points_done(points: float):
    mutex.lock()
    ready_loading_points += points
    mutex.unlock()


func report_node_done(node: Node):
    mutex.lock()
    nodes_waiting.erase(node)
    mutex.unlock()


func _process(_delta):
    if currently_loading == LoadingType.FILE:
        process_load_file()
    elif currently_loading == LoadingType.READY:
        process_load_ready()


func process_load_file():
    var load_status := ResourceLoader.load_threaded_get_status(loaded_scene_path, file_load_progress)
    match load_status:
        ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
            # This is returned when the requested path isn't being loaded, but
            # unfortunately it will return this just after the load starts too
            return

        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            # Scene in the process of being loaded
            progress_changed.emit(file_load_progress[0])

        ResourceLoader.THREAD_LOAD_FAILED:
            # Scene failed to load
            push_error("Loading scene '%s' failed" % loaded_scene_path, load_status)
            process_mode = PROCESS_MODE_DISABLED

        ResourceLoader.THREAD_LOAD_LOADED:
            # Scene is done loading
            loaded_scene = ResourceLoader.load_threaded_get(loaded_scene_path)
            progress_changed.emit(1.0)
            get_tree().change_scene_to_packed(loaded_scene)
            if loaded_scene_path in GlobalData.LOADMANAGER_LOAD_READY_MESSAGES:
                set_message.emit(GlobalData.LOADMANAGER_LOAD_READY_MESSAGES[loaded_scene_path])
                currently_loading = LoadingType.READY
                progress_changed.emit(0.0)
            else:
                loading_done.emit()
                currently_loading = LoadingType.NOT_LOADING
                process_mode = PROCESS_MODE_DISABLED


func process_load_ready():
    if not nodes_waiting.is_empty():
        var cur_scene := get_tree().current_scene
        if cur_scene != null and cur_scene.process_mode != PROCESS_MODE_DISABLED:
            cur_scene.process_mode = PROCESS_MODE_DISABLED
        progress_changed.emit(ready_loading_points / ready_loading_points_total)
    else:
        progress_changed.emit(1.0)
        loading_done.emit()
        currently_loading = LoadingType.NOT_LOADING
        process_mode = PROCESS_MODE_DISABLED
        get_tree().current_scene.process_mode = PROCESS_MODE_INHERIT


func cleanup_loading_scene():
    loading_screen_root.queue_free()
