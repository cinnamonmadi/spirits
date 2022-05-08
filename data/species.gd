extends Resource

class_name Species

export var name: String

export(Array, Types.Type) var types

export var base_health: int
export var base_mana: int
export var base_attack: int
export var base_defense: int
export var base_speed: int
export var base_focus: int

export var catch_rate: float
export var base_exp_yield: float

export(Array, Resource) var levelup_moves
export(Array, int) var levelup_move_levels