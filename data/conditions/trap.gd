extends Condition

func config():
    type = Type.TRAP
    reverse = Type.NONE
    duration_type = DurationType.FIXED
    duration = 1

    success_message = " laid a trap!"
    failure_message = ""
    expire_message = "'s trap ended."
    extend_message = ""

func on_attacked(attacker, familiar, move):
    if move.power == 0:
        return .on_attacked(attacker, familiar, move)
    attacker.apply_condition(Type.TRAPPED, {})
    familiar.apply_condition(Type.TRAPPING, { "trapped_familiar": attacker })
    familiar.remove_condition(self)
    return {
        "type": ResponseType.INTERRUPT,
        "message": " trapped " + attacker.get_display_name() + "!"
    }