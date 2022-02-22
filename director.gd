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
    player_party.familiars.append(Familiar.new(Familiar.Species.SPHYNX, 20))
    player_party.familiars[0].nickname = "Beerus"
    player_party.familiars.append(Familiar.new(Familiar.Species.SLIME, 20))
    player_party.familiars[1].nickname = "Deputy"
    player_party.familiars.append(Familiar.new(Familiar.Species.MIMIC, 3))
    player_party.familiars[2].nickname = "Cat"

    player_inventory.add_item(Inventory.Item.POTION, 5)
    player_inventory.add_item(Inventory.Item.HI_POTION, 2)
    player_inventory.add_item(Inventory.Item.ETHER, 3)
    player_inventory.add_item(Inventory.Item.RUBY, 3)
    player_inventory.add_item(Inventory.Item.SAPPHIRE, 3)
    player_inventory.add_item(Inventory.Item.EMERALD, 3)
    player_inventory.add_item(Inventory.Item.ONYX, 3)
    player_inventory.add_item(Inventory.Item.QUARTZ, 3)
    player_inventory.add_item(Inventory.Item.RARE_RUBY, 3)
    player_inventory.add_item(Inventory.Item.RARE_SAPPHIRE, 3)
    player_inventory.add_item(Inventory.Item.RARE_EMERALD, 3)
    player_inventory.add_item(Inventory.Item.RARE_ONYX, 3)
    player_inventory.add_item(Inventory.Item.RARE_QUARTZ, 3)
    player_inventory.add_item(Inventory.Item.PEARL, 3)
    player_inventory.add_item(Inventory.Item.PEARL2, 3)
    player_inventory.add_item(Inventory.Item.PEARL3, 3)
    player_inventory.add_item(Inventory.Item.PEARL4, 3)
    player_inventory.add_item(Inventory.Item.PEARL5, 3)
    player_inventory.add_item(Inventory.Item.PEARL6, 3)
    player_inventory.add_item(Inventory.Item.PEARL7, 3)
    player_inventory.add_item(Inventory.Item.PEARL8, 3)
    player_inventory.add_item(Inventory.Item.PEARL9, 3)

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
