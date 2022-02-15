class_name Familiar

# Stat constants
const SPECIES_INFO = {
    "SPHYNX": {
        "health": 50,
        "mana": 20,
        "attack": 75,
        "defense": 85,
        "speed": 40,
        "focus": 20,
        "moves": [
            { "level": 1, "move": "SPOOK" },
            { "level": 1, "move": "EMBER" },
            { "level": 1, "move": "TAUNT" },
            { "level": 1, "move": "BASK" },
        ]
    },
    "OWLBEAR": {
        "health": 50,
        "mana": 20,
        "attack": 75,
        "defense": 85,
        "speed": 40,
        "focus": 20,
        "moves": [
            { "level": 1, "move": "SPOOK" },
            { "level": 1, "move": "EMBER" },
            { "level": 1, "move": "TAUNT" },
            { "level": 1, "move": "BASK" },
        ]
    }
}
const MOVE_INFO = {
    "SPOOK": {
        "type": "GHOST",
        "cost": 2,
        "power": 0,
    },
    "EMBER": {
        "type": "FIRE",
        "cost": 3,
        "power": 60,
    },
    "TAUNT": {
        "type": "NORMAL",
        "cost": 1,
        "power": 40,
    },
    "BASK": {
        "type": "FIRE",
        "cost": 0,
        "power": 20,
    }
}

# Stats
var species: String
var nickname: String = ""
var type: String
var level: int
var experience: int

var health: int
var max_health: int

var mana: int
var max_mana: int

var attack: int
var defense: int
var speed: int

var moves = []

func _init(as_species: String, at_level: int):
    species = as_species
    set_level(at_level)
    health = max_health
    mana = max_mana
    for move in SPECIES_INFO[species]["moves"]:
        moves.append(move["move"])
        if moves.size() == 4:
            break

func set_level(value: int):
    level = value
    var species_info = SPECIES_INFO[species]
    max_health = int((species_info["health"] * 2 * level) / 100) + level + 10
    max_mana = int((species_info["mana"] * 2 * level) / 100) + level + 5
    attack = int((species_info["attack"] * 2 * level) / 100) + 5
    defense = int((species_info["defense"] * 2 * level) / 100) + 5
    speed = int((species_info["speed"] * 2 * level) / 100) + 5

func get_portrait_path() -> String:
    return "res://battle/familiars/" + species.to_lower().replace(" ", "_") + ".png"

func get_display_name() -> String:
    var display_name: String
    if nickname == "":
        display_name = species
    else:
        display_name = nickname
    return display_name
