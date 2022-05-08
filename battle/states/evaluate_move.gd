extends Node
class_name EvaluateMove

onready var director = get_node("/root/Director")
onready var effect_factory = get_node("/root/EffectFactory")

onready var player_sprites = get_parent().get_node("player_sprites")
onready var player_labels = get_parent().get_node("ui/player_labels")
onready var enemy_sprites = get_parent().get_node("enemy_sprites")
onready var enemy_labels = get_parent().get_node("ui/enemy_labels")
onready var battle_dialog = get_parent().get_node("ui/battle_dialog")
onready var timer = get_parent().get_node("timer")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

enum Todo {
    BURNOUT_PLAYER,
    BURNOUT_ENEMY,
    FAINT_PLAYER,
    FAINT_ENEMY,
    CURE_CONDITION,
}

var current_action 
var player_familiar_died 
var enemy_familiar_died
var todos
var announcements

func begin(params):
    if not params.initialize:
        return

    current_action = get_parent().actions.pop_front()
    player_familiar_died = false
    enemy_familiar_died = false
    todos = []

    if current_action.action == Action.USE_MOVE:
        # Check if the attacking familiar burnt themselves out or died
        if current_action.who == "player":
            if director.player_party.familiars[current_action.familiar].burnout != 0:
                todos.append({ "todo": Todo.BURNOUT_PLAYER, "familiar": current_action.familiar })
        if current_action.who == "enemy":
            if get_parent().enemy_party.familiars[current_action.familiar].burnout != 0:
                todos.append({ "todo": Todo.BURNOUT_ENEMY, "familiar": current_action.familiar })

        # Check if target familiar died
        if current_action.target_who == "player":
            if not director.player_party.familiars[current_action.target_familiar].is_living():
                todos.append({ "todo": Todo.FAINT_PLAYER, "familiar": current_action.target_familiar })
        if current_action.target_who == "enemy":
            if not get_parent().enemy_party.familiars[current_action.target_familiar].is_living():
                todos.append({ "todo": Todo.FAINT_ENEMY, "familiar": current_action.target_familiar })

    var battle_is_over = director.player_party.get_living_familiar_count() == 0 or get_parent().get_enemy_living_familiar_count() == 0
    if not battle_is_over and get_parent().actions.size() == 0:
        countdown_temporary_conditions()

func burnout_familiar(familiar: Familiar):
    var burnout_damage = familiar.burnout * (ceil(familiar.get_level() / 25.0) + 1)
    familiar.change_health(-burnout_damage)

func burnout_player_familiar(familiar_index: int):
    var familiar = director.player_party.familiars[familiar_index]
    burnout_familiar(familiar)
    if not director.player_party.familiars[current_action.familiar].is_living():
        todos.push_front({ "todo": Todo.FAINT_PLAYER, "familiar": current_action.familiar })
    battle_dialog.open_and_wait(familiar.get_display_name() + " burned out!", get_parent().BATTLE_DIALOG_WAIT_TIME)

func burnout_enemy_familiar(familiar_index: int):
    var familiar = get_parent().enemy_party.familiars[familiar_index]
    burnout_familiar(familiar)
    if not get_parent().enemy_party.familiars[current_action.familiar].is_living():
        todos.push_front({ "todo": Todo.FAINT_ENEMY, "familiar": current_action.familiar })
    battle_dialog.open_and_wait("Enemy " + familiar.get_display_name() + " burned out!", get_parent().BATTLE_DIALOG_WAIT_TIME)

func faint_player_familiar(familiar_index: int):
    for action_index in range(0, get_parent().actions.size()):
        if get_parent().actions[action_index].who == "player" and get_parent().actions[action_index].familiar == familiar_index:
            get_parent().actions.remove(action_index)
            break
    player_sprites.get_child(familiar_index).visible = false
    player_labels.get_child(familiar_index).visible = false
    create_death_effect(player_sprites.get_child(familiar_index).position)
    battle_dialog.open_and_wait(director.player_party.familiars[familiar_index].get_display_name() + " fainted!", get_parent().BATTLE_DIALOG_WAIT_TIME)
    player_familiar_died = true

func faint_enemy_familiar(familiar_index: int):
    for action_index in range(0, get_parent().actions.size()):
        if get_parent().actions[action_index].who == "enemy" and get_parent().actions[action_index].familiar == familiar_index:
            get_parent().actions.remove(action_index)
            break
    enemy_sprites.get_child(1 - familiar_index).visible = false
    enemy_labels.get_child(1 - familiar_index).visible = false
    create_death_effect(enemy_sprites.get_child(1 - familiar_index).position)
    battle_dialog.open_and_wait("Enemy " + get_parent().enemy_party.familiars[familiar_index].get_display_name() + " fainted!", get_parent().BATTLE_DIALOG_WAIT_TIME)
    enemy_familiar_died = true

func create_death_effect(death_position: Vector2):
    var effect = effect_factory.create_effect(effect_factory.Effect.MONSTER_DEATH)
    get_parent().add_child(effect)
    effect.position = death_position
    effect.start()

func countdown_temporary_conditions():
    for familiar_index in range(0, min(2, director.player_party.get_living_familiar_count())):
        var familiar = director.player_party.familiars[familiar_index]
        countdown_conditions_for_familiar(familiar, "player", familiar_index)
    for familiar_index in range(0, min(2, get_parent().enemy_party.get_living_familiar_count())):
        var familiar = get_parent().enemy_party.familiars[familiar_index]
        countdown_conditions_for_familiar(familiar, "enemy", familiar_index)

func countdown_conditions_for_familiar(familiar, who, familiar_index):
    if not familiar.is_living():
        return
    for condition_index in range(0, familiar.conditions.size()):
        if familiar.conditions[condition_index].duration == Conditions.CONDITION_DURATION_INDEFINITE:
            continue
        familiar.conditions[condition_index].duration -= 1
        if familiar.conditions[condition_index].duration == 0:
            todos.append({
                "todo": Todo.CURE_CONDITION,
                "who": who,
                "familiar": familiar_index,
                "condition": condition_index,
            })

func cure_condition(who: String, familiar_index: int, condition_index: int):
    var familiar
    if who == "player":
        familiar = director.player_party.familiars[familiar_index]
    else:
        familiar = get_parent().enemy_party.familiars[familiar_index]
    var message = familiar.get_display_name() + Conditions.CONDITION_INFO[familiar.conditions[condition_index].type].expire_message
    familiar.conditions.remove(condition_index)
    battle_dialog.open_and_wait(message, get_parent().BATTLE_DIALOG_WAIT_TIME)

func end_state():
    if director.player_party.get_living_familiar_count() == 0 or get_parent().get_enemy_living_familiar_count() == 0:
        battle_dialog.keep_open = false
        battle_dialog.close()
        get_parent().set_state(State.ANNOUNCE_WINNER, { "first_time_entering_state": true })
        return

    if director.player_party.get_living_familiar_count() >= 2:
        for i in range(0, min(director.player_party.familiars.size(), 2)):
            if not director.player_party.familiars[i].is_living():
                get_parent().set_state(State.PARTY_MENU, { "switch_required": true })
                return

    if get_parent().actions.size() == 0:
        get_parent().recharge_energy()
        get_parent().set_state(State.CHOOSE_ACTION, {})
        return

    get_parent().set_state(State.ANIMATE_MOVE, {})

func pop_next_todo():
    var next_todo = todos.pop_front()
    if next_todo.todo == Todo.BURNOUT_PLAYER:
        burnout_player_familiar(next_todo.familiar)
    elif next_todo.todo == Todo.BURNOUT_ENEMY:
        burnout_enemy_familiar(next_todo.familiar)
    elif next_todo.todo == Todo.FAINT_PLAYER:
        faint_player_familiar(next_todo.familiar)
    elif next_todo.todo == Todo.FAINT_ENEMY:
        faint_enemy_familiar(next_todo.familiar)
    elif next_todo.todo == Todo.CURE_CONDITION:
        cure_condition(next_todo.who, next_todo.familiar, next_todo.condition)

func process(_delta):
    if Input.is_action_just_pressed("action"):
        battle_dialog.progress()
    if not battle_dialog.is_open():
        if todos.size() == 0:
            end_state()
        else:
            pop_next_todo()

func handle_tween_finish():
    pass

func handle_timer_timeout():
    end_state()
