extends Node
class_name ChooseMove

onready var director = get_node("/root/Director")

onready var move_select = get_parent().get_node("ui/move_select")
onready var move_info = get_parent().get_node("ui/move_info")

const State = preload("res://battle/states/states.gd")

var current_familiar

func begin():
    current_familiar = director.player_party.familiars[get_parent().actions.size() - 1]
    move_select.open()
    move_select.set_labels([current_familiar.moves])

func process(_delta):
    # If player pressed back, return to choose action screen
    if Input.is_action_just_pressed("back"):
        move_select.close()
        move_info.close()
        get_parent().set_state(State.CHOOSE_ACTION)
        return
    
    # Handle input
    get_parent().chosen_move = move_select.check_for_input()
    open_move_info(current_familiar.moves[move_select.cursor_position.y])

    # If they haven't chosen a move, don't do anything else
    if get_parent().chosen_move == "":
        return
    
    # If we've reached this point in the code, it means they *have* chosen a move
    # So set the state to choosing a target
    move_select.close()
    move_info.close()
    get_parent().set_state(State.CHOOSE_TARGET)

func open_move_info(move: String):
    var move_info_values = Familiar.MOVE_INFO[move]
    move_info.open(move_info_values["type"], String(move_info_values["cost"]) + " MP")

func handle_tween_finish():
    pass