extends Node
class_name EvaluateMove

onready var director = get_node("/root/Director")
onready var familiar_factory = get_node("/root/FamiliarFactory")

onready var player_sprites = get_parent().get_node("player_sprites")
onready var player_labels = get_parent().get_node("player_labels")
onready var enemy_sprites = get_parent().get_node("enemy_sprites")
onready var enemy_labels = get_parent().get_node("enemy_labels")
onready var battle_dialog = get_parent().get_node("ui/battle_dialog")
onready var timer = get_parent().get_node("timer")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

var current_action 
var familiar_died 
var announcements

func begin(_params):
    current_action = get_parent().actions[get_parent().current_turn]

    familiar_died = false
    announcements = []

    if current_action.action == Action.USE_MOVE:
        # Check if the attacking familiar burnt themselves out or died
        if current_action.who == "player":
            if director.player_party.familiars[current_action.familiar].mana == 0:
                burnout_player_familiar(current_action.familiar)
            if not director.player_party.familiars[current_action.familiar].is_living():
                faint_player_familiar(current_action.familiar)
        if current_action.who == "enemy":
            if get_parent().enemy_party.familiars[current_action.familiar].mana == 0:
                burnout_enemy_familiar(current_action.familiar)
            if not get_parent().enemy_party.familiars[current_action.familiar].is_living():
                faint_enemy_familiar(current_action.familiar)

        # Check if target familiar died
        if current_action.target_who == "player":
            if not director.player_party.familiars[current_action.target_familiar].is_living():
                faint_player_familiar(current_action.target_familiar)
        if current_action.target_who == "enemy":
            if not get_parent().enemy_party.familiars[current_action.target_familiar].is_living():
                faint_enemy_familiar(current_action.target_familiar)

func burnout_familiar(familiar: Familiar):
    familiar.is_burntout = true
    var burnout_damage = ceil(familiar.get_level() / 25.0) + 1
    familiar.change_health(-burnout_damage)

func burnout_player_familiar(familiar_index: int):
    var familiar = director.player_party.familiars[familiar_index]
    burnout_familiar(familiar)
    announcements.append(familiar_factory.get_display_name(familiar) + " burned out!")

func burnout_enemy_familiar(familiar_index: int):
    var familiar = get_parent().enemy_party.familiars[familiar_index]
    burnout_familiar(familiar)
    announcements.append("Enemy " + familiar_factory.get_display_name(familiar) + " burned out!")

func faint_player_familiar(familiar_index: int):
    player_sprites.get_child(familiar_index).visible = false
    player_labels.get_child(familiar_index).visible = false
    announcements.append(familiar_factory.get_display_name(director.player_party.familiars[familiar_index]) + " fainted!")
    familiar_died = true

func faint_enemy_familiar(familiar_index: int):
    enemy_sprites.get_child(1 - familiar_index).visible = false
    enemy_labels.get_child(1 - familiar_index).visible = false
    announcements.append("Enemy " + familiar_factory.get_display_name(get_parent().enemy_party.familiars[familiar_index]) + " fainted!")
    familiar_died = true

func end_state():
    if director.player_party.get_living_familiar_count() == 0 or get_parent().enemy_party.get_living_familiar_count() == 0:
        battle_dialog.keep_open = false
        battle_dialog.close()
        get_parent().set_state(State.ANNOUNCE_WINNER, { "first_time_entering_state": true })
    elif familiar_died and current_action.target_who == "player" and director.player_party.get_living_familiar_count() >= 2:
        get_parent().set_state(State.PARTY_MENU, {})
    elif get_parent().current_turn == get_parent().actions.size() - 1:
        get_parent().actions = []
        get_parent().current_turn = -1
        get_parent().recharge_energy()
        get_parent().set_state(State.CHOOSE_ACTION, {})
    else:
        get_parent().set_state(State.ANIMATE_MOVE, {})

func process(_delta):
    if Input.is_action_just_pressed("action"):
        battle_dialog.progress()
    if not battle_dialog.is_open():
        if announcements.size() == 0:
            end_state()
        else:
            battle_dialog.open_and_wait(announcements.pop_front(), get_parent().BATTLE_DIALOG_WAIT_TIME)

func handle_tween_finish():
    pass

func handle_timer_timeout():
    end_state()
