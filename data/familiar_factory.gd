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
        "cost": 7,
        "power": 0,
        "desc": "Splash water on your foe",
    },
    Move.EMBER: {
        "type": Type.FIRE,
        "cost": 3,
        "power": 40,
        "desc": "Light your foe on fire",
    },
    Move.TACKLE: {
        "type": Type.NORMAL,
        "cost": 1,
        "power": 40,
        "desc": "Tackle your foe",
    },
    Move.VINE_WHIP: {
        "type": Type.GRASS,
        "cost": 0,
        "power": 40,
        "desc": "Whip your foe with vine",
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

func get_and_join_display_names(familiars) -> String:
    var names = get_display_name(familiars[0])
    for i in range(1, familiars.size()):
        names += " and " + get_display_name(familiars[i])
    return names

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

func get_stringified_move_info(move: int, row_char_length: int):
    var stringified_move_info = ["", "", ""]
    var move_info = MOVE_INFO[move]
    stringified_move_info[0] = get_type_name(move_info.type) + "  COST " + String(move_info.cost) + "  POWER "
    if move_info.power == 0:
        stringified_move_info[0] += "N/A"
    else: 
        stringified_move_info[0] += String(move_info.power)

    var words = move_info.desc.split(" ")
    var current_index = 1
    while words.size() != 0:
        var next_word = words[0]
        words.remove(0)

        if stringified_move_info[current_index].length() != 0:
            next_word = " " + next_word
        
        var space_left_in_row = row_char_length - stringified_move_info[current_index].length()
        if space_left_in_row < next_word.length():
            if current_index == stringified_move_info.size() - 1:
                break
            current_index += 1
            if next_word[0] == " ":
                next_word = next_word.substr(1)
        
        stringified_move_info[current_index] += next_word
    
    return stringified_move_info
