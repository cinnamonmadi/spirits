extends Node
class_name ExecuteMove

onready var director = get_node("/root/Director")

onready var tween = get_parent().get_node("tween")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

const EXECUTE_MOVE_DURATION: float = 1.0

var current_action 

func begin():
    current_action = get_parent().actions[get_parent().current_turn]

    if current_action.action == Action.USE_MOVE:
        execute_use_move()
    elif current_action.action == Action.SWITCH:
        execute_switch()

func process(_delta):
    if current_action.who == "player":
        get_parent().update_player_label(current_action.familiar)
    else:
        get_parent().update_enemy_label(current_action.familiar)
    if current_action.target_who == "player":
        get_parent().update_player_label(current_action.target_familiar)
    else:
        get_parent().update_enemy_label(current_action.target_familiar)

func handle_tween_finish():
    get_parent().set_state(State.EVALUATE_MOVE)

func execute_use_move():
    var attacker  
    var defender

    if current_action.who == "player":
        attacker = director.player_party.familiars[current_action.familiar]
    else:
        attacker = get_parent().enemy_party.familiars[current_action.familiar]

    # Assign the defender, but if the defender is dead, choose another defender from the defending party
    # Note that this code assumes that if all members of a given party are dead, then we would have never reached this code
    var defending_party
    var defending_party_size
    if current_action.target_who == "player":
        defending_party = director.player_party
        defending_party_size = 2
    else:
        defending_party = get_parent().enemy_party
        defending_party_size = defending_party.familiars.size()
    while not defending_party.familiars[current_action.target_familiar].is_living():
        current_action.target_familiar = (current_action.target_familiar + 1) % defending_party_size
    defender = defending_party.familiars[current_action.target_familiar]

    var move = current_action.move
    var move_info = Familiar.MOVE_INFO[move]

    var base_damage = (((((2 * attacker.level) / 5) + 2) * move_info.power * (attacker.attack / defender.defense)) / 50) + 2
    var random = director.rng.randf_range(0.85, 1.0)
    var damage = base_damage * random

    tween.interpolate_property(defender, "health", defender.health, max(0, defender.health - damage), EXECUTE_MOVE_DURATION)
    tween.interpolate_property(attacker, "mana", attacker.mana, max(0, attacker.mana - move_info.cost), EXECUTE_MOVE_DURATION)
    tween.start()

func execute_switch():
    if current_action.who == "player":
        director.player_party.swap_familiars(current_action.familiar, current_action.with)
        get_parent().set_state(State.SUMMON_FAMILIARS)
