extends Node

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
    VINE_WHIP,
    BANANA
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
        "catch_rate": 0.75,
        "base_exp_yield": 50,
        "moves": [
            { "level": 1, "move": Move.SPLASH },
            { "level": 1, "move": Move.EMBER },
            { "level": 1, "move": Move.TACKLE },
            { "level": 1, "move": Move.VINE_WHIP },
            { "level": 6, "move": Move.BANANA },
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
        "catch_rate": 0.75,
        "base_exp_yield": 50,
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
        "catch_rate": 0.75,
        "base_exp_yield": 50,
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
        "catch_rate": 0.75,
        "base_exp_yield": 50,
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
        "catch_rate": 0.75,
        "base_exp_yield": 50,
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
        "catch_rate": 0.75,
        "base_exp_yield": 50,
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


func _ready():
    pass

func create_familiar(species: int, level: int) -> Familiar:
    var new_familiar = Familiar.new(species, SPECIES_INFO[species], level)
    return new_familiar

func get_portrait_path(familiar: Familiar) -> String:
    return "res://battle/familiars/" + Species.keys()[familiar.species].to_lower().replace(" ", "_") + ".png"

func get_display_name(familiar: Familiar) -> String:
    if familiar.nickname == "":
        return Species.keys()[familiar.species]
    else:
        return familiar.nickname

func get_type_name(type: int) -> String:
    return Type.keys()[type]

func get_move_name(move: int) -> String:
    return Move.keys()[move]

func get_move_names(familiar: Familiar) -> String:
    var move_names = []
    for move in familiar.moves:
        move_names.append(Move.keys()[move])
    return move_names

func get_move_type_names(familiar: Familiar) -> String:
    var move_type_names = []
    for move in familiar.moves:
        move_type_names.append(Type.keys()[MOVE_INFO[move].type])
    return move_type_names
