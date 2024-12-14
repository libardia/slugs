extends Label


@export var ground: Ground
var format_string: String


func _ready():
    format_string = text


func _process(_delta):
    # Minus one because one of the children is the bg
    text = format_string % (ground.get_child_count() - 1)
