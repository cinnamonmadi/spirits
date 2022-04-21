extends Node
class_name EvaluateMove

onready var director = get_node("/root/Director")
onready var familiar_factory = get_node("/root/FamiliarFactory")

onready var player_sprites = get_parent().get_node("player_sprites")
onready var player_labels = get_parent().get_node("player_labels")
onready var enemy_sprites = get_parent().get_node("enemy_sprites")
onready var enemy_labels = get_parent().get_node("enemy_labels")
onready var battle_dialog = get_parent().get_node("ui/battle_dialog")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

var current_action 

func begin(_params):
    current_action = get_parent().actions[get_parent().current_turn]

    if current_action.action == Action.USE_MOVE:
        if current_action.target_who == "player" and not director.player_party.familiars[current_action.target_familiar].is_living():
            player_sprites.get_child(current_action.target_familiar).visible = false
            player_labels.get_child(current_action.target_familiar).visible = false
            battle_dialog.open(familiar_factory.get_display_name(director.player_party.familiars[current_action.target_familiar]) + " fainted!")
            return
        elif current_action.target_who == "enemy" and not get_parent().enemy_party.familiars[current_action.target_familiar].is_living():
            enemy_sprites.get_child(enemy_sprites.get_child_count() - 1 - current_action.target_familiar).visible = false
            enemy_labels.get_child(enemy_labels.get_child_count() - 1 - current_action.target_familiar).visible = false
            battle_dialog.open("Enemy " + familiar_factory.get_display_name(get_parent().enemy_party.familiars[current_action.target_familiar]) + " fainted!")
            return

    end_state(false)

func end_state(familiar_died: bool):
    if director.player_party.get_living_familiar_count() == 0 or get_parent().enemy_party.get_living_familiar_count() == 0:
        battle_dialog.close()
        get_parent().set_state(State.ANNOUNCE_WINNER, { "first_time_entering_state": true })
    elif familiar_died and current_action.target_who == "player" and director.player_party.get_living_familiar_count() >= 2:
        get_parent().set_state(State.PARTY_MENU, {})
    elif get_parent().current_turn == get_parent().actions.size() - 1:
        get_parent().actions = []
        get_parent().current_turn = -1
        get_parent().set_state(State.CHOOSE_ACTION, {})
    else:
        get_parent().set_state(State.ANIMATE_MOVE, {})

func process(_delta):
    if Input.is_action_just_pressed("action"):
        if battle_dialog.is_waiting():
            end_state(true)
        else:
            battle_dialog.progress()

func handle_tween_finish():
    pass

func handle_timer_timeout():
    pass
