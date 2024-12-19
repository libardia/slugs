extends Node


# Scene paths
const SCENEPATH_MAIN_MENU := "res://scenes/main_menu.tscn"
const SCENEPATH_LEVEL := "res://scenes/level.tscn"
const SCENEPATH_LOADING_SCREEN := "res://scenes/loading_screen.tscn"

# Scenes here have another step in the load manager to wait for scenes with complex _ready
const LOADMANAGER_ALSO_LOAD_READY := [
    SCENEPATH_LEVEL
]
