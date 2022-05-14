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
    TRAP,
    TRAP_RELEASE,
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

enum ResponseType {
    NONE,
    INTERRUPT,
    REPLACE_ACTION,
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

func config():
    pass

func _init():
    config()
    if duration_type != DurationType.INDEFINITE:
        ttl = duration

func on_apply(_params, _familiar):
    pass

func on_remove(_familiar):
    pass

func on_perform_action(_action, _familiar):
    return {
        "type": ResponseType.NONE,
        "message": "",
    }

func on_attacked(_attacker, _familiar, _move):
    return {
        "type": ResponseType.NONE,
        "message": "",
    }