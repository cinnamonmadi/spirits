extends Node
class_name ExecuteMove

onready var director = get_node("/root/Director")
onready var familiar_factory = get_node("/root/FamiliarFactory")

onready var player_labels = get_parent().get_node("player_labels")
onready var enemy_labels = get_parent().get_node("enemy_labels")
onready var tween = get_parent().get_node("tween")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

const EXECUTE_MOVE_DURATION: float = 1.0

var current_action 

func begin(_params):
    current_action = get_parent().actions[get_parent().current_turn]

    if current_action.action == Action.USE_MOVE:
        execute_use_move()
    elif current_action.action == Action.SWITCH:
        execute_switch()
    elif current_action.action == Action.USE_ITEM:
        execute_use_item()

func process(_delta):
    var done_interpolating = true

    for child in player_labels.get_children():
        if child.is_interpolating():
            done_interpolating = false
    for child in enemy_labels.get_children():
        if child.is_interpolating():
            done_interpolating = false
            break

    if done_interpolating:
        get_parent().set_state(State.EVALUATE_MOVE, {})

func handle_tween_finish():
    pass

func handle_timer_timeout():
    pass

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
        print(current_action.target_familiar)
    defender = defending_party.familiars[current_action.target_familiar]

    var move = current_action.move
    var move_info = familiar_factory.MOVE_INFO[move]

    # Compute base damage
    var base_damage = (((((2 * attacker.get_level()) / 5) + 2) * move_info.power * (attacker.attack / defender.defense)) / 50) + 2

    # Compute STAB
    var stab = 1
    if attacker.types.has(move_info.type):
        stab = 1.5 
    
    # Compute weaknesses / resistances
    var type_mod = 1.0
    for type in defender.types:
        var type_info = familiar_factory.TYPE_INFO[type]
        if type_info.weaknesses.has(move_info.type):
            type_mod *= 2.0
        elif type_info.resistances.has(move_info.type):
            type_mod *= 0.5

    var random = director.rng.randf_range(0.85, 1.0)
    var damage = base_damage * stab * type_mod * random

    # Apply damage and mana cost
    defender.change_health(-damage)
    attacker.change_mana(-move_info.cost)

func execute_switch():
    if current_action.who == "player":
        director.player_party.swap_familiars(current_action.familiar, current_action.with)
        get_parent().set_state(State.SUMMON_FAMILIARS, { "trigger_witch_exit": false })

func execute_use_item():
    var target_familiar = null
    if current_action.target_who == "player":
        target_familiar = director.player_party.familiars[current_action.target_familiar]
    else:
        var item_info = Inventory.ITEM_INFO[current_action.item]
        if item_info.action == Inventory.ItemAction.CAPTURE_MONSTER:
            try_to_catch_familiar(item_info)
        else:
            target_familiar = get_parent().enemy_party.familiars[current_action.familiar]

    if target_familiar != null:
        director.player_inventory.use_item(current_action.item, target_familiar)
        return

    get_parent().set_state(State.EVALUATE_MOVE, {})

func try_to_catch_familiar(gem_info):
    if get_parent().enemy_captured[current_action.target_familiar]:
        # TODO handle this somehow with a message or visual cue?
        # TODO similarly, do a type comparison check
        print("already caught!")
        return
    var target_familiar = get_parent().enemy_party.familiars[current_action.target_familiar]

    # Calculate the catch rate
    var health_mod = float(((3.0 * target_familiar.max_health) - (2.0 * target_familiar.health)) / (3.0 * target_familiar.max_health)) # (3max_health - 2health) / 3max_health
    var ally_mod = 1.0 - (float(get_parent().enemy_party.get_living_familiar_count() - 1) * 0.25) # 1 - (0.25 * num_allies)
    var gem_mod = 1.0 + (float(gem_info.value) * 0.5) # 1 + (0.5 * gem_grade)
    var catch_rate = health_mod * ally_mod * gem_mod * target_familiar.get_catch_rate()

    # Randomize the catch value
    var catch_value = director.rng.randf_range(0.0, 1.0)

    # If the catch value is less than the catch rate, success! (So lower catch rate means lower chances of success)
    if catch_value < catch_rate:
        print("success! " + String(catch_value) + " vs " + String(catch_rate))
        get_parent().enemy_captured[current_action.target_familiar] = true
        get_parent().enemy_sprites.get_child(3 - current_action.target_familiar).flip_h = true
    else:
        print("fail! " + String(catch_value) + " vs " + String(catch_rate))
