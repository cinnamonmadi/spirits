extends Resource

class_name Move

enum MoveTargets {
    TARGETS_SELF,
    TARGETS_ONE_ALLY,
    TARGETS_ALL_ALLIES,
    TARGETS_ONE_ENEMY,
    TARGETS_ALL_ENEMIES,
}

enum ConditionTargets {
    MOVE_TARGET,
    SELF,
}

export var name: String = ""
export var desc: String

export(Types.Type) var type
export var cost: int
export(int, 0, 100) var power: int
export var priority: int = 2
export(int, 1, 5) var prudence = 1
export(MoveTargets) var targets
export(Array, Condition.Type) var conditions
export(Array, float) var condition_rates
export(Array, ConditionTargets) var condition_targets