extends KinematicBody2D
class_name Actor

onready var sprite = $sprite

const TILE_SIZE: int = 64
const direction_names = ["up", "right", "down", "left"]
const direction_vectors = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

var direction: Vector2
var facing_direction: Vector2
var speed: float = 128.0

var paused: bool = false

func _ready():
    add_to_group("pausables")
    direction = Vector2.ZERO

func _physics_process(_delta):
    if paused:
        sprite.stop()
        return
    var _linear_velocity = move_and_slide(direction.normalized() * speed)
    update_sprite()

func update_sprite():
    if direction.x > 0:
        facing_direction = Vector2.RIGHT
    elif direction.x < 0:
        facing_direction = Vector2.LEFT
    elif direction.y > 1:
        facing_direction = Vector2.DOWN
    elif direction.y < -1:
        facing_direction = Vector2.UP
    var animation_prefix: String
    if direction == Vector2.ZERO:
        animation_prefix = "idle_"
    else:
        animation_prefix = "move_"
    for index in range(0, 4):
        if facing_direction == direction_vectors[index]:
            sprite.play(animation_prefix + direction_names[index])
