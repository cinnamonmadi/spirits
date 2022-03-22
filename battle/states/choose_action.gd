extends Node
class_name ChooseAction

onready var director = get_node("/root/Director")

onready var battle_actions = get_parent().get_node("ui/battle_actions")
onready var target_cursor = get_parent().get_node("ui/target_cursor")

const State = preload("res://battle/states/states.gd")

func begin(_params):
    # If the player has chosen actions for all their familiars, begin the turn
    var chosen_all_actions = get_parent().actions.size() == min(director.player_party.get_living_familiar_count(), 2)
    if chosen_all_actions:
        battle_actions.close()
        get_parent().set_state(State.BEGIN_TURN, {})
        return

    battle_actions.open()
    battle_actions.cursor_position.y = 0
    battle_actions.set_cursor_position()

    get_parent().set_target_cursor("player", get_parent().get_choosing_familiar_index())

func process(_delta):
    # If the player presses back, allow them to reselect the previous fighter's action
    if Input.is_action_just_pressed("back"):
        if get_parent().actions.size() > 0:
            var previous_action = get_parent().actions.pop_back()
            if previous_action.action == Action.USE_ITEM:
                director.player_inventory.add_item(previous_action.item, 1)
            battle_actions.cursor_position.y = 0
            battle_actions.set_cursor_position()
            get_parent().set_target_cursor("player", get_parent().actions.size())
            return

    # Check for input on the action select
    var action = battle_actions.check_for_input()
    if action == "FIGHT":
        get_parent().set_state(State.CHOOSE_MOVE, {})
    elif action == "SPIRITS":
        target_cursor.visible = false
        get_parent().set_state(State.PARTY_MENU, {})
    elif action == "ITEM":
        target_cursor.visible = false
        get_parent().set_state(State.ITEM_MENU, {})
    
func handle_tween_finish():
    pass

func handle_timer_timeout():
    pass
