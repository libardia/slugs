class_name LoadingScreen
extends CanvasLayer


@warning_ignore("unused_signal")
signal loading_screen_ready
@warning_ignore("unused_signal")
signal loading_screen_finished


func _ready():
    print("loading screen base")


@warning_ignore("unused_parameter")
func _on_progress_changed(progress: float):
    pass


func _on_loading_done():
    pass
