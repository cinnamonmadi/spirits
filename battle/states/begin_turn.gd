extends Node
class_name BeginTurn

onready var director = get_node("/root/Director")

onready var move_select = get_parent().get_node("ui/move_select")
onready var move_info = get_parent().get_node("ui/move_info")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

var current_familiar

func begin():
    enemy_choose_actions()

    # Compute the action speeds
    var action_speeds = []
    for action in get_parent().actions:
        action_speeds.append(get_action_speed(action))

    # Sort actions on their speed
    for i in range(1, get_parent().actions.size()):
        var current_index = i
        while current_index != 0 and action_speeds[current_index] > action_speeds[current_index - 1]:
            var temp = get_parent().actions[current_index]
            var temp_speed = action_speeds[current_index]

            get_parent().actions[current_index] = get_parent().actions[current_index - 1]
            action_speeds[current_index] = action_speeds[current_index - 1]

            get_parent().actions[current_index - 1] = temp
            action_speeds[current_index - 1] = temp_speed

            current_index -= 1
    
    # Confirm that I sorted everything right
    for i in range(0, action_speeds.size()):
        print(String(action_speeds[i]) + ", ")

    get_parent().current_turn = -1
    get_parent().set_state(State.ANIMATE_MOVE)

func process(_delta):
    pass

func handle_tween_finish():
    pass

func get_action_speed(action) -> int:
    if action.action == Action.RUN:
        return 1000
    elif action.action == Action.USE_ITEM: 
        return 999
    elif action.action == Action.SWITCH:
        return 998
    else:
        return get_parent().get_acting_familiar(action).speed

func enemy_choose_actions():
    for i in range(0, get_parent().enemy_party.familiars.size()):
        var enemy_chosen_move = get_parent().enemy_party.familiars[i].moves[director.rng.randi_range(0, 3)]
        get_parent().actions.append({
            "who": "enemy",
            "familiar": i,
            "action": Action.USE_MOVE,
            "move": enemy_chosen_move,
            "target_who": "player",
            "target_familiar": 0
        })
