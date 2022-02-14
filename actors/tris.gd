extends KinematicBody2D

onready var world = get_parent()
onready var dialog = get_parent().find_node("dialog")

onready var sprite = $sprite
onready var camera = $camera

const TILE_SIZE: int = 64
const direction_names = ["up", "right", "down", "left"]
const direction_vectors = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

enum State {
    MOVING,
    DIALOG
}

var input_direction: Vector2
var facing_direction: Vector2
var speed: float = 128.0

var state = State.MOVING
var paused: bool = false

var rng
var steps_to_battle = -1

func _ready():
    set_camera_bounds()
    rng = RandomNumberGenerator.new()
    rng.randomize()
    steps_to_battle = rng.randi_range(10, 20)
    input_direction = Vector2.ZERO

func set_camera_bounds():
    var tilemap = get_parent().find_node("tilemap")
    var tilemap_size = Vector2.ZERO
    while tilemap.get_cell(int(tilemap_size.x), 0) != tilemap.INVALID_CELL:
        tilemap_size.x += 1
    while tilemap.get_cell(0, int(tilemap_size.y)) != tilemap.INVALID_CELL:
        tilemap_size.y += 1
    camera.limit_right = TILE_SIZE * tilemap_size.x
    camera.limit_bottom = TILE_SIZE * tilemap_size.y
    print(camera.limit_right)

func handle_input():
    if state == State.MOVING:
        if Input.is_action_just_pressed("up"):
            input_direction.y = -1
        if Input.is_action_just_pressed("down"):
            input_direction.y = 1
        if Input.is_action_just_pressed("right"):
            input_direction.x = 1
        if Input.is_action_just_pressed("left"):
            input_direction.x = -1
        if Input.is_action_just_released("up"):
            if Input.is_action_pressed("down"):
                input_direction.y = 1
            else:
                input_direction.y = 0
        if Input.is_action_just_released("down"):
            if Input.is_action_pressed("up"):
                input_direction.y = -1
            else:
                input_direction.y = 0
        if Input.is_action_just_released("right"):
            if Input.is_action_pressed("left"):
                input_direction.x = -1
            else:
                input_direction.x = 0
        if Input.is_action_just_released("left"):
            if Input.is_action_pressed("right"):
                input_direction.x = 1
            else:
                input_direction.x = 0
        if Input.is_action_just_pressed("action"):
            try_interact()
    elif state == State.DIALOG:
        if Input.is_action_just_pressed("action"):
            input_direction = Vector2.ZERO
            dialog.progress()
            if not dialog.is_open():
                state = State.MOVING

func try_interact():
    if input_direction != Vector2.ZERO:
        return
    var interact_position = position + (facing_direction * TILE_SIZE)
    for npc in get_tree().get_nodes_in_group("npcs"):
        if npc.position == interact_position:
            if npc.dialog != "":
                dialog.open(npc.dialog)
                state = State.DIALOG
            break

func _physics_process(_delta):
    if paused:
        return
    handle_input()
    if state == State.MOVING:
        var _linear_velocity = move_and_slide(input_direction * speed)
    update_sprite()

func update_sprite():
    if input_direction != Vector2.ZERO:
        facing_direction = input_direction
    var animation_prefix: String
    if input_direction == Vector2.ZERO:
        animation_prefix = "idle_"
    else:
        animation_prefix = "move_"
    for index in range(0, 4):
        if facing_direction == direction_vectors[index]:
            sprite.play(animation_prefix + direction_names[index])
