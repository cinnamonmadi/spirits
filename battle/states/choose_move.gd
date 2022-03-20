extends Node
class_name ChooseMove

onready var director = get_node("/root/Director")

onready var move_select = get_parent().get_node("ui/move_select")
onready var move_info = get_parent().get_node("ui/move_info")
onready var battle_actions = get_parent().get_node("ui/battle_actions")

const State = preload("res://battle/states/states.gd")

var current_familiar

func begin(_params):
    current_familiar = director.player_party.familiars[get_parent().get_choosing_familiar_index()]
    battle_actions.open()
    move_select.open()
    move_select.set_labels([current_familiar.get_move_names()])

func process(_delta):
    # If player pressed back, return to choose action screen
    if Input.is_action_just_pressed("back"):
        move_select.close()
        move_info.close()
        get_parent().set_state(State.CHOOSE_ACTION, {})
        return
    
    # Handle input
    var has_chosen_move = move_select.check_for_input()
    open_move_info(current_familiar.moves[move_select.cursor_position.y])
    # If they haven't chosen a move, don't do anything else
    if not has_chosen_move:
        return
    
    # If we've reached this point in the code, it means they *have* chosen a move
    # So set the state to choosing a target
    battle_actions.close()
    move_select.close()
    move_info.close()
    get_parent().targeting_for_action = Action.USE_MOVE
    get_parent().set_state(State.CHOOSE_TARGET, { "chosen_move": current_familiar.moves[move_select.cursor_position.y], "action": Action.USE_MOVE })

func open_move_info(move: int):
    var move_info_values = Familiar.MOVE_INFO[move]
    move_info.open(Familiar.Type.keys()[move_info_values["type"]], String(move_info_values["cost"]) + " MP")

func handle_tween_finish():
    pass
