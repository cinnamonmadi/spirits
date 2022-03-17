class_name Familiar

enum Species {
    SPHYNX,
    GOBLIN,
    GHOST,
    HIPPOCAMPUS,
    SLIME,
    MIMIC
}

enum Type {
    FIRE,
    GRASS,
    WATER,
    NORMAL
}

enum Move {
    SPLASH,
    EMBER,
    TACKLE,
    VINE_WHIP
}

# Stat constants
const SPECIES_INFO = {
    Species.SPHYNX: {
        "types": [Type.FIRE],
        "health": 50,
        "mana": 20,
        "attack": 75,
        "defense": 85,
        "speed": 40,
        "focus": 20,
        "moves": [
            { "level": 1, "move": Move.SPLASH },
            { "level": 1, "move": Move.EMBER },
            { "level": 1, "move": Move.TACKLE },
            { "level": 1, "move": Move.VINE_WHIP },
        ]
    },
    Species.GOBLIN: {
        "types": [Type.FIRE],
        "health": 50,
        "mana": 20,
        "attack": 75,
        "defense": 85,
        "speed": 40,
        "focus": 20,
        "moves": [
            { "level": 1, "move": Move.SPLASH },
            { "level": 1, "move": Move.EMBER },
            { "level": 1, "move": Move.TACKLE },
            { "level": 1, "move": Move.VINE_WHIP },
        ]
    },
    Species.GHOST: {
        "types": [Type.WATER],
        "health": 50,
        "mana": 20,
        "attack": 75,
        "defense": 85,
        "speed": 40,
        "focus": 20,
        "moves": [
            { "level": 1, "move": Move.SPLASH },
            { "level": 1, "move": Move.EMBER },
            { "level": 1, "move": Move.TACKLE },
            { "level": 1, "move": Move.VINE_WHIP },
        ]
    },
    Species.HIPPOCAMPUS: {
        "types": [Type.WATER],
        "health": 50,
        "mana": 20,
        "attack": 75,
        "defense": 85,
        "speed": 40,
        "focus": 20,
        "moves": [
            { "level": 1, "move": Move.SPLASH },
            { "level": 1, "move": Move.EMBER },
            { "level": 1, "move": Move.TACKLE },
            { "level": 1, "move": Move.VINE_WHIP },
        ]
    },
    Species.SLIME: {
        "types": [Type.NORMAL],
        "health": 50,
        "mana": 20,
        "attack": 75,
        "defense": 85,
        "speed": 40,
        "focus": 20,
        "moves": [
            { "level": 1, "move": Move.SPLASH },
            { "level": 1, "move": Move.EMBER },
            { "level": 1, "move": Move.TACKLE },
            { "level": 1, "move": Move.VINE_WHIP },
        ]
    },
    Species.MIMIC: {
        "types": [Type.GRASS],
        "health": 50,
        "mana": 20,
        "attack": 75,
        "defense": 85,
        "speed": 40,
        "focus": 20,
        "moves": [
            { "level": 1, "move": Move.SPLASH },
            { "level": 1, "move": Move.EMBER },
            { "level": 1, "move": Move.TACKLE },
            { "level": 1, "move": Move.VINE_WHIP },
        ]
    }
}

const MOVE_INFO = {
    Move.SPLASH: {
        "type": Type.WATER,
        "cost": 2,
        "power": 40,
    },
    Move.EMBER: {
        "type": Type.FIRE,
        "cost": 3,
        "power": 40,
    },
    Move.TACKLE: {
        "type": Type.NORMAL,
        "cost": 1,
        "power": 40,
    },
    Move.VINE_WHIP: {
        "type": Type.GRASS,
        "cost": 0,
        "power": 40,
    }
}

const TYPE_INFO = {
    Type.FIRE: {
        "weaknesses": [
            Type.WATER
        ],
        "resistances": [
            Type.GRASS
        ]
    },
    Type.WATER: {
        "weaknesses": [
            Type.GRASS
        ],
        "resistances": [
            Type.FIRE
        ]
    },
    Type.GRASS: {
        "weaknesses": [
            Type.FIRE
        ],
        "resistances": [
            Type.WATER
        ]
    },
    Type.NORMAL: {
        "weaknesses": [],
        "resistances": []
    }
}

# Stats
var species: int
var nickname: String = ""
var types 
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

func _init(as_species: int, at_level: int):
    species = as_species
    set_level(at_level)
    health = max_health
    mana = max_mana
    for move in SPECIES_INFO[species]["moves"]:
        moves.append(move["move"])
        if moves.size() == 4:
            break

func is_living() -> bool:
    return health > 0

func set_level(value: int):
    level = value
    var species_info = SPECIES_INFO[species]
    types = species_info.types
    max_health = int((species_info["health"] * 2 * level) / 100) + level + 10
    max_mana = int((species_info["mana"] * 2 * level) / 100) + level + 5
    attack = int((species_info["attack"] * 2 * level) / 100) + 5
    defense = int((species_info["defense"] * 2 * level) / 100) + 5
    speed = int((species_info["speed"] * 2 * level) / 100) + 5

func change_health(amount: int):
    health += amount
    health = int(clamp(health, 0, max_health))

func change_mana(amount: int):
    mana += amount
    mana = int(clamp(mana, 0, max_mana))

func get_portrait_path() -> String:
    return "res://battle/familiars/" + Species.keys()[species].to_lower().replace(" ", "_") + ".png"

func get_display_name() -> String:
    var display_name: String
    if nickname == "":
        display_name = Species.keys()[species]
    else:
        display_name = nickname
    return display_name

func get_type_name():
    return Type.keys()[types[0]]

func get_move_names():
    var move_names = []
    for move in moves:
        move_names.append(Move.keys()[move])
    return move_names

func get_move_type_names():
    var move_type_names = []
    for move in moves:
        move_type_names.append(Type.keys()[MOVE_INFO[move].type])
    return move_type_names
