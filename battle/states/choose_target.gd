extends Node
class_name ChooseTarget

onready var director = get_node("/root/Director")

onready var enemy_sprites = get_parent().get_node("enemy_sprites")
onready var player_sprites = get_parent().get_node("player_sprites")
onready var target_cursor = get_parent().get_node("ui/target_cursor")
onready var battle_actions = get_parent().get_node("ui/battle_actions")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

const direction_names = ["up", "right", "down", "left"]
const direction_vectors = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

var target_who
var target_index

func begin():
    target_who = "enemy"
    target_index = 0
    wrap_target_cursor(-1)
    get_parent().set_target_cursor(target_who, target_index)

func process(_delta):
    # If player pressed back, return to choose move screen
    if Input.is_action_just_pressed("back"):
        target_cursor.visible = false
        get_parent().set_state(State.CHOOSE_MOVE)
        return
    
    # If the player chose their target, add the action to the actions list
    if Input.is_action_just_pressed("action"):
        get_parent().actions.append({
            "who": "player",
            "familiar": get_parent().player_choosing_index,
            "action": Action.USE_MOVE,
            "move": get_parent().chosen_move,
            "target_who": target_who,
            "target_familiar": target_index
        })

        target_cursor.visible = false

        # After adding the action, return the CHOOSE_ACTION state
        # This state will be in charge of deciding whether to progress into the BEGIN_TURN state or not
        get_parent().set_state(State.CHOOSE_ACTION)
        return
    
    # Check if the player has pressed a directional key, and move the cursor accordingly
    for i in range(0, 4):
        if Input.is_action_just_pressed(direction_names[i]):
            navigate_target_cursor(direction_vectors[i])
            break

func handle_tween_finish():
    pass

func navigate_target_cursor(input_direction: Vector2):
    if input_direction.y != 0:
        if target_who == "player":
            target_who = "enemy"
        else:
            target_who = "player"
    else:
        target_index -= input_direction.x
    wrap_target_cursor(int(input_direction.x))
    get_parent().set_target_cursor(target_who, target_index)

func wrap_target_cursor(wrap_direction: int):
    var target_index_max = 2
    if target_who == "player" and director.player_party.familiars.size() == 1:
        target_index_max = 1
    if target_who == "enemy":
        target_index_max = get_parent().enemy_party.familiars.size()

    if target_index >= target_index_max:
        target_index = 0
    elif target_index < 0:
        target_index = target_index_max - 1

    while not target_cursor_has_valid_target():
        target_index -= wrap_direction
        if target_index >= target_index_max:
            target_index = 0
        elif target_index < 0:
            target_index = target_index_max - 1

func target_cursor_has_valid_target():
    if target_who == "player" and director.player_party.familiars[target_index].is_living():
        return true
    elif target_who == "enemy" and get_parent().enemy_party.familiars[target_index].is_living():
        return true
    return false
