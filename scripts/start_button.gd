extends Button


func _pressed():
    # GroundLoader.pick_ground()
    # get_tree().change_scene_to_file(GlobalData.SCENEPATH_LEVEL)
    LoadManager.load_scene(GlobalData.SCENEPATH_LEVEL)
