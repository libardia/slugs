extends Label


@export var ground: Ground
var format_string: String


func _ready():
    format_string = text


func _process(_delta):
    text = format_string % ground.get_child_count()
