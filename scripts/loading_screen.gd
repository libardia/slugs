extends LoadingScreen


@onready var message_label: Label = $VBoxContainer/Message
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar


func _ready():
    progress_bar.min_value = 0
    progress_bar.max_value = 1
    loading_screen_ready.emit()


func _on_progress_changed(progress: float):
    progress_bar.value = progress


func _on_loading_done():
    loading_screen_finished.emit()


func _on_set_message(message: String):
    message_label.text = message
