extends Node

var battle_scene = preload("res://battle/battle.tscn")
var transition_scene = preload("res://transition.tscn")

var world_instance
var battle_instance
var transition_instance

enum State {
    WORLD,
    TRANSITION,
    BATTLE
}

var state = State.WORLD

func _ready():
    var root = get_tree().get_root()
    world_instance = root.get_child(root.get_child_count() - 1)

func _process(_delta):
    if state == State.TRANSITION and transition_instance.finished:
        var root = get_tree().get_root()
        
        transition_instance.free()
        root.remove_child(world_instance)

        battle_instance = battle_scene.instance()
        root.add_child(battle_instance)
        state = State.BATTLE

func start_battle():
    for actor in get_tree().get_nodes_in_group("actors"):
        actor.paused = true
    transition_instance = transition_scene.instance()
    world_instance.add_child(transition_instance)
    state = State.TRANSITION

func end_battle():
    var root = get_tree().get_root()
    battle_instance.free()
    root.add_child(world_instance)
    for actor in get_tree().get_nodes_in_group("actors"):
        actor.paused = false
    state = State.WORLD