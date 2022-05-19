extends Actor

onready var attack_effect_scene = preload("res://actors/player/player_attack_effect.tscn")

onready var dialog = get_parent().get_node("ui/dialog")

onready var camera = $camera
onready var interact_scanbox = $interact_scanbox

const MOVE_SPEED: float = 128.0

var input_direction: Vector2
var speaking_npc = null
var is_speaking: bool = false

func _ready():
    input_direction = Vector2.ZERO
    set_camera_bounds()
    speed = MOVE_SPEED

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
    if not is_speaking:
        if Input.is_action_just_pressed("action"):
            try_interact()
        else:
            direction = input_direction
    else:
        if Input.is_action_just_pressed("action"):
            direction = Vector2.ZERO
            dialog.progress()
            if not dialog.is_open():
                if speaking_npc != null:
                    speaking_npc.stop_speaking()
                is_speaking = false

func try_interact():
    # Disable all scanbox colliders
    for scanbox_collider in interact_scanbox.get_children():
        scanbox_collider.disabled = true

    # Enable the correct scanbox collider
    interact_scanbox.get_node("collider_" + get_direction_name(facing_direction)).disabled = false

    # Finally, check if any NPCs are in the scanbox range
    for npc in get_tree().get_nodes_in_group("talkers"):
        if interact_scanbox.overlaps_body(npc):
            if npc.dialog != "":
                npc.start_speaking(facing_direction)
                speaking_npc = npc
                is_speaking = true
                dialog.open(npc.dialog)
                direction = Vector2.ZERO
            return

func _physics_process(_delta):
    if paused:
        return false
    handle_input()