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
var rng = RandomNumberGenerator.new()

func _ready():
    player_familiars.append(Familiar.new("SPHYNX", 5))
    player_familiars[0].nickname = "Beerus"
    player_familiars.append(Familiar.new("OWLBEAR", 5))
    player_familiars[1].nickname = "Deputy"

    rng.randomize()
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
    transition_instance.queue_free()
    battle_instance = battle_scene.instance()
    root.add_child(battle_instance)
    state = State.BATTLE

func end_battle():
    var root = get_tree().get_root()
    battle_instance.queue_free()
    root.add_child(world_instance)
    world_instance.set_paused(false)
    state = State.WORLD
