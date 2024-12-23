extends Button


func _pressed():
    GroundLoader.pick_ground()
    LoadManager.load_scene(ScenePaths.LEVEL)
