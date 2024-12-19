extends Node


signal progress_changed
signal loading_done

var loading_screen: PackedScene = preload(GlobalData.SCENEPATH_LOADING_SCREEN)
var loading_screen_root: LoadingScreen
var loaded_scene_path: String
var loaded_scene: PackedScene
var sub_threads: bool
var progress := []


func _ready():
    process_mode = PROCESS_MODE_DISABLED


func load_scene(scene_path: String, use_sub_threads: bool = false):
    sub_threads = use_sub_threads
    loaded_scene_path = scene_path
    loading_screen_root = loading_screen.instantiate()
    progress_changed.connect(loading_screen_root._on_progress_changed)
    loading_done.connect(loading_screen_root._on_loading_done)
    loading_screen_root.loading_screen_ready.connect(start_load)
    loading_screen_root.loading_screen_finished.connect(cleanup_loading_scene)
    add_child(loading_screen_root)


func start_load():
    var state := ResourceLoader.load_threaded_request(loaded_scene_path, "", sub_threads)
    if state == OK:
        process_mode = PROCESS_MODE_ALWAYS


func _process(_delta):
    var load_status := ResourceLoader.load_threaded_get_status(loaded_scene_path, progress)
    match load_status:
        ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
            # Scene could not be loaded
            push_error("Loading scene '%s' failed" % loaded_scene_path)
            process_mode = PROCESS_MODE_DISABLED

        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            # Scene in the process of being loaded
            progress_changed.emit(progress[0])

        ResourceLoader.THREAD_LOAD_LOADED:
            # Scene is done loading
            loaded_scene = ResourceLoader.load_threaded_get(loaded_scene_path)
            progress_changed.emit(1.0)
            get_tree().change_scene_to_packed(loaded_scene)
            print("immediately after scene change")
            loading_done.emit()
            process_mode = PROCESS_MODE_DISABLED


func cleanup_loading_scene():
    loading_screen_root.queue_free()
