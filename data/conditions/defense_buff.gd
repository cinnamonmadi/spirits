extends Condition

func config():
    type = Type.DEFENSE_BUFF
    reverse = Type.DEFENSE_DEBUFF
    duration_type = DurationType.EXTENDABLE

    success_message = "'s defense was raised!"
    failure_message = "'s defense is already raised!"
    expire_message = "'s defense returned to normal."
    extend_message = "'s defense buff was extended!"

func on_apply(_params, familiar):
    familiar.defense_mod = 2.0

func on_remove(familiar):
    familiar.defense_mod = 1.0