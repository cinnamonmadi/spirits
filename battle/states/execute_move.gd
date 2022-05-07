extends Node
class_name ExecuteMove

onready var director = get_node("/root/Director")
onready var familiar_factory = get_node("/root/FamiliarFactory")

onready var player_sprites = get_parent().get_node("player_sprites")
onready var enemy_sprites = get_parent().get_node("enemy_sprites")
onready var player_labels = get_parent().get_node("ui/player_labels")
onready var enemy_labels = get_parent().get_node("ui/enemy_labels")
onready var tween = get_parent().get_node("tween")
onready var battle_dialog = get_parent().get_node("ui/battle_dialog")
onready var catch_effect = get_parent().get_node("catch_effect")
onready var battle_sound_player = get_parent().get_node("battle_sound_player")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

const EXECUTE_MOVE_DURATION: float = 1.0

enum MoveEffect {
    DAMAGE,
    CONDITION
}

var current_action 
var catch_successful: bool
var sprite_effect
var move_effects = []

var attacker  
var defender

func _ready():
    sprite_effect = SpriteEffect.new()
    get_parent().add_child(sprite_effect)
    catch_effect.connect("animation_finished", self, "_on_catch_effect_finished")
    catch_effect.connect("hide_enemy", self, "_on_catch_hide_enemy")

func begin(_params):
    current_action = get_parent().actions[0]

    if current_action.action == Action.USE_MOVE:
        execute_use_move()
    elif current_action.action == Action.SWITCH:
        execute_switch()
    elif current_action.action == Action.USE_ITEM:
        execute_use_item()
    elif current_action.action == Action.REST:
        execute_rest()

func process(_delta):
    var done_interpolating = true

    if not sprite_effect.is_finished:
        done_interpolating = false

    if catch_effect.is_playing: 
        done_interpolating = false

    if battle_dialog.is_open():
        if Input.is_action_just_pressed("action"):
            battle_dialog.progress()
    if battle_dialog.is_open():
        done_interpolating = false

    for child in player_labels.get_children():
        if child.is_interpolating():
            done_interpolating = false
    for child in enemy_labels.get_children():
        if child.is_interpolating():
            done_interpolating = false
            break

    if done_interpolating and move_effects.size() != 0:
        execute_next_move_effect()
        done_interpolating = false

    if done_interpolating:
        get_parent().set_state(State.EVALUATE_MOVE, { "initialize": true })

func handle_tween_finish():
    pass

func handle_timer_timeout():
    pass

func execute_use_move():
    # Determine attacker and defender
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

    var move_info = familiar_factory.MOVE_INFO[current_action.move]

    move_effects = []
    for condition in move_info.conditions:
        move_effects.append({
            "effect": MoveEffect.CONDITION,
            "condition": condition,
        })

    if move_info.power != 0:
        execute_move_effect_damage()

func execute_next_move_effect():
    var next = move_effects[0]
    move_effects.remove(0)
    print(move_effects)

    if next.effect == MoveEffect.CONDITION:
        execute_move_effect_condition(next.condition)

func execute_move_effect_damage():
    var move_info = familiar_factory.MOVE_INFO[current_action.move]

    # Compute base damage
    var base_damage = (((((2 * attacker.get_level()) / 5) + 2) * move_info.power * (attacker.get_attack() / defender.get_defense())) / 50) + 2

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

    var target_familiar_sprite: Sprite
    if current_action.target_who == "player":
        target_familiar_sprite = player_sprites.get_child(current_action.target_familiar)
    else:
        target_familiar_sprite = enemy_sprites.get_child(1 - current_action.target_familiar)
    sprite_effect.begin(SpriteEffect.SpriteEffectType.FLICKER, target_familiar_sprite, current_action.target_who == "enemy")
    battle_sound_player.play_sound(battle_sound_player.HIT_NORMAL)

func execute_move_effect_condition(condition):
    if not defender.is_living():
        return

    var move_info = familiar_factory.MOVE_INFO[current_action.move]

    var defender_already_has_condition = false
    for defender_condition in defender.conditions:
        if condition.type == defender_condition.type:
            defender_already_has_condition = true
            break
    var condition_info = familiar_factory.CONDITION_INFO[condition.type]

    if defender_already_has_condition:
        if move_info.power == 0:
            battle_dialog.open_and_wait(familiar_factory.get_display_name(defender) + condition_info.failure_message, get_parent().BATTLE_DIALOG_WAIT_TIME)
        return

    var apply_condition_value = director.rng.randf_range(0.0, 1.0)
    if apply_condition_value <= condition.rate:
        defender.conditions.append({
            "type": condition.type,
            "duration": condition_info.duration,
        })
        battle_dialog.open_and_wait(familiar_factory.get_display_name(defender) + condition_info.success_message, get_parent().BATTLE_DIALOG_WAIT_TIME)
    elif move_info.power == 0:
        battle_dialog.open_and_wait(familiar_factory.get_display_name(attacker) + "'s attack missed!", get_parent().BATTLE_DIALOG_WAIT_TIME)

func execute_switch():
    if current_action.who == "player":
        director.player_party.swap_familiars(current_action.familiar, current_action.with)
    get_parent().set_state(State.SUMMON_FAMILIARS, { "trigger_witch_exit": false, "who": current_action.who })

func execute_use_item():
    var target_familiar = null
    if current_action.target_who == "player":
        target_familiar = director.player_party.familiars[current_action.target_familiar]
    else:
        var item_info = Inventory.ITEM_INFO[current_action.item]
        if item_info.action == Inventory.ItemAction.CAPTURE_MONSTER:
            try_to_catch_familiar(item_info)
            return
        else:
            target_familiar = get_parent().enemy_party.familiars[current_action.familiar]

    if target_familiar != null:
        director.player_inventory.use_item(current_action.item, target_familiar)
        return

    get_parent().set_state(State.EVALUATE_MOVE, { "initialize": true })

func try_to_catch_familiar(gem_info):
    if get_parent().enemy_captured[current_action.target_familiar]:
        battle_dialog.open("Wild " + familiar_factory.get_display_name(get_parent().enemy_party.familiars[current_action.target_familiar]) + " is already caught!")
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
    var catch_effect_ticks: int
    catch_successful = catch_value <= catch_rate
    if catch_successful:
        print("success! " + String(catch_value) + " vs " + String(catch_rate))
        get_parent().enemy_captured[current_action.target_familiar] = true
        for i in range(0, get_parent().actions.size()):
            if get_parent().actions[i].who == "enemy" and get_parent().actions[i].familiar == current_action.target_familiar:
                get_parent().actions.remove(i)
                break
        catch_effect_ticks = 3
    else:
        print("fail! " + String(catch_value) + " vs " + String(catch_rate))
        var tick_zone_size = (1 - catch_rate) / 4
        for zone in range(0, 4):
            if catch_value < catch_rate + (tick_zone_size * (zone + 1)) :
                catch_effect_ticks = 3 - zone 

    catch_effect.position = enemy_sprites.get_child(1 - current_action.target_familiar).position
    catch_effect.start(catch_effect_ticks, catch_successful)

func _on_catch_hide_enemy():
    enemy_sprites.get_child(1 - current_action.target_familiar).visible = false
    enemy_labels.get_child(1 - current_action.target_familiar).visible = false

func _on_catch_effect_finished():
    var dialog_message = "Wild " + familiar_factory.get_display_name(get_parent().enemy_party.familiars[current_action.target_familiar]) 
    if catch_successful:
        dialog_message += " was caught!"
    else:
        dialog_message += " broke free!"
    battle_dialog.open_and_wait(dialog_message, get_parent().BATTLE_DIALOG_WAIT_TIME)

func execute_rest():
    if current_action.who == "player":
        director.player_party.familiars[current_action.familiar].is_resting = true
    elif current_action.who == "enemy":
        get_parent().enemy_party.familiars[current_action.familiar].is_resting = true
