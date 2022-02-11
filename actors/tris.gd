extends Actor

onready var world = get_parent()
onready var dialog = get_parent().find_node("dialog")

enum State {
    MOVING,
    DIALOG
}

const input_direction_names = ["up", "right", "down", "left"]
const input_direction_vectors = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

var input_direction: Vector2
var state = State.MOVING

var rng
var steps_to_battle = -1

func _ready():
    rng = RandomNumberGenerator.new()
    rng.randomize()
    steps_to_battle = rng.randi_range(10, 20)
    input_direction = Vector2.ZERO

func handle_input():
    if state == State.MOVING:
        for i in range(0, input_direction_names.size()):
            if Input.is_action_just_pressed(input_direction_names[i]):
                input_direction = input_direction_vectors[i]
            elif Input.is_action_just_released(input_direction_names[i]):
                input_direction = Vector2.ZERO
                for j in range(0, input_direction_names.size()):
                    if i == j:
                        continue
                    if Input.is_action_pressed(input_direction_names[j]):
                        input_direction = input_direction_vectors[j]
                        break
        if Input.is_action_just_pressed("action"):
            try_interact()
    elif state == State.DIALOG:
        if Input.is_action_just_pressed("action"):
            input_direction = Vector2.ZERO
            dialog.progress()
            if not dialog.is_open():
                state = State.MOVING

func try_interact():
    if is_moving_between_tiles():
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
        move()
        try_find_next_target(input_direction)
    update_sprite()

func update_sprite():
    if facing_direction == Vector2.UP:
        sprite.play("up")
    elif facing_direction == Vector2.DOWN:
        sprite.play("down")
    else:
        sprite.play("side")
    sprite.flip_h = facing_direction == Vector2.LEFT
    sprite.speed_scale = speed

    if input_direction == Vector2.ZERO:
        sprite.stop()
        sprite.frame = 0
    elif input_direction != Vector2.ZERO and target_position == Vector2.ZERO:
        # If the player is walking up against a wall, play the walk animation in slow motion
        sprite.speed_scale = 0.5

func handle_reached_target():
    steps_to_battle -= 1
    if steps_to_battle <= 0:
        steps_to_battle = rng.randi_range(10, 20)

        input_direction = Vector2.ZERO
        world.init_start_battle()
