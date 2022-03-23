extends Node

var battle_scene = preload("res://battle/battle.tscn")
var transition_scene = preload("res://transition.tscn")

var world_instance
var battle_instance
var transition_instance

var player_party = Party.new()
var player_inventory = Inventory.new()

enum State {
    WORLD,
    TRANSITION,
    BATTLE
}

var state = State.WORLD
var rng = RandomNumberGenerator.new()

func _ready():
    player_party.add_familiar(Familiar.new(Familiar.Species.SPHYNX, 5))
    player_party.familiars[0].nickname = "Beerus"
    player_party.familiars[0].experience = player_party.familiars[0].get_experience_tnl() - 3
    player_party.add_familiar(Familiar.new(Familiar.Species.SLIME, 5))
    player_party.familiars[1].nickname = "Deputy"
    player_party.add_familiar(Familiar.new(Familiar.Species.MIMIC, 3))
    player_party.familiars[2].nickname = "Cat"
    player_party.familiars[0].health -= 10

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
    # battle_instance.surprise_round = "player"
    root.add_child(battle_instance)
    state = State.BATTLE

func end_battle():
    var root = get_tree().get_root()
    battle_instance.queue_free()
    root.add_child(world_instance)
    world_instance.end_battle()
    state = State.WORLD
