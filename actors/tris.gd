extends KinematicBody2D

onready var world = get_parent()
onready var dialog = get_parent().get_node("ui/dialog")

onready var sprite = $sprite
onready var camera = $camera
onready var interact_scanbox = $interact_scanbox

const TILE_SIZE: int = 64
const direction_names = ["up", "right", "down", "left"]
const direction_vectors = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

enum State {
    MOVING,
    DIALOG
}

var direction: Vector2
var facing_direction: Vector2
var speed: float = 128.0

var state = State.MOVING
var paused: bool = false

var rng
var steps_to_battle = -1

func _ready():
    add_to_group("pausables")
    set_camera_bounds()
    rng = RandomNumberGenerator.new()
    rng.randomize()
    steps_to_battle = rng.randi_range(10, 20)
    direction = Vector2.ZERO

func set_camera_bounds():
    var tilemap = get_parent().find_node("tilemap")
    var tilemap_size = Vector2.ZERO
    while tilemap.get_cell(int(tilemap_size.x), 0) != tilemap.INVALID_CELL:
        tilemap_size.x += 1
    while tilemap.get_cell(0, int(tilemap_size.y)) != tilemap.INVALID_CELL:
        tilemap_size.y += 1
    camera.limit_right = TILE_SIZE * tilemap_size.x
    camera.limit_bottom = TILE_SIZE * tilemap_size.y

func handle_input():
    if state == State.MOVING:
        if Input.is_action_just_pressed("up"):
            direction.y = -1
        if Input.is_action_just_pressed("down"):
            direction.y = 1
        if Input.is_action_just_pressed("right"):
            direction.x = 1
        if Input.is_action_just_pressed("left"):
            direction.x = -1
        if Input.is_action_just_released("up"):
            if Input.is_action_pressed("down"):
                direction.y = 1
            else:
                direction.y = 0
        if Input.is_action_just_released("down"):
            if Input.is_action_pressed("up"):
                direction.y = -1
            else:
                direction.y = 0
        if Input.is_action_just_released("right"):
            if Input.is_action_pressed("left"):
                direction.x = -1
            else:
                direction.x = 0
        if Input.is_action_just_released("left"):
            if Input.is_action_pressed("right"):
                direction.x = 1
            else:
                direction.x = 0
        if Input.is_action_just_pressed("action"):
            try_interact()
    elif state == State.DIALOG:
        if Input.is_action_just_pressed("action"):
            direction = Vector2.ZERO
            dialog.progress()
            if not dialog.is_open():
                state = State.MOVING

func try_interact():
    if direction != Vector2.ZERO:
        return

    # Disable all scanbox colliders
    for scanbox_collider in interact_scanbox.get_children():
        scanbox_collider.disabled = true

    # Get the interact direction name from the facing_direction
    var interact_direction: String = ""
    for i in range(0, 4):
        if facing_direction == direction_vectors[i]:
            interact_direction = direction_names[i]
    if interact_direction == "":
        print("Error! Somehow facing direction has not matched up to a proper direction name!")
        return

    # And use this name to enable the correct scanbox collider
    interact_scanbox.get_node("collider_" + interact_direction).disabled = false

    # Finally, check if any NPCs are in the scanbox range
    for npc in get_tree().get_nodes_in_group("npcs"):
        if interact_scanbox.overlaps_body(npc):
            if npc.dialog != "":
                # Make NPC face player
                for i in range(0, 4):
                    if facing_direction == direction_vectors[i]:
                        npc.facing_direction = direction_vectors[(i + 2) % 4]
                dialog.open(npc.dialog)
                state = State.DIALOG
            break
    
func _physics_process(_delta):
    if paused:
        sprite.stop()
        return
    handle_input()
    if state == State.MOVING:
        var _linear_velocity = move_and_slide(direction * speed)
    update_sprite()

func update_sprite():
    if direction.x == 1:
        facing_direction = Vector2.RIGHT
    elif direction.x == -1:
        facing_direction = Vector2.LEFT
    elif direction.y == 1:
        facing_direction = Vector2.DOWN
    elif direction.y == -1:
        facing_direction = Vector2.UP
    var animation_prefix: String
    if direction == Vector2.ZERO:
        animation_prefix = "idle_"
    else:
        animation_prefix = "move_"
    for index in range(0, 4):
        if facing_direction == direction_vectors[index]:
            sprite.play(animation_prefix + direction_names[index])
