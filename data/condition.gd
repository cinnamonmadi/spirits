class_name Conditions

enum Condition {
    ATTACK_BUFF,
    ATTACK_DEBUFF,
    DEFENSE_BUFF,
    DEFENSE_DEBUFF,
    SPEED_BUFF,
    SPEED_DEBUFF,
    FOCUS_BUFF,
    FOCUS_DEBUFF,
}

const CONDITION_DURATION_INDEFINITE = -1
const CONDITION_INFO = {
    Condition.ATTACK_DEBUFF: {
        "success_message": "'s attack was lowered!",
        "failure_message": "'s attack is already lowered!",
        "expire_message": "'s attack returned to normal.",
        "duration": 4, 
    }
}