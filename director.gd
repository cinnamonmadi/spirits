extends Node

var battle_scene = preload("res://battle/battle.tscn")
var transition_scene = preload("res://transition.tscn")

var world_instance
var battle_instance
var transition_instance

var player_familiars = []

enum State {
    WORLD,
    TRANSITION,
    BATTLE
}

var state = State.WORLD

func _ready():
    player_familiars.append(Familiar.new())
    player_familiars[0].species = "SPHYNX"
    player_familiars[0].health = 20
    player_familiars[0].max_health = 20
    player_familiars[0].mana = 10
    player_familiars[0].max_mana = 10
    player_familiars[0].moves = ["SPOOK", "TAUNT", "EMBER", "BASK"]
    player_familiars.append(Familiar.new())
    player_familiars[1].species = "OWLBEAR"
    player_familiars[1].health = 34
    player_familiars[1].max_health = 40
    player_familiars[1].mana = 5
    player_familiars[1].max_mana = 5
    player_familiars[1].moves = ["SPOOK", "TAUNT", "EMBER", "BASK"]

    var root = get_tree().get_root()
    world_instance = root.get_child(root.get_child_count() - 1)

func is_player_wiped():
    for familiar in player_familiars:
        if familiar.health > 0:
            return false
    return true

func player_switch_familiars(index_a, index_b):
    var temp_familiar = player_familiars[index_a]
    player_familiars[index_a] = player_familiars[index_b]
    player_familiars[index_b] = temp_familiar 

func _process(_delta):
    if state == State.TRANSITION and transition_instance.finished:
        finish_start_battle()

func start_battle():
    var root = get_tree().get_root()
    world_instance.set_paused(true)
    transition_instance = transition_scene.instance()
    root.add_child(transition_instance)

    state = State.TRANSITION

func finish_start_battle():
    var root = get_tree().get_root()
    root.remove_child(world_instance)
    root.remove_child(transition_instance)
    transition_instance.queue_free()
    battle_instance = battle_scene.instance()
    root.add_child(battle_instance)
    state = State.BATTLE

func end_battle():
    var root = get_tree().get_root()
    root.remove_child(battle_instance)
    battle_instance.queue_free()
    root.add_child(world_instance)
    world_instance.set_paused(false)
    state = State.WORLD
