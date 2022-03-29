extends Node
class_name ChooseAction

onready var director = get_node("/root/Director")

onready var target_cursor = get_parent().get_node("ui/target_cursor")

const State = preload("res://battle/states/states.gd")

func begin(_params):
    # If the enemy has a surprise round, just go straight into their actions
    if get_parent().surprise_round == "enemy":
        get_parent().set_state(State.BEGIN_TURN, {})
        return

    # If the player has chosen actions for all their familiars, begin the turn
    var chosen_all_actions = get_parent().actions.size() == min(director.player_party.get_living_familiar_count(), 2)
    if chosen_all_actions:
        get_parent().set_actions_menu_frame(-1)
        get_parent().set_state(State.BEGIN_TURN, {})
        return

    get_parent().set_actions_menu_frame(0)
    get_parent().set_target_cursor("player", get_parent().get_choosing_familiar_index())

func process(_delta):
    # If the player presses back, allow them to reselect the previous fighter's action
    if Input.is_action_just_pressed("back"):
        if get_parent().actions.size() > 0:
            var previous_action = get_parent().actions.pop_back()
            if previous_action.action == Action.USE_ITEM:
                director.player_inventory.add_item(previous_action.item, 1)
            get_parent().set_target_cursor("player", get_parent().actions.size())
    elif Input.is_action_just_pressed("left"):
        get_parent().set_actions_menu_frame(1)
        get_parent().set_state(State.CHOOSE_MOVE, {})
    elif Input.is_action_just_pressed("down"):
        get_parent().set_actions_menu_frame(2)
        target_cursor.visible = false
        get_parent().set_state(State.PARTY_MENU, {})
    elif Input.is_action_just_pressed("right"):
        get_parent().set_actions_menu_frame(3)
        target_cursor.visible = false
        get_parent().set_state(State.ITEM_MENU, {})

func handle_tween_finish():
    pass

func handle_timer_timeout():
    pass
