extends Condition

func config():
    type = Type.TRAP_RELEASE
    reverse = Type.NONE
    duration_type = DurationType.INSTANT

    success_message = " ended its trap"
    failure_message = ""
    expire_message = ""
    extend_message = ""

func on_apply(_params, familiar):
    for condition in familiar.conditions:
        if condition.type == Type.TRAPPING:
            condition.release_trapped_familiar(familiar)
