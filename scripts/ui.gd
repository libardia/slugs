extends CanvasLayer


@export var ground: Ground


@onready var total_quads: Label = $TotalQuads
@onready var tq_format: String = total_quads.text


func _process(_delta):
    # Minus one because one of the children is the bg
    total_quads.text = tq_format % (ground.get_child_count() - 1)
