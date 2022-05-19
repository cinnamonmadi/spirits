extends Node

var battle_scene = preload("res://battle/battle.tscn")
var transition_scene = preload("res://transition.tscn")

var world_instance
var battle_instance
var transition_instance

var player_party = Party.new()
var player_inventory = Inventory.new()
var enemy_party = Party.new()

enum State {
    WORLD,
    TRANSITION,
    BATTLE
}

var state = State.WORLD
var rng = RandomNumberGenerator.new()

func _ready():
    player_party.add_familiar(Familiar.new(load("res://data/species/mimic.tres"), 5))
    player_party.familiars[0].nickname = "Beerus"
    player_party.familiars[0].add_experience(player_party.familiars[0].get_experience_tnl() - 3)
    player_party.familiars[0].moves.append(load("res://data/moves/trap.tres"))
    player_party.add_familiar(Familiar.new(load("res://data/species/mimic.tres"), 5))
    player_party.familiars[1].nickname = "Deputy"
    player_party.add_familiar(Familiar.new(load("res://data/species/mimic.tres"), 5))
    player_party.familiars[2].nickname = "Cat"

    player_inventory.add_item(Inventory.Item.POTION, 5)
    player_inventory.add_item(Inventory.Item.HI_POTION, 2)
    player_inventory.add_item(Inventory.Item.ETHER, 3)
    player_inventory.add_item(Inventory.Item.RUBY, 3)
    player_inventory.add_item(Inventory.Item.SAPPHIRE, 3)

    rng.randomize()
    var root = get_tree().get_root()
    world_instance = root.get_child(root.get_child_count() - 1)

func start_battle():
    var root = get_tree().get_root()
    root.remove_child(world_instance)
    battle_instance = battle_scene.instance()
    root.add_child(battle_instance)
    state = State.BATTLE

func end_battle():
    var root = get_tree().get_root()
    battle_instance.queue_free()
    root.add_child(world_instance)
    world_instance.end_battle()
    state = State.WORLD
