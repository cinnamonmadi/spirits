extends Condition

func _init():
    type = Type.ATTACK_DEBUFF
    reverse = Type.ATTACK_BUFF
    duration_type = DurationType.EXTENDABLE

    success_message = "'s attack was lowered!"
    failure_message = "'s attack is already lowered!"
    expire_message = "'s attack returned to normal."
    extend_message = "'s attack debuff was extended!"

func on_apply(familiar):
    familiar.attack_mod = 0.5

func on_remove(familiar):
    familiar.attack_mod = 1.0