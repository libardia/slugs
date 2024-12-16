extends Node


var custom_ground := false
var custom_ground_texture: Texture2D


func pick_ground() -> void:
    DisplayServer.file_dialog_show("Custom Ground Image", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["*.png"], capture_dialog)


func capture_dialog(status: bool, selected_paths: PackedStringArray, _selected_filter_index: int):
    if status:
        var img := Image.load_from_file(selected_paths[0])
        var tex := ImageTexture.create_from_image(img)
        custom_ground_texture = tex
    print(status)
