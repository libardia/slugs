extends Button


func _pressed():
    GroundLoader.pick_ground()
    LoadManager.load_scene(GlobalData.SCENEPATH_LEVEL)
