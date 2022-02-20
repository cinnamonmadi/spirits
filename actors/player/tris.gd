extends Actor

onready var dialog = get_parent().get_node("ui/dialog")

onready var camera = $camera
onready var interact_scanbox = $interact_scanbox

enum State {
    MOVING,
    DIALOG
}

var speaking_npc = null

var state = State.MOVING

func _ready():
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
                if speaking_npc != null:
                    speaking_npc.stop_speaking()
                state = State.MOVING

func try_interact():
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
                npc.start_speaking(facing_direction)
                speaking_npc = npc
                dialog.open(npc.dialog)
                direction = Vector2.ZERO
                state = State.DIALOG
            break
    
func _physics_process(_delta):
    handle_input()
    if state == State.DIALOG:
        direction = Vector2.ZERO
