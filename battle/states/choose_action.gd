extends Node
class_name ChooseAction

onready var director = get_node("/root/Director")

onready var battle_actions = get_parent().get_node("ui/battle_actions")

const State = preload("res://battle/states/states.gd")

func begin():
    battle_actions.open()
    get_parent().actions = []

func process(_delta):
    # If the player has chosen actions for all their familiars, begin the turn
    var chosen_all_actions = get_parent().actions.size() == director.player_party.get_living_familiar_count()
    if chosen_all_actions:
        battle_actions.close()
        get_parent().set_state(State.BEGIN_TURN)
        return

    # If the player presses back, allow them to reselect the previous fighter's action
    if Input.is_action_just_pressed("back"):
        if get_parent().actions.size() > 0:
            get_parent().actions.pop_back()
            battle_actions.cursor_position.y = 0
            return

    # Check for input on the action select
    var action = battle_actions.check_for_input()
    if action == "FIGHT":
        get_parent().set_state(State.CHOOSE_MOVE)
    
func handle_tween_finish():
    pass