class_name Slug
extends CharacterBody2D


@export var walk_speed := 50.0
@export var long_jump_velocity := Vector2(200, -200)
@export var high_jump_velocity := Vector2(50, -400)

@onready var jump_timer: Timer = $JumpTimer
@onready var sprite: Sprite2D = $Sprite2D

var facing := 1.0
var next_jump := Vector2.ZERO
var going_to_jump := false
var jump_now := false


func _ready():
    jump_timer.timeout.connect(decide_jump)


func _input(event):
    if is_on_floor():
        if event.is_action_pressed("jump"):
            going_to_jump = true
            jump_timer.start()
        elif event.is_action_released("jump"):
            decide_jump()


func decide_jump():
    if going_to_jump and is_on_floor():
        if jump_timer.is_stopped():
            next_jump = high_jump_velocity
        else:
            next_jump = long_jump_velocity
            jump_timer.stop()
        jump_now = true
    going_to_jump = false


func _physics_process(delta: float) -> void:
    # Add the gravity.
    if not is_on_floor():
        velocity += get_gravity() * delta

    # Get the input direction and handle the movement/deceleration.
    if is_on_floor():
        var move_direction := Input.get_axis("move-left", "move-right")
        if move_direction and not going_to_jump:
            facing = 1 if move_direction > 0 else -1
            sprite.scale.x = facing
            velocity.x = move_direction * walk_speed
        else:
            velocity.x = move_toward(velocity.x, 0, walk_speed)

    # Handle jump.
    if jump_now and is_on_floor():
        jump_now = false
        velocity.y = next_jump.y
        velocity.x = next_jump.x * facing
        next_jump = Vector2.ZERO

    move_and_slide()
