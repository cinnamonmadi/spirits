class_name Familiar

const MAX_LEVEL = 100

# Stats
var species: int
var species_info
var nickname: String = ""
var types 
var experience: int
var level: int

var health: int
var max_health: int

var mana: int
var max_mana: int

var attack: int
var defense: int
var speed: int
var focus: int

var moves = []

var is_resting: bool
var participated: bool
var is_burntout: bool
var burnout: int

func _init(as_species: int, with_species_info, at_level: int):
    species = as_species
    species_info = with_species_info
    experience = 0
    set_level(at_level)
    health = max_health
    mana = max_mana
    for move in species_info.moves:
        if move.level <= level:
            moves.append(move.move)
        if moves.size() == 4:
            break

    is_resting = false
    participated = false
    is_burntout = false
    burnout = 0

func is_living() -> bool:
    return health > 0

func get_catch_rate() -> float:
    return species_info.catch_rate

func get_experience_yield() -> int:
    return int((species_info.base_exp_yield * get_level()) / 7.0)

func set_level(value: int):
    experience = get_experience_at_level(value)
    level = value
    update_stats()

func update_stats():
    types = species_info.types
    max_health = int((species_info.health * 2 * level) / 100) + level + 10
    max_mana = int((species_info.mana * 1.25 * level) / 100) + 5
    attack = int((species_info.attack * 2 * level) / 100) + 5
    defense = int((species_info.defense * 2 * level) / 100) + 5
    speed = int((species_info.speed * 2 * level) / 100) + 5
    focus = int((species_info.focus * 2 * level) / 100) + 5

func get_level() -> int:
    return level

func get_experience_at_level(the_level: int) -> int:
    return int(pow((the_level), 3))

func get_current_experience() -> int:
    if get_level() == 1:
        return experience
    else:
        return experience - get_experience_at_level(get_level())

func get_experience_tnl() -> int:
    return get_experience_at_level(level + 1) - get_experience_at_level(level)

# If the amount of experience gained is more than needed to reach the next level, the remaining EXP is returned
# This allows experience gain to pause whenever there's a level up
func add_experience(amount: int):
    if get_level() == MAX_LEVEL:
        return 
    var tnl = get_experience_tnl() - get_current_experience()
    experience += amount
    if tnl > amount:
        return 0
    else:
        level += 1
        update_stats()
        return amount - tnl

func change_health(amount: int):
    health += amount
    health = int(clamp(health, 0, max_health))

func change_mana(amount: int):
    mana += amount
    if mana < 0:
        burnout = mana * -1
    mana = int(clamp(mana, 0, max_mana))

func get_level_up_moves(for_level):
    var level_up_moves = []
    for move in species_info.moves:
        if move.level == for_level:
            level_up_moves.append(move.move)
    return level_up_moves
