class_name LoadingScreen
extends CanvasLayer


@warning_ignore("unused_signal")
signal loading_screen_ready
@warning_ignore("unused_signal")
signal loading_screen_finished


@warning_ignore("unused_parameter")
func _on_progress_changed(progress: float):
    pass


func _on_loading_done():
    pass


@warning_ignore("unused_parameter")
func _on_set_message(message: String):
    pass
