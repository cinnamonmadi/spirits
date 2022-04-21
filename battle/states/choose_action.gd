extends Node
class_name ChooseAction

onready var director = get_node("/root/Director")
onready var familiar_factory = get_node("/root/FamiliarFactory")
onready var util = get_node("/root/Util")

onready var action_select = get_parent().get_node("ui/action_select")
onready var target_cursor = get_parent().get_node("ui/target_cursor")
onready var battle_dialog = get_parent().get_node("ui/battle_dialog")

const State = preload("res://battle/states/states.gd")

var current_familiar 

func begin(_params):
    # If the player has chosen actions for all their familiars, begin the turn
    var chosen_all_actions = get_parent().actions.size() == min(director.player_party.get_living_familiar_count(), 2)
    if chosen_all_actions:
        action_select.close()
        get_parent().set_state(State.BEGIN_TURN, {})
        return

    open_prompt()
    action_select.open(current_familiar.moves)

func open_prompt():
    current_familiar = director.player_party.familiars[get_parent().get_choosing_familiar_index()]
    battle_dialog.open("What will " + familiar_factory.get_display_name(current_familiar) + " do?")

func process(_delta):
    # If the player presses back, allow them to reselect the previous fighter's action
    if Input.is_action_just_pressed("back"):
        if get_parent().actions.size() > 0:
            var previous_action = get_parent().actions.pop_back()
            if previous_action.action == Action.USE_ITEM:
                director.player_inventory.add_item(previous_action.item, 1)
            action_select.reset_cursor_position()
            open_prompt()
    elif Input.is_action_just_pressed("action"):
        var selected_move = action_select.get_selected_move_index()
        # If the player chose a move, transition to the CHOOSE_TARGET state
        if selected_move != -1:
            var chosen_move = current_familiar.moves[selected_move]
            get_parent().targeting_for_action = Action.USE_MOVE
            get_parent().set_state(State.CHOOSE_TARGET, { "chosen_move": chosen_move, "action": Action.USE_MOVE })
        # If the player chose the switch action, open the party menu
        elif action_select.cursor_position == action_select.CURSOR_POSITION_SWITCH:
            get_parent().set_state(State.PARTY_MENU, {})
        # If the player chose the item action, open the inventory
        elif action_select.cursor_position == action_select.CURSOR_POSITION_ITEM:
            get_parent().set_state(State.ITEM_MENU, {})
    else:
        for direction in util.DIRECTIONS.keys():
            if Input.is_action_just_pressed(direction):
                action_select.navigate(util.DIRECTIONS[direction])
                break

func handle_tween_finish():
    pass

func handle_timer_timeout():
    pass
