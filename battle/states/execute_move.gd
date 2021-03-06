extends Node
class_name ExecuteMove

onready var director = get_node("/root/Director")

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
    CONDITION,
    MESSAGE
}

var current_action 
var catch_successful: bool
var sprite_effect
var move_effects = []

var attacker  
var defenders

func _ready():
    sprite_effect = SpriteEffect.new()
    get_parent().add_child(sprite_effect)
    catch_effect.connect("animation_finished", self, "_on_catch_effect_finished")
    catch_effect.connect("hide_enemy", self, "_on_catch_hide_enemy")

func begin(params):
    current_action = get_parent().actions[0]

    if params.skip_action:
        return
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
    attacker = get_parent().get_acting_familiar(current_action)

    # Assign the defender, but if the defender is dead, choose another defender from the defending party
    # Note that this code assumes that if all members of a given party are dead, then we would have never reached this code
    var defending_party
    if current_action.target_who == "player":
        defending_party = director.player_party
    else:
        defending_party = director.enemy_party
    defenders = []
    if current_action.move.targets == Move.MoveTargets.TARGETS_ONE_ALLY or current_action.move.targets == Move.MoveTargets.TARGETS_ONE_ENEMY:
        var target_familiar_index = current_action.target_familiar
        if not defending_party.familiars[current_action.target_familiar].is_living():
            target_familiar_index = (target_familiar_index + 1) % 2
        defenders.append(defending_party.familiars[target_familiar_index])
    elif current_action.move.targets == Move.MoveTargets.TARGETS_SELF:
        defenders.append(attacker)
    elif current_action.move.targets == Move.MoveTargets.TARGETS_ALL_ALLIES or current_action.move.targets == Move.MoveTargets.TARGETS_ALL_ENEMIES:
        for i in defending_party.get_live_fighter_indeces():
            defenders.append(defending_party.familiars[i])

    move_effects = []

    var interrupted_defenders = []
    for defender in defenders:
        for condition in defender.conditions:
            var response = condition.on_attacked(attacker, defender, current_action.move)
            if response.type == Condition.ResponseType.INTERRUPT:
                interrupted_defenders.append(defender)
            if response.message != "":
                move_effects.append({
                    "effect": MoveEffect.MESSAGE,
                    "defender": defender,
                    "message": response.message,
                })
    for defender in interrupted_defenders:
        defenders.erase(defender)

    for defender in defenders:
        for i in range(0, current_action.move.conditions.size()):
            move_effects.append({
                "effect": MoveEffect.CONDITION,
                "defender": defender,
                "condition": current_action.move.conditions[i],
                "rate": current_action.move.condition_rates[i]
            })

    if current_action.move.power != 0:
        for defender in defenders:
            execute_move_effect_damage(defender)

func execute_next_move_effect():
    var next = move_effects[0]
    move_effects.remove(0)

    if next.effect == MoveEffect.CONDITION:
        execute_move_effect_condition(next.defender, next.condition, next.rate)
    elif next.effect == MoveEffect.MESSAGE:
        execute_move_effect_interrupted(next.defender, next.message)

func check_condition_interrupts_attack(defender) -> String:
    for condition in defender.conditions:
        var interrupt = condition.on_attacked(attacker, defender, current_action.move)
        if interrupt != "":
            return interrupt
    return ""

func execute_move_effect_interrupted(defender, message):
    var familiar_name = defender.get_display_name()
    if current_action.target_who == "enemy":
        familiar_name = "Enemy " + familiar_name
    battle_dialog.open_and_wait(familiar_name + message, get_parent().BATTLE_DIALOG_WAIT_TIME)


func execute_move_effect_damage(defender):
    # Compute base damage
    var base_damage = (((((2 * attacker.get_level()) / 5) + 2) * current_action.move.power * (attacker.get_attack() / defender.get_defense())) / 50) + 2

    # Compute STAB
    var stab = 1
    if attacker.species.types.has(current_action.move.type):
        stab = 1.5 
    
    # Compute weaknesses / resistances
    var type_mod = 1.0
    for type in defender.species.types:
        var type_info = Types.TYPE_INFO[type]
        if type_info.weaknesses.has(current_action.move.type):
            type_mod *= 2.0
        elif type_info.resistances.has(current_action.move.type):
            type_mod *= 0.5

    var random = director.rng.randf_range(0.85, 1.0)
    var damage = base_damage * stab * type_mod * random

    # Apply damage and mana cost
    defender.change_health(-damage)
    attacker.change_mana(-current_action.move.cost)

    var target_familiar_sprite: Sprite
    if current_action.target_who == "player":
        for i in range(0, min(2, director.player_party.familiars.size())):
            if director.player_party.familiars[i] == defender:
                target_familiar_sprite = player_sprites.get_child(i)
    else:
        for i in range(0, min(2, director.enemy_party.familiars.size())):
            if director.enemy_party.familiars[i] == defender:
                target_familiar_sprite = enemy_sprites.get_child(1 - i)
    target_familiar_sprite.start_animation(FamiliarSprite.Animation.HURT)
    sprite_effect.begin(SpriteEffect.SpriteEffectType.FLICKER, target_familiar_sprite, current_action.target_who == "enemy")
    battle_sound_player.play_sound(battle_sound_player.HIT_NORMAL)

func execute_move_effect_condition(defender, condition_type, rate):
    if not defender.is_living():
        return

    var apply_condition_value = director.rng.randf_range(0.0, 1.0)
    var response_message = ""
    if apply_condition_value <= rate:
        response_message = defender.apply_condition(condition_type, {}, current_action.move.power != 0)

    if response_message != "":
        var familiar_name = defender.get_display_name()
        if current_action.target_who == "enemy":
            familiar_name = "Enemy " + familiar_name
        battle_dialog.open_and_wait(familiar_name + response_message, get_parent().BATTLE_DIALOG_WAIT_TIME)
    elif current_action.move.power == 0:
        var familiar_name = attacker.get_display_name()
        if current_action.who == "enemy":
            familiar_name = "Enemy " + familiar_name
        battle_dialog.open_and_wait(familiar_name + "'s attack missed!", get_parent().BATTLE_DIALOG_WAIT_TIME)

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
            target_familiar = director.enemy_party.familiars[current_action.familiar]

    if target_familiar != null:
        director.player_inventory.use_item(current_action.item, target_familiar)
        return

    get_parent().set_state(State.EVALUATE_MOVE, { "initialize": true })

func try_to_catch_familiar(gem_info):
    if get_parent().enemy_captured[current_action.target_familiar]:
        battle_dialog.open("Wild " + director.enemy_party.familiars[current_action.target_familiar].get_display_name() + " is already caught!")
        return

    var target_familiar = director.enemy_party.familiars[current_action.target_familiar]

    # Calculate the catch rate
    var health_mod = float(((3.0 * target_familiar.max_health) - (2.0 * target_familiar.health)) / (3.0 * target_familiar.max_health)) # (3max_health - 2health) / 3max_health
    var ally_mod = 1.0 - (float(director.enemy_party.get_living_familiar_count() - 1) * 0.25) # 1 - (0.25 * num_allies)
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
    var dialog_message = "Wild " + director.enemy_party.familiars[current_action.target_familiar].get_display_name() 
    if catch_successful:
        dialog_message += " was caught!"
    else:
        dialog_message += " broke free!"
    battle_dialog.open_and_wait(dialog_message, get_parent().BATTLE_DIALOG_WAIT_TIME)

func execute_rest():
    if current_action.who == "player":
        director.player_party.familiars[current_action.familiar].is_resting = true
    elif current_action.who == "enemy":
        director.enemy_party.familiars[current_action.familiar].is_resting = true
