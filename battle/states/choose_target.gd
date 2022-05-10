extends Node
class_name ChooseTarget

onready var director = get_node("/root/Director")
onready var util = get_node("/root/Util")

onready var enemy_sprites = get_parent().get_node("enemy_sprites")
onready var player_sprites = get_parent().get_node("player_sprites")
onready var target_cursor = get_parent().get_node("ui/target_cursor")
onready var target_cursor_2 = get_parent().get_node("ui/target_cursor_2")
onready var battle_dialog = get_parent().get_node("ui/battle_dialog")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

var target_who
var target_index
var targeting_action
var chosen_move
var chosen_item
var can_navigate

func begin(params):
    # Get params
    can_navigate = true
    target_who = "enemy"
    target_index = 0

    targeting_action = params.action
    if targeting_action == Action.USE_MOVE:
        chosen_move = params.chosen_move
        if chosen_move.targets == Move.MoveTargets.TARGETS_SELF:
            target_who = "player"
            target_index = get_parent().get_choosing_familiar_index()
            can_navigate = false
        elif chosen_move.targets == Move.MoveTargets.TARGETS_ALL_ALLIES:
            target_who = "player"
            target_index = get_parent().get_choosing_familiar_index()
            var opposite_index = 1
            if target_index == 1:
                opposite_index = 0
            if director.player_party.familiars.size() > 1 and director.player_party.familiars[opposite_index].is_living():
                set_target_cursor(target_cursor_2, target_who, opposite_index)
            can_navigate = false
        elif chosen_move.targets == Move.MoveTargets.TARGETS_ALL_ENEMIES:
            target_who = "enemy"
            if get_parent().enemy_party.familiars[0].is_living():
                set_target_cursor(target_cursor, target_who, 0)
            if get_parent().enemy_party.familiars.size() > 1 and get_parent().enemy_party.familiars[1].is_living():
                set_target_cursor(target_cursor_2, target_who, 1)
            can_navigate = false
    elif targeting_action == Action.USE_ITEM:
        chosen_item = params.chosen_item

    wrap_target_cursor(-1)
    set_target_cursor(target_cursor, target_who, target_index)
    battle_dialog.open("Choose a target...")

func process(_delta):
    # If player pressed back, return to choose move screen
    if Input.is_action_just_pressed("back"):
        target_cursor.visible = false
        if get_parent().targeting_for_action == Action.USE_MOVE:
            get_parent().set_state(State.CHOOSE_ACTION, {})
        elif get_parent().targeting_for_action == Action.USE_ITEM:
            get_parent().set_state(State.ITEM_MENU, {})
        return
    
    # If the player chose their target, add the action to the actions list
    if Input.is_action_just_pressed("action"):
        if targeting_action == Action.USE_MOVE:
            get_parent().actions.append({
                "who": "player",
                "familiar": get_parent().get_choosing_familiar_index(),
                "action": Action.USE_MOVE,
                "move": chosen_move,
                "target_who": target_who,
                "target_familiar": int(target_index)
            })
        elif targeting_action == Action.USE_ITEM:
            get_parent().actions.append({
                "who": "player",
                "familiar": get_parent().get_choosing_familiar_index(),
                "action": Action.USE_ITEM,
                "item": chosen_item,
                "target_who": target_who,
                "target_familiar": int(target_index),
            })
            director.player_inventory.remove_item(chosen_item, 1)

        target_cursor.visible = false
        target_cursor_2.visible = false

        # After adding the action, return the CHOOSE_ACTION state
        # This state will be in charge of deciding whether to progress into the BEGIN_TURN state or not
        get_parent().set_state(State.CHOOSE_ACTION, {})
        return
    
    # Check if the player has pressed a directional key, and move the cursor accordingly
    for direction in util.DIRECTIONS.keys():
        if Input.is_action_just_pressed(direction):
            navigate_target_cursor(util.DIRECTIONS[direction])
            break

func handle_tween_finish():
    pass

func handle_timer_timeout():
    pass

func set_target_cursor(cursor_to_set, to_target_who: String, to_target_index: int):
    var offset = Vector2(0, 120)
    var cursor_base_position
    if to_target_who == "player":
        cursor_base_position = player_sprites.rect_position + player_sprites.get_child(to_target_index).position
        offset = Vector2(0, -80)
    else:
        cursor_base_position = enemy_sprites.rect_position + enemy_sprites.get_child(1 - to_target_index).position

    cursor_to_set.flip_v = to_target_who == "player"
    cursor_to_set.position = cursor_base_position + offset
    cursor_to_set.visible = true

func navigate_target_cursor(input_direction: Vector2):
    if not can_navigate:
        return

    target_index -= input_direction.x
    wrap_target_cursor(int(input_direction.x))
    set_target_cursor(target_cursor, target_who, target_index)

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
