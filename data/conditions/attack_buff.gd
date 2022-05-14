extends Condition

func _init():
    type = Type.ATTACK_BUFF
    reverse = Type.ATTACK_DEBUFF
    duration_type = DurationType.EXTENDABLE

    success_message = "'s attack was raised!"
    failure_message = "'s attack is already raised!"
    expire_message = "'s attack returned to normal."
    extend_message = "'s attack buff was extended!"

func on_apply(familiar):
    familiar.attack_mod = 2.0

func on_remove(familiar):
    familiar.attack_mod = 1.0