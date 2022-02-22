extends Actor

onready var dialog = get_parent().get_node("ui/dialog")

onready var camera = $camera
onready var interact_scanbox = $interact_scanbox

enum State {
    MOVING,
    ROLLING,
    DIALOG
}

const ROLL_SPEED: float = 256.0
const END_ROLL_SPEED: float = 64.0
const MOVE_SPEED: float = 128.0

var state = State.MOVING
var input_direction: Vector2
var speaking_npc = null

func _ready():
    sprite.connect("animation_finished", self, "_on_animation_finished")
    input_direction = Vector2.ZERO
    set_camera_bounds()

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
    if state == State.MOVING:
        direction = input_direction
        if direction != Vector2.ZERO and Input.is_action_just_pressed("back"):
            state = State.ROLLING
        elif Input.is_action_just_pressed("action"):
            try_interact()
    elif state == State.DIALOG:
        if Input.is_action_just_pressed("action"):
            direction = Vector2.ZERO
            dialog.progress()
            if not dialog.is_open():
                if speaking_npc != null:
                    speaking_npc.stop_speaking()
                state = State.MOVING

func try_interact():
    # Disable all scanbox colliders
    for scanbox_collider in interact_scanbox.get_children():
        scanbox_collider.disabled = true

    # Enable the correct scanbox collider
    interact_scanbox.get_node("collider_" + get_direction_name(facing_direction)).disabled = false

    # Finally, check if any NPCs are in the scanbox range
    for npc in get_tree().get_nodes_in_group("npcs"):
        if interact_scanbox.overlaps_body(npc):
            if npc.dialog != "":
                npc.start_speaking(facing_direction)
                speaking_npc = npc
                dialog.open(npc.dialog)
                direction = Vector2.ZERO
                state = State.DIALOG
            break

func _physics_process(_delta):
    if paused:
        return false
    handle_input()
    if state == State.ROLLING and sprite.frame >= 10 and input_direction != Vector2.ZERO:
        state = State.MOVING
    if state == State.MOVING:
        speed = MOVE_SPEED
    elif state == State.ROLLING:
        if sprite.frame < 3 or sprite.frame >= 13:
            speed = 0
        elif sprite.frame >= 10:
            speed = 64.0
        else:
            speed = ROLL_SPEED
    elif state == State.DIALOG:
        direction = Vector2.ZERO

    var is_invulnerable = state == State.ROLLING and speed != 0
    set_collision_layer_bit(0, not is_invulnerable)

func update_animation():
    if state == State.ROLLING:
        update_sprite("roll")
    else:
        .update_animation()

func _on_animation_finished():
    if state == State.ROLLING:
        state = State.MOVING

func handle_monster_attack(monster):
    get_parent().init_start_battle(monster)
