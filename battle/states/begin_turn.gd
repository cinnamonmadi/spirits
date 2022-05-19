extends Node
class_name BeginTurn

onready var director = get_node("/root/Director")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

var current_familiar

func priority_of(action) -> int:
    if action.action == Action.RUN:
        return 20
    elif action.action == Action.USE_ITEM:
        return 19
    elif action.action == Action.SWITCH:
        return 18
    elif action.action == Action.USE_MOVE:
        return action.move.priority
    else:
        return 2

func action_sorter(a, b):
    if priority_of(a) > priority_of(b):
        return true
    elif priority_of(a) < priority_of(b):
        return false
    else:
        return get_parent().get_acting_familiar(a).get_speed() > get_parent().get_acting_familiar(b).get_speed()

func begin(_params):
    enemy_choose_actions()

    get_parent().actions.sort_custom(self, "action_sorter")
    
    get_parent().set_state(State.ANIMATE_MOVE, {})

func process(_delta):
    pass

func handle_tween_finish():
    pass

func handle_timer_timeout():
    pass

func enemy_choose_actions():
    for i in range(0, min(director.enemy_party.familiars.size(), 2)):
        if not director.enemy_party.familiars[i].is_living():
            continue
        var moves = director.enemy_party.familiars[i].moves
        var enemy_chosen_move = moves[director.rng.randi_range(0, moves.size() - 1)]
        get_parent().actions.append({
            "who": "enemy",
            "familiar": i,
            "action": Action.USE_MOVE,
            "move": enemy_chosen_move,
            "target_who": "player",
            "target_familiar": 0
        })
