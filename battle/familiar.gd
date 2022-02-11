class_name Familiar

# Stat constants
const MOVE_INFO = {
    "SPOOK": {
        "type": "GHOST",
        "cost": 2,
        "power": 0,
    },
    "EMBER": {
        "type": "FIRE",
        "cost": 3,
        "power": 10,
    },
    "TAUNT": {
        "type": "NORMAL",
        "cost": 1,
        "power": 5,
    },
    "BASK": {
        "type": "FIRE",
        "cost": 0,
        "power": 5,
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
var focus: int

var moves = []

func get_portrait_path() -> String:
    return "res://battle/familiars/" + species.to_lower().replace(" ", "_") + ".png"

func get_display_name() -> String:
    var display_name: String
    if nickname == "":
        display_name = species
    else:
        display_name = nickname
    return display_name

func check_stat_bounds():
    health = int(max(0, health))
    health = int(min(max_health, health))
    mana = int(max(0, mana))
    mana = int(min(max_mana, mana))

func use_move(move: String, enemy: Familiar):
    var move_info = MOVE_INFO[move]

    enemy.health -= move_info["power"]
    mana -= move_info["cost"]

    check_stat_bounds()
    enemy.check_stat_bounds()
