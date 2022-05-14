extends Condition

func config():
    type = Type.DEFENSE_DEBUFF
    reverse = Type.DEFENSE_BUFF
    duration_type = DurationType.EXTENDABLE

    success_message = "'s defense was lowered!"
    failure_message = "'s defense is already lowered!"
    expire_message = "'s defense returned to normal."
    extend_message = "'s defense debuff was extended!"

func on_apply(_params, familiar):
    familiar.defense_mod = 0.5

func on_remove(familiar):
    familiar.defense_mod = 1.0