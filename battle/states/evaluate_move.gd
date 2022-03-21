extends Node
class_name EvaluateMove

onready var director = get_node("/root/Director")

onready var player_sprites = get_parent().get_node("player_sprites")
onready var player_labels = get_parent().get_node("player_labels")
onready var enemy_sprites = get_parent().get_node("enemy_sprites")
onready var enemy_labels = get_parent().get_node("enemy_labels")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

var current_action 

func begin(_params):
    current_action = get_parent().actions[get_parent().current_turn]

    if current_action.action == Action.USE_MOVE:
        if current_action.target_who == "player" and not director.player_party.familiars[current_action.target_familiar].is_living():
            player_sprites.get_child(current_action.target_familiar).visible = false
            player_labels.get_child(current_action.target_familiar).visible = false
            if director.player_party.get_living_familiar_count() == 0:
                get_parent().set_state(State.ANNOUNCE_WINNER, {})
                return
            elif director.player_party.get_living_familiar_count() >= 2:
                get_parent().set_state(State.PARTY_MENU, {})
                return
        elif current_action.target_who == "enemy" and not get_parent().enemy_party.familiars[current_action.target_familiar].is_living():
            enemy_sprites.get_child(enemy_sprites.get_child_count() - 1 - current_action.target_familiar).visible = false
            enemy_labels.get_child(enemy_labels.get_child_count() - 1 - current_action.target_familiar).visible = false
            if get_parent().enemy_party.get_living_familiar_count() == 0:
                get_parent().set_state(State.ANNOUNCE_WINNER, {})
                return

    if get_parent().current_turn == get_parent().actions.size() - 1:
        get_parent().actions = []
        get_parent().current_turn = -1
        get_parent().set_state(State.CHOOSE_ACTION, {})
    else:
        get_parent().set_state(State.ANIMATE_MOVE, {})

func process(_delta):
    pass

func handle_tween_finish():
    pass
