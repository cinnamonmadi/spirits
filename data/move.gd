extends Resource

class_name Move

enum MoveTargets {
    TARGETS_SELF,
    TARGETS_ONE_ALLY,
    TARGETS_ALL_ALLIES,
    TARGETS_ONE_ENEMY,
    TARGETS_ALL_ENEMIES,
}

export var name: String = ""
export var desc: String

export(Types.Type) var type
export var cost: int
export(int, 0, 100) var power: int
export(MoveTargets) var targets
export(Array, Conditions.Condition) var conditions
export(Array, float) var condition_rates