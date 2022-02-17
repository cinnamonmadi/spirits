extends Node
class_name ChooseAction

onready var director = get_node("/root/Director")

onready var battle_actions = get_parent().get_node("ui/battle_actions")
onready var target_cursor = get_parent().get_node("ui/target_cursor")

const State = preload("res://battle/states/states.gd")

func begin():
    # If the player has chosen actions for all their familiars, begin the turn
    var chosen_all_actions = get_parent().actions.size() == min(director.player_party.get_living_familiar_count(), 2)
    if chosen_all_actions:
        battle_actions.close()
        get_parent().set_state(State.BEGIN_TURN)
        return

    battle_actions.open()

    get_parent().player_choosing_index = get_parent().actions.size()
    if not director.player_party.familiars[get_parent().player_choosing_index].is_living():
        get_parent().player_choosing_index += 1
    get_parent().set_target_cursor("player", get_parent().player_choosing_index)

func process(_delta):
    # If the player presses back, allow them to reselect the previous fighter's action
    if Input.is_action_just_pressed("back"):
        if get_parent().actions.size() > 0:
            get_parent().actions.pop_back()
            get_parent().set_target_cursor("player", get_parent().actions.size())
            battle_actions.cursor_position.y = 0
            return

    # Check for input on the action select
    var action = battle_actions.check_for_input()
    if action == "FIGHT":
        get_parent().set_state(State.CHOOSE_MOVE)
    elif action == "SPIRITS":
        target_cursor.visible = false
        get_parent().set_state(State.PARTY_MENU)
    
func handle_tween_finish():
    pass
