extends Reference
class_name Condition

enum Type {
    NONE,
    ATTACK_BUFF,
    ATTACK_DEBUFF,
    DEFENSE_BUFF,
    DEFENSE_DEBUFF,
    SPEED_BUFF,
    SPEED_DEBUFF,
    FOCUS_BUFF,
    FOCUS_DEBUFF,
    PARALYZED,
    DECOY,
    IS_TRAP,
    IS_TRAP_RELEASE,
    TRAPPED,
    TRAPPING,
    TRAPPING_RELEASE,
    BIDE,
    BASK,
    BRAMBLES,
}

enum DurationType {
    INDEFINITE,
    EXTENDABLE,
    FIXED,
    INSTANT
}

var type
var reverse = Type.NONE

var success_message: String = ""
var failure_message: String = ""
var expire_message: String = ""
var extend_message: String = ""

var duration_type = DurationType.FIXED
var duration: int = 4
var ttl: int = 0

func _init():
    if duration_type != DurationType.INDEFINITE:
        ttl = duration

func on_apply(_familiar):
    pass

func on_remove(_familiar):
    pass