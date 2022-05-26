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
    ANNOUNCE,
    BURNOUT_PLAYER,
    BURNOUT_ENEMY,
    FAINT_PLAYER,
    FAINT_ENEMY,
    CURE_CONDITION,
}

var current_action 
var player_familiar_died 
var enemy_familiar_died
var todos = []
var announcements

func begin(params):
    current_action = get_parent().actions.pop_front()
    todos = []

    if not params.initialize:
        return

    player_familiar_died = false
    enemy_familiar_died = false

    if current_action.action == Action.USE_MOVE:
        # Check if the attacking familiar burnt themselves out or died
        if current_action.who == "player":
            if director.player_party.familiars[current_action.familiar].burnout != 0:
                todos.append({ "todo": Todo.BURNOUT_PLAYER, "familiar": current_action.familiar })
        if current_action.who == "enemy":
            if director.enemy_party.familiars[current_action.familiar].burnout != 0:
                todos.append({ "todo": Todo.BURNOUT_ENEMY, "familiar": current_action.familiar })

        # Check if target familiar died
        if current_action.target_who == "player":
            var dead_familiars = []
            for i in range(0, min(2, director.player_party.familiars.size())):
                if not director.player_party.familiars[i].is_living() and get_parent().player_sprites.get_child(i).visible:
                    dead_familiars.append(i)
            if dead_familiars.size() != 0:
                todos.append({ "todo": Todo.FAINT_PLAYER, "familiars": dead_familiars })
        if current_action.target_who == "enemy":
            var dead_familiars = []
            for i in range(0, min(2, director.enemy_party.familiars.size())):
                if not director.enemy_party.familiars[i].is_living() and get_parent().enemy_sprites.get_child(1 - i).visible:
                    dead_familiars.append(i)
            if dead_familiars.size() != 0:
                todos.append({ "todo": Todo.FAINT_ENEMY, "familiars": dead_familiars })

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
    var familiar = director.enemy_party.familiars[familiar_index]
    burnout_familiar(familiar)
    if not director.enemy_party.familiars[current_action.familiar].is_living():
        todos.push_front({ "todo": Todo.FAINT_ENEMY, "familiar": current_action.familiar })
    battle_dialog.open_and_wait("Enemy " + familiar.get_display_name() + " burned out!", get_parent().BATTLE_DIALOG_WAIT_TIME)

func faint_player_familiar(familiars):
    for familiar_index in familiars:
        for action_index in range(0, get_parent().actions.size()):
            if get_parent().actions[action_index].who == "player" and get_parent().actions[action_index].familiar == familiar_index:
                get_parent().actions.remove(action_index)
                break
        player_sprites.get_child(familiar_index).visible = false
        player_labels.get_child(familiar_index).visible = false
        create_death_effect(player_sprites.get_child(familiar_index).position)
        todos.insert(0, {
            "todo": Todo.ANNOUNCE,
            "message": director.player_party.familiars[familiar_index].get_display_name() + " fainted!" 
        })
    player_familiar_died = true

func faint_enemy_familiar(familiars):
    for familiar_index in familiars:
        for action_index in range(0, get_parent().actions.size()):
            if get_parent().actions[action_index].who == "enemy" and get_parent().actions[action_index].familiar == familiar_index:
                get_parent().actions.remove(action_index)
                break
        enemy_sprites.get_child(1 - familiar_index).visible = false
        enemy_labels.get_child(1 - familiar_index).visible = false
        create_death_effect(enemy_sprites.get_child(1 - familiar_index).position)
        todos.insert(0, {
            "todo": Todo.ANNOUNCE,
            "message": "Enemy " + director.enemy_party.familiars[familiar_index].get_display_name() + " fainted!"
        })
    enemy_familiar_died = true

func announce(message: String):
    battle_dialog.open_and_wait(message, get_parent().BATTLE_DIALOG_WAIT_TIME)

func create_death_effect(death_position: Vector2):
    var effect = effect_factory.create_effect(effect_factory.Effect.MONSTER_DEATH)
    get_parent().add_child(effect)
    effect.position = death_position
    effect.start()

func countdown_temporary_conditions():
    for familiar_index in director.player_party.get_live_fighter_indeces():
        var familiar = director.player_party.familiars[familiar_index]
        countdown_conditions_for_familiar(familiar, "player", familiar_index)
    for familiar_index in director.enemy_party.get_live_fighter_indeces():
        var familiar = director.enemy_party.familiars[familiar_index]
        countdown_conditions_for_familiar(familiar, "enemy", familiar_index)

func countdown_conditions_for_familiar(familiar, who, familiar_index):
    if not familiar.is_living():
        return
    var expired_conditions = familiar.tick_conditions()
    for condition in expired_conditions:
        todos.append({
            "todo": Todo.CURE_CONDITION,
            "who": who,
            "familiar": familiar_index,
            "condition": condition,
        })

func cure_condition(who: String, familiar_index: int, condition: Condition):
    var familiar
    if who == "player":
        familiar = director.player_party.familiars[familiar_index]
    else:
        familiar = director.enemy_party.familiars[familiar_index]
    familiar.conditions.erase(condition)
    if condition.expire_message != "":
        battle_dialog.open_and_wait(familiar.get_display_name() + condition.expire_message, get_parent().BATTLE_DIALOG_WAIT_TIME)

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
    if next_todo.todo == Todo.ANNOUNCE:
        announce(next_todo.message)
    elif next_todo.todo == Todo.BURNOUT_PLAYER:
        burnout_player_familiar(next_todo.familiar)
    elif next_todo.todo == Todo.BURNOUT_ENEMY:
        burnout_enemy_familiar(next_todo.familiar)
    elif next_todo.todo == Todo.FAINT_PLAYER:
        faint_player_familiar(next_todo.familiars)
    elif next_todo.todo == Todo.FAINT_ENEMY:
        faint_enemy_familiar(next_todo.familiars)
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
