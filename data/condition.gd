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

const DURATION_INDEFINITE = -1
const NO_REVERSE = -1

const CONDITION_INFO = {
    Condition.ATTACK_BUFF: {
        "success_message": "'s attack was raised!",
        "failure_message": "'s attack is already raised!",
        "expire_message": "'s attack returned to normal.",
        "duration": 4, 
        "reverse": Condition.ATTACK_DEBUFF,
    },
    Condition.ATTACK_DEBUFF: {
        "success_message": "'s attack was lowered!",
        "failure_message": "'s attack is already lowered!",
        "expire_message": "'s attack returned to normal.",
        "duration": 4, 
        "reverse": Condition.ATTACK_BUFF,
    },
    Condition.DEFENSE_BUFF: {
        "success_message": "'s defense was raised!",
        "failure_message": "'s defense is already raised!",
        "expire_message": "'s defense returned to normal.",
        "duration": 4, 
        "reverse": Condition.DEFENSE_DEBUFF,
    },
    Condition.DEFENSE_DEBUFF: {
        "success_message": "'s defense was lowered!",
        "failure_message": "'s defense is already lowered!",
        "expire_message": "'s defense returned to normal.",
        "duration": 4, 
        "reverse": Condition.DEFENSE_BUFF,
    },
    Condition.SPEED_BUFF: {
        "success_message": "'s speed was raised!",
        "failure_message": "'s speed is already raised!",
        "expire_message": "'s speed returned to normal.",
        "duration": 4, 
        "reverse": Condition.SPEED_DEBUFF,
    },
    Condition.SPEED_DEBUFF: {
        "success_message": "'s speed was lowered!",
        "failure_message": "'s speed is already lowered!",
        "expire_message": "'s speed returned to normal.",
        "duration": 4, 
        "reverse": Condition.SPEED_BUFF,
    },
    Condition.FOCUS_BUFF: {
        "success_message": "'s focus was raised!",
        "failure_message": "'s focus is already raised!",
        "expire_message": "'s focus returned to normal.",
        "duration": 4, 
        "reverse": Condition.FOCUS_DEBUFF,
    },
    Condition.FOCUS_DEBUFF: {
        "success_message": "'s focus was lowered!",
        "failure_message": "'s focus is already lowered!",
        "expire_message": "'s focus returned to normal.",
        "duration": 4, 
        "reverse": Condition.FOCUS_BUFF,
    },
    Condition.PARALYZED: {
        "success_message": " was paralyzed!",
        "failure_message": " is already paralyzed!",
        "expire_message": " was cured of its paralysis.",
        "duration": DURATION_INDEFINITE, 
        "reverse": NO_REVERSE,
    },
    Condition.DECOY: {
        "success_message": "'s placed a decoy!",
        "failure_message": "'s already has a decoy!",
        "expire_message": "'s decoy was destroyed!",
        "duration": DURATION_INDEFINITE, 
        "reverse": NO_REVERSE,
    },
    Condition.IS_TRAP: {
        "success_message": " set a trap!",
        "failure_message": " is already trapping!", # Shouldn't happen anyways
        "expire_message": " ended its trap!",
        "duration": DURATION_INDEFINITE, 
        "reverse": Condition.IS_TRAP_RELEASE,
    },
    Condition.IS_TRAP_RELEASE: {
        "success_message": " set a trap!",
        "failure_message": "", 
        "expire_message": " ended its trap!",
        "duration": DURATION_INDEFINITE, 
        "reverse": Condition.IS_TRAP,
    },
    Condition.TRAPPED: {
        "success_message": " was trapped!",
        "failure_message": " is already trapped!", # Shouldn't happen anyways
        "expire_message": " escaped its trap!",
        "duration": DURATION_INDEFINITE, 
        "reverse": NO_REVERSE,
    },
    Condition.TRAPPING: {
        "success_message": "",
        "failure_message": "", 
        "expire_message": " released its foe!",
        "duration": DURATION_INDEFINITE, 
        "reverse": Condition.TRAPPING_RELEASE,
    },
    Condition.TRAPPING_RELEASE: {
        "success_message": "",
        "failure_message": "", 
        "expire_message": "",
        "duration": DURATION_INDEFINITE, 
        "reverse": Condition.TRAPPING,
    },
    Condition.BIDE: {
        "success_message": " is storing energy!",
        "failure_message": "", 
        "expire_message": " unleashed its energy!",
        "duration": 3, 
        "reverse": NO_REVERSE,
    },
    Condition.BASK: {
        "success_message": " is basking in the sun.",
        "failure_message": "", 
        "expire_message": "",
        "duration": 2, 
        "reverse": NO_REVERSE,
    },
    Condition.BRAMBLES: {
        "success_message": " covered itself in brambles!",
        "failure_message": " is already covered in brambles!", 
        "expire_message": "'s brambles wore off!",
        "duration": 4, 
        "reverse": NO_REVERSE,
    },
}