class_name Familiar

const MAX_LEVEL = 100

# Stats
var species: Species
var nickname: String
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

var conditions = []

var is_resting: bool
var participated: bool
var is_burntout: bool
var burnout: int

func _init(as_species: Species, at_level: int):
    species = as_species
    experience = 0
    set_level(at_level)
    health = max_health
    mana = max_mana
    for i in range(0, species.levelup_moves.size()):
        if species.levelup_move_levels[i] <= level:
            moves.append(species.levelup_moves[i])
        if moves.size() == 4:
            break

    is_resting = false
    participated = false
    is_burntout = false
    burnout = 0

func get_display_name() -> String:
    if nickname == "":
        return species.name
    else: 
        return nickname

func get_portrait_path() -> String:
    return "res://battle/familiars/" + species.name.to_lower() + ".png"

func is_living() -> bool:
    return health > 0

func get_experience_yield() -> int:
    return int((species.base_exp_yield * get_level()) / 7.0)

func set_level(value: int):
    experience = get_experience_at_level(value)
    level = value
    update_stats()

func update_stats():
    max_health = int((species.base_health * 2 * level) / 100) + level + 10
    max_mana = int((species.base_mana * 1.25 * level) / 100) + 5
    attack = int((species.base_attack * 2 * level) / 100) + 5
    defense = int((species.base_defense * 2 * level) / 100) + 5
    speed = int((species.base_speed * 2 * level) / 100) + 5
    focus = int((species.base_focus * 2 * level) / 100) + 5

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
    if health == 0:
        conditions = []

func change_mana(amount: int):
    mana += amount
    if mana < 0:
        burnout = mana * -1
    mana = int(clamp(mana, 0, max_mana))

func get_level_up_moves(for_level):
    var returned_level_up_moves = []
    for i in range(0, species.levelup_moves.size()):
        if species.levelup_move_levels[i] == for_level:
            returned_level_up_moves.append(species.levelup_moves[i])
    return returned_level_up_moves

func get_attack():
    var attack_mod = 1
    for condition in conditions:
        if condition == Conditions.Condition.ATTACK_BUFF:
            attack_mod = 2
            break
        if condition == Conditions.Condition.ATTACK_DEBUFF:
            attack_mod = 0.5
            break
    return attack * attack_mod

func get_defense():
    var defense_mod
    for condition in conditions:
        if condition == Conditions.Condition.DEFENSE_BUFF:
            defense_mod = 2
            break
        if condition == Conditions.Condition.DEFENSE_DEBUFF:
            defense_mod = 0.5
            break
    return defense * defense_mod

func get_focus():
    var focus_mod
    for condition in conditions:
        if condition == Conditions.Condition.FOCUS_BUFF:
            focus_mod = 2
            break
        if condition == Conditions.Condition.FOCUS_DEBUFF:
            focus_mod = 0.5
            break
    return focus * focus_mod

func get_speed():
    var speed_mod
    for condition in conditions:
        if condition == Conditions.Condition.SPEED_BUFF:
            speed_mod = 2
            break
        if condition == Conditions.Condition.SPEED_DEBUFF:
            speed_mod = 0.5
            break
    return speed

func clear_temporary_conditions():
    var conditions_to_remove = []
    for i in range(0, conditions.size()):
        if conditions[i].duration != Conditions.DURATION_INDEFINITE:
            conditions_to_remove.append(i)
    for condition_index in conditions_to_remove:
        conditions.remove(condition_index)
