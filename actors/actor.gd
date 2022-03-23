extends KinematicBody2D
class_name Actor

onready var sprite = $sprite

const TILE_SIZE: int = 64
const direction_names = ["up", "right", "down", "left"]
const direction_vectors = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

var direction: Vector2
var facing_direction: Vector2 = Vector2.DOWN
var speed: float = 128.0

var paused: bool = false

func _ready():
    add_to_group("pausables")
    direction = Vector2.ZERO

func get_direction_name(direction_vector: Vector2):
    for i in range(0, 4):
        if direction_vectors[i] == direction_vector:
            return direction_names[i]
    return ""

func get_direction_vector(direction_name: String):
    for i in range(0, 4):
        if direction_names[i] == direction_name:
            return direction_vectors[i]
    return Vector2.ZERO

func _physics_process(_delta):
    if paused:
        sprite.stop()
        return
    var _linear_velocity = move_and_slide(direction.normalized() * speed)
    update_animation()

func update_facing_direction():
    if direction.x > 0:
        facing_direction = Vector2.RIGHT
    elif direction.x < 0:
        facing_direction = Vector2.LEFT
    elif direction.y > 0:
        facing_direction = Vector2.DOWN
    elif direction.y < 0:
        facing_direction = Vector2.UP

func update_animation():
    if direction == Vector2.ZERO:
        update_sprite("idle")
    else:
        update_sprite("move")

func update_sprite(animation_name: String):
    update_facing_direction()
    sprite.play(animation_name + "_" + get_direction_name(facing_direction))
